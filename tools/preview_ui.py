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
FONTS = None
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
            transparency=node.BackgroundTransparency or 0, z=node.ZIndex or 1}
        local scale=node:FindFirstChildOfClass("UIScale")
        data.scale=scale and scale.Scale or 1
        local corner=node:FindFirstChildOfClass("UICorner")
        data.radius=corner and corner.CornerRadius.Offset or 0
        data.radiusScale=corner and corner.CornerRadius.Scale or 0
        data.rotation=node.Rotation or 0
        local fit=node:FindFirstChildOfClass("UITextSizeConstraint")
        if fit then data.fitMin=fit.MinTextSize; data.fitMax=fit.MaxTextSize end
        local padding=node:FindFirstChildOfClass("UIPadding")
        if padding and not node:FindFirstChildOfClass("UIListLayout") then
            data.pad={padding.PaddingLeft and padding.PaddingLeft.Offset or 0, padding.PaddingRight and padding.PaddingRight.Offset or 0}
        end
        local layout=node:FindFirstChildOfClass("UIListLayout")
        if layout then data.listPadding=layout.Padding.Offset end
        local grid=node:FindFirstChildOfClass("UIGridLayout")
        if grid then data.grid={grid.CellSize.X.Offset,grid.CellSize.Y.Offset,grid.CellPadding.X.Offset,grid.CellPadding.Y.Offset} end
        if node.ClassName=="ViewportFrame" then
            local pet=node:FindFirstChild("Pet")
            local body=pet and pet._children and pet._children[1]
            data.petColor=body and color(body.Color) or nil
        end
        data.order=node.LayoutOrder or 0
        data.clips=(node.ClipsDescendants==true) or node.ClassName=="ScrollingFrame"
        for _,child in ipairs(node._children or {}) do
            if child.ClassName=="UIStroke" and child.Enabled~=false then
                if child.ApplyStrokeMode==Enum.ApplyStrokeMode.Contextual and node.Text~=nil then
                    data.textStroke=color(child.Color); data.textStrokeWidth=child.Thickness
                else
                    data.stroke=color(child.Color); data.strokeWidth=child.Thickness
                end
            end
        end
        for _,child in ipairs(node._children or {}) do
            if child.ClassName=="Frame" or child.ClassName=="TextLabel" or child.ClassName=="TextButton" or child.ClassName=="ScrollingFrame" or child.ClassName=="ViewportFrame" then
                table.insert(data.children,capture(child))
            end
        end
        return data
    end
    local Upgrades=loadModule("shared/domain/Upgrades")
    local Pricing=loadModule("shared/domain/Pricing")
    local Rebirth=loadModule("shared/domain/Rebirth")
    local Gacha=loadModule("shared/domain/Gacha")
    local PetConfig=loadModule("shared/config/Pets")
    local sampleProfile={cash=1250000,gems=12,rebirths=1,upgradeLevels={FriesPerClick=1,BagCapacity=2},pity={StarterFryer=7},
        pets={{id="P1",type="FryKing",machine="StarterFryer"},{id="P2",type="MayoJar",machine="StarterFryer"},
            {id="P3",type="PotatoPup",machine="StarterFryer"},{id="P4",type="CrinkleFry",machine="StarterFryer"},
            {id="P5",type="PaperCup",machine="StarterFryer"}},equippedPets={"P1","P2"}}
    local owned={}
    for _,pet in ipairs(sampleProfile.pets) do
        local kind=PetConfig.Types[pet.type]; local bonuses={}
        for _,stat in ipairs(PetConfig.StatOrder) do table.insert(bonuses,{stat=stat,amount=kind.Stats[stat]}) end
        local equipped=pet.id=="P1" or pet.id=="P2"
        local golden=pet.id=="P2"
        if golden then for _,b in ipairs(bonuses) do b.amount*=2 end end
        table.insert(owned,{id=pet.id,type=pet.type,name=(golden and "Golden " or "")..kind.Name,rarity=kind.Rarity,rank=PetConfig.Rarities[kind.Rarity].Rank,bonuses=bonuses,equipped=equipped,golden=golden})
    end
    for _, example in ipairs({{1280,720,true,12,"desktop"},{390,844,false,0,"phone"},{640,360,true,30,"landscape"},{947,600,false,0,"laptop-unclaimed"},
        {1280,720,true,12,"desktop-shop",true},{390,844,true,12,"phone-shop",true},{640,360,true,12,"landscape-shop",true},
        {1280,720,true,12,"desktop-rebirth","rebirth"},{390,844,true,12,"phone-rebirth","rebirth"},{640,360,true,12,"landscape-rebirth","rebirth"},
        {1280,720,true,12,"desktop-spin","gacha"},{390,844,true,12,"phone-spin","gacha"},{844,390,true,12,"wide-landscape",nil},
        {1280,720,true,12,"desktop-pets","pets"},{390,844,true,12,"phone-pets","pets"},
        {1280,720,true,12,"desktop-settings","settings"},{640,360,true,12,"landscape-pets","pets"}}) do
        local app=loadModule("client/ui/AppView").new(makeInstance("PlayerGui"),function() end)
        app:resize(Vector2.new(example[1],example[2]))
        app:update({hasStation=example[3],nearStation=example[3],volatile=true,
            profile={cash=1250000,gems=12,bag={fries=example[4]}},shop=Upgrades.snapshot(sampleProfile),rebirth=Rebirth.snapshot(sampleProfile),
            machine=Gacha.snapshot(sampleProfile,"StarterFryer"),pets={owned=owned,equipped=2,slots=3,max=50,mergeCount=5,
                mergeable={{type="CrinkleFry",name="Crinkle Fry",count=5,rank=1}},autoDelete={Common=true}},
            settings={PetsFollow=true,ShowOtherPets=false},
            spin={serial=1,id="P2",type="MayoJar"},
            stats={perClick=Pricing.click(sampleProfile),perSecond=0.5,perFry=Pricing.perFry(sampleProfile),
                capacity=Pricing.capacity(sampleProfile),saleValue=Pricing.sale(sampleProfile)}})
        if example[6] == "rebirth" then app.rebirth:toggle() elseif example[6] == "gacha" then app.gacha:toggle()
        elseif example[6] == "pets" then app.pets:toggle(); app.pets:select("P2") elseif example[6] == "settings" then app.settings:toggle()
        elseif example[6] then app.shop:toggle() end
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
    def font(size, bold=False, family=''):
        size = max(7, int(size))
        # Real Roblox fonts when --fonts points at LuckiestGuy-Regular.ttf and Fredoka.ttf.
        if FONTS and 'LuckiestGuy' in family and (FONTS / 'LuckiestGuy-Regular.ttf').exists():
            return ImageFont.truetype(str(FONTS / 'LuckiestGuy-Regular.ttf'), size)
        if FONTS and 'Fredoka' in family and (FONTS / 'Fredoka.ttf').exists():
            f = ImageFont.truetype(str(FONTS / 'Fredoka.ttf'), size)
            try: f.set_variation_by_name('SemiBold')
            except Exception: pass
            return f
        windows = 'C:/Windows/Fonts/' + ('arialbd.ttf' if bold else 'arial.ttf')
        linux = '/usr/share/fonts/truetype/dejavu/' + ('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf')
        return ImageFont.truetype(windows if Path(windows).exists() else linux, size)
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
        radius=item.get('radius',0)*scale+item.get('radiusScale',0)*min(iw,ih)
        radius=max(0,min(radius,min(iw,ih)/2))
        has_stroke='stroke' in item
        if (bg and alpha>0 or has_stroke) and iw>0 and ih>0:
            fill=None
            if bg and alpha>0:
                base=image.getpixel((max(0,min(w-1,int(x))),max(0,min(h-1,int(y)))))
                fill=tuple(int(c*alpha+b*(1-alpha)) for c,b in zip(bg,base))
            stroke=tuple(int(c) for c in item['stroke']) if has_stroke else fill
            width=max(1,round(item.get('strokeWidth',0)*scale)) if has_stroke else 0
            rotation=item.get('rotation',0)
            if rotation:
                # Draw on a layer and rotate it about the element's centre, as Roblox does.
                pad=int(max(iw,ih)); layer=Image.new('RGBA',(int(iw)+2*pad,int(ih)+2*pad),(0,0,0,0))
                ld=ImageDraw.Draw(layer)
                ld.rounded_rectangle((pad,pad,pad+iw,pad+ih),radius=radius,fill=fill,outline=stroke,width=width)
                layer=layer.rotate(-rotation,resample=Image.BICUBIC,center=(pad+iw/2,pad+ih/2))
                image.paste(layer,(int(x)-pad,int(y)-pad),layer)
            else:
                draw.rounded_rectangle((x,y,x+iw,y+ih),radius=radius,fill=fill,outline=stroke,width=width)
        text=item.get('text')
        # UIPadding moves text and children inside the padded area, as in Roblox.
        padl,padr=[v*scale for v in item.get('pad',[0,0])]
        x+=padl; iw-=padl+padr
        if text:
            family=item.get('font','') or ''
            text_size=item.get('textSize',15)*scale
            if item.get('textScaled') and item.get('fitMax'):
                text_size=item['fitMax']*scale
            f=font(text_size,'Bold' in family,family)
            if item.get('textScaled'):
                floor=(item.get('fitMin') or 8)*scale
                while (draw.textlength(text,font=f)>iw-2 or text_size*1.05>ih) and text_size>floor:
                    text_size-=1; f=font(text_size,True,family)
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
                # TextButtons centre text by default in Roblox.
                if item.get('align')=='TextXAlignment.Center' or (item.get('class')=='TextButton' and not item.get('align')):
                    tx=x+(iw-draw.textlength(line,font=f))/2
                sw=round(item.get('textStrokeWidth',0)*scale)
                draw.text((tx,ty),line,font=f,fill=tuple(int(c) for c in item.get('fg',(255,255,255))),
                    stroke_width=sw,stroke_fill=tuple(int(c) for c in item.get('textStroke',(0,0,0))))
                ty+=lh
        if item.get('petColor') and iw>0:
            # Portrait placeholder: the pet's body colour with eyes (Studio renders the 3D model).
            r=min(iw,ih)*0.36; cx=x+iw/2; cy=y+ih/2+r*0.1
            draw.ellipse((cx-r,cy-r,cx+r,cy+r),fill=tuple(int(c) for c in item['petColor']),outline=(61,31,31),width=max(1,int(r/10)))
            for side in (-1,1):
                ex=cx+side*r*0.35; ey=cy-r*0.15; er=r*0.2
                draw.ellipse((ex-er,ey-er,ex+er,ey+er),fill=(255,255,255))
                draw.ellipse((ex-er*0.6,ey-er*0.5,ex+er*0.6,ey+er*0.7),fill=(45,30,30))
        children=item.get('children',[])
        if item.get('clips') and children:
            # ClipsDescendants / ScrollingFrame: draw children, then restore pixels outside the box.
            before=image.copy(); clipped=dict(item); clipped['clips']=False
            for key in ('bg','stroke','text','petColor'): clipped.pop(key,None)
            clipped['anchor']=[0,0]; clipped['scale']=1
            clipped['pos']=[0,(x-padl-px)/inherited,0,(y-py)/inherited]; clipped['size']=[0,(iw+padl+padr)/scale,0,ih/scale]
            node(clipped,(px,py,pw,ph),inherited)
            mask=Image.new('L',(w,h),255); ImageDraw.Draw(mask).rectangle((x-padl,y,x+iw+padr,y+ih),fill=0)
            image.paste(before,(0,0),mask)
            return
        if 'grid' in item:
            # Place children in rows like a UIGridLayout; rows past the visible area are skipped.
            cw,ch,gx,gy=[v*scale for v in item['grid']]
            per=max(1,int((iw+gx)//(cw+gx)))
            for i,child in enumerate(sorted(children, key=lambda c: c.get('order',0))):
                if not child.get('visible',True): continue
                row,col=divmod(i,per)
                if row*(ch+gy)>ih: break
                child=dict(child); child['pos']=[0,col*(cw+gx)/scale,0,row*(ch+gy)/scale]
                child['size']=[0,item['grid'][0],0,item['grid'][1]]; child['anchor']=[0,0]
                node(child,(x,y,iw,ih),scale)
            return
        if 'listPadding' in item:
            # Stack children vertically like a UIListLayout, in LayoutOrder.
            offset=0
            for child in sorted(children, key=lambda c: c.get('order',0)):
                child=dict(child); child['pos']=[0,0,0,offset]
                node(child,(x,y,iw,ih),scale)
                offset+=child['size'][3]+item['listPadding']
            return
        for child in sorted(children, key=lambda c: c.get('z',1)): node(child,(x,y,iw,ih),scale)
    for child in sorted(sample['ui']['children'], key=lambda c: c.get('z',1)): node(child,(0,36,w,h-60))
    image.save(output)


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--luau',required=True)
    parser.add_argument('--fonts',help='folder with LuckiestGuy-Regular.ttf and Fredoka.ttf from Google Fonts')
    args=parser.parse_args()
    global FONTS
    FONTS=Path(args.fonts) if args.fonts else None
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
