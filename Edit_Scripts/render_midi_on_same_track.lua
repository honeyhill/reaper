-- @description Render selected MIDI item to audio or render audio item to new take
-- @version 1.6
-- @author HONEYHILL
-- @changelog
--   - Added logic to check if the selected item is MIDI or audio.
--   - If MIDI, it renders the item using the existing logic.
--   - If audio, it executes action 41999 (Render item to new take).

-- Ensure an item is selected
local item = reaper.GetSelectedMediaItem(0, 0)
if not item then
    reaper.ShowMessageBox("No item selected. Please select a MIDI or audio item to render.", "Error", 0)
    return
end

-- Get the active take
local take = reaper.GetActiveTake(item)
if not take then
    reaper.ShowMessageBox("No active take found in the selected item.", "Error", 0)
    return
end

-- Check if the take is MIDI or audio
if reaper.TakeIsMIDI(take) then
    -- MIDI processing

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

else
    -- Audio processing: Render item to new take
    reaper.Main_OnCommand(41999, 0) -- Render item to new take
end

-- Finalize
reaper.Undo_BeginBlock()
reaper.Undo_EndBlock("Render MIDI or audio item", -1)

-- Update the Arrange view
reaper.UpdateArrange()
