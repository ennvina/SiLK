--
-- Silk : Silent Lich King, by Vinny - vinnywow@netscape.net
--
-- Developed for Silent - Illidan EU
--

local taggedmobs = {}
local db

function Silk_LoadDB()
    local currentversion = 100
    db = SilkDB
    if not db or not db.version or (db.version < 040) then
        db = {}

        -- activation
        db.enabled = true

        -- frame geometry
        db.dimensions = {}
        db.scales = {}
        db.positions = {}
        db.visible = {}
        db.version = 040
    end

--  check version here, and import older db if possible
    if (db.version < 042) then
        db.stun = {}
        db.stun.showraid = false
        db.version = 042
    end
    if (db.version < 051) then
        db.timeout = 10
        db.version = 051
    end
    if (db.version < 060) then
        db.channel = "default"
        db.version = 060
    end
    if (db.version < 080) then
        db.records = {}
    end
    
    -- ultimate checks for corrupted addons
    if not db.enabled then
        db.enabled = true
    end
    if not db.dimensions then
        db.dimensions = {}
    end
    if not db.scales then
        db.scales = {}
    end
    if not db.positions then
        db.positions = {}
    end
    if not db.visible then
        db.visible = {}
    end
    if not db.stun then
        db.stun = {}
    end
    if not db.stun.showraid then
        db.stun.showraid = false
    end
    if not db.timeout then
        db.timeout = 10
    end
    if not db.channel then
        db.channel = "default"
    end
    if not db.records then
        db.records = {}
    end

    db.version = currentversion
    SilkDB = db
end

local windowname = {
    valkyr = "Val'kyrs",
    aaa = "AAA",
    corpo = "Corporeality",
    spitecaller = "Spitecaller",
    adherent = "Corrupting Adherent",
    sk = "Spirit Kings",
}

local frames = {}
local windows = {}
local buttonSize = 10
local titleHeight = 11
local titleBarInset = 2
local healthHeight = 20
local healthInset = 1
local nbstunicons = 3   -- suppose 3 stuns maximum, i.e. no D.R. reset
local halionHeight = 32
local halionInset = 2

local customnpcid = nil


local stunspells = {
    100,    -- warrior - Charge
    107570, -- warrior - Storm Bolt
    46968,  -- warrior - Shockwave

    5211,   -- druid - Bash (Bear stun)
    9005,   -- druid - Pounce (Cat stun) (stealth)
    22570,  -- druid - Maim (Cat stun)

    853,    -- paladin - Hammer of Justice
    2812,   -- paladin - Holy Wrath
    105593, -- paladin - Fist of Justice

    408,    -- rogue - Kidney Shot
    1833,   -- rogue - Cheap Shot (stealth)

    19577,  -- hunter - Beast Mastery (pet stun)
    50519,  -- hunter - Sonic Blast (Bat stun)
    56626,  -- hunter - Sting (Wasp stun)

    44572,  -- mage - Deep Freeze
    11129,  -- mage - Combustion

    30283,  -- warlock - Shadow fury
    89766,  -- warlock - Axe Toss (Felguard stun)

    58861,  -- shaman - Wolf stun

    47481,  -- death knight - Gnaw (Ghoul stun)

    113656, -- monk - Fists of Fury
    122057, -- monk - Clash
    119392, -- monk - Charging Ox Wave
    119381, -- monk - Leg Sweep

    20549,  -- Tauren - War Stomp
}

local function GetHumanReadableTime(seconds, ceiling)
  local round = nil
  if ceiling then
      round = math.ceil
  else
      round = math.floor
  end
  if seconds >= 300 then -- >= 5min
    return tostring(round(seconds/60)) .. "m";
  elseif seconds >= 10 then
    return tostring(round(seconds)) .. "s";
  else
    return tostring(round(seconds*10)/10) .. "s";
  end
end

local function GetRemainingTime(expiration)
    local seconds = expiration - GetTime()
    if seconds < 0 then
        return "0"
    elseif seconds >= 10 then
        return tostring(math.floor(seconds));
    else
        return tostring(math.floor(seconds*10)/10);
    end
end

do
	local function OnEnter(self)
        if self._ttEnabled then
		    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    		if self._ttTitle then GameTooltip:AddLine(self._ttTitle,nil,nil,nil,true) end
	    	if self._ttText then GameTooltip:AddLine(self._ttText,1,1,1,true) end
		    GameTooltip:Show()
        end
	end

	local function OnLeave(self)
		GameTooltip:Hide()
	end

	function AddTooltipText(obj,title,text)
		obj._ttTitle = title
		obj._ttText = text
        if not obj._ttExists then
            obj._ttExists = true
            obj:HookScript("OnEnter",OnEnter)
            obj:HookScript("OnLeave",OnLeave)
        end
		obj._ttEnabled = true
	end

    function ResetTooltipText(obj)
		obj._ttEnabled = false
	end
end

function Silk_ShortHelp()
  Silk_Message(SILK_COMMANDHELP1 .. ".");
  Silk_Message(SILK_COMMANDHELP2 .. ".");
  Silk_Message(SILK_COMMANDHELP2B.. ".");
  Silk_Message(SILK_COMMANDHELP2C.. ".");
  Silk_Message(SILK_COMMANDHELP0 .. ".");
end

function Silk_Help()
  Silk_Message(SILK_COMMANDHELP1 .. ".");
  Silk_Message(SILK_COMMANDHELP2 .. ".");
  Silk_Message(SILK_COMMANDHELP2B.. ".");
  Silk_Message(SILK_COMMANDHELP2C.. ".");
  Silk_Message(SILK_COMMANDHELP3 .. ".");
  Silk_Message(SILK_COMMANDHELP4 .. ".");
  Silk_Message(SILK_COMMANDHELP5 .. ".");
  Silk_Message(SILK_COMMANDHELP6 .. ".");
  Silk_Message(SILK_COMMANDHELP7 .. ".");
  Silk_Message(SILK_COMMANDHELP8 .. ".");
  Silk_Message(SILK_COMMANDHELP9 .. ".");
  Silk_Message(SILK_COMMANDHELP0 .. ".");
end

--------------------------
-- FRAME UTILITY FUNCTIONS
--------------------------

local futils = {}

do
    local moved = {}
    local resized = {}
    local scaled = {}

    function futils:SaveDimensions(f)
        frames[f:GetName()] = f
        resized[f:GetName()] = true

        local name = f:GetName()
        db.dimensions[name].width = f:GetWidth()
        db.dimensions[name].height = f:GetHeight()
    end
    
    function futils:LoadDimensions(f)
        frames[f:GetName()] = f
        resized[f:GetName()] = true

        local name = f:GetName()
        local dims = db.dimensions[name]
        if dims then
            f:SetWidth(dims.width)
            f:SetHeight(dims.height)
        else
            db.dimensions[name] = {
                width = f:GetWidth(),
                height = f:GetHeight()
            }
        end
    end
    
    function futils:SaveScale(f)
        frames[f:GetName()] = f
        scaled[f:GetName()] = true

        local name = f:GetName()
        db.scales[name] = f:GetScale()
    end
    
    function futils:LoadScale(f)
        frames[f:GetName()] = f
        scaled[f:GetName()] = true

        local name = f:GetName()
        local scale = db.scales[name]
        if scale then
            f:SetScale(scale)
        else
            db.scales[name] = f:GetScale()
        end
    end

	function futils:SavePosition(f)
        frames[f:GetName()] = f
        moved[f:GetName()] = true

		local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
		local name = f:GetName()
		local pos = db.positions[name]
        if not pos then
            pos = {}
            db.positions[name] = pos
        end
		pos.point = point
		pos.relativeTo = relativeTo and relativeTo:GetName()
		pos.relativePoint = relativePoint
		pos.xOfs = xOfs
		pos.yOfs = yOfs
		f:SetUserPlaced(false)
	end

    function futils:LoadPosition(f)
        frames[f:GetName()] = f
        moved[f:GetName()] = true

        local name = f:GetName()
		f:ClearAllPoints()
		local pos = db.positions[name]
		if pos then
			f:SetPoint(pos.point,_G[pos.relativeTo] or UIParent,pos.relativePoint,pos.xOfs,pos.yOfs)
        else
			f:SetPoint("CENTER",UIParent,"CENTER",0,0)
			db.positions[name] = {
				point = "CENTER",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				xOfs = 0,
				yOfs = 0,
			}
		end
	end

    function futils:ResetAll()
        for n,f in pairs(frames) do
            if moved[n] then
                f:SetPoint("CENTER",UIParent,"CENTER",0,0)
                futils:SavePosition(f)
            end
            if scaled[n] then
                f:SetScale(1)
                futils:SaveScale(f)
            end
            if resized[n] then
                f:SetWidth(200)
                f:SetHeight(200)
                futils:SaveDimensions(f)
            end
        end
    end
