-- @description Deselect all notes to the left of the editor cursor
-- @version 1.0
-- @author HONEYHILL
-- @changelog
--   Initial release

-- Get the active MIDI editor
local midiEditor = reaper.MIDIEditor_GetActive()
if not midiEditor then return end

-- Get the active take from the MIDI editor
local take = reaper.MIDIEditor_GetTake(midiEditor)
if not take or not reaper.TakeIsMIDI(take) then return end

-- Get the current position of the MIDI editor cursor in PPQ
local cursorPos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())

-- Loop through all MIDI notes and deselect notes to the left of the cursor
local noteIndex = 0
while true do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
    if not retval then break end

    -- Deselect notes whose start position is less than the cursor position
    if startppqpos < cursorPos then
        reaper.MIDI_SetNote(take, noteIndex, false, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    end

    noteIndex = noteIndex + 1
end

-- Finalize changes and update the MIDI editor
reaper.MIDI_Sort(take)
reaper.Undo_BeginBlock()
reaper.Undo_EndBlock("Deselect all notes to the left of the editor cursor", -1)
