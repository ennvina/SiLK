local _, Silk = ...

-------------------
-- RECORD FUNCTIONS
-------------------

local recordproto = {}

function recordproto:Begin()
    self.starts = GetTime()
    self.recording = true
end

function recordproto:End()
    self.ends = GetTime()
    self.recording = false
end

function recordproto:GetUnit(guid)
    return self.unit[guid]
end

function recordproto:RegisterUnit(guid)
    self.unit[guid] = {
        -- times
        created = GetTime(),
        forgotten = -1, -- forgotten before unit reached 50%
        killed = -1,    -- considered "killed" below 50%

        -- raidicon
        raidicon = -1,

        -- stuns
        stun = {},

        -- health in percent
        life = -1
    }
end

function recordproto:Forget(guid)
    local unit = self:GetUnit(guid)
    if not unit then
        self:RegisterUnit(guid)
        unit = self:GetUnit(guid)
    end
    if      (unit.killed < 0)       -- forget only units that weren't killed
        and (unit.forgotten < 0)    -- and that were not already forgotten
    then
        unit.forgotten = GetTime()
    end
end

function recordproto:SetHP(guid, health, total)
    local unit = self:GetUnit(guid)
    if not unit then
        self:RegisterUnit(guid)
        unit = self:GetUnit(guid)
    end
    local newLife = 100*health/total
    if unit.life < 0 then
        unit.life = newLife
        if newLife < 50 then
            unit.killed = GetTime()
        end
    elseif newLife < unit.life then
        -- keep only the lowest life ever known
        local oldLife = unit.life
        unit.life = newLife
        if (oldLife > 50) and (newLife <= 50) then
            unit.killed = GetTime()
        end
    end
end

function recordproto:SetRaidIcon(guid, raidicon)
    raidicon = raidicon or 0
    local unit = self:GetUnit(guid)
    if not unit then
        self:RegisterUnit(guid)
        unit = self:GetUnit(guid)
    end
--    if (unit.raidicon > 0) and (raidicon ~= unit.raidicon) then
--        Silk_Warning() -- not implemented to avoid flood, and it would not be the best place to warn the user anyway
--    end
    if (unit.raidicon <= 0) or (raidicon > 0) then  -- allow updates only if icon is set, ignore when icon is unset
        unit.raidicon = raidicon
    end
end

function recordproto:SetStun(guid, spell, duration, caster)
    local unit = self:GetUnit(guid)
    if not unit then
        self:RegisterUnit(guid)
        unit = self:GetUnit(guid)
    end
    local stun = {
        spell = spell,
        started = GetTime(),
        duration = duration,
        caster = caster
    }
    local index = #unit.stun + 1
    unit.stun[index] = stun
end

function recordproto:ToString()
    local version = 1

    local units = ""
    for guid,u in pairs(self.unit) do
        local stuns = ""
        for i,s in pairs(u.stun) do
            local duration = math.ceil(s.duration*10)/10
            local caster = tostring(s.caster) -- slight precaution in case caster is nil
            local stun = string.format("%d/%d/%.1f/%s", s.spell, s.started, duration, caster)
            stuns = stuns..stun..","
        end
        local unit = string.format("%s,%d,%d,%d,%d,%d,%s", guid:sub(13,18), u.created, u.forgotten, u.killed, u.raidicon, u.life, stuns)
        units = units..unit..";"
    end

    local recording = 0
    if self.recording then recording = 1 end

    local str = string.format("%d;%d;%d;%d;%s", version, self.starts, self.ends, recording, units)
    return str
end

function recordproto:FromString(str)
--    Silk_Debug("Depacking Record: "..str)
    local version,starts,ends,recording,units = str:match("^ *(%d+);(%d+);([+-]?%d+);([01]);(.*) *$")
    Silk_Debug("Importing Record: version="..tonumber(version).." starts="..tonumber(starts).." ends="..tonumber(ends).." recording="..tonumber(recording))
    self.starts = tonumber(starts)
    self.ends = tonumber(ends)
    if tonumber(recording) == 1 then self.recording = true else self.recording = false end
    self.unit = {} -- will be filled thereafter
    for unit in string.gmatch(units, "([^;]*);") do