end

---------------------------------------
-- HANDLERS
---------------------------------------
local handlers

handlers = {
	Anchor_OnSizeChanged = function(self, width, height)
		if self._sizing then
			if not self.__noresizing and IsShiftKeyDown() then
				self.ratio = height / width

				self.faux_window:SetWidth((width * self:GetEffectiveScale()) / self.faux_window:GetEffectiveScale())
				self.faux_window:SetHeight((height * self:GetEffectiveScale()) / self.faux_window:GetEffectiveScale())

--				self:Fire("OnSizeChanged")
			else
				local h = width * self.ratio
				self:SetHeight(h)
				-- self.faux_window:GetEffectiveScale() doesn't work because this 
				-- handler is called again by SetHeight, which then causes the 
				-- calculated scale to become 1
				local scale = (width * self:GetEffectiveScale()) / (self.faux_window:GetWidth() * UIParent:GetEffectiveScale())
				self.faux_window:SetScale(scale)

--				self:Fire("OnScaleChanged")
			end
		end
        if self.hp then
            for k,v in pairs(self.hp) do
                v:UpdateSize()
            end
        end
	end,

    Title_OnMouseDown = function(self)
        if IsShiftKeyDown() then
            self.window:StartMoving()
        end
    end,

    Title_OnMouseUp = function(self)
        self.window:StopMovingOrSizing()
        futils:SavePosition(self.window)
    end,

	Corner_OnMouseDown = function(self)
		self.window._sizing = true
		self.window:StartSizing("BOTTOMRIGHT")
	end,

	Corner_OnMouseUp = function(self)
		self.window:StopMovingOrSizing()
		self.window._sizing = nil
		futils:SaveDimensions(self.window.faux_window)
		futils:SaveScale(self.window.faux_window)
		futils:SaveDimensions(self.window)
		futils:SavePosition(self.window)
	end,

	Button_OnLeave = function(self)
		self.t:SetVertexColor(0.33,0.33,0.33)
	end,

	Button_OnEnter = function(self)
		self.t:SetVertexColor(0,1,0)
	end,
    
    Close_OnClick = function(self)
        self.window:Hide()
        db.visible[self.window:GetName()].show = false
    end
}

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
--    Silk_Debug("Depacking Record : "..str)
    local version,starts,ends,recording,units = str:match("^ *(%d+);(%d+);([+-]?%d+);([01]);(.*) *$")
    Silk_Debug("Importing Record : version="..tonumber(version).." starts="..tonumber(starts).." ends="..tonumber(ends).." recording="..tonumber(recording))
    self.starts = tonumber(starts)
    self.ends = tonumber(ends)
    if tonumber(recording) == 1 then self.recording = true else self.recording = false end
    self.unit = {} -- will be filled thereafter
    for unit in string.gmatch(units, "([^;]*);") do
--        Silk_Debug("Depacking Unit : "..unit)
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
--            Silk_Debug("Depacking Stun : "..stun)
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

