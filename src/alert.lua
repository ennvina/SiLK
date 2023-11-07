local _, Silk = ...

-- Global variables for debugging
SilkDebug = false

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
    elseif UnitInParty("player") and (GetNumSubgroupMembers() > 0) then
        SendChatMessage(msg, "PARTY")
    else
        SendChatMessage(msg, "WHISPER", nil, UnitName("player"))
    end
end
