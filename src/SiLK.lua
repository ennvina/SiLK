local AddonName, Silk = ...

--
-- Silk: Silent Lich King, by Vinny / Ennvina
--
-- Developed for Silent - Illidan EU
-- Resurrected for Silent - Sulfuron EU
--

-- Optimize frequent calls
local GetChannelName = GetChannelName
local GetNumSubgroupMembers = GetNumSubgroupMembers
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
local Cmd = Silk.Cmd

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

SLASH_SILK1 = SILK_SLASHCMD1
SLASH_SILK2 = SILK_SLASHCMD2
function SlashCmdList.SILK(msg, editBox)
  Cmd:Invoke(msg)
end
