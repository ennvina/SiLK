local _, Silk = ...

local Cmd = {}

function Cmd:ShortHelp()
  Silk_Message(SILK_COMMANDHELP1 .. ".");
  Silk_Message(SILK_COMMANDHELP2 .. ".");
  Silk_Message(SILK_COMMANDHELP0 .. ".");
end

function Cmd:Help()
  Silk_Message(SILK_COMMANDHELP1 .. ".");
  Silk_Message(SILK_COMMANDHELP2 .. ".");
  Silk_Message(SILK_COMMANDHELP3 .. ".");
  Silk_Message(SILK_COMMANDHELP4 .. ".");
  Silk_Message(SILK_COMMANDHELP5 .. ".");
  Silk_Message(SILK_COMMANDHELP7 .. ".");
  Silk_Message(SILK_COMMANDHELP8 .. ".");
  Silk_Message(SILK_COMMANDHELP9 .. ".");
end

-------------------
-- GLOBAL FUNCTIONS
-------------------

function Cmd:ToggleStunShowRaid()
    Silk.db.stun.showraid = not Silk.db.stun.showraid
    if Silk.db.stun.showraid then
        Silk_Message(SILK_STUN_SHOWRAID_ENABLED)
    else
        Silk_Message(SILK_STUN_SHOWRAID_DISABLED)
    end
end

function Cmd:Invoke(cmd)
  if cmd == "" then
    self:ShortHelp();
  elseif string.lower(cmd) == "help" then
    self:Help();
  elseif string.lower(cmd) == "enable" then
    Silk.db.enabled = true;
  elseif string.lower(cmd) == "disable" then
    Silk.db.enabled = false;
  elseif string.lower(cmd) == "show" then
    Silk.Window:Show(Silk.Constants.windowname.valkyr)
  elseif string.lower(cmd) == "reset" then
    Silk_ResetRecords()
  elseif string.lower(cmd) == "resetwin" then
    Silk.FrameUtils:ResetAll();
  elseif string.lower(cmd):match"^stun +[^ ]+" then
    local stuncmd = cmd:match("^stun *(.*)")
    if string.lower(stuncmd) == "showraid" then
      self:ToggleStunShowRaid()
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
    Silk.Window:StartTest()
  elseif string.lower(cmd) == "version" then
    Silk_Message("version "..(Silk.db.version/100))
  end
end

Silk.Cmd = Cmd