function records:CreateRecord()
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
function records:GetRecord()
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
function records:GetLastRecord()
    if #records == 0 then
        return nil
    end
    return records[#records]
end

function records:ResetAll()
    records = {}
end

-------------------------
-- HEALTH PANEL FUNCTIONS
-------------------------

local hpproto = {}

function hpproto:CreateMainFrame()
    local inset = healthInset
    mainframe = CreateFrame("Frame",nil,self,"BackdropTemplate")
    mainframe:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",healthHeight*(1+nbstunicons)+inset,0)
    mainframe:SetPoint("TOPRIGHT",self,"TOPRIGHT",-inset,0)
    mainframe:SetBackdrop({
        bgFile = "",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        insets = {left = 2, right = 2, top = 2, bottom = 2},
        edgeSize = 9,
    })
    mainframe:SetFrameLevel(self:GetFrameLevel()+4)
    self.mainframe = mainframe
end

function hpproto:CreateHealthBar()
    local inset = 2
    local healthbar = CreateFrame("Frame",nil,self.mainframe)
    healthbar:SetPoint("BOTTOMLEFT",self.mainframe,"BOTTOMLEFT",inset,inset)
    healthbar:SetPoint("TOPRIGHT",self.mainframe,"TOPRIGHT",-inset,-inset)

    local r1,g1,b1 = 0,0.25,0.125;
    local r2,g2,b2 = 0,0.75,0;
	local gradient = healthbar:CreateTexture(nil,"ARTWORK")
    gradient:SetAllPoints(true)
    gradient:SetTexture(1,1,1,1)
--	gradient:SetGradient("VERTICAL",r1,g1,b1,r2,g2,b2) -- @!!!
    healthbar.gradient = gradient

    healthbar:SetFrameLevel(self.mainframe:GetFrameLevel()-1)
    self.healthbar = healthbar
end

function hpproto:CreatePercent()
    local inset = 4
	local percent = self.mainframe:CreateFontString(nil,"OVERLAY")
	percent:SetFont(GameFontNormal:GetFont(),11)
	percent:SetPoint("RIGHT",self.mainframe,"RIGHT",-inset,0)
	percent:SetShadowOffset(1,-1)
	percent:SetShadowColor(0,0,0)
	self.percent = percent
end

function hpproto:CreateNameLabel()
    local inset = -1
	local namelabel = self.mainframe:CreateFontString(nil,"OVERLAY")
	namelabel:SetFont(GameFontNormal:GetFont(),7)
	namelabel:SetPoint("LEFT",self.mainframe,"LEFT",inset+healthHeight,0)
	namelabel:SetShadowOffset(1,-1)
	namelabel:SetShadowColor(0,0,0)
	self.namelabel = namelabel
end

function hpproto:CreateStunIcon()
    local inset = 1
    local stunicon = { last = 0 }
    for s=1,nbstunicons do
        local icon = self:CreateTexture(nil,"ARTWORK")
        icon:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",healthHeight*(s-1)+inset,0)
        icon:SetPoint("TOPRIGHT",self,"TOPLEFT",healthHeight*s+inset,0)
        local frame = CreateFrame("Frame",nil,self)
        frame:SetFrameLevel(self:GetFrameLevel()+4)
        frame:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",healthHeight*(s-1)+inset,0)
        frame:SetPoint("TOPRIGHT",self,"TOPLEFT",healthHeight*s+inset,0)
        frame:EnableMouse(true) -- for tooltips
        icon.frame = frame
        stunicon[s] = icon
    end
    self.stunicon = stunicon
end

function hpproto:CreateStunLabel()
	local stunlabel = self.mainframe:CreateFontString(nil,"OVERLAY")
	stunlabel:SetFont(GameFontNormal:GetFont(),12)
	stunlabel:SetPoint("LEFT",self,"LEFT",0,0)
	stunlabel:SetShadowOffset(1,-1)
	stunlabel:SetShadowColor(0,0,0)
    stunlabel:SetTextColor(0,1,0,1)
	self.stunlabel = stunlabel
end

function hpproto:CreateRaidIcon()
    local inset = 1
    local reduction = 3
    local raidicon = self.mainframe:CreateTexture(nil,"OVERLAY")
    raidicon:SetPoint("BOTTOMLEFT",self.mainframe,"BOTTOMLEFT",inset+reduction,reduction)
    raidicon:SetPoint("TOPRIGHT",self.mainframe,"TOPLEFT",inset+healthHeight-reduction,-reduction)
    raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    self.raidicon = raidicon
end

function hpproto:SetHP(health,total)
    if not self.healthbar then
        self:CreateHealthBar()
    end
    if not self.percent then
        self:CreatePercent()
    end
    self.health = health
    self.total = total
    if total > 0 then
        self.percent:SetText(math.floor(100*health/total).."%")
    else
        self.percent:SetText("")
    end
    self:UpdateSize()
end

function hpproto:SetName(name)
    if not self.namelabel then
        self:CreateNameLabel()
    end
    self.namelabel.text = name
	self.namelabel:SetText(name)
end

function hpproto:SetStun(spell, expiration, caster)
    if not self.stunicon then
        self:CreateStunIcon()
    end
    if not self.stunlabel then
        self:CreateStunLabel()
    end
    if spell == 0 then
        self.stunicon.last = 0
        for s=1,nbstunicons do
            self.stunicon[s]:SetAlpha(0)
            ResetTooltipText(self.stunicon[s].frame)
        end
        self.stunlabel:SetAlpha(0)
        return
    end
    self.stun = {
        spell = spell,
        expiration = expiration,
        caster = caster
    }
    local inset = 1
    local index = min(self.stunicon.last+1,nbstunicons)
    local spellname,_,icon = GetSpellInfo(spell)
    self.stunicon[index].icon = icon
    self.stunicon[index]:SetTexture(icon)
    self.stunicon[index]:SetAlpha(1)
    if index > 1 then
        self.stunicon[index-1]:SetAlpha(0.5)
    end
    self.stunicon.last = index
    self.stunlabel:SetPoint("LEFT",self,"LEFT",inset+healthHeight*index,0)
    self.stunlabel:SetAlpha(1)
    self.stunlabel.expiration = expiration
    self:UpdateStunDuration()

    local source = spellname -- @!!!
    local castername = UnitName(caster)
    if castername then
        source = source .. " ("..castername..")"
    end
    local duration = GetHumanReadableTime(max(expiration-GetTime(),0), true)

    AddTooltipText(self.stunicon[index].frame,castername,spellname.." ("..duration..")")
    
    if db.stun.showraid then
        local target = self.namelabel.text
        if self.raidicon and self.raidicon.raidicon > 0 then
            target = target .. " {rt"..self.raidicon.raidicon.."}"
        end
        local raidtext = string.format(SILK_STUN_RAID_MESSAGE, target, source, duration)
        Silk_ShowRaid(raidtext)
    end
end

function hpproto:SetRaidIcon(raidicon)
    raidicon = raidicon or 0
    if not self.raidicon then
        self:CreateRaidIcon()
    end
    self.raidicon.raidicon = raidicon
    if raidicon == 0 then
        self.raidicon:SetTexCoord(0,0,0,0)
    else
        local line = floor((raidicon-1)/4)
        local col = raidicon-1 - line*4
        local left,right,top,bottom = 0.25*col, 0.25*(1+col), 0.25*line, 0.25*(1+line)
        self.raidicon:SetTexCoord(left,right,top,bottom)
    end
end

function hpproto:Reset()
    self:Hide()
    self:SetHP(0,0)
    self:SetName("")
    self:SetRaidIcon(0)
    self:SetStun(0)
end

function hpproto:SetUnit(unit)
    local name = UnitName(unit)
    local health = UnitHealth(unit)
    local total = UnitHealthMax(unit)
    local raidicon = GetRaidTargetIndex(unit)

    self:Show()
    self:SetName(name)
    self:SetHP(health, total)
    self:SetRaidIcon(raidicon)
    self:SetStun(0)

    local guid = UnitGUID(unit)
    local record = records:GetRecord()
    record:SetHP(guid, health, total)
    record:SetRaidIcon(guid, raidicon)
end

function hpproto:UpdateUnit(unit)
    local health = UnitHealth(unit)
    local total = UnitHealthMax(unit)
    local raidicon = GetRaidTargetIndex(unit)

    self:SetHP(health, total)
    self:SetRaidIcon(raidicon)

    local guid = UnitGUID(unit)
    local record = records:GetRecord()
    record:SetHP(guid, health, total)
    record:SetRaidIcon(guid, raidicon)

    -- look into debuff lists to check if a stun is applied
    local i = 1
    local debuff, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unit, i)
    while debuff do
        for j,stunId in pairs(stunspells) do
            if spellId == stunId then
                if not self.stun or (self.stun.spell ~= spellId) or (self.stun.expiration ~= expirationTime) or (self.stun.caster ~= unitCaster) then
                    -- stun found, more precisely a new stun
                    self:SetStun(spellId, expirationTime, unitCaster)
                    local duration = max(expirationTime-GetTime(),0)
                    record:SetStun(guid, spellId, duration, UnitName(unitCaster))
                end
                return
            end
        end
        i = i + 1
        debuff,_,_,_,_,_,expirationTime,unitCaster,_,_,spellId = UnitDebuff(unit, i)
    end
end

function hpproto:UpdateStunDuration()
    if self.stunlabel and self.stunlabel.expiration then
        self.stunlabel:SetText(GetRemainingTime(self.stunlabel.expiration))

        local currentTime = GetTime()
        if currentTime > self.stunlabel.expiration then
            local alpha = 1 - 0.5*(currentTime - self.stunlabel.expiration)
            alpha = max(min(alpha,1),0)
            self.stunlabel:SetAlpha(alpha)
            if self.stunicon and (self.stunicon.last > 0) then
                self.stunicon[self.stunicon.last]:SetAlpha(max(alpha,0.5))
            end
        end
    end
end

function hpproto:Update()
    self:UpdateStunDuration()
end

function hpproto:UpdateSize()
    if self.healthbar then
        if self.total > 0 then
            local minhealth = self.minhealth or 0
            local maxhealth = self.maxhealth or 1
            local width = self.healthbar:GetWidth()*(1/(maxhealth-minhealth))*(min(max(self.health/self.total,minhealth),maxhealth)-minhealth) -- minhealth% - maxhealth%
            self.healthbar.gradient:SetPoint("RIGHT",self.healthbar,"LEFT",width,0)
        else
            self.healthbar.gradient:SetPoint("RIGHT",self.healthbar,"LEFT",0,0)
        end
    end
end

-- inspired by DXE's health panels
function Silk_CreateHealthPanels(window,minhealth,maxhealth)
    window.hp = {}
	for i=1,3 do
		local hp = CreateFrame("Frame",nil,window.container)
        hp:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-healthHeight*(i-1))
        hp:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-healthHeight*i)

        for k,v in pairs(hpproto) do hp[k]=v end

        hp.minhealth = minhealth
        hp.maxhealth = maxhealth

        hp:CreateMainFrame()

        hp:Hide()

		window.hp[i] = hp
	end
end

-------------------------
-- UNIT TRACKER FUNCTIONS
-------------------------

local tracker = {
    unit = {},
    localwindowname = windowname.valkyr,
    defaultnpcid = 36609  -- real Val'kyr ID
}

local sctracker = nil
local catracker = nil
local sktracker = nil

function tracker:UnitIsValkyr(unit)
    local guid = UnitGUID(unit)
    local npcid = tonumber("0x"..guid:sub(7,10))
    if customnpcid then
        return npcid == customnpcid
    else
        return npcid == self.defaultnpcid
    end
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
        Silk_Debug("Unit casted something")
    end
    self.unit[guid].health = health
    self.unit[guid].touch = GetTime()

    if self.unit[guid].obsolete then
        self:UnregisterFromWindow(unit)
        records:GetRecord():Forget(guid)
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
    return windows[self.localwindowname]
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
                Silk_Debug("Tracking : "..guid)
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
            Silk_Debug("Untracking : "..guid)
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
    if not self.unit[guid].obsolete and (GetTime() > (self.unit[guid].touch + db.timeout)) then
        self.unit[guid].obsolete = true
        self:UnregisterFromWindowByGUID(guid)
        records:GetRecord():Forget(guid)
        Silk_Debug("Timeout on : "..guid)
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
                records:GetRecord():Forget(guid)
            end
            self.unit = {}
        end
        if records:GetLastRecord() and records:GetLastRecord().recording then
            records:GetLastRecord():End()
            Silk_Debug("Record stopped")
            Silk_UpdateTimeLines()
        end
        return
    end

    local units = {}

    -- look for every target val'kyr, but do not report the same val'kyr twice
    if UnitExists("target") and self:UnitIsValkyr("target") then
        units["target"] = true  -- always insert self target first
    end
    for i=1,40 do
        local unit = "raid"..i.."target"
        if UnitExists(unit) and self:UnitIsValkyr(unit) then
            local exists = false
            for u in pairs(units) do
                if UnitIsUnit(unit,u) then
                    exists = true
                    break
                end
            end
            if not exists then
                units[unit] = true
            end
        end
    end
    for i=1,5 do
        local unit = "boss"..i
        if UnitExists(unit) and self:UnitIsValkyr(unit) then
            local exists = false
            for u in pairs(units) do
                if UnitIsUnit(unit,u) then
                    exists = true
                    break
                end
            end
            if not exists then
                units[unit] = true
            end
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

