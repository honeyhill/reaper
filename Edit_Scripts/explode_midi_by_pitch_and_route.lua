-- @description Explode MIDI note rows to new tracks and retain input settings
-- @version 1.5
-- @author HONEYHILL
-- @changelog
--   Updated logic to select parent and child tracks for proper input matching with SWS.

-- Start undo block
reaper.Undo_BeginBlock()

-- Get the selected MIDI item
local item = reaper.GetSelectedMediaItem(0, 0)
if not item then
    reaper.ShowMessageBox("No MIDI item selected. Please select a MIDI item to explode.", "Error", 0)
    return
end

-- Get the original track
local originalTrack = reaper.GetMediaItemTrack(item)
if not originalTrack then
    reaper.ShowMessageBox("No track found for the selected item.", "Error", 0)
    return
end

-- Count the number of tracks before the explode operation
local trackCountBefore = reaper.CountTracks(0)

-- Execute the explode MIDI note rows command
reaper.Main_OnCommand(40920, 0) -- Item: Explode MIDI note rows (pitch) to new items

-- Count the number of tracks after the explode operation
local trackCountAfter = reaper.CountTracks(0)

-- Select the original (parent) track
reaper.SetOnlyTrackSelected(originalTrack)

-- Select all child tracks (newly created tracks)
for i = trackCountBefore, trackCountAfter - 1 do
    local newTrack = reaper.GetTrack(0, i)
    if newTrack then
        reaper.SetTrackSelected(newTrack, true)
    end
end

-- Use SWS command to match inputs of all selected tracks to the first selected track
local swsCommandID = reaper.NamedCommandLookup("_SWS_INPUTMATCH")
if swsCommandID ~= 0 then
    reaper.Main_OnCommand(swsCommandID, 0)
else
    reaper.ShowMessageBox("SWS extension not installed or command not found.", "Error", 0)
end

-- End undo block
reaper.Undo_EndBlock("Explode MIDI note rows to new tracks and retain input settings", -1)

-- Refresh the arrange view
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
