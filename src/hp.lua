local _, Silk = ...

local constants = Silk.Constants

-------------------------
-- HEALTH PANEL FUNCTIONS
-------------------------

local hpproto = {}

function hpproto:CreateMainFrame()
    local inset = constants.healthInset
    local mainframe = CreateFrame("Frame",nil,self,"BackdropTemplate")
    mainframe:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",constants.healthHeight*(1+constants.nbstunicons)+inset,0)
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
    local healthbar = CreateFrame("StatusBar", nil, self.mainframe, "SilkStatusBarTemplate")
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
    namelabel:SetPoint("LEFT",self.mainframe,"LEFT",inset+constants.healthHeight,0)
    namelabel:SetShadowOffset(1,-1)
    namelabel:SetShadowColor(0,0,0)
    self.namelabel = namelabel
end

function hpproto:CreateStunIcon()
    local inset = 1
    local stunicon = { last = 0 }
    for s=1,constants.nbstunicons do
        local icon = self:CreateTexture(nil,"ARTWORK")
        icon:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",constants.healthHeight*(s-1)+inset,0)
        icon:SetPoint("TOPRIGHT",self,"TOPLEFT",constants.healthHeight*s+inset,0)
        local frame = CreateFrame("Frame",nil,self)
        frame:SetFrameLevel(self:GetFrameLevel()+4)
        frame:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",constants.healthHeight*(s-1)+inset,0)
        frame:SetPoint("TOPRIGHT",self,"TOPLEFT",constants.healthHeight*s+inset,0)
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
    raidicon:SetPoint("TOPRIGHT",self.mainframe,"TOPLEFT",inset+constants.healthHeight-reduction,-reduction)
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
        for s=1,constants.nbstunicons do
            self.stunicon[s]:SetAlpha(0)
            Silk.Tooltip.ResetText(self.stunicon[s].frame)
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
    local index = math.min(self.stunicon.last+1,constants.nbstunicons)
    local spellname,_,icon = GetSpellInfo(spell)
    self.stunicon[index].icon = icon
    self.stunicon[index]:SetTexture(icon)
    self.stunicon[index]:SetAlpha(1)
    if index > 1 then
        self.stunicon[index-1]:SetAlpha(0.5)
    end
    self.stunicon.last = index
    self.stunlabel:SetPoint("LEFT",self,"LEFT",inset+constants.healthHeight*index,0)
    self.stunlabel:SetAlpha(1)
    self.stunlabel.expiration = expiration
    self:UpdateStunDuration()

    local source = spellname -- @!!!
    local castername = UnitName(caster)
    if castername then
        source = source .. " ("..castername..")"
    end
    local duration = Silk.Time.GetHumanReadableTime(math.max(expiration-GetTime(),0), true)

    Silk.Tooltip.AddText(self.stunicon[index].frame,castername,spellname.." ("..duration..")")

    if Silk.db.stun.showraid then
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
        local line = math.floor((raidicon-1)/4)
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
    local record = Silk.Records:GetRecord()
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
    local record = Silk.Records:GetRecord()
    record:SetHP(guid, health, total)
    record:SetRaidIcon(guid, raidicon)

    -- look into debuff lists to check if a stun is applied
    local i = 1
    local debuff, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unit, i)
    while debuff do
        if constants.stunspells[spellId] then
            if not self.stun or (self.stun.spell ~= spellId) or (self.stun.expiration ~= expirationTime) or (self.stun.caster ~= unitCaster) then
                -- stun found, more precisely a new stun
                self:SetStun(spellId, expirationTime, unitCaster)
                local duration = math.max(expirationTime-GetTime(),0)
                record:SetStun(guid, spellId, duration, UnitName(unitCaster))
            end
            return
        end
        i = i + 1
        debuff, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unit, i)
    end
end

function hpproto:UpdateStunDuration()
    if self.stunlabel and self.stunlabel.expiration then
        self.stunlabel:SetText(Silk.Time.GetRemainingTime(self.stunlabel.expiration))

        local currentTime = GetTime()
        if currentTime > self.stunlabel.expiration then
            local alpha = 1 - 0.5*(currentTime - self.stunlabel.expiration)
            alpha = math.max(math.min(alpha,1),0)
            self.stunlabel:SetAlpha(alpha)
            if self.stunicon and (self.stunicon.last > 0) then
                self.stunicon[self.stunicon.last]:SetAlpha(math.max(alpha,0.5))
            end
        end
    end
end

function hpproto:Update()
    self:UpdateStunDuration()
end

local function isHeroicRaid()
    local difficulyID = GetRaidDifficultyID()
    if difficulyID then
        return select(3,GetDifficultyInfo(difficulyID))
    end
end

function hpproto:UpdateSize()
    if self.healthbar then
        if self.total > 0 then
            local minhealth = isHeroicRaid() and (self.total/2) or 0
            local maxhealth = self.total
            self.healthbar:SetMinMaxValues(minhealth, maxhealth)
            self.healthbar:SetValue(self.health)
        else
            self.healthbar:SetMinMaxValues(0, 1)
            self.healthbar:SetValue(0)
        end
    end
end

-- inspired by DXE's health panels
function Silk.CreateHealthPanels(window)
    window.hp = {}
    for i=1,3 do
        local hp = CreateFrame("Frame",nil,window.container)
        hp:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-constants.healthHeight*(i-1))
        hp:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-constants.healthHeight*i)

        for k,v in pairs(hpproto) do hp[k]=v end

        hp:CreateMainFrame()

        hp:Hide()

        window.hp[i] = hp
    end
end