function Silk_CreateTracker(name, npcid)
    local newtracker = {}
    for k,v in pairs(tracker) do
        newtracker[k] = v
    end
    newtracker.unit = {}
    newtracker.localwindowname = name
    newtracker.defaultnpcid = npcid
    newtracker.CheckUnitObsolete = function(self, unit)
        local guid = UnitGUID(unit)
        local health = UnitHealth(unit)
        self.unit[guid].health = health
        self.unit[guid].touch = GetTime()
    
        if self.unit[guid].obsolete then
            self:UnregisterFromWindow(unit)
            records:GetRecord():Forget(guid)
        end
    end
    return newtracker
end

function Silk_CreateSCTracker()
    sctracker = Silk_CreateTracker(windowname.spitecaller, 48415) -- Spitecaller ID
end

function Silk_CreateCATracker()
    catracker = Silk_CreateTracker(windowname.adherent, 43622) -- Corrupting Adherent ID
end

function Silk_CreateSKTracker()
    sktracker = Silk_CreateTracker(windowname.sk, 60710) -- Subetai the Swift ID
--[[
return -- Return now because the code below is untested
end
function Silk_Untested()
--]]
    sktracker.CheckUnitObsolete = function(self, unit)
        local guid = UnitGUID(unit)
        local health = UnitHealth(unit)

        self.unit[guid].health = health
        self.unit[guid].touch = GetTime()

        -- Check if unit stun is available again
        local index = self.unit[guid].index
        local window = self:GetValkyrWindow()
        if window and index > 0 then
            local hp = window.hp[index]
            if hp.stunicon.last > 0 and (GetTime() > (hp.stunlabel.expiration+15)) then
                hp:SetStun(0)
                Silk_Debug("Unit DR reset")
            end
        end

        if self.unit[guid].obsolete then
            self:UnregisterFromWindow(unit)
            records:GetRecord():Forget(guid)
        end
    end
end

----------------
-- AAA FUNCTIONS
----------------

local tlproto = {}

function tlproto:CreateUnitFrame()
    local inset = healthInset
    local bgframe = CreateFrame("Frame",nil,self)
    bgframe:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",inset+self:GetHeight(),0)
    bgframe:SetPoint("TOPRIGHT",self,"TOPRIGHT",-inset,0)
    bgframe:SetFrameLevel(self:GetFrameLevel()+2)
    self.bgframe = bgframe

    local unitframe = CreateFrame("Frame",nil,bgframe)
    unitframe:SetAllPoints(true)
    unitframe:SetFrameLevel(bgframe:GetFrameLevel()+2)
    unitframe:Hide()
    unitframe:SetBackdrop({
        bgFile = "",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        insets = {left = 1, right = 1, top = 1, bottom = 1},
        edgeSize = 9,
    })
    self.unitframe = unitframe
end

function tlproto:CreateStunFrames()
    local inset = 2
    local bgframe = self.bgframe
    self.stunframe = {}
    for i=1,nbstunicons do
        local stunframe = CreateFrame("Frame",nil,bgframe)
        stunframe:SetFrameLevel(bgframe:GetFrameLevel()+4)
        stunframe:Hide()
        stunframe:SetBackdrop({
            bgFile = "",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            insets = {left = 1, right = 1, top = 1, bottom = 1},
            edgeSize = 9,
        })
        stunframe:EnableMouse(true) -- for tooltips

        local icon = stunframe:CreateTexture(nil,"OVERLAY")
        icon:SetPoint("BOTTOMLEFT",stunframe,"BOTTOMLEFT",inset,inset)
        icon:SetPoint("TOPRIGHT",stunframe,"TOPLEFT",bgframe:GetHeight()-2*inset-inset,-inset)
        stunframe.icon = icon

        self.stunframe[i] = stunframe
    end
end

function tlproto:CreateUnitIcon()
    local inset = healthInset
    uniticon = self:CreateTexture(nil,"OVERLAY")
    uniticon:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",inset,inset)
    uniticon:SetPoint("TOPRIGHT",self,"TOPLEFT",-inset+self:GetHeight(),-inset)
    uniticon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    uniticon:SetTexCoord(0,0,0,0)
    self.uniticon = uniticon
end

function tlproto:SetUnitTimes(starts, ends, verystart, veryend)
    verystart = verystart or starts
    veryend = veryend or ends

    if not self.unitframe then
        self:CreateUnitFrame()
    end

    local unitframe = self.unitframe
    local bgframe = self.bgframe
    local x0, x1 = 0, bgframe:GetWidth()
    if (ends > starts) and (veryend > verystart) then
        x0 = x1 * (starts-verystart) / (veryend-verystart)
        x1 = x1 * (ends-verystart) / (veryend-verystart)
    end
--    Silk_Debug("getwidth=="..bgframe:GetWidth().." x0=="..x0.." x1=="..x1)
    unitframe:SetPoint("BOTTOMLEFT",bgframe,"BOTTOMLEFT",x0,0)
    unitframe:SetPoint("TOPRIGHT",bgframe,"TOPLEFT",x1,0)

    unitframe:Show()
end

function tlproto:SetStun(index, spell, starts, duration, caster, verystart, veryend)
    if not self.stunframe then
        self:CreateStunFrames()
    end

    local stunframe = self.stunframe[index]
    if spell == 0 then
        stunframe:Hide()
        stunframe.icon:SetAlpha(0)
        return
    end

    local bgframe = self.bgframe
    local x0, x1 = 0, bgframe:GetWidth()
    if (duration >= 0) and (veryend > verystart) then
        x0 = x1 * (starts-verystart) / (veryend-verystart)
        x1 = x1 * (starts+duration-verystart) / (veryend-verystart)
--        Silk_Debug("getwidth=="..bgframe:GetWidth().." x0=="..x0.." x1=="..x1)
    else
        return
    end
    local inset = 2
    stunframe:SetPoint("BOTTOMLEFT",bgframe,"BOTTOMLEFT",x0,inset)
    stunframe:SetPoint("TOPRIGHT",bgframe,"TOPLEFT",x1,-inset)

    local spellname,_,icon = GetSpellInfo(spell)
    stunframe.icon:SetTexture(icon)
    stunframe.icon:SetAlpha(1)

    local title = caster
    local text = spellname.." ("..GetHumanReadableTime(max(duration,0), true)..")"
    AddTooltipText(stunframe,title,text)

    stunframe:Show()
end

function tlproto:SetRaidIcon(raidicon)
    raidicon = raidicon or 0
    if not self.uniticon then
        self:CreateUnitIcon()
    end
    if raidicon == 0 then
        self.uniticon:SetTexCoord(0,0,0,0)
    else
        local line = floor((raidicon-1)/4)
        local col = raidicon-1 - line*4
        local left,right,top,bottom = 0.25*col, 0.25*(1+col), 0.25*line, 0.25*(1+line)
        self.uniticon:SetTexCoord(left,right,top,bottom)
    end
end

function tlproto:Clear()
    if self.unitframe then
        self.unitframe:Hide()
    end
    if self.uniticon then
        self.uniticon:SetTexCoord(0,0,0,0)
    end
    if self.stunframe then
        for i=1,nbstunicons do
            self.stunframe[i]:Hide()
            self.stunframe[i].icon:SetAlpha(0)
        end
    end
