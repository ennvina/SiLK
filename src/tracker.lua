local _, Silk = ...

local constants = Silk.Constants

-------------------------
-- UNIT TRACKER FUNCTIONS
-------------------------

local tracker = {
    unit = {},
    localwindowname = constants.windowname.valkyr,
    defaultnpcid = "36609"  -- real Val'kyr ID
}

function tracker:UnitIsValkyr(guid)
    if guid:sub(1,8) == "Vehicle-" then
        local npcid = select(6, strsplit("-", guid))
        return npcid == self.defaultnpcid
    end
    --[[ For testing on Training Dummies
    if guid:sub(1,9) == "Creature-" then
        local npcid = select(6, strsplit("-", guid))
        return npcid == "31144" or npcid == "32666" or npcid == "32667"
    end
    ]]
    return false
end

function tracker:UnitIsTracked(unit)
    local guid = UnitGUID(unit)
    return self.unit[guid]
end

function tracker:UnitIsObsolete(unit)
    local guid = UnitGUID(unit)
    return self.unit[guid].obsolete
end

function tracker:TrackUnit(unit)
    local guid = UnitGUID(unit)
    self.unit[guid] = {
        tracked = true,
        health = UnitHealth(unit),
        obsolete = false,
        index = 0,
        touch = GetTime()
    }
    self:RegisterToWindow(unit)
end

function tracker:CheckUnitObsolete(unit)
    local guid = UnitGUID(unit)
    local health = UnitHealth(unit)
    if health > self.unit[guid].health then -- Val'kyr healed herself
        self.unit[guid].obsolete = true
        Silk_Debug("Unit gained life")
    elseif UnitCastingInfo(unit) then -- Val'kyr is casting something
        self.unit[guid].obsolete = true
        Silk_Debug("Unit did cast something")
    end
    self.unit[guid].health = health
    self.unit[guid].touch = GetTime()

    if self.unit[guid].obsolete then
        self:UnregisterFromWindow(unit)
        Silk.Records:GetRecord():Forget(guid)
    end
end

function tracker:UpdateUnit(unit)
    if not self:UnitIsTracked(unit) then
        self:TrackUnit(unit)
    end
    if not self:UnitIsObsolete(unit) then
        self:CheckUnitObsolete(unit)
    end
    if not self:UnitIsObsolete(unit) then
        self:UpdateRegistered(unit)
    end
end

function tracker:GetValkyrWindow()
    return Silk.Window:GetByName(self.localwindowname)
end

function tracker:RegisterToWindow(unit)
    local window = self:GetValkyrWindow()
    if window then
        local guid = UnitGUID(unit)
        for i=1,3 do
            if window.hp[i] and not window.hp[i].guid or (window.hp[i].guid == 0) then
                self.unit[guid].index = i
                local hp = window.hp[i]
                hp.guid = guid
                hp:SetUnit(unit)
                Silk_Debug("Tracking: "..guid)
                return
            end
        end
        Silk_Warning(SILK_TOO_MANY_UNITS_WARNING)
    end
end

function tracker:UnregisterFromWindow(unit)
    local guid = UnitGUID(unit)
    self:UnregisterFromWindowByGUID(guid)
end

function tracker:UnregisterFromWindowByGUID(guid)
    local window = self:GetValkyrWindow()
    if window then
        local index = self.unit[guid].index
        if index > 0 then
            window.hp[index]:Reset()
            window.hp[index].guid = 0
            self.unit[guid].index = 0
            Silk_Debug("Untracking: "..guid)
        end
    end
end

function tracker:UpdateRegistered(unit)
    local window = self:GetValkyrWindow()
    if window then
        local guid = UnitGUID(unit)
        local index = self.unit[guid].index
        if index > 0 then
            local hp = window.hp[index]
            hp:UpdateUnit(unit)
        end
    end
end

function tracker:CheckGC(guid)
    if not self.unit[guid].obsolete and (GetTime() > (self.unit[guid].touch + Silk.db.timeout)) then
        self.unit[guid].obsolete = true
        self:UnregisterFromWindowByGUID(guid)
        Silk.Records:GetRecord():Forget(guid)
        Silk_Debug("Timeout on: "..guid)
    end
end

function tracker:Update()
    if not UnitAffectingCombat("player") then
        local unitexists = false
        for _ in pairs(self.unit) do
            unitexists = true
            break
        end
        if unitexists then
            -- Reset everything when player leaves combat
            for guid in pairs(self.unit) do
                self:UnregisterFromWindowByGUID(guid)
                Silk.Records:GetRecord():Forget(guid)
            end
            self.unit = {}
        end
        if Silk.Records:GetLastRecord() and Silk.Records:GetLastRecord().recording then
            Silk.Records:GetLastRecord():End()
            Silk_Debug("Record stopped")
--            Silk.UpdateTimeLines()
        end
        return
    end

    local units = {}

    -- look for every target val'kyr, but do not report the same val'kyr twice
    local candidates = { "target", "focus", "targettarget", "focustarget" }
    for i=1,40 do
        table.insert(candidates, "raid"..i.."target")
    end
    for i=1,5 do
        table.insert(candidates, "boss"..i)
    end
    local trackedGUIDs = {}
    for _, unit in ipairs(candidates) do
        local guid = UnitGUID(unit)
        if guid and not trackedGUIDs[guid] and UnitExists(unit) and self:UnitIsValkyr(guid) then
            units[unit] = true
            trackedGUIDs[guid] = true
        end
    end

    -- iterate through all reported val'kyrs and update them
    for u in pairs(units) do
        self:UpdateUnit(u)
    end

    -- iterate through all tracked val'kyrs and make them obsolete if too old, kind of garbage collection
    for guid in pairs(self.unit) do
        self:CheckGC(guid)
    end
end

-- function Silk.CreateTracker(name, npcid)
--     local newtracker = {}
--     for k,v in pairs(tracker) do
--         newtracker[k] = v
--     end
--     newtracker.unit = {}
--     newtracker.localwindowname = name
--     newtracker.defaultnpcid = npcid
--     newtracker.CheckUnitObsolete = function(self, unit)
--         local guid = UnitGUID(unit)
--         local health = UnitHealth(unit)
--         self.unit[guid].health = health
--         self.unit[guid].touch = GetTime()
--
--         if self.unit[guid].obsolete then
--             self:UnregisterFromWindow(unit)
--             Silk.Records:GetRecord():Forget(guid)
--         end
--     end
--     return newtracker
-- end

Silk.tracker = tracker
