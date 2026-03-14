ScriptName = "PG_PerspectiveGrid"

PG_PerspectiveGrid = {}

PG_PerspectiveGrid.MSG_BASE = MOHO.MSG_BASE + 2100
PG_PerspectiveGrid.MSG_CHANGE = PG_PerspectiveGrid.MSG_BASE
PG_PerspectiveGrid.MSG_RESET = PG_PerspectiveGrid.MSG_BASE + 1

function PG_PerspectiveGrid:Name()
    return "Perspective Grid"
end

function PG_PerspectiveGrid:Version()
    return "1.0.0"
end

function PG_PerspectiveGrid:Description()
    return "Click-drag to generate converging perspective guide lines from a center point."
end

function PG_PerspectiveGrid:Creator()
    return "Earl B (ilivetruth.com) + Codex"
end

function PG_PerspectiveGrid:UILabel()
    return "Perspective Grid"
end

function PG_PerspectiveGrid:ColorizeIcon()
    return false
end

function PG_PerspectiveGrid:IsEnabled(moho)
    if moho:DisableDrawingTools() then
        return false
    end
    return moho:DrawingMesh() ~= nil
end

function PG_PerspectiveGrid:IsRelevant(moho)
    return self:IsEnabled(moho)
end

function PG_PerspectiveGrid:ResetPrefs()
    self.lineCount = 99
    self.dragging = false
    self.centerVec = LM.Vector2:new_local()
    self.centerVec:Set(0, 0)
    self.dragVec = LM.Vector2:new_local()
    self.dragVec:Set(0, 0)
end

function PG_PerspectiveGrid:LoadPrefs(prefs)
    self.lineCount = prefs:GetInt("PG_PerspectiveGrid.lineCount", 99)
    self.dragging = false
    self.centerVec = LM.Vector2:new_local()
    self.centerVec:Set(0, 0)
    self.dragVec = LM.Vector2:new_local()
    self.dragVec:Set(0, 0)
end

function PG_PerspectiveGrid:SavePrefs(prefs)
    prefs:SetInt("PG_PerspectiveGrid.lineCount", self.lineCount)
end

local function clamp(v, lo, hi)
    if v < lo then
        return lo
    end
    if v > hi then
        return hi
    end
    return v
end

local function pointToLM(x, y)
    local v = LM.Vector2:new_local()
    v:Set(x, y)
    return v
end

function PG_PerspectiveGrid:AddLine(moho, x1, y1, x2, y2, drawingFrame)
    local mesh = moho:DrawingMesh()
    if mesh == nil then
        return
    end

    mesh:AddLonePoint(pointToLM(x1, y1), drawingFrame)
    mesh:AppendPoint(pointToLM(x2, y2), drawingFrame)

    local n = mesh:CountPoints() - 2
    mesh:Point(n):SetCurvature(MOHO.PEAKED, drawingFrame)
    mesh:Point(n + 1):SetCurvature(MOHO.PEAKED, drawingFrame)

    -- Keep each stroke isolated as exactly two points.
    mesh:SelectNone()
    mesh:Point(n).fSelected = true
    mesh:Point(n + 1).fSelected = true
    moho:CreateShape(false, false, drawingFrame)
end

function PG_PerspectiveGrid:GenerateFan(moho, cx, cy, radius)
    local mesh = moho:DrawingMesh()
    if mesh == nil then
        return
    end

    local lines = clamp(math.floor(self.lineCount + 0.5), 2, 720)
    local drawingFrame = moho.layerFrame

    moho.document:PrepUndo(moho.drawingLayer)
    moho.document:SetDirty()

    for i = 0, lines - 1 do
        local angle = (2 * math.pi * i) / lines
        local x2 = cx + (radius * math.cos(angle))
        local y2 = cy + (radius * math.sin(angle))
        self:AddLine(moho, cx, cy, x2, y2, drawingFrame)
    end

    moho:UpdateUI()
end

function PG_PerspectiveGrid:OnMouseDown(moho, mouseEvent)
    self.dragging = true
    self.centerVec:Set(mouseEvent.drawingVec)
    self.dragVec:Set(mouseEvent.drawingVec)
    mouseEvent.view:DrawMe()
end

function PG_PerspectiveGrid:OnMouseMoved(moho, mouseEvent)
    if not self.dragging then
        return
    end

    self.dragVec:Set(mouseEvent.drawingVec)
    mouseEvent.view:DrawMe()
end

function PG_PerspectiveGrid:OnMouseUp(moho, mouseEvent)
    if not self.dragging then
        return
    end

    self.dragging = false
    self.dragVec:Set(mouseEvent.drawingVec)

    local dx = self.dragVec.x - self.centerVec.x
    local dy = self.dragVec.y - self.centerVec.y
    local radius = math.sqrt((dx * dx) + (dy * dy))
    radius = clamp(radius, 0.01, 100000)

    self:GenerateFan(moho, self.centerVec.x, self.centerVec.y, radius)
    mouseEvent.view:DrawMe()
end

function PG_PerspectiveGrid:DrawMe(moho, view)
    if not self.dragging then
        return
    end

    local g = view:Graphics()
    if g == nil then
        return
    end

    if moho.LayerToScreen == nil then
        return
    end

    local centerPt = LM.Point:new_local()
    local edgePt = LM.Point:new_local()
    local ok1 = pcall(function()
        moho:LayerToScreen(self.centerVec, centerPt)
    end)
    local ok2 = pcall(function()
        moho:LayerToScreen(self.dragVec, edgePt)
    end)
    if (not ok1) or (not ok2) then
        return
    end

    g:Push()
    g:SetColor(255, 180, 80)
    g:SetSmoothing(true)
    g:DrawLine(centerPt.x - 8, centerPt.y, centerPt.x + 8, centerPt.y)
    g:DrawLine(centerPt.x, centerPt.y - 8, centerPt.x, centerPt.y + 8)
    g:DrawLine(centerPt.x, centerPt.y, edgePt.x, edgePt.y)
    g:Pop()
end

function PG_PerspectiveGrid:DoLayout(moho, layout)
    self.linesText = LM.GUI.StaticText("Lines")
    layout:AddChild(self.linesText)

    self.linesIn = LM.GUI.TextControl(0, "000", self.MSG_CHANGE, LM.GUI.FIELD_UINT)
    layout:AddChild(self.linesIn)

    self.resetBtn = LM.GUI.Button("Reset", self.MSG_RESET)
    layout:AddChild(self.resetBtn)
end

function PG_PerspectiveGrid:UpdateWidgets(moho)
    self.linesIn:SetValue(self.lineCount)
end

function PG_PerspectiveGrid:HandleMessage(moho, view, msg)
    if msg == self.MSG_CHANGE then
        self.lineCount = clamp(self.linesIn:IntValue(), 2, 720)
        self.linesIn:SetValue(self.lineCount)
    elseif msg == self.MSG_RESET then
        self.lineCount = 99
    end

    self:UpdateWidgets(moho)
    if view ~= nil then
        view:DrawMe()
    end
end

PG_PerspectiveGrid:ResetPrefs()