end

function Silk_GetAAAWindow()
    return windows[windowname.aaa]
end

function Silk_UpdateTimeLineControls()
    window = Silk_GetAAAWindow()
    if not window then return end

    window.tlc.valkyrlabel:SetFormattedText(SILK_VALKYR_X_ON_Y, window.currentcolumn, #window.column)

    local mincolumn = min(1,#window.column)
    if window.currentcolumn <= mincolumn then
        window.tlc.lbutton:Disable()
    else
        window.tlc.lbutton:Enable()
    end

    local maxcolumn = #window.column
    if window.currentcolumn >= maxcolumn then
        window.tlc.rbutton:Disable()
    else
        window.tlc.rbutton:Enable()
    end
end

function Silk_ShowTimeLineColumn()
    window = Silk_GetAAAWindow()
    if not window then return end

    if not window.currentcolumn or not window.column then return end

    -- show column here
    local interval = window.column[window.currentcolumn]
    Silk_Debug("Showing "..#interval.units.." unit(s), living from "..interval.starts.." (earliest) up to "..interval.ends.." (latest)")
	for i=1,3 do
        local tl = window.tl[i]
        if i <= #interval.units then
            local guid = interval.units[i]
            local unit = window.record.unit[guid]
            tl:SetRaidIcon(unit.raidicon)
            local starts = unit.created
            local ends = max(unit.forgotten, unit.killed)
            if ends < 0 then ends = interval.ends end
            tl:SetUnitTimes(starts, ends, interval.starts, interval.ends)
            for j=1,nbstunicons do
                local stun = unit.stun[j]
                if stun then
--                    Silk_Debug("Showing stun spell "..stun.spell.." from "..stun.started.." during "..stun.duration.."secs by caster "..stun.caster)
                    tl:SetStun(j, stun.spell, stun.started, stun.duration, stun.caster, interval.starts, interval.ends)
                else
                    tl:SetStun(j,0)
                end
            end
        else
            tl:Clear()
        end
    end
end

function Silk_SetTimeLines(record)
    window = Silk_GetAAAWindow()
    if not window then return end

    Silk_Debug("Setting record "..record.name)
    window.record = record

    if not window.currentcolumn then
        window.currentcolumn = 0
    end
    local column = window.currentcolumn

    window.column = {}

    -- get the begin/end pair for every unit
    local ends = record.ends
    if ends < 0 then ends = GetTime() end
    local units = {}
    for guid,u in pairs(record.unit) do
        local created = u.created
        local forgotten = u.forgotten
        local killed = u.killed
        local beginning = created
        local ending = ends
        if (forgotten > 0) or (killed > 0) then
            ending = max(forgotten, killed)
        end
        units[#units+1] = {
            guid = guid,
            starts = beginning,
            ends = ending
        }
    end
    Silk_Debug("Found "..#units.." unit(s) for interval candidates")

    -- unite units with compatible begin/end pair
    local intervals = {}
    for i,unit in pairs(units) do
        local compatibleindex = -1
        for j,interval in pairs(intervals) do
            if (unit.starts < interval.ends) and (unit.ends > interval.starts) then
                compatibleindex = j
                break
            end
        end
        if compatibleindex < 0 then
            -- not interval compatible, creating a new one
            intervals[#intervals+1] = {
                starts = unit.starts,
                ends = unit.ends,
                units = { unit.guid }
            }
        else
            -- interval comatible, merging interval with unit
            local interval = intervals[compatibleindex]
            interval.starts = min(interval.starts, unit.starts)
            interval.ends = max(interval.ends, unit.ends)
            interval.units[#interval.units+1] = unit.guid
        end
    end

    Silk_Debug("Found "..#intervals.." distinct interval(s)")

    -- sorting intervals by the starting point
    table.sort(intervals, function(i1, i2) return i1.starts < i2.starts end)

    window.column = intervals

    local mincolumn = min(1,#window.column)
    local maxcolumn = #window.column
    if (window.currentcolumn < mincolumn) then
        window.currentcolumn = mincolumn
    elseif (window.currentcolumn > maxcolumn) then
        window.currentcolumn = maxcolumn
    end

    Silk_ShowTimeLineColumn()
    Silk_UpdateTimeLineControls()
end

function Silk_UpdateTimeLines()
    window = Silk_GetAAAWindow()
    if not window then return end

    if not window.record then return end
    Silk_SetTimeLines(window.record)
end

function Silk_PrevUnit()
    window = Silk_GetAAAWindow()
    if not window then return end

    if not window.currentcolumn or not window.column then return end

    if (#window.column > 0) and (window.currentcolumn-1 >= 1) then
        window.currentcolumn = window.currentcolumn - 1
        Silk_ShowTimeLineColumn()
        Silk_UpdateTimeLineControls()
    end
end

function Silk_NextUnit()
    window = Silk_GetAAAWindow()
    if not window then return end

    if not window.currentcolumn or not window.column then return end

    if (#window.column > 0) and (window.currentcolumn+1 <= #window.column) then
        window.currentcolumn = window.currentcolumn + 1
        Silk_ShowTimeLineColumn()
        Silk_UpdateTimeLineControls()
    end
end

function Silk_CreateTimeLines(window)
    -- Time Lines
    window.tl = {}
	for i=1,3 do
		local tl = CreateFrame("Frame",nil,window.container)
        tl:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-healthHeight*(i-1))
        tl:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-healthHeight*i)

        for k,v in pairs(tlproto) do tl[k]=v end

        tl:CreateUnitFrame()
        tl:CreateUnitIcon()

--        tl:Hide()

		window.tl[i] = tl
	end

    -- Time Line Controller
    local tlc = CreateFrame("Frame",nil,window.container)
    tlc:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-healthHeight*3)
    tlc:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-healthHeight*4)

    local arrowButtonInset = 3
    local lbutton = CreateFrame("Button",nil,tlc)
    lbutton:SetPoint("BOTTOMLEFT",tlc,"BOTTOMLEFT",arrowButtonInset,arrowButtonInset)
    lbutton:SetPoint("TOPRIGHT",tlc,"TOPLEFT",healthHeight-arrowButtonInset,-arrowButtonInset)
    lbutton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    lbutton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    lbutton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    lbutton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    lbutton:SetScript("OnClick", Silk_PrevUnit)
    lbutton:Disable()
    lbutton.window = window
    tlc.lbutton = lbutton

    local rbutton = CreateFrame("Button",nil,tlc)
    rbutton:SetPoint("BOTTOMLEFT",tlc,"BOTTOMRIGHT",-healthHeight+arrowButtonInset,arrowButtonInset)
    rbutton:SetPoint("TOPRIGHT",tlc,"TOPRIGHT",-arrowButtonInset,-arrowButtonInset)
    rbutton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    rbutton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    rbutton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
    rbutton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    rbutton:SetScript("OnClick", Silk_NextUnit)
    rbutton:Disable()
    rbutton.window = window
    tlc.rbutton = rbutton

    local recorddropdown = CreateFrame("Frame", "SilkRecordDropDown", tlc, "UIDropDownMenuTemplate")
    recorddropdown:SetPoint("BOTTOMLEFT",tlc,"BOTTOMLEFT",healthHeight,0)
    recorddropdown:SetPoint("TOPRIGHT",tlc,"TOP",0,0)
    recorddropdown:SetScale(healthHeight / recorddropdown:GetHeight())
    UIDropDownMenu_Initialize(recorddropdown,
    function(self,level)
        local info = UIDropDownMenu_CreateInfo()
        info.hasArrow = false
        info.checked = false
        info.func = function()
            UIDropDownMenu_SetText(recorddropdown, self:GetText())
            local record = records[self:GetID()]
            Silk_SetTimeLines(record)
            if SilkExport and (SilkExport == 1) then
                if not ChatFrameEditBox:IsVisible() then
                    ChatFrameEditBox:Show()
                    ChatFrameEditBox:SetText(record:ToString())
                else
                    ChatFrameEditBox:Insert(" "..record:ToString())
                end
            end
        end
        for i=1,#records do
            local record = records[i]
            info.text = record.name
            info.value = { ["Level1_Key"] = record.name; }
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    tlc.recorddropdown = recorddropdown

    local valkyrlabel = tlc:CreateFontString(nil,"OVERLAY")
	valkyrlabel:SetFont(GameFontNormal:GetFont(),9)
	valkyrlabel:SetPoint("LEFT",tlc,"CENTER",0,0)
	valkyrlabel:SetShadowOffset(1,-1)
	valkyrlabel:SetShadowColor(0,0,0)
    valkyrlabel:SetFormattedText(SILK_VALKYR_X_ON_Y, 0, 0)
	tlc.valkyrlabel = valkyrlabel
    
    window.tlc = tlc

    -- adjust min-resize settings
    -- local w,h = window:GetMinResize()
    -- h = h+tlc:GetHeight()
    -- window:SetMinResize(w,h) -- @!!!
    -- if window:GetHeight() < h then
    --     window:SetHeight(h)
    -- end
end

-------------------
-- HALION FUNCTIONS
-------------------

local halionproto = {}

function halionproto:CreateIcon()
    local inset = halionInset
    local reduction = 6
    icon = self:CreateTexture(nil,"OVERLAY")
    icon:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",inset+reduction,reduction)
    icon:SetPoint("TOPRIGHT",self,"TOPLEFT",inset+halionHeight-reduction,-reduction)
    self.icon = icon
end

function halionproto:CreateBuffLabel()
    local leftmargin = 5
	local bufflabel = self:CreateFontString(nil,"OVERLAY")
	bufflabel:SetFont(GameFontNormal:GetFont(),12)
	bufflabel:SetPoint("LEFT",self,"LEFT",halionHeight+leftmargin,0)
	bufflabel:SetShadowOffset(1,-1)
	bufflabel:SetShadowColor(0,0,0)
    bufflabel:SetTextColor(0,1,0,1)
	self.bufflabel = bufflabel
end

function halionproto:SetMandatoryBuff(spellid)
    self.mandatory = spellid
end

function halionproto:SetForbiddenBuff(spellid)
    self.forbidden = spellid
end

function halionproto:SetZeroBuff(spellid)
    self.zero = spellid
end

function halionproto:SetIcon(texture)
    if not self.icon then
        self:CreateIcon()
    end
    self.icon:SetTexture(texture)
    self.icon.texture = texture
end

function halionproto:SetBuff(percent)
    if not self.bufflabel then
        self:CreateBuffLabel()
    end
    if not percent then
        self.bufflabel:SetTextColor(0.5,0.5,0.5,1) -- grey
        self.bufflabel:SetText("?? %")
if self.bufflabel.percent ~= percent then
Silk_Message("Telling ?? for "..self.name)
end
    elseif percent > 0 then
        self.bufflabel:SetTextColor(1,0,0,1) -- red
        self.bufflabel:SetText("+"..percent.." %")
if self.bufflabel.percent ~= percent then
Silk_Message("Telling >0 for "..self.name)
end
    elseif percent < 0 then
        self.bufflabel:SetTextColor(0,1,0,1) -- green
        self.bufflabel:SetText(percent.." %")
if self.bufflabel.percent ~= percent then
Silk_Message("Telling <0 for "..self.name)
end
    else
        self.bufflabel:SetTextColor(1,1,0,1) -- yellow
        self.bufflabel:SetText("0 %")
if self.bufflabel.percent ~= percent then
Silk_Message("Telling 0 for "..self.name)
end
    end
    self.bufflabel.percent = percent
end

function halionproto:UpdateUnit(unit)
    -- mandates a specific buff if required
    if self.mandatory then
        local i = 1
        local b,_,_,_,_,_,_,_,_,_,s=UnitBuff(unit,i)
        while b and (s ~= self.mandatory) do
            i = i+1
            b,_,_,_,_,_,_,_,_,_,s = UnitBuff(unit,i)
        end
        if not b or s ~= self.mandatory then
            return false
        end
    end

    -- disallows a specific buff if required
    if self.forbidden then
        local i = 1
        local b,_,_,_,_,_,_,_,_,_,s=UnitBuff(unit,i)
        while b and (s ~= self.forbidden) do
            i = i+1
            b,_,_,_,_,_,_,_,_,_,s = UnitBuff(unit,i)
        end
        if b and s == self.forbidden then
            return false
        end
    end

    -- 0% buff if known
    if self.zero then
        local i = 1
        local b,_,_,_,_,_,_,_,_,_,s=UnitBuff(unit,i)
        while b and (s ~= self.zero) do
            i = i+1
            b,_,_,_,_,_,_,_,_,_,s = UnitBuff(unit,i)
        end
        if b and s == self.zero then
            if not self.bufflabel or not self.bufflabel.percent or (self.bufflabel.percent ~= 0) then
                self:SetBuff(0)
            end
            return true
        end
    end

    local percent = nil
    local i = 1
    local b = UnitBuff(unit,i)
    while b do
        local tt=CorpoTooltip
        tt:SetUnitBuff(unit,i)
        for i=1,tt:NumLines() do
            local t=getglobal("CorpoTooltipTextLeft"..i)
            local T=string.lower(t:GetText())
            if T:match(SILK_INCREASE_MATCH..".* %d+%%.*"..SILK_DECREASE_MATCH) then
                percent = tonumber(T:match(SILK_INCREASE_MATCH..".*( %d+)%%.*"..SILK_INCREASE_MATCH))
                break
            elseif T:match(SILK_DECREASE_MATCH..".* %d+%%.*"..SILK_INCREASE_MATCH) then
                percent = -tonumber(T:match(SILK_DECREASE_MATCH..".*( %d+)%%.*"..SILK_DECREASE_MATCH))
                break
            end
        end
        tt:Hide()
        if percent then
            break
        end
        i = i+1
        b = UnitBuff(unit,i)
    end
    
    if not percent then
        -- unable to decipher buffs
        return false
    end

    if not self.bufflabel or not self.bufflabel.percent or (self.bufflabel.percent ~= percent) then
Silk_Message("Applying "..percent.." ("..type(percent)..")")
        self:SetBuff(percent)
        self:SetBuff(0)
    end

    return true
end

function Silk_CreateHalionPanels(window)
    window.halion = {}
    local topPoint = 0

	local hfire = CreateFrame("Frame",nil,window.container)
    hfire:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-topPoint)
    hfire:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-(topPoint+halionHeight))
    for k,v in pairs(halionproto) do hfire[k]=v end
    hfire:SetForbiddenBuff(75476) -- forbidden buff in fire form
    hfire:SetZeroBuff(74826) -- buff respresenting 0%
    hfire:SetIcon("Interface\\Icons\\inv_misc_head_dragon_01")
    hfire.name="Fire"-- for testing purposes
--    hfire:SetBuff(nil) -- initialize buff with ??%
    window.halion[1] = hfire

    topPoint = topPoint+halionHeight

	local hshadow = CreateFrame("Frame",nil,window.container)
    hshadow:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-topPoint)
    hshadow:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-(topPoint+halionHeight))
    for k,v in pairs(halionproto) do hshadow[k]=v end
    hshadow:SetMandatoryBuff(75476) -- special buff in shadow form
    hshadow:SetZeroBuff(74826) -- buff respresenting 0%
    hshadow:SetIcon("Interface\\Icons\\inv_misc_head_dragon_black")
    hshadow.name="Shadow"-- for testing purposes
--    hshadow:SetBuff(nil) -- initialize buff with ??%
    window.halion[2] = hshadow

    -- adjust min-resize settings
    -- local width = 50
    -- local height = 2*titleBarInset+titleHeight+2*halionHeight+1
    -- window:SetMinResize(width,height) -- @!!!
end

function Silk_UpdateHalionPanels(window)
    if UnitAffectingCombat("player") then
        window.incombat = true
    else
        if window.incombat then
            for i=1,2 do
                local hpanel = window.halion[i]
                hpanel:SetBuff(nil) -- buff with ??%
            end
            window.incombat = nil
        end
        return
    end

    local units = {}
    local targetname = "Halion"
--    local targetname = "Mannequin d'entraînement de grand maître" -- for testing purposes
--    local targetname = "Vinny" -- for testing purposes

    -- look for every target Halion, but do not report the same Halion twice
    if UnitExists("target") and (UnitName("target") == targetname) then
        units["target"] = true  -- always insert self target first
    end
    for i=1,40 do
        local unit = "raid"..i.."target"
        if UnitExists(unit) and (UnitName(unit) == targetname) then
            local exists = false
            for u in pairs(units) do
                if UnitIsUnit(unit,u) then
                    exists = true
                    break
                end
            end
            if not exists then
                units[unit] = true
            end
        end
    end

    -- iterate through all reported Halion and update them for all Halion panels
    for i=1,2 do
        local hpanel = window.halion[i]
        local updated = false
        for u in pairs(units) do
            updated = updated or hpanel:UpdateUnit(u)
        end
        if not updated then
            -- no update for this panel : mark as unknown
            hpanel:SetBuff(nil)
        end
    end
end


---------------------------
-- GENERIC WINDOW FUNCTIONS
---------------------------

-- inspired by DXE's CreateWindow
function Silk_CreateWindow(name)
	--[===[@debug@
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")
	--@end-debug@]===]
    local width = 50
    local height = 2*titleBarInset+titleHeight+3*healthHeight+1

	local properName = name:gsub(" ",""):gsub("'","")

	local window = CreateFrame("Frame","SilkWindow"..properName,UIParent,"BackdropTemplate")
	window:SetWidth(width)
	window:SetHeight(height)
	window:SetMovable(true)
	window:SetClampedToScreen(true)
	window:SetResizable(true)
--	window:SetMinResize(width,height) -- @!!!
    window:SetPoint("CENTER")
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        insets = {left = 2, right = 2, top = 2, bottom = 2},
        edgeSize = 9,
    })

    -- Inside
	-- Important: Make sure faux_window:GetEffectiveScale() == UIParent:GetEffectiveScale() on creation
	local faux_window = CreateFrame("Frame","SilkWindow"..properName.."Frame",window)
	faux_window:SetWidth(width)
	faux_window:SetHeight(height)
