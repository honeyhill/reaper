import os
import xml.etree.ElementTree as ET
from datetime import datetime

def parse_version_from_lua(filepath):
    """
    Reads the version number from the Lua script header (e.g., @version 1.2).
    """
    with open(filepath, "r") as lua_file:
        for line in lua_file:
            if line.startswith("-- @version"):
                return line.split()[2].strip()
    return "1.0"  # Default version if none found

def update_index(root_folder, index_file):
    """
    Scans the specified folder for .lua scripts and .ReaperThemeZip files and updates the ReaPack index.xml file.

    Args:
        root_folder (str): Path to the folder containing scripts and themes.
        index_file (str): Path to the index.xml file to update.
    """
    # Parse existing index.xml or create a new XML structure
    if os.path.exists(index_file) and os.path.getsize(index_file) > 0:
        tree = ET.parse(index_file)
        root = tree.getroot()
    else:
        root = ET.Element("index", version="1", commit="", name="HONEYHILL")

    # Keep track of processed items
    processed_items = {}

    # Define categories
    categories = {
        "MIDI Editing": []
    }

    # Scan the root folder for Lua scripts and Reaper themes
    for dirpath, _, filenames in os.walk(root_folder):
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            relative_path = os.path.relpath(filepath, root_folder).replace("\\", "/")

            if filename.endswith(".lua"):
                # Handle Lua scripts
                raw_link = f"https://raw.githubusercontent.com/honeyhill/reaper/main/{relative_path}"
                name = os.path.splitext(filename)[0] + ".lua"
                description = f"deselect all odd numbered notes"
                version = parse_version_from_lua(filepath)
                categories["MIDI Editing"].append((name, description, version, raw_link, relative_path))

    # Update categories in the index.xml
    for category_name, items in categories.items():
        category_element = root.find(f"category[@name='{category_name}']")
        if not category_element:
            category_element = ET.SubElement(root, "category", name=category_name)

        for name, description, version, raw_link, relative_path in items:
            reapack_element = category_element.find(f"reapack[@name='{name}']")

            if reapack_element:
                # Update existing entry if needed
                version_element = reapack_element.find("version")
                if version_element is not None and version_element.get("name") != version:
                    version_element.set("name", version)
                    version_element.set("time", datetime.utcnow().isoformat() + "Z")
            else:
                # Add new entry
                reapack_element = ET.SubElement(category_element, "reapack", name=name, type="script")
                metadata_element = ET.SubElement(reapack_element, "metadata")
                ET.SubElement(metadata_element, "description", name=description)
                version_element = ET.SubElement(reapack_element, "version", name=version, author="HONEYHILL", time=datetime.utcnow().isoformat() + "Z")
                ET.SubElement(version_element, "source", main="main midi_editor midi_inlineeditor", file=os.path.basename(relative_path)).text = raw_link

    # Write the updated index.xml back to file
    tree = ET.ElementTree(root)
    tree.write(index_file, encoding="utf-8", xml_declaration=True)

# Example usage
root_folder = "./"  # Root directory to scan for all scripts
index_file = "./index.xml"
update_index(root_folder, index_file)