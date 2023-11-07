local _, Silk = ...

local constants = Silk.Constants

----------------
-- AAA FUNCTIONS
----------------

local tlproto = {}

function tlproto:CreateUnitFrame()
    local inset = constants.healthInset
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
    for i=1,constants.nbstunicons do
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
    local inset = constants.healthInset
    local uniticon = self:CreateTexture(nil,"OVERLAY")
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
    local text = spellname.." ("..Silk.Time.GetHumanReadableTime(math.max(duration,0), true)..")"
    Silk.Tooltip.AddText(stunframe,title,text)

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
        local line = math.floor((raidicon-1)/4)
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
        for i=1,constants.nbstunicons do
            self.stunframe[i]:Hide()
            self.stunframe[i].icon:SetAlpha(0)
        end
    end
end

function Silk_GetAAAWindow()
    return Silk.windows[constants.windowname.aaa]
end

function Silk_UpdateTimeLineControls()
    local window = Silk_GetAAAWindow()
    if not window then return end

    window.tlc.valkyrlabel:SetFormattedText(SILK_VALKYR_X_ON_Y, window.currentcolumn, #window.column)

    local mincolumn = math.min(1,#window.column)
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
    local window = Silk_GetAAAWindow()
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
            local ends = math.max(unit.forgotten, unit.killed)
            if ends < 0 then ends = interval.ends end
            tl:SetUnitTimes(starts, ends, interval.starts, interval.ends)
            for j=1,constants.nbstunicons do
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
    local window = Silk_GetAAAWindow()
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
            ending = math.max(forgotten, killed)
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
            interval.starts = math.min(interval.starts, unit.starts)
            interval.ends = math.max(interval.ends, unit.ends)
            interval.units[#interval.units+1] = unit.guid
        end
    end

    Silk_Debug("Found "..#intervals.." distinct interval(s)")

    -- sorting intervals by the starting point
    table.sort(intervals, function(i1, i2) return i1.starts < i2.starts end)

    window.column = intervals

    local mincolumn = math.min(1,#window.column)
    local maxcolumn = #window.column
    if (window.currentcolumn < mincolumn) then
        window.currentcolumn = mincolumn
    elseif (window.currentcolumn > maxcolumn) then
        window.currentcolumn = maxcolumn
    end

    Silk_ShowTimeLineColumn()
    Silk_UpdateTimeLineControls()
end

function Silk.UpdateTimeLines()
    local window = Silk_GetAAAWindow()
    if not window then return end

    if not window.record then return end
    Silk_SetTimeLines(window.record)
end

function Silk_PrevUnit()
    local window = Silk_GetAAAWindow()
    if not window then return end

    if not window.currentcolumn or not window.column then return end

    if (#window.column > 0) and (window.currentcolumn-1 >= 1) then
        window.currentcolumn = window.currentcolumn - 1
        Silk_ShowTimeLineColumn()
        Silk_UpdateTimeLineControls()
    end
end

function Silk_NextUnit()
    local window = Silk_GetAAAWindow()
    if not window then return end

    if not window.currentcolumn or not window.column then return end

    if (#window.column > 0) and (window.currentcolumn+1 <= #window.column) then
        window.currentcolumn = window.currentcolumn + 1
        Silk_ShowTimeLineColumn()
        Silk_UpdateTimeLineControls()
    end
end

function Silk.CreateTimeLines(window)
    -- Time Lines
    window.tl = {}
	for i=1,3 do
		local tl = CreateFrame("Frame",nil,window.container)
        tl:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-constants.healthHeight*(i-1))
        tl:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-constants.healthHeight*i)

        for k,v in pairs(tlproto) do tl[k]=v end

        tl:CreateUnitFrame()
        tl:CreateUnitIcon()

--        tl:Hide()

		window.tl[i] = tl
	end

    -- Time Line Controller
    local tlc = CreateFrame("Frame",nil,window.container)
    tlc:SetPoint("TOPLEFT",window.container,"TOPLEFT",0,-constants.healthHeight*3)
    tlc:SetPoint("BOTTOMRIGHT",window.container,"TOPRIGHT",0,-constants.healthHeight*4)

    local arrowButtonInset = 3
    local lbutton = CreateFrame("Button",nil,tlc)
    lbutton:SetPoint("BOTTOMLEFT",tlc,"BOTTOMLEFT",arrowButtonInset,arrowButtonInset)
    lbutton:SetPoint("TOPRIGHT",tlc,"TOPLEFT",constants.healthHeight-arrowButtonInset,-arrowButtonInset)
    lbutton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    lbutton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    lbutton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    lbutton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    lbutton:SetScript("OnClick", Silk_PrevUnit)
    lbutton:Disable()
    lbutton.window = window
    tlc.lbutton = lbutton

    local rbutton = CreateFrame("Button",nil,tlc)
    rbutton:SetPoint("BOTTOMLEFT",tlc,"BOTTOMRIGHT",-constants.healthHeight+arrowButtonInset,arrowButtonInset)
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
    recorddropdown:SetPoint("BOTTOMLEFT",tlc,"BOTTOMLEFT",constants.healthHeight,0)
    recorddropdown:SetPoint("TOPRIGHT",tlc,"TOP",0,0)
    recorddropdown:SetScale(constants.healthHeight / recorddropdown:GetHeight())
    UIDropDownMenu_Initialize(recorddropdown,
    function(self,level)
        local info = UIDropDownMenu_CreateInfo()
        info.hasArrow = false
        info.checked = false
        info.func = function()
            UIDropDownMenu_SetText(recorddropdown, self:GetText())
            local record = Silk.Records[self:GetID()]
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
        for i=1,#Silk.Records do
            local record = Silk.Records[i]
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
