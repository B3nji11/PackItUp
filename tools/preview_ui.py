"""Render approximate HUD layout previews from the real UI modules and test doubles.

This is not a Roblox screenshot. Use Studio for final rendering/input acceptance.
"""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import argparse
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('fries_tests', ROOT / 'tools/test.py')
tests = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tests)

CAPTURE = r'''
do
    local function quote(s)
        return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r') .. '"'
    end
    local function encode(v)
        if type(v) == "string" then return quote(v) end
        if type(v) ~= "table" then return tostring(v) end
        local values = {}
        if #v > 0 then
            for _, x in ipairs(v) do table.insert(values, encode(x)) end
            return "[" .. table.concat(values, ",") .. "]"
        end
        for k,x in pairs(v) do table.insert(values, quote(k)..":"..encode(x)) end
        return "{" .. table.concat(values, ",") .. "}"
    end
    local function color(c) return c and {c.R*255,c.G*255,c.B*255} or nil end
    local function dimensions(v) return v and {v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset} or {0,0,0,0} end
    local function capture(node)
        local data = {class=node.ClassName, name=node.Name, children={}, visible=node.Visible,
            pos=dimensions(node.Position), size=dimensions(node.Size),
            anchor=node.AnchorPoint and {node.AnchorPoint.X,node.AnchorPoint.Y} or {0,0},
            text=node.Text, textSize=node.TextSize, textScaled=node.TextScaled, font=node.Font,
            align=node.TextXAlignment, bg=color(node.BackgroundColor3), fg=color(node.TextColor3),
            transparency=node.BackgroundTransparency or 0}
        local scale=node:FindFirstChildOfClass("UIScale")
        data.scale=scale and scale.Scale or 1
        local corner=node:FindFirstChildOfClass("UICorner")
        data.radius=corner and corner.CornerRadius.Offset or 0
        local stroke=node:FindFirstChildOfClass("UIStroke")
        if stroke then data.stroke=color(stroke.Color); data.strokeWidth=stroke.Thickness end
        for _,child in ipairs(node._children or {}) do
            if child.ClassName=="Frame" or child.ClassName=="TextLabel" or child.ClassName=="TextButton" then
                table.insert(data.children,capture(child))
            end
        end
        return data
    end
    for _, example in ipairs({{1280,720,true,12,"desktop"},{390,844,false,0,"phone"},{568,320,true,20,"landscape"}}) do
        local app=loadModule("client/ui/AppView").new(makeInstance("PlayerGui"),function() end)
        app:resize(Vector2.new(example[1],example[2]))
        app:update({hasStation=example[3],nearStation=example[3],volatile=true,
            profile={cash=1250,bag={fries=example[4]}},stats={perClick=1,perSecond=0.5,saleValue=10}})
        print("UI_PREVIEW:"..encode({name=example[5],width=example[1],height=example[2],ui=capture(app.hud.frame.Parent)}))
    end
end
'''


def render(sample, output):
    w, h = sample['width'], sample['height']
    image = Image.new('RGB', (w, h), (113, 137, 116))
    draw = ImageDraw.Draw(image)
    # Neutral backdrop to inspect contrast without implying an engine screenshot.
    for y in range(h):
        tone = int(18 * y / h)
        draw.line((0,y,w,y), fill=(113-tone,137-tone,116-tone))
    def font(size, bold=False):
        return ImageFont.truetype('C:/Windows/Fonts/' + ('arialbd.ttf' if bold else 'arial.ttf'), max(7, int(size)))
    draw.text((10, 5), 'LAYOUT PREVIEW - approximate fonts; not a Studio screenshot', font=font(10), fill=(245,242,225))
    def node(item, box, inherited=1):
        if not item.get('visible', True): return
        px,py,pw,ph=box
        scale=inherited*item.get('scale',1)
        pos=item['pos']; size=item['size']; anchor=item['anchor']
        iw=size[0]*pw+size[1]*scale; ih=size[2]*ph+size[3]*scale
        x=px+pos[0]*pw+pos[1]*inherited-anchor[0]*iw
        y=py+pos[2]*ph+pos[3]*inherited-anchor[1]*ih
        bg=item.get('bg'); alpha=1-item.get('transparency',0)
        if bg and alpha>0 and iw>0 and ih>0:
            base=image.getpixel((max(0,min(w-1,int(x))),max(0,min(h-1,int(y)))))
            fill=tuple(int(c*alpha+b*(1-alpha)) for c,b in zip(bg,base))
            stroke=tuple(int(c) for c in item.get('stroke',fill))
            draw.rounded_rectangle((x,y,x+iw,y+ih),radius=item.get('radius',0)*scale, fill=fill,
                outline=stroke,width=max(1,round(item.get('strokeWidth',0)*scale)))
        text=item.get('text')
        if text:
            text_size=item.get('textSize',15)*scale
            f=font(text_size,'Bold' in item.get('font',''))
            if item.get('textScaled'):
                while draw.textlength(text,font=f)>iw-2 and text_size>10*scale:
                    text_size-=1; f=font(text_size,True)
            lines=[]
            for raw in text.split('\n'):
                line=''
                for word in raw.split(' '):
                    proposal=(line+' '+word).strip()
                    if line and draw.textlength(proposal,font=f)>iw-2:
                        lines.append(line); line=word
                    else: line=proposal
                lines.append(line)
            lh=text_size*1.15; ty=y+(ih-lh*len(lines))/2
            for line in lines:
                tx=x
                if item.get('align')=='TextXAlignment.Center': tx=x+(iw-draw.textlength(line,font=f))/2
                draw.text((tx,ty),line,font=f,fill=tuple(int(c) for c in item.get('fg',(255,255,255))))
                ty+=lh
        for child in item.get('children',[]): node(child,(x,y,iw,ih),scale)
    for child in sample['ui']['children']: node(child,(0,36,w,h-60))
    image.save(output)


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--luau',required=True)
    args=parser.parse_args()
    source=tests.bundle().replace('test("disconnect frees the chosen plot for another player", function()',
        CAPTURE+'\ntest("disconnect frees the chosen plot for another player", function()')
    output=ROOT/'artifacts'/'ui-preview'
    output.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='fries-preview-') as directory:
        script=Path(directory)/'preview.luau'; script.write_text(source,encoding='utf-8')
        result=subprocess.run([args.luau,str(script)],capture_output=True,text=True,check=True)
    for line in result.stdout.splitlines():
        if line.startswith('UI_PREVIEW:'):
            sample=json.loads(line[len('UI_PREVIEW:'):])
            render(sample,output/(sample['name']+'.png'))
            print(output/(sample['name']+'.png'))

if __name__=='__main__': main()
