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
    self.channel = love.thread.getChannel("music")
    self:generatePatternCache()
end

function MusicGenerator:generatePatternCache()
    self.patternCache = {}
    for i,pattern in ipairs(self.patterns) do
        self.patternCache[i] = self:createPatternSound(pattern)
    end
end

function MusicGenerator:createPatternSound(pattern)
    local melody = {}
    -- Generate 8-bar phrase with structure
    for i=1,32 do
        table.insert(melody, {
            note = pattern.scale[math.random(#pattern.scale)],
            duration = pattern.rhythm[math.random(#pattern.rhythm)]
        })
    end
    
    local sampleRate = 44100
    local totalSamples = 0
    
    -- First pass: calculate exact sample count
    for _,note in ipairs(melody) do
        local noteDuration = note.duration * (60/pattern.bpm)
        totalSamples = totalSamples + math.ceil(noteDuration * sampleRate)
    end

    local soundData = love.sound.newSoundData(totalSamples, sampleRate, 16, 1)
    local pos = 0
    
    for _,note in ipairs(melody) do
        local noteDuration = note.duration * (60/pattern.bpm)
        local samples = math.ceil(noteDuration * sampleRate)
        local freq = 440 * 2^((note.note - 69)/12)
        
        for i=0, samples-1 do
            if pos + i >= totalSamples then break end  -- Safety check
            
            local t = i / sampleRate  -- Relative time within note
            local value = 0
            
            -- Waveform generation
            if pattern.wave == "sawtooth" then
                value = 2 * (t * freq % 1) - 1
            elseif pattern.wave == "square" then
                value = math.sin(2 * math.pi * freq * t) > 0 and 0.8 or -0.8
            elseif pattern.wave == "triangle" then
                value = math.abs((t * freq % 1) * 2 - 1) * 2 - 1
            end
            
            -- ADSR envelope (now note-local)
            local env = math.min(t/pattern.attack, 1) * 
                      math.max(0, 1 - (t-pattern.attack)/pattern.decay)
            
            -- Filter with resonance
            local filtered = value * math.exp(-t*2)
            
            soundData:setSample(pos + i + 1, filtered * pattern.intensity * env)
        end
        
        pos = pos + samples
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
    for i,p in ipairs(self.patterns) do
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