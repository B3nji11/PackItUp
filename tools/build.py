"""Build a standalone Roblox XML place using only Python's standard library.

The source layout is also compatible with the included Rojo project.
Run: python tools/build.py
"""
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def item(parent, class_name, name):
    node = ET.SubElement(parent, "Item", {"class": class_name})
    props = ET.SubElement(node, "Properties")
    ET.SubElement(props, "string", {"name": "Name"}).text = name
    return node


def add_sources(parent, directory):
    for path in sorted(directory.iterdir()):
        if path.is_dir():
            add_sources(item(parent, "Folder", path.name), path)
        elif path.suffix == ".luau":
            name = path.stem
            class_name = "ModuleScript"
            if name.endswith(".server"):
                name, class_name = name[:-7], "Script"
            elif name.endswith(".client"):
                name, class_name = name[:-7], "LocalScript"
            node = item(parent, class_name, name)
            ET.SubElement(node.find("Properties"), "ProtectedString", {"name": "Source"}).text = path.read_text(encoding="utf-8")


def build():
    root = ET.Element("roblox", {"version": "4"})
    workspace = item(root, "Workspace", "Workspace")
    ET.SubElement(workspace.find("Properties"), "bool", {"name": "FilteringEnabled"}).text = "true"
    shared = item(item(root, "ReplicatedStorage", "ReplicatedStorage"), "Folder", "FriesShared")
    server = item(item(root, "ServerScriptService", "ServerScriptService"), "Folder", "FriesServer")
    player = item(root, "StarterPlayer", "StarterPlayer")
    scripts = item(player, "StarterPlayerScripts", "StarterPlayerScripts")
    client = item(scripts, "Folder", "FriesClient")
    for parent, name in ((shared, "shared"), (server, "server"), (client, "client")):
        add_sources(parent, ROOT / "src" / name)
    item(root, "StarterGui", "StarterGui")
    item(root, "Lighting", "Lighting")
    item(root, "Players", "Players")
    sound = item(root, "SoundService", "SoundService")
    ET.SubElement(sound.find("Properties"), "bool", {"name": "RespectFilteringEnabled"}).text = "true"
    for i, node in enumerate(root.iter("Item")):
        node.set("referent", f"RBX{i:05d}")
    output = ROOT / "FriesGame.rbxlx"
    ET.indent(root)
    ET.ElementTree(root).write(output, encoding="utf-8", xml_declaration=True)
    # Independently parse the artifact and confirm source round-tripping.
    parsed = ET.parse(output)
    actual = [node.text for node in parsed.findall(".//ProtectedString[@name='Source']")]
    expected = [p.read_text(encoding="utf-8") for p in (ROOT / "src").rglob("*.luau")]
    assert sorted(actual) == sorted(expected), "Embedded source differs from source files"
    assert len(parsed.findall(".//Item[@class='Script']")) == 1
    assert len(parsed.findall(".//Item[@class='LocalScript']")) == 1
    print(f"Built {output.name}: {len(actual)} source files, XML and source round-trip verified.")


if __name__ == "__main__":
    build()
