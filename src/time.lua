local _, Silk = ...

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

Silk.Time = {
    GetHumanReadableTime = GetHumanReadableTime,
    GetRemainingTime = GetRemainingTime,
}
