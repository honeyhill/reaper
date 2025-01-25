-- @description Deselect odd media items
-- @version 1.0
-- @author HONEYHILL
-- @changelog
--   Initial release

-- Start undo block
reaper.Undo_BeginBlock()

-- Get the total number of media items
local itemCount = reaper.CountMediaItems(0)

-- Loop through all media items
for i = 0, itemCount - 1 do
    local item = reaper.GetMediaItem(0, i)

    -- Deselect odd-indexed media items (1st, 3rd, 5th, ...)
    if (i % 2 == 0) then
        reaper.SetMediaItemSelected(item, false)
    end
end

-- Update the Arrange view and end undo block
reaper.UpdateArrange()
reaper.Undo_EndBlock("Deselect odd media items", -1)
