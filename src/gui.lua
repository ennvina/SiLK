local _, Silk = ...

-- Optimize frequent calls
local IsShiftKeyDown = IsShiftKeyDown

--------------------------
-- FRAME UTILITY FUNCTIONS
--------------------------

local FrameUtils = {
    frames = {},
    moved = {},
    resized = {},
    scaled = {},
    backup = {},

    SaveDimensions = function(self, f)
        self.frames[f:GetName()] = f
        self.resized[f:GetName()] = true

        local name = f:GetName()
        SilkDB.dimensions[name].width = f:GetWidth()
        SilkDB.dimensions[name].height = f:GetHeight()
    end,

    LoadDimensions = function(self, f)
        self.frames[f:GetName()] = f
        self.resized[f:GetName()] = true

        local name = f:GetName()
        local dims = SilkDB.dimensions[name]
        if dims then
            f:SetWidth(dims.width)
            f:SetHeight(dims.height)
        else
            SilkDB.dimensions[name] = {
                width = f:GetWidth(),
                height = f:GetHeight()
            }
        end
    end,

    SaveScale = function(self, f)
        self.frames[f:GetName()] = f
        self.scaled[f:GetName()] = true

        local name = f:GetName()
        SilkDB.scales[name] = f:GetScale()
    end,

    LoadScale = function(self, f)
        self.frames[f:GetName()] = f
        self.scaled[f:GetName()] = true

        local name = f:GetName()
        local scale = SilkDB.scales[name]
        if scale then
            f:SetScale(scale)
            if f.window then
                self:SetResizeBounds(f.window, scale)
            end
        else
            SilkDB.scales[name] = f:GetScale()
        end
    end,

    SavePosition = function(self, f)
        self.frames[f:GetName()] = f
        self.moved[f:GetName()] = true

        local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
        local name = f:GetName()
        local pos = SilkDB.positions[name]
        if not pos then
            pos = {}
            SilkDB.positions[name] = pos
        end
        pos.point = point
        pos.relativeTo = relativeTo and relativeTo:GetName()
        pos.relativePoint = relativePoint
        pos.xOfs = xOfs
        pos.yOfs = yOfs
        f:SetUserPlaced(false)
    end,

    LoadPosition = function(self, f)
        self.frames[f:GetName()] = f
        self.moved[f:GetName()] = true

        local name = f:GetName()
        f:ClearAllPoints()
        local pos = SilkDB.positions[name]
        if pos then
            f:SetPoint(pos.point,_G[pos.relativeTo] or UIParent,pos.relativePoint,pos.xOfs,pos.yOfs)
        else
            f:SetPoint("CENTER",UIParent,"CENTER",0,0)
            SilkDB.positions[name] = {
                point = "CENTER",
                relativeTo = "UIParent",
                relativePoint = "CENTER",
                xOfs = 0,
                yOfs = 0,
            }
        end
    end,

    Backup = function(self, f)
        local dims = {}
        dims.width = f:GetWidth()
        dims.height = f:GetHeight()

        local scale = {}
        scale.scale = f:GetScale()

        local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
        local pos = {}
        pos.point = point
        pos.relativeTo = relativeTo and relativeTo:GetName()
        pos.relativePoint = relativePoint
        pos.xOfs = xOfs
        pos.yOfs = yOfs

        self.frames[f:GetName()] = f
        self.backup[f:GetName()] = { dims=dims, scale=scale, pos=pos }
    end,

    ResetAll = function(self)
        for n,f in pairs(self.frames) do
            local backup = self.backup[n]
            if self.moved[n] then
                f:ClearAllPoints()
                local pos = backup and backup.pos
                if pos then
                    f:SetPoint(pos.point,_G[pos.relativeTo] or UIParent,pos.relativePoint,pos.xOfs,pos.yOfs)
                else
                    f:SetPoint("CENTER",UIParent,"CENTER",0,0)
                end
                self:SavePosition(f)
            end
            if self.scaled[n] then
                local scale = backup and backup.scale and backup.scale.scale or 1
                f:SetScale(scale)
                if f.window then
                    self:SetResizeBounds(f.window, scale)
                end
                self:SaveScale(f)
            end
            if self.resized[n] then
                local dims = backup and backup.dims
                local width = dims and dims.width or f.defaultWidth or 300
                local height = dims and dims.height or 2*Silk.Constants.titleBarInset+Silk.Constants.titleHeight+3*Silk.Constants.healthHeight+1
                f:SetWidth(width)
                f:SetHeight(height)
                self:SaveDimensions(f)
            end
        end
    end,

    SetResizeBounds = function(self, f, scale)
        if f.minWidth and f.minHeight and f.maxWidth and f.maxHeight then
            f:SetResizeBounds(f.minWidth*scale, f.minHeight*scale, math.min(f.maxWidth*scale, 1920), math.min(f.maxHeight*scale, 1080))
        end
    end,
}

