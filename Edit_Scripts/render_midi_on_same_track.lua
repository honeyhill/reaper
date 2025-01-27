-- @description Render selected MIDI item to audio
-- @version 1.5
-- @author HONEYHILL
-- @changelog
--   Removed logic to force visibility of only active take.

-- Ensure a MIDI item is selected
local item = reaper.GetSelectedMediaItem(0, 0)
if not item then
    reaper.ShowMessageBox("No MIDI item selected. Please select a MIDI item to render.", "Error", 0)
    return
end

-- Get the track and the start position of the selected item
local track = reaper.GetMediaItemTrack(item)
local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

-- Check if the track contains a VSTi instrument
local fxCount = reaper.TrackFX_GetCount(track)
local instrumentIndex = reaper.TrackFX_GetInstrument(track)
if instrumentIndex == -1 then
    reaper.ShowMessageBox("No VSTi instrument found on the selected track.", "Error", 0)
    return
end

-- Temporarily bypass all FX after the VSTi
for i = instrumentIndex + 1, fxCount - 1 do
    reaper.TrackFX_SetEnabled(track, i, false)
end

-- Render the MIDI item to audio
reaper.Main_OnCommand(40209, 0) -- Apply track/take FX to items (new take)

-- Re-enable the FX after the VSTi
for i = instrumentIndex + 1, fxCount - 1 do
    reaper.TrackFX_SetEnabled(track, i, true)
end

-- Get the new rendered audio take
local newTake = reaper.GetActiveTake(item)
if not newTake or reaper.TakeIsMIDI(newTake) then
    reaper.ShowMessageBox("Rendering failed. Please check your setup.", "Error", 0)
    return
end

-- Finalize
reaper.Undo_BeginBlock()
reaper.Undo_EndBlock("Render MIDI to audio", -1)

-- Update the Arrange view
reaper.UpdateArrange()
