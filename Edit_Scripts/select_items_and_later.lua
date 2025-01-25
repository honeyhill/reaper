-- @description Select media item and all items to the right on the same track
-- @version 1.0
-- @author HONEYHILL
-- @changelog
--   Initial release

-- Start undo block
reaper.Undo_BeginBlock()

-- Get the first selected media item
local selectedItem = reaper.GetSelectedMediaItem(0, 0)
if not selectedItem then
    reaper.ShowMessageBox("No media item selected.", "Error", 0)
    return
end

-- Get the track and position of the selected item
local track = reaper.GetMediaItemTrack(selectedItem)
local itemStartPos = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")

-- Deselect all items
local itemCount = reaper.CountMediaItems(0)
for i = 0, itemCount - 1 do
    local item = reaper.GetMediaItem(0, i)
    reaper.SetMediaItemSelected(item, false)
end

-- Loop through all media items and select items to the right on the same track
for i = 0, itemCount - 1 do
    local item = reaper.GetMediaItem(0, i)
    local itemTrack = reaper.GetMediaItemTrack(item)
    local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

    if itemTrack == track and itemStart >= itemStartPos then
        reaper.SetMediaItemSelected(item, true)
    end
end

-- Update the Arrange view and end undo block
reaper.UpdateArrange()
reaper.Undo_EndBlock("Select media item and all items to the right on the same track", -1)