--	addon:RegisterBackground(faux_window)
	faux_window:SetPoint("TOPLEFT")
	window.faux_window = faux_window

	local corner = CreateFrame("Frame", nil, faux_window)
	corner:SetFrameLevel(faux_window:GetFrameLevel() + 9)
	corner:EnableMouse(true)
	corner:SetScript("OnMouseDown", handlers.Corner_OnMouseDown)
	corner:SetScript("OnMouseUp", handlers.Corner_OnMouseUp)
	corner:SetHeight(12)
	corner:SetWidth(12)
	corner:SetPoint("BOTTOMRIGHT")
	corner.t = corner:CreateTexture(nil,"ARTWORK")
	corner.t:SetAllPoints(true)
	corner.t:SetTexture("Interface\\Addons\\SiLK\\icons\\ResizeGrip.tga") -- taken from DXE
	AddTooltipText(corner,SILK_RESIZE_TOOLTIP)
	corner.window = window

	-- Border
	local border = CreateFrame("Frame",nil,faux_window)
	border:SetAllPoints(true)
	border:SetFrameLevel(border:GetFrameLevel()+10)
--	addon:RegisterBorder(border)

	-- Title Bar
	local titlebar = CreateFrame("Frame",nil,faux_window)
	titlebar:SetPoint("TOPLEFT",faux_window,"TOPLEFT",titleBarInset,-titleBarInset)
	titlebar:SetPoint("BOTTOMRIGHT",faux_window,"TOPRIGHT",-titleBarInset, -(titleHeight+titleBarInset))
	titlebar:EnableMouse(true)
	titlebar:SetMovable(true)
    titlebar:SetScript("OnMouseDown",handlers.Title_OnMouseDown)
    titlebar:SetScript("OnMouseUp",handlers.Title_OnMouseUp)
	AddTooltipText(titlebar,SILK_MOVE_TOOLTIP)
