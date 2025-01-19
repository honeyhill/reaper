import os
import xml.etree.ElementTree as ET

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
        root = ET.Element("index", version="1")

    # Keep track of processed items
    processed_items = {}

    # Scan the root folder for Lua scripts and Reaper themes
    for dirpath, _, filenames in os.walk(root_folder):
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            relative_path = os.path.relpath(filepath, root_folder).replace("\\", "/")

            if filename.endswith(".lua"):
                # Handle Lua scripts
                raw_link = f"https://raw.githubusercontent.com/honeyhill/reaper/main/{relative_path}"
                tag = "script"
                name = os.path.splitext(filename)[0]
                description = f"Description for {filename}"
                version = parse_version_from_lua(filepath)
            elif filename.endswith(".ReaperThemeZip"):
                # Handle Reaper themes
                raw_link = f"https://raw.githubusercontent.com/honeyhill/reaper/main/{relative_path}"
                tag = "theme"
                name = os.path.splitext(filename)[0]
                description = f"Color theme for Reaper: {name}"
                version = "1.0"
            else:
                continue

            # Check if the item is already in the index
            found = False
            for item in root.findall(tag):
                link = item.find("link").text
                if link == raw_link:
                    if tag == "script":
                        version_element = item.find("version")
                        if version_element.text != version:
                            version_element.text = version
                    found = True
                    processed_items[raw_link] = True
                    break

            if not found:
                # Add new item entry
                item_element = ET.SubElement(root, tag)
                ET.SubElement(item_element, "author").text = "HONEYHILL"
                ET.SubElement(item_element, "name").text = name
                ET.SubElement(item_element, "description").text = description
                ET.SubElement(item_element, "version").text = version
                ET.SubElement(item_element, "link").text = raw_link
                ET.SubElement(item_element, "changelog").text = "Initial release"

                processed_items[raw_link] = True

    # Remove items from the index if they no longer exist in the folder
    for tag in ["script", "theme"]:
        for item in root.findall(tag):
            link = item.find("link").text
            if link not in processed_items:
                root.remove(item)

    # Write the updated index.xml back to file
    tree = ET.ElementTree(root)
    tree.write(index_file, encoding="UTF-8", xml_declaration=True)

# Example usage
root_folder = "./"  # Adjust to include both Lua script and theme folder
index_file = "./index.xml"
update_index(root_folder, index_file)