--        Silk_Debug("Depacking Unit: "..unit)
        local guid,created,forgotten,killed,raidicon,life,stuns = unit:match("^ *(%x+),(%d+),([+-]?%d+),([+-]?%d+),(%d+),(%d+),(.*) *$")
        guid = "0xF150008F01"..guid -- rebuild unit that was truncated for compression purposes
        Silk_Debug("Unit "..guid.." : created="..tonumber(created).." forgotten="..tonumber(forgotten).." killed="..tonumber(killed).." raidicon="..tonumber(raidicon).." life="..tonumber(life))
        self.unit[guid] = {
            created = tonumber(created),
            forgotten = tonumber(forgotten),
            killed = tonumber(killed),
            stun = {}, -- will be filled thereafter
            raidicon = tonumber(raidicon),
            life = tonumber(life)
        }
        for stun in string.gmatch(stuns, "([^,]*),") do
--            Silk_Debug("Depacking Stun: "..stun)
            local spell,started,duration,caster = stun:match("^ *(%d+)/(%d+)/(%d+\.?%d*)/(.*) *$")
            Silk_Debug("Stun spell="..tonumber(spell).." started="..tonumber(started).." duration="..tonumber(duration).." caster="..caster)
            self.unit[guid].stun[#self.unit[guid].stun + 1] = {
                spell = tonumber(spell),
                started = tonumber(started),
                duration = tonumber(duration),
                caster = caster,
            }
        end
    end
end

local records = {}

local Records = {}

function Records:CreateRecord()
    local record = {
        unit = {},
        starts = -1,
        ends = -1,
        recording = false   -- not used yet
    }

    for k,v in pairs(recordproto) do record[k]=v end

    local index = #records + 1
    record.name = "Combat "..index
    record:Begin()
    records[index] = record

    return record
end

-- Get the current record of create a new one if needed
function Records:GetRecord()
    if #records == 0 then
        return self:CreateRecord()
    end
    local record = records[#records]
    if record.ends > 0 then -- previous record terminated, need a new record
        return self:CreateRecord()
    else
        return record
    end
end

-- Get the last record if and only if one exists, this record may or may not be terminated yet
function Records:GetLastRecord()
    if #records == 0 then
        return nil
    end
    return records[#records]
end

function Records:ResetAll()
    records = {}
end

-- Records but not Records?? Need a major rework here

function Silk_CreateRecord()
    if Records:GetLastRecord() and Records:GetLastRecord().recording then
        Records:GetLastRecord():End()
    end
    Records:CreateRecord()
end
function Silk_ImportRecord(str)
    Records:CreateRecord():FromString(str)
end
function Silk_SaveRecords()
    if Records:GetLastRecord() and Records:GetLastRecord().recording then
        Records:GetLastRecord():End()
    end
    Silk.db.records = records
    Silk_Debug(#records.." record(s) saved.")
end
function Silk_LoadRecords()
    if Silk.db.records then
        local recordsproto = {}
        for k,v in pairs(records) do
            if type(v) == "function" then
                recordsproto[k]=v
            end
        end
        records = Silk.db.records
        for k,v in pairs(recordsproto) do
            records[k]=v
        end
        Silk_Debug(#records.." record(s) loaded.")
    else
        Silk_Warning("Can not load records: no record previously saved.")
    end
end
function Silk_ResetRecords()
    if Silk.db.records then
        local recordsproto = {}
        for k,v in pairs(records) do
            if type(v) == "function" then
                recordsproto[k]=v
            end
        end
        records = {}
        Silk.db.records = records
        for k,v in pairs(recordsproto) do
            records[k]=v
        end
        Silk_Debug("Resetting saved record(s).")
    else
        Silk_Warning("Can not reset records: no record previously saved.")
    end
end

Silk.Records = Records