--	self:RegisterMoveSaving(titlebar,"CENTER","UIParent","CENTER",0,0,true,window)
    titlebar.window = window

	local gradient = titlebar:CreateTexture(nil,"ARTWORK")
	local r,g,b,a = 0.25,0.7,1,1;
	gradient:SetAllPoints(true)
	gradient:SetTexture(r,g,b,a)
--	gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0) -- @!!!
	window.gradient = gradient

	local titletext = titlebar:CreateFontString(nil,"OVERLAY")
	titletext:SetFont(GameFontNormal:GetFont(),8)
	titletext:SetPoint("LEFT",titlebar,"LEFT",5,0)
	titletext:SetText(name)
	titletext:SetShadowOffset(1,-1)
	titletext:SetShadowColor(0,0,0)
	window.titletext = titletext

	local close = CreateFrame("Button",nil,faux_window)
	close:SetFrameLevel(close:GetFrameLevel()+5)
	close:SetScript("OnClick",handlers.Close_OnClick)
	close.t = close:CreateTexture(nil,"ARTWORK")
	close.t:SetAllPoints(true)
	close.t:SetTexture("Interface\\Addons\\SiLK\\icons\\X.tga") -- taken from DXE
	close.t:SetVertexColor(0.33,0.33,0.33)
	close:SetScript("OnEnter",handlers.Button_OnEnter)
	close:SetScript("OnLeave",handlers.Button_OnLeave)
	AddTooltipText(close,SILK_CLOSE_TOOLTIP)
	close:SetWidth(buttonSize)
	close:SetHeight(buttonSize)
	close:SetPoint("RIGHT",titlebar,"RIGHT")
    close.window = window

	window.lastbutton = close

	-- Container
	local container = CreateFrame("Frame",nil,faux_window)
	container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-titleHeight-titleBarInset)
	container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
	window.container = container

	-- Content
--	local content = CreateFrame("Frame",nil,container)
--	content:SetPoint("TOPLEFT",container,"TOPLEFT")
--	content:SetPoint("BOTTOMRIGHT",container,"BOTTOMRIGHT")
--	window.content = content

--	for k,v in pairs(prototype) do window[k] = v end

	windows[name] = window

--	self:RegisterDefaultScale(faux_window)
--	self:RegisterDefaultDimensions(window)
--	self:RegisterDefaultDimensions(faux_window)

    futils:LoadPosition(window)
	futils:LoadScale(faux_window)
	futils:LoadPosition(window)
	futils:LoadDimensions(window)
	futils:LoadDimensions(faux_window)

	window.ratio = window:GetHeight() / window:GetWidth()
	window:SetScript("OnSizeChanged", handlers.Anchor_OnSizeChanged)

	window.callbacks = {}

	return window
end

function Silk_CreateWindowContents(window, name)
    if name == windowname.valkyr then
        Silk_CreateHealthPanels(window,0.5,1) -- 50% - 100%
    elseif name == windowname.spitecaller then
        Silk_CreateHealthPanels(window,0,1) -- 0% - 100%
    elseif name == windowname.adherent then
        Silk_CreateHealthPanels(window,0,1) -- 0% - 100%
    elseif name == windowname.sk then
        Silk_CreateHealthPanels(window,0,1) -- 0% - 100%
    elseif name == windowname.aaa then
        Silk_CreateTimeLines(window)
    elseif name == windowname.corpo then
        Silk_CreateHalionPanels(window)
    end
end


function Silk_RestoreWindows()
    for n,v in pairs(db.visible) do
        if v.show then
            window = windows[v.name]
            if window == nil then
                window = Silk_CreateWindow(v.name)
                Silk_CreateWindowContents(window, v.name)
            end
            window:Show()
        end
    end
end

function Silk_ShowWindow(rawname, creator)
    local window = windows[rawname]
    if window == nil then
        window = Silk_CreateWindow(rawname)
        Silk_CreateHealthPanels(window)
    end
    window:Show()
    db.visible[window:GetName()] = { show = true, name = rawname }
end

function Silk_TestWindow()
    local rawname = windowname.valkyr