---------------------------------------
-- HANDLERS
---------------------------------------

local Handlers = {
    Anchor_OnSizeChanged = function(self, width, height)
        if self._sizing then
            if not IsShiftKeyDown() then
                self.ratio = height / width

                self.faux_window:SetWidth((width * self:GetEffectiveScale()) / self.faux_window:GetEffectiveScale())
                self.faux_window:SetHeight((height * self:GetEffectiveScale()) / self.faux_window:GetEffectiveScale())
            else
                local h = width * self.ratio
                self:SetHeight(h)
                -- self.faux_window:GetEffectiveScale() doesn't work because this
                -- handler is called again by SetHeight, which then causes the
                -- calculated scale to become 1
                local scale = (width * self:GetEffectiveScale()) / (self.faux_window:GetWidth() * UIParent:GetEffectiveScale())
                self.faux_window:SetScale(scale)
                FrameUtils:SetResizeBounds(self, scale)
            end
        end
        if self.hp then
            for k,v in pairs(self.hp) do
                v:UpdateSize()
            end
        end
    end,

    Window_OnMouseDown = function(self)
        if not SilkDB.locked then
            self:StartMoving()
        end
    end,

    Window_OnMouseUp = function(self)
        self:StopMovingOrSizing()
        FrameUtils:SavePosition(self)
    end,

    Corner_OnMouseDown = function(self)
        self.window._sizing = true
        self.window:StartSizing("BOTTOMRIGHT")
    end,

    Corner_OnMouseUp = function(self)
        self.window:StopMovingOrSizing()
        self.window._sizing = nil
        FrameUtils:SaveDimensions(self.window.faux_window)
        FrameUtils:SaveScale(self.window.faux_window)
        FrameUtils:SaveDimensions(self.window)
        FrameUtils:SavePosition(self.window)
    end,

    Close_OnClick = function(self)
        self.window:Hide()
        SilkDB.visible[self.window:GetName()].show = false
    end
}


---------------------------------------
-- TOOLTIPS
---------------------------------------

local function OnEnter(self)
    if self._ttEnabled then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self._ttTitle then GameTooltip:AddLine(self._ttTitle,nil,nil,nil,true) end
        if self._ttText then GameTooltip:AddLine(self._ttText,1,1,1,true) end
        GameTooltip:Show()
    end
end

local function OnLeave(self)
    GameTooltip:Hide()
end

local Tooltip = {
    AddText = function(obj,title,text)
        obj._ttTitle = title
        obj._ttText = text
        if not obj._ttExists then
            obj._ttExists = true
            obj:HookScript("OnEnter",OnEnter)
            obj:HookScript("OnLeave",OnLeave)
        end
        obj._ttEnabled = true
    end,

    ResetText = function(obj)
        obj._ttEnabled = false
    end,
}


---------------------------------------
-- EXPORTS
---------------------------------------

Silk.FrameUtils = FrameUtils
Silk.Handlers = Handlers
Silk.Tooltip = Tooltip
