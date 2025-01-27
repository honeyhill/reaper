-- @description Hide tracks with no items from the TCP
-- @version 1.0
-- @author HONEYHILL
-- @changelog
--   Initial release

-- Begin undo block
reaper.Undo_BeginBlock()

-- Loop through all tracks
local trackCount = reaper.CountTracks(0)
for i = 0, trackCount - 1 do
    local track = reaper.GetTrack(0, i)

    -- Check if the track has any media items
    local itemCount = reaper.CountTrackMediaItems(track)
    if itemCount == 0 then
        -- Hide the track in the TCP
        reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 0)
    else
        -- Ensure tracks with items remain visible in the TCP
        reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 1)
    end
end

-- End undo block
reaper.Undo_EndBlock("Hide tracks with no items from TCP", -1)

-- Update the arrange view
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
