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
local Window = Silk.Window

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
    Window:Show(constants.windowname.valkyr, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "sc" or string.lower(cmd) == "spitecaller" then
    Window:Show(constants.windowname.spitecaller, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "ca" or string.lower(cmd) == "adherent" then
    Window:Show(constants.windowname.adherent, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "sk" then
    Window:Show(constants.windowname.sk, Silk.CreateHealthPanels)
  elseif string.lower(cmd) == "aaa" then
    Window:Show(constants.windowname.aaa, Silk.CreateTimeLines)
  elseif string.lower(cmd) == "corpo" then
    Window:Show(constants.windowname.corpo, Silk.CreateHalionPanels)
  elseif string.lower(cmd) == "reset" then
    Silk_ResetRecords()
  elseif string.lower(cmd) == "resetwin" then
    futils:ResetAll();
  elseif string.lower(cmd):match"^stun +[^ ]+" then
    local stuncmd = cmd:match("^stun *(.*)")
    if string.lower(stuncmd) == "showraid" then
      Silk_ToggleStunShowRaid()
    end
  elseif string.lower(cmd):match"^timeout +%d+" then
    local timeout = tonumber(cmd:match("^timeout *(%d*)"))
    Silk.db.timeout = timeout
    Silk_Message(string.format(SILK_TIMEOUT_SET_MESSAGE, Silk.db.timeout))
  elseif string.lower(cmd):match"^channel +[^ ]+" then
    local channel = cmd:match("^channel *(.*)")
    Silk.db.channel = channel
    Silk_Message(string.format(SILK_CHANNEL_MESSAGE, Silk.db.channel))
  elseif string.lower(cmd) == "test" then
    Window:StartTest()
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

    Window:UpdateAll()
end

function Silk_OnEvent(self, event, ...)
  if event == "ADDON_LOADED" then
    local addonName = ...;
    if addonName:lower() == "silk" then
      Silk_Message(SILK_WELCOME)
      Silk:LoadDB()
      Silk_LoadRecords()
      Window:RestoreAll()
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