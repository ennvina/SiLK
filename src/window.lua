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
	--[===[@debug@
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")
	--@end-debug@]===]
    local width = 50
    local height = 2*constants.titleBarInset+constants.titleHeight+3*constants.healthHeight+1

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
--    addon:RegisterBorder(border)

    -- Title Bar
    local titlebar = CreateFrame("Frame",nil,faux_window)
    titlebar:SetPoint("TOPLEFT",faux_window,"TOPLEFT",constants.titleBarInset,-constants.titleBarInset)
    titlebar:SetPoint("BOTTOMRIGHT",faux_window,"TOPRIGHT",-constants.titleBarInset, -(constants.titleHeight+constants.titleBarInset))
    titlebar:EnableMouse(true)
    titlebar:SetMovable(true)
    titlebar:SetScript("OnMouseDown",handlers.Title_OnMouseDown)
    titlebar:SetScript("OnMouseUp",handlers.Title_OnMouseUp)
    Tooltip.AddText(titlebar,SILK_MOVE_TOOLTIP)
--    self:RegisterMoveSaving(titlebar,"CENTER","UIParent","CENTER",0,0,true,window)
    titlebar.window = window

    local gradient = titlebar:CreateTexture(nil,"ARTWORK")
    local r,g,b,a = 0.25,0.7,1,1;
    gradient:SetAllPoints(true)
    gradient:SetTexture(r,g,b,a)
--    gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0) -- @!!!
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

--    self:RegisterDefaultScale(faux_window)
--    self:RegisterDefaultDimensions(window)
--    self:RegisterDefaultDimensions(faux_window)

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

---------------------------------------
-- EXPORTS
---------------------------------------

Silk.Window = Window
