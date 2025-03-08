MusicGenerator = {
    currentPattern = 1,
    patterns = {
        { -- Pattern 1: Exploration theme
            name = "cyber_arpeggio",
            scale = {60, 64, 67, 72}, -- C Major 7th
            rhythm = {0.25, 0.125, 0.125, 0.5},
            wave = "sawtooth",
            bpm = 128,
            attack = 0.1,
            decay = 0.3,
            intensity = 0.4
        },
        { -- Pattern 2: Boss combat
            name = "boss_battle",
            scale = {55, 59, 62, 65}, -- G Minor
            rhythm = {0.5, 0.25, 0.25, 1},
            wave = "square",
            bpm = 140,
            attack = 0.05,
            decay = 0.2,
            intensity = 0.6
        }
    },
    currentSource = nil,
    enabled = true
}

function MusicGenerator:init()
    -- This channel is currently not used. Remove if unnecessary.
    self.channel = love.thread.getChannel("music")
    self:generatePatternCache()
end

function MusicGenerator:generatePatternCache()
    self.patternCache = {}
    for i, pattern in ipairs(self.patterns) do
        self.patternCache[i] = self:createPatternSound(pattern)
    end
end

function MusicGenerator:createPatternSound(pattern)
    local melody = {}
    local sampleRate = 44100

    -- First pass: generate melody notes with their sample counts precomputed
    for i = 1, 32 do
        local note = {
            note = pattern.scale[math.random(#pattern.scale)],
            duration = pattern.rhythm[math.random(#pattern.rhythm)]
        }
        local noteDuration = note.duration * (60 / pattern.bpm)
        note.samples = math.ceil(noteDuration * sampleRate)
        table.insert(melody, note)
    end

    -- Calculate the total number of samples for the sound data
    local totalSamples = 0
    for _, note in ipairs(melody) do
        totalSamples = totalSamples + note.samples
    end

    local soundData = love.sound.newSoundData(totalSamples, sampleRate, 16, 1)
    local pos = 0  -- Tracks the current sample position

    -- Second pass: generate audio for each note
    for _, note in ipairs(melody) do
        local samples = note.samples
        local freq = 440 * 2 ^ ((note.note - 69) / 12)

        for i = 1, samples do
            local t = (i - 1) / sampleRate  -- time within the note
            local value = 0

            -- Waveform generation
            if pattern.wave == "sawtooth" then
                value = 2 * ((t * freq) % 1) - 1
            elseif pattern.wave == "square" then
                value = math.sin(2 * math.pi * freq * t) > 0 and 0.8 or -0.8
            elseif pattern.wave == "triangle" then
                value = math.abs(((t * freq) % 1) * 2 - 1) * 2 - 1
            end

            -- ADSR envelope calculation (attack and decay only)
            local env
            if t < pattern.attack then
                env = t / pattern.attack
            elseif t < pattern.attack + pattern.decay then
                env = 1 - ((t - pattern.attack) / pattern.decay)
            else
                env = 0  -- Note is silent after decay; add a sustain phase if desired.
            end

            -- Apply a resonance filter (exponential decay)
            local filtered = value * math.exp(-t * 2)

            -- Write the sample to soundData (adjusting for 0-indexed samples)
            soundData:setSample(pos + i - 1, filtered * pattern.intensity * env)
        end

        pos = pos + samples  -- Move the write position forward
    end

    return love.audio.newSource(soundData, "static")
end

function MusicGenerator:update(dt)
    if self.enabled and (not self.currentSource or not self.currentSource:isPlaying()) then
        self:playCurrentPattern()
    end
end

function MusicGenerator:playCurrentPattern()
    if self.patternCache[self.currentPattern] then
        self.currentSource = self.patternCache[self.currentPattern]:clone()
        self.currentSource:play()
    end
end

function MusicGenerator:switchPattern(patternName)
    for i, p in ipairs(self.patterns) do
        if p.name == patternName then
            self.currentPattern = i
            if self.currentSource then
                self.currentSource:stop()
            end
            self:playCurrentPattern()
            return
        end
    end
end

return MusicGenerator