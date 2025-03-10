MusicGenerator = {
    currentPattern = 1,
    patterns = {
        { -- Xbox Marijuana Full Song
            name = "xbox_marijuana",
            sections = {
                intro = {
                    melody = {
                        {note = 72, duration = 0.25}, {note = 72, duration = 0.25},
                        {note = 74, duration = 0.5}, {note = 76, duration = 0.25},
                        {note = 77, duration = 0.25}, {note = 79, duration = 0.5}
                    },
                    length = 2
                },
                main = {
                    melody = {
                        {note = 72, duration = 0.25}, {note = 71, duration = 0.25},
                        {note = 69, duration = 0.5}, {note = 67, duration = 0.25},
                        {note = 65, duration = 0.25}, {note = 64, duration = 0.5},
                        {note = 62, duration = 0.25}, {note = 60, duration = 0.25},
                        {note = 59, duration = 0.5}, {note = 60, duration = 0.25},
                        {note = 64, duration = 0.25}, {note = 67, duration = 0.5}
                    },
                    length = 4
                }
            },
            wave = "square",
            bpm = 140,
            attack = 0.05,
            decay = 0.1,
            intensity = 0.7,
            structure = {"intro", "main"}
        }
    },
    currentSources = {},
    enabled = true
}

function MusicGenerator:init()
    self.sampleRate = 44100  -- Initialize first
    self:generatePatternCache()
    self.activeSources = {}
    self.sectionTimer = 0
    self.currentSection = 1
    self.beat = 0
end

function MusicGenerator:midiToFreq(note)
    return 440 * math.pow(2, (note - 69)/12)
end

function MusicGenerator:generatePatternCache()
    self.patternCache = {}
    for i, pattern in ipairs(self.patterns) do
        local cached = {
            sections = {},
            bpm = pattern.bpm,
            structure = pattern.structure
        }
        
        for sectionName, section in pairs(pattern.sections) do
            cached.sections[sectionName] = self:createSectionSound(
                section.melody,
                pattern
            )
        end
        
        self.patternCache[i] = cached
    end
end

function MusicGenerator:createSectionSound(notes, pattern)
    local totalSamples = 0
    for _, note in ipairs(notes) do
        local noteDuration = note.duration * (60 / pattern.bpm)
        totalSamples = totalSamples + math.ceil(noteDuration * self.sampleRate)
    end

    local soundData = love.sound.newSoundData(totalSamples, self.sampleRate, 16, 1)
    local pos = 0

    for _, note in ipairs(notes) do
        local noteDuration = note.duration * (60 / pattern.bpm)
        local samples = math.ceil(noteDuration * self.sampleRate)
        local freq = self:midiToFreq(note.note)

        for i = 1, samples do
            local t = (i - 1) / self.sampleRate
            local value = 0

            -- Square wave generation
            if pattern.wave == "square" then
                value = math.sin(2 * math.pi * freq * t) > 0 and 0.8 or -0.8
            end

            -- ADSR envelope
            local env = math.min(t/pattern.attack, 1) * 
                       math.max(1 - (t - pattern.attack)/pattern.decay, 0)

            soundData:setSample(pos + i - 1, value * pattern.intensity * env)
        end
        pos = pos + samples
    end

    return love.audio.newSource(soundData, "static")
end

function MusicGenerator:update(dt)
    if not self.enabled then return end
    
    local currentPattern = self.patternCache[self.currentPattern]
    self.beat = self.beat + dt * (currentPattern.bpm / 60)
    self.sectionTimer = self.sectionTimer + dt

    -- Clean finished sources using utils.arrayRemove
    self.activeSources = utils.arrayRemove(self.activeSources, function(t, i, j)
        return t[i] and t[i]:isPlaying()
    end)

    -- Section progression
    local sectionName = currentPattern.structure[self.currentSection]
    local sectionData = self.patterns[self.currentPattern].sections[sectionName]
    local sectionDuration = sectionData.length * (60 / currentPattern.bpm)

    if self.sectionTimer >= sectionDuration then
        self.currentSection = self.currentSection + 1
        if self.currentSection > #currentPattern.structure then
            self.currentSection = 2  -- Skip intro after first play
        end
        self.sectionTimer = 0
        self:playCurrentSection()
    end
end

function MusicGenerator:playCurrentSection()
    local currentPattern = self.patternCache[self.currentPattern]
    local sectionName = currentPattern.structure[self.currentSection]
    
    -- Stop previous sources
    for _, src in ipairs(self.activeSources) do
        src:stop()
    end
    self.activeSources = {}

    -- Start new section
    local src = currentPattern.sections[sectionName]:clone()
    src:play()
    table.insert(self.activeSources, src)
end

function MusicGenerator:switchPattern(patternName)
    for i, p in ipairs(self.patterns) do
        if p.name == patternName then
            self.currentPattern = i
            self.currentSection = 1
            self.sectionTimer = 0
            if #self.activeSources > 0 then
                self:playCurrentSection()
            end
            return
        end
    end
end

return MusicGenerator