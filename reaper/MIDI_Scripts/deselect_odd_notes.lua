-- @description Deselect odd notes (1st, 3rd,...) in MIDI editor from current selection (every other note keeps its selection)
-- @version 1.0
-- @author HONEYHILL
-- @changelog
--   Initial release

-- Get the active MIDI editor
local midiEditor = reaper.MIDIEditor_GetActive()
if not midiEditor then
    reaper.ShowMessageBox("No active MIDI editor found.", "Error", 0)
    return
end

-- Get the active take from the MIDI editor
local take = reaper.MIDIEditor_GetTake(midiEditor)
if not take or not reaper.TakeIsMIDI(take) then
    reaper.ShowMessageBox("No active MIDI take found.", "Error", 0)
    return
end

-- Keep track of selected note indices
local selectedNotes = {}
local noteIndex = 0

-- Loop through all MIDI notes to gather selected notes
while true do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
    if not retval then break end -- Exit the loop if there are no more notes

    if selected then
        table.insert(selectedNotes, noteIndex)
    end

    noteIndex = noteIndex + 1
end

-- Deselect odd-indexed notes from the selection
for i = 1, #selectedNotes, 2 do -- Start from the first note in the selection
    local noteIndex = selectedNotes[i]
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
    if retval then
        reaper.MIDI_SetNote(take, noteIndex, false, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    end
end

-- Finalize changes and update the MIDI editor
reaper.MIDI_Sort(take)
reaper.Undo_BeginBlock()
reaper.Undo_EndBlock("Deselect every other MIDI note", -1)