--    local rawname = windowname.spitecaller
--    local rawname = windowname.sk
    valkyrwindow = windows[rawname]
    if valkyrwindow == nil then
        Silk_Warning(SILK_CANT_TEST)
        return
    end

    local hp = valkyrwindow.hp

    for i=1,3 do
        if not hp[i]:IsShown() then hp[i]:Show() end
        local health = 400+math.random(60)*10
        local total = 1000
        local raidicon = math.random(3)+3*(i-1)-1
        local spell = stunspells[math.random(#stunspells)]
        while not GetSpellInfo(spell) do -- In case we fetch spell from a wrong expansion
            spell = stunspells[math.random(#stunspells)]
        end
        local duration = math.random(6)/math.random(3)
        hp[i]:SetHP(health,total)
        hp[i]:SetName("Val'kyr")
        hp[i]:SetRaidIcon(raidicon)
        hp[i]:SetStun(spell, GetTime()+duration, "player")

        local guid = UnitGUID("player")
        local record = records:GetRecord()
        record:SetHP(guid, health, total)
        record:SetRaidIcon(guid, raidicon)
        record:SetStun(guid, spell, duration, UnitName("player"))
	end

end

-------------------
-- GLOBAL FUNCTIONS
-------------------

function Silk_ToggleStunShowRaid()
    db.stun.showraid = not db.stun.showraid
    if db.stun.showraid then
        Silk_Message(SILK_STUN_SHOWRAID_ENABLED)
    else
        Silk_Message(SILK_STUN_SHOWRAID_DISABLED)
    end
end

function Silk_Invoke(cmd)
  if cmd == "" then
    Silk_ShortHelp();
  elseif string.lower(cmd) == "help" then
    Silk_Help();
  elseif string.lower(cmd) == "enable" then
    db.enabled = true;
  elseif string.lower(cmd) == "disable" then
    db.enabled = false;
  elseif string.lower(cmd) == "show" then
    Silk_ShowWindow(windowname.valkyr, Silk_CreateHealthPanels)
  elseif string.lower(cmd) == "sc" or string.lower(cmd) == "spitecaller" then
    Silk_ShowWindow(windowname.spitecaller, Silk_CreateHealthPanels)
  elseif string.lower(cmd) == "ca" or string.lower(cmd) == "adherent" then
    Silk_ShowWindow(windowname.adherent, Silk_CreateHealthPanels)
  elseif string.lower(cmd) == "sk" then
    Silk_ShowWindow(windowname.sk, Silk_CreateHealthPanels)
  elseif string.lower(cmd) == "aaa" then
    Silk_ShowWindow(windowname.aaa, Silk_CreateTimeLines)
  elseif string.lower(cmd) == "corpo" then
    Silk_ShowWindow(windowname.corpo, Silk_CreateHalionPanels)
  elseif string.lower(cmd) == "reset" then
    Silk_ResetRecords()
  elseif string.lower(cmd) == "resetwin" then
    futils.ResetAll();
  elseif string.lower(cmd):match"^stun +[^ ]+" then
    local stuncmd = cmd:match("^stun *(.*)")
    if string.lower(stuncmd) == "showraid" then
      Silk_ToggleStunShowRaid()
    end
  elseif string.lower(cmd):match"^npc +%d+" then
    local npcid = tonumber(cmd:match("^npc *(%d*)"))
    customnpcid = npcid
    Silk_Message(string.format(SILK_NPC_SET_MESSAGE, customnpcid))
  elseif string.lower(cmd):match"^timeout +%d+" then
    local timeout = tonumber(cmd:match("^timeout *(%d*)"))
    db.timeout = timeout
    Silk_Message(string.format(SILK_TIMEOUT_SET_MESSAGE, db.timeout))
  elseif string.lower(cmd):match"^channel +[^ ]+" then
    local channel = cmd:match("^channel *(.*)")
    db.channel = channel
    Silk_Message(string.format(SILK_CHANNEL_MESSAGE, db.channel))
  elseif string.lower(cmd) == "test" then
    Silk_TestWindow()
  elseif string.lower(cmd) == "version" then
    Silk_Message("version "..(db.version/100))
  end
end

SLASH_SILK1 = SILK_SLASHCMD1
SLASH_SILK2 = SILK_SLASHCMD2
function SlashCmdList.SILK(msg, editbox)
  Silk_Invoke(msg)
end

function Silk_OnUpdate()
    if not db.enabled then
        return
    end
    
    if not sctracker then
        Silk_CreateSCTracker()
    end
    if not catracker then
        Silk_CreateCATracker()
    end
    if not sktracker then
        Silk_CreateSKTracker()
    end

    -- Update unit list
    tracker:Update()
    sctracker:Update()
    catracker:Update()
    sktracker:Update()

    -- Update visual information into health panels
    for n,w in pairs(windows) do
        if w.hp then
            for i,hp in pairs(w.hp) do
                hp:Update()
            end
        end
        if w.halion then
            Silk_UpdateHalionPanels(w)
        end
    end
end

function Silk_OnEvent(self, event, ...)
  if event == "CHAT_MSG_ADDON" then
    local prefix, message, _, sender = ...
    if prefix == "Silk" then
      -- We received a message from another Silk user telling us information.

      --local item1, item2 = message:match("([^\t]*)\t([^\t]*)")
--      Silk_Message("Received silk message : "..message)
    end
  elseif event == "ADDON_LOADED" then
    local addonName = ...;
    if addonName:lower() == "silk" then
      Silk_Message(SILK_WELCOME)
      Silk_LoadDB()
      Silk_LoadRecords()
      Silk_RestoreWindows()
    end
  end
end

function Silk_Message(msg)
  DEFAULT_CHAT_FRAME:AddMessage(string.format(SILK_CHATMESSAGE, msg));
end

function Silk_Warning(msg)
  DEFAULT_CHAT_FRAME:AddMessage(string.format(SILK_CHATWARNING, msg));
end

function Silk_Debug(msg)
  if SilkDebug and (SilkDebug == 1) then
    DEFAULT_CHAT_FRAME:AddMessage(string.format(SILK_CHATMESSAGE, msg));
  end
end

function Silk_ShowRaid(msg)
    if db.channel and (string.lower(db.channel) ~= "default") and (GetChannelName(db.channel) > 0) then
        SendChatMessage(msg, "CHANNEL", nil, GetChannelName(db.channel))
    elseif UnitInRaid("player") then
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            SendChatMessage(msg, "RAID")
        else
            Silk_Debug("You must be raid leader or raid officer to announce to raid")
        end
    elseif UnitInParty("player") and (GetNumPartyMembers() > 0) then
        SendChatMessage(msg, "PARTY")
    else
        SendChatMessage(msg, "WHISPER", nil, UnitName("player"))
    end
end

-- functions for debugging purposes
function Silk_GUID()
    Silk_Message(tonumber("0x"..UnitGUID("target"):sub(7,10)))
end
function Silk_NBR()
    Silk_Message("Number of records : "..#records)
end
function Silk_CreateRecord()
    if records:GetLastRecord() and records:GetLastRecord().recording then
        records:GetLastRecord():End()
    end
    records:CreateRecord()
end
function Silk_ImportRecord(str)
    records:CreateRecord():FromString(str)
end
function Silk_SaveRecords()
    if records:GetLastRecord() and records:GetLastRecord().recording then
        records:GetLastRecord():End()
    end
    db.records = records
    Silk_Debug(#records.." record(s) saved.")
end
function Silk_LoadRecords()
    if db.records then
        local recordsproto = {}
        for k,v in pairs(records) do
            if type(v) == "function" then
                recordsproto[k]=v
            end
        end
        records = db.records
        for k,v in pairs(recordsproto) do
            records[k]=v
        end
        Silk_Debug(#records.." record(s) loaded.")
    else
        Silk_Warning("Can not load records : no record previously saved.")
    end
end
function Silk_ResetRecords()
    if db.records then
        local recordsproto = {}
        for k,v in pairs(records) do
            if type(v) == "function" then
                recordsproto[k]=v
            end
        end
        records = {}
        db.records = records
        for k,v in pairs(recordsproto) do
            records[k]=v
        end
        Silk_Debug("Resetting saved record(s).")
    else
        Silk_Warning("Can not reset records : no record previously saved.")
    end
end