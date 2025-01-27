-- @description Apply custom action to multiple selected tracks sequentially
-- @version 1.1
-- @author HONEYHILL
-- @changelog
--   Fixed logic to process tracks sequentially using remembered track IDs.

-- Custom action ID
local customActionID = reaper.NamedCommandLookup("_e14d4c0cb25c4f56a4bf7e09ddd7246a")
if customActionID == 0 then
    reaper.ShowMessageBox("Custom action not found. Please check the action ID.", "Error", 0)
    return
end

-- Start undo block
reaper.Undo_BeginBlock()

-- Get the number of selected tracks
local numSelectedTracks = reaper.CountSelectedTracks(0)
if numSelectedTracks == 0 then
    reaper.ShowMessageBox("No tracks selected. Please select at least one track.", "Error", 0)
    reaper.Undo_EndBlock("Apply custom action to multiple tracks", -1)
    return
end

-- Store the track IDs of selected tracks in a table
local trackList = {}
for i = 0, numSelectedTracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    if track then
        trackList[#trackList + 1] = reaper.GetTrackGUID(track)
    end
end

-- Process each track one by one
for _, trackGUID in ipairs(trackList) do
    local track = reaper.BR_GetMediaTrackByGUID(0, trackGUID)
    if track then
        -- Select only this track
        reaper.SetOnlyTrackSelected(track)

        -- Apply the custom action
        reaper.Main_OnCommand(customActionID, 0)

        -- Allow time for the action to complete
        reaper.UpdateArrange()
    end
end

-- Restore selection to all originally selected tracks
for _, trackGUID in ipairs(trackList) do
    local track = reaper.BR_GetMediaTrackByGUID(0, trackGUID)
    if track then
        reaper.SetTrackSelected(track, true)
    end
end

-- End undo block
reaper.Undo_EndBlock("Apply custom action to multiple tracks", -1)
