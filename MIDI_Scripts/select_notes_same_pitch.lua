-- @description Select note and all notes to the right with the same pitch in MIDI editor
-- @version 1.3
-- @author HONEYHILL
-- @changelog
--   Fixed selection logic to reliably select all later notes with the same pitch.

-- Get the active MIDI editor
local midiEditor = reaper.MIDIEditor_GetActive()
if not midiEditor then return end

-- Get the active take from the MIDI editor
local take = reaper.MIDIEditor_GetTake(midiEditor)
if not take or not reaper.TakeIsMIDI(take) then return end

-- Find the first selected note (the note you double-clicked)
local targetPitch = nil
local targetStartPPQ = nil

-- Loop through selected notes to identify the double-clicked note
local noteIndex = -1
repeat
    noteIndex = reaper.MIDI_EnumSelNotes(take, noteIndex)
    if noteIndex ~= -1 then
        local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
        if retval then
            targetPitch = pitch
            targetStartPPQ = startppqpos
            break
        end
    end
until noteIndex == -1

-- If no note is selected, exit
if not targetPitch or not targetStartPPQ then return end

-- Deselect all notes in the take
local noteIndex = 0
while true do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
    if not retval then break end
    reaper.MIDI_SetNote(take, noteIndex, false, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    noteIndex = noteIndex + 1
end

-- Select all notes with the same pitch to the right of the target note
noteIndex = 0
while true do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
    if not retval then break end

    if pitch == targetPitch and startppqpos >= targetStartPPQ then
        reaper.MIDI_SetNote(take, noteIndex, true, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    end

    noteIndex = noteIndex + 1
end

-- Finalize changes and update the MIDI editor
reaper.MIDI_Sort(take)
reaper.Undo_BeginBlock()
reaper.Undo_EndBlock("Select all notes to the right with the same pitch", -1)
