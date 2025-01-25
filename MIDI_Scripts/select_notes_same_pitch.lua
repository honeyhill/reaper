-- @description Select note and all notes to the right with the same pitch in MIDI editor
-- @version 1.1
-- @author HONEYHILL
-- @changelog
--   Adjusted for use as a Mouse Modifier in Reaper

-- Get the active MIDI editor
local midiEditor = reaper.MIDIEditor_GetActive()
if not midiEditor then return end

-- Get the active take from the MIDI editor
local take = reaper.MIDIEditor_GetTake(midiEditor)
if not take or not reaper.TakeIsMIDI(take) then return end

-- Find the first selected note (the one double-clicked)
local noteIndex = -1
local targetPitch = nil
local targetStartPPQ = nil

repeat
    noteIndex = reaper.MIDI_EnumSelNotes(take, noteIndex)
    if noteIndex ~= -1 then
        -- Get the details of the selected note
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

-- Loop through all notes in the MIDI take
local allNotes = {}
local noteIndex = 0

while true do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, noteIndex)
    if not retval then break end

    -- Select notes with the same pitch to the right
    if pitch == targetPitch and startppqpos >= targetStartPPQ then
        reaper.MIDI_SetNote(take, noteIndex, true, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    else
        reaper.MIDI_SetNote(take, noteIndex, false, muted, startppqpos, endppqpos, chan, pitch, vel, false)
    end

    noteIndex = noteIndex + 1
end

-- Finalize changes and update the MIDI editor
reaper.MIDI_Sort(take)
reaper.Undo_BeginBlock()
reaper.Undo_EndBlock("Select all notes to the right with the same pitch", -1)
