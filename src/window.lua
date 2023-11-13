local _, Silk = ...

local constants = Silk.Constants
local futils = Silk.FrameUtils
local handlers = Silk.Handlers
local records = Silk.Records
local Tooltip = Silk.Tooltip

-- All managed windows
local windows = {}

---------------------------
-- GENERIC WINDOW FUNCTIONS
---------------------------

local Window = {}

function Window:GetByName(name)
    return windows[name]
end

-- inspired by DXE's CreateWindow
function Window:Create(name)
    local properName = name:gsub(" ",""):gsub("'","")

    local window = CreateFrame("Frame","SilkWindow"..properName,UIParent,"BackdropTemplate")
    window.defaultWidth = 250
    window.defaultHeight = 2*constants.titleBarInset+constants.titleHeight+3*constants.healthHeight+1
    window.minWidth = 0 -- No lower limit for width, to avoid scale locks
    window.minHeight = window.defaultHeight -- Locked height
    window.maxWidth = 1000
    window.maxHeight = window.defaultHeight -- Locked height
    window:SetClampedToScreen(true)
    window:SetWidth(window.defaultWidth)
    window:SetHeight(window.defaultHeight)
    window:SetResizable(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:SetScript("OnMouseDown",handlers.Window_OnMouseDown)
    window:SetScript("OnMouseUp",handlers.Window_OnMouseUp)
    window:SetResizeBounds(window.minWidth, window.minHeight, window.maxWidth, window.maxHeight)
    window:SetPoint("CENTER")
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        insets = { left = 2, right = 3, top = 2, bottom = 3 },
        edgeSize = 9,
    })

    -- Inside
    -- Important: Make sure faux_window:GetEffectiveScale() == UIParent:GetEffectiveScale() on creation
    local faux_window = CreateFrame("Frame","SilkWindow"..properName.."Frame",window)
    faux_window.defaultWidth = window:GetWidth()
    faux_window.defaultHeight = window:GetHeight()
    faux_window:SetWidth(faux_window.defaultWidth)
    faux_window:SetHeight(faux_window.defaultHeight)
    faux_window:SetPoint("TOPLEFT")
    window.faux_window = faux_window
    faux_window.window = window

    local corner = CreateFrame("Button", nil, faux_window, "PanelResizeButtonTemplate")
    corner:SetFrameLevel(faux_window:GetFrameLevel() + 9)
    corner:EnableMouse(true)
    corner:SetScript("OnMouseDown", handlers.Corner_OnMouseDown)
    corner:SetScript("OnMouseUp", handlers.Corner_OnMouseUp)
    corner:SetHeight(12)
    corner:SetWidth(12)
    corner:SetPoint("BOTTOMRIGHT")
    Tooltip.AddText(corner,SILK_RESIZE_TOOLTIP)
    corner.window = window

    -- Border
    local border = CreateFrame("Frame",nil,faux_window)
    border:SetAllPoints(true)
    border:SetFrameLevel(border:GetFrameLevel()+10)

    -- Title Bar
    local titlebar = CreateFrame("Frame", nil, faux_window, "SilkTitleBarTemplate")
    titlebar:SetPoint("TOPLEFT",faux_window,"TOPLEFT",constants.titleBarInset,-constants.titleBarInset)
    titlebar:SetPoint("BOTTOMRIGHT",faux_window,"TOPRIGHT",-constants.titleBarInset, -(constants.titleHeight+constants.titleBarInset))
    titlebar.window = window

    local titletext = titlebar.label
    titletext:SetText(name)

    local close = CreateFrame("Button", nil, faux_window, "UIPanelCloseButtonNoScripts")
    close:SetFrameLevel(close:GetFrameLevel()+5)
    close:SetScript("OnClick", handlers.Close_OnClick)
    close:SetWidth(constants.buttonSize)
    close:SetHeight(constants.buttonSize)
    close:SetPoint("RIGHT",titlebar,"RIGHT")
    close.window = window

    window.lastbutton = close

    -- Container
    local container = CreateFrame("Frame",nil,faux_window)
    container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-constants.titleHeight-constants.titleBarInset)
    container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
    window.container = container

    -- Content
    local content = CreateFrame("Frame",nil,container)
--    content:SetPoint("TOPLEFT",container,"TOPLEFT")
--    content:SetPoint("BOTTOMRIGHT",container,"BOTTOMRIGHT")
--    window.content = content

--    for k,v in pairs(prototype) do window[k] = v end

    windows[name] = window

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

function Window:CreateContents(window, name)
    if name == constants.windowname.valkyr
    or name == constants.windowname.spitecaller
    or name == constants.windowname.adherent
    or name == constants.windowname.sk then
        Silk.CreateHealthPanels(window)
    elseif name == constants.windowname.aaa then
        Silk.CreateTimeLines(window)
    elseif name == constants.windowname.corpo then
        Silk.CreateHalionPanels(window)
    end
end

function Window:RestoreAll()
    for _, v in pairs(Silk.db.visible) do
        if v.show then
            local window = windows[v.name]
            if window == nil then
                window = self:Create(v.name)
                self:CreateContents(window, v.name)
            end
            window:Show()
        end
    end
end

function Window:Show(rawname)
    local window = windows[rawname]
    if window == nil then
        window = Window:Create(rawname)
        Silk.CreateHealthPanels(window)
    end
    window:Show()
    Silk.db.visible[window:GetName()] = { show = true, name = rawname }
end

function Window:UpdateAll()
    -- Update visual information into health panels
    for _, w in pairs(windows) do
        if w.hp then
            for _, hp in pairs(w.hp) do
                hp:Update()
            end
        end
        if w.halion then
            Silk.UpdateHalionPanels(w)
        end
    end
end

function Window:StartTest()
    local rawname = constants.windowname.valkyr
--    local rawname = constants.windowname.spitecaller
--    local rawname = constants.windowname.sk
    local valkyrwindow = windows[rawname]
    if valkyrwindow == nil then
        Silk_Warning(SILK_CANT_TEST)
        return
    end

    local hp = valkyrwindow.hp

    local testStunSpells = {}
    for id, _ in pairs(constants.stunspells) do
        if GetSpellInfo(id) then -- In case spell is from a wrong expansion
            table.insert(testStunSpells, id)
        end
    end

    for i=1,3 do
        if not hp[i]:IsShown() then hp[i]:Show() end
        local health = 400+math.random(60)*10
        local total = 1000
        local raidicon = math.random(3)+3*(i-1)-1
        local spell = testStunSpells[math.random(#testStunSpells)]
        while not GetSpellInfo(spell) do
            spell = testStunSpells[math.random(#testStunSpells)]
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

---------------------------------------
-- EXPORTS
---------------------------------------

Silk.Window = Window
