-- @description Hide tracks with no items from the TCP, but keep folder tracks visible if they have child tracks with items
-- @version 1.1
-- @author HONEYHILL
-- @changelog
--   - Prevents folder tracks from being hidden if they contain child tracks with media items

-- Begin undo block
reaper.Undo_BeginBlock()

-- Create a table to store tracks that should remain visible
local visible_tracks = {}

-- First pass: Check which tracks have items and mark folder tracks with item-containing children as visible
local trackCount = reaper.CountTracks(0)
for i = 0, trackCount - 1 do
    local track = reaper.GetTrack(0, i)
    local itemCount = reaper.CountTrackMediaItems(track)
    
    if itemCount > 0 then
        visible_tracks[track] = true
    end
    
    -- Check if the track is a folder (folder depth > 0)
    local folderDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    if folderDepth > 0 then
        -- Iterate through child tracks to see if any have items
        for j = i + 1, trackCount - 1 do
            local childTrack = reaper.GetTrack(0, j)
            local childItemCount = reaper.CountTrackMediaItems(childTrack)

            -- If child has items, mark the parent folder track as visible
            if childItemCount > 0 then
                visible_tracks[track] = true
                break
            end

            -- Stop if we reach another folder at the same or higher level
            local childFolderDepth = reaper.GetMediaTrackInfo_Value(childTrack, "I_FOLDERDEPTH")
            if childFolderDepth <= 0 then
                break
            end
        end
    end
end

-- Second pass: Hide or show tracks based on collected data
for i = 0, trackCount - 1 do
    local track = reaper.GetTrack(0, i)
    if visible_tracks[track] then
        reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 1)
    else
        reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 0)
    end
end

-- End undo block
reaper.Undo_EndBlock("Hide tracks with no items from TCP, but keep folder tracks with active children", -1)

-- Update the arrange view
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
