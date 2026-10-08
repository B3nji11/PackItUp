"""Compile every Luau file and execute unchanged source modules in the Luau VM.

Usage: python tools/test.py --luau PATH_TO_LUAU_EXE --compiler PATH_TO_LUAU_COMPILE_EXE
The temporary bundle supplies ModuleScript resolution, not rewritten game logic.
"""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def bundle():
    lines = [
        "local game, workspace, Instance, Enum, Color3, ColorSequence, NumberSequence, Vector3, Vector2, CFrame, UDim, UDim2, Random, task",
        "local nodes, factories, loaded = {}, {}, {}",
        "local function node(path)",
        "  if nodes[path] then return nodes[path] end",
        "  local value = { Name = string.match(path, '[^/]+$') or '', path = path }",
        "  function value:WaitForChild(name) assert(self[name], 'Missing child '..name..' in '..path); return self[name] end",
        "  nodes[path] = value",
        "  local parentPath = string.match(path, '^(.*)/[^/]+$')",
        "  if parentPath then value.Parent = node(parentPath); value.Parent[value.Name] = value end",
        "  return value",
        "end",
    ]
    for path in sorted((ROOT / "src").rglob("*.luau")):
        key = path.relative_to(ROOT / "src").as_posix()[:-5]
        key = key.removesuffix(".server").removesuffix(".client")
        quoted = json.dumps(key)
        lines.append(f"node({quoted})")
        lines.append(f"factories[{quoted}] = function(script, require)\n{path.read_text(encoding='utf-8')}\nend")
    lines += [
        "local function loadModule(target)",
        "  local key = if type(target) == 'string' then target else target.path",
        "  assert(factories[key], 'Missing module: '..tostring(key))",
        "  if loaded[key] ~= nil then return loaded[key] end",
        "  local result = factories[key](nodes[key], loadModule)",
        "  loaded[key] = if result == nil then true else result",
        "  return loaded[key]",
        "end",
        "local passed, failed = 0, 0",
        "local function eq(a,b) assert(a == b, tostring(a)..' ~= '..tostring(b)) end",
        "local function near(a,b) assert(math.abs(a-b) < 0.000001, tostring(a)..' not near '..tostring(b)) end",
        "local function test(name, fn)",
        "  local ok, err = pcall(fn)",
        "  if ok then passed += 1; print('PASS '..name) else failed += 1; print('FAIL '..name..': '..tostring(err)) end",
        "end",
    ]
    for path in sorted((ROOT / "tests").glob("*.spec.luau")):
        lines.append(f"do\n{path.read_text(encoding='utf-8')}\nend")
    lines += ["print(string.format('RESULT: %d passed, %d failed', passed, failed))", "assert(failed == 0, 'Tests failed')"]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--luau", required=True)
    parser.add_argument("--compiler", required=True)
    args = parser.parse_args()
    files = sorted((ROOT / "src").rglob("*.luau")) + sorted((ROOT / "tests").glob("*.luau"))
    for path in files:
        result = subprocess.run([args.compiler, "--null", str(path)], capture_output=True, text=True)
        if result.returncode:
            raise SystemExit(f"Compilation failed: {path}\n{result.stdout}\n{result.stderr}")
    print(f"Compilation passed for {len(files)} Luau files.", flush=True)
    with tempfile.TemporaryDirectory(prefix="fries-tests-") as directory:
        script = Path(directory) / "suite.luau"
        script.write_text(bundle(), encoding="utf-8")
        result = subprocess.run([args.luau, str(script)], text=True)
        raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
