local AddonName, Silk = ...

--
-- Silk: Silent Lich King, by Vinny / Ennvina
--
-- Developed for Silent - Illidan EU
-- Resurrected for Silent - Sulfuron EU
--

-- Optimize frequent calls
local GetChannelName = GetChannelName
local GetNumPartyMembers = GetNumPartyMembers
local GetRaidTargetIndex = GetRaidTargetIndex
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local SendChatMessage = SendChatMessage
local UnitAffectingCombat = UnitAffectingCombat
local UnitDebuff = UnitDebuff
local UnitExists = UnitExists
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local constants = Silk.Constants
local futils = Silk.FrameUtils
local handlers = Silk.Handlers
local Tooltip = Silk.Tooltip
local records = Silk.Records

local buttonSize = 10
local titleHeight = 11
local titleBarInset = 2

local customnpcid = nil

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
    local height = 2*titleBarInset+titleHeight+3*constants.healthHeight+1

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
	Tooltip.AddText(corner,SILK_RESIZE_TOOLTIP)
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
	Tooltip.AddText(titlebar,SILK_MOVE_TOOLTIP)
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
	Tooltip.AddText(close,SILK_CLOSE_TOOLTIP)
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

	Silk.windows[name] = window

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
    if name == constants.windowname.valkyr then
        -- @todo set HP bar 0%-100% in normal mode
        Silk.CreateHealthPanels(window,0.5,1) -- 50% - 100%
    elseif name == constants.windowname.spitecaller then
        Silk.CreateHealthPanels(window,0,1) -- 0% - 100%
    elseif name == constants.windowname.adherent then
        Silk.CreateHealthPanels(window,0,1) -- 0% - 100%
    elseif name == constants.windowname.sk then
        Silk.CreateHealthPanels(window,0,1) -- 0% - 100%
    elseif name == constants.windowname.aaa then
        Silk.CreateTimeLines(window)
    elseif name == constants.windowname.corpo then
        Silk.CreateHalionPanels(window)
    end
end


function Silk_RestoreWindows()
    for n,v in pairs(Silk.db.visible) do
        if v.show then
            local window = Silk.windows[v.name]
            if window == nil then
                window = Silk_CreateWindow(v.name)
                Silk_CreateWindowContents(window, v.name)
            end
            window:Show()
        end
    end
end

function Silk_ShowWindow(rawname, creator)
    local window = Silk.windows[rawname]
    if window == nil then
        window = Silk_CreateWindow(rawname)
        Silk.CreateHealthPanels(window)
    end
    window:Show()
    Silk.db.visible[window:GetName()] = { show = true, name = rawname }
end

function Silk_TestWindow()
    local rawname = constants.windowname.valkyr
--    local rawname = constants.windowname.spitecaller
--    local rawname = constants.windowname.sk
    local valkyrwindow = Silk.windows[rawname]
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
        local spell = constants.stunspells[math.random(#constants.stunspells)]
        while not GetSpellInfo(spell) do -- In case we fetch spell from a wrong expansion
            spell = constants.stunspells[math.random(#constants.stunspells)]
        end
        local duration = math.random(6)/math.random(3)
        hp[i]:SetHP(health,total)
        hp[i]:SetName("Val'kyr Shadowguard")
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
    Silk.db.stun.showraid = not Silk.db.stun.showraid
    if Silk.db.stun.showraid then
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
    Silk.db.enabled = true;
  elseif string.lower(cmd) == "disable" then
    Silk.db.enabled = false;
  elseif string.lower(cmd) == "show" then
    Silk_ShowWindow(constants.windowname.valkyr, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "sc" or string.lower(cmd) == "spitecaller" then
    Silk_ShowWindow(constants.windowname.spitecaller, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "ca" or string.lower(cmd) == "adherent" then
    Silk_ShowWindow(constants.windowname.adherent, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "sk" then
    Silk_ShowWindow(constants.windowname.sk, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "aaa" then
    Silk_ShowWindow(constants.windowname.aaa, Silk.CreateTimeLines)
  elseif string.lower(cmd) == "corpo" then
    Silk_ShowWindow(constants.windowname.corpo, Silk.CreateHalionPanels)
  elseif string.lower(cmd) == "reset" then
    Silk_ResetRecords()
  elseif string.lower(cmd) == "resetwin" then
    futils:ResetAll();
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
    Silk.db.timeout = timeout
    Silk_Message(string.format(SILK_TIMEOUT_SET_MESSAGE, Silk.db.timeout))
  elseif string.lower(cmd):match"^channel +[^ ]+" then
    local channel = cmd:match("^channel *(.*)")
    Silk.db.channel = channel
    Silk_Message(string.format(SILK_CHANNEL_MESSAGE, Silk.db.channel))
  elseif string.lower(cmd) == "test" then
    Silk_TestWindow()
  elseif string.lower(cmd) == "version" then
    Silk_Message("version "..(Silk.db.version/100))
  end
end

SLASH_SILK1 = SILK_SLASHCMD1
SLASH_SILK2 = SILK_SLASHCMD2
function SlashCmdList.SILK(msg, editbox)
  Silk_Invoke(msg)
end

function Silk_OnUpdate()
    if not Silk.db.enabled then
        return
    end

    -- Update unit list
    Silk.tracker:Update()

    -- Update visual information into health panels
    for n,w in pairs(Silk.windows) do
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
--      Silk_Message("Received silk message: "..message)
    end
  elseif event == "ADDON_LOADED" then
    local addonName = ...;
    if addonName:lower() == "silk" then
      Silk_Message(SILK_WELCOME)
      Silk:LoadDB()
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
    if Silk.db.channel and (string.lower(Silk.db.channel) ~= "default") and (GetChannelName(Silk.db.channel) > 0) then
        SendChatMessage(msg, "CHANNEL", nil, GetChannelName(Silk.db.channel))
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
    Silk_Message("Number of records: "..#records)
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