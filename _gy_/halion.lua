local _, Silk = ...

local constants = Silk.Constants

-------------------
-- HALION FUNCTIONS
-------------------

local halionproto = {}

function halionproto:CreateIcon()
    local inset = constants.halionInset
    local reduction = 6
    local icon = self:CreateTexture(nil,"OVERLAY")
    icon:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",inset+reduction,reduction)
    icon:SetPoint("TOPRIGHT",self,"TOPLEFT",inset+constants.halionHeight-reduction,-reduction)
    self.icon = icon
end

function halionproto:CreateBuffLabel()
    local leftmargin = 5
	local bufflabel = self:CreateFontString(nil,"OVERLAY")
	bufflabel:SetFont(GameFontNormal:GetFont(),12)
	bufflabel:SetPoint("LEFT",self,"LEFT",constants.halionHeight+leftmargin,0)
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
    hfire:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-(topPoint+constants.halionHeight))
    for k,v in pairs(halionproto) do hfire[k]=v end
    hfire:SetForbiddenBuff(75476) -- forbidden buff in fire form
    hfire:SetZeroBuff(74826) -- buff respresenting 0%
    hfire:SetIcon("Interface\\Icons\\inv_misc_head_dragon_01")
    hfire.name="Fire"-- for testing purposes
--    hfire:SetBuff(nil) -- initialize buff with ??%
    window.halion[1] = hfire

    topPoint = topPoint+constants.halionHeight

	local hshadow = CreateFrame("Frame",nil,window.container)
    hshadow:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-topPoint)
    hshadow:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-(topPoint+constants.halionHeight))
    for k,v in pairs(halionproto) do hshadow[k]=v end
    hshadow:SetMandatoryBuff(75476) -- special buff in shadow form
    hshadow:SetZeroBuff(74826) -- buff respresenting 0%
    hshadow:SetIcon("Interface\\Icons\\inv_misc_head_dragon_black")
    hshadow.name="Shadow"-- for testing purposes
--    hshadow:SetBuff(nil) -- initialize buff with ??%
    window.halion[2] = hshadow

    -- adjust min-resize settings
    -- local width = 50
    -- local height = 2*constants.titleBarInset+constants.titleHeight+2*constants.halionHeight+1
    -- window:SetMinResize(width,height) -- @!!!
end

function Silk.UpdateHalionPanels(window)
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
            -- no update for this panel: mark as unknown
            hpanel:SetBuff(nil)
        end
    end
end
