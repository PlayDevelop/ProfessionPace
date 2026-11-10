local _, ns = ...
local L = ns.Logic
local ADDON = "ProfessionPace"
local professions = {
    {171, "Alchemy", 136240}, {164, "Blacksmithing", 136241},
    {333, "Enchanting", 136244}, {202, "Engineering", 136243},
    {182, "Herbalism", 136246}, {165, "Leatherworking", 136247},
    {186, "Mining", 136248}, {393, "Skinning", 134366},
    {197, "Tailoring", 136249}, {185, "Cooking", 133971},
    {129, "First Aid", 135966}, {356, "Fishing", 136245},
}
local known, names = {}, {}
for _, p in ipairs(professions) do known[p[1]] = p; names[p[2]] = p end
local db, panel, rows, footer, subtitle
local events = CreateFrame("Frame")
local minimapButton
local Say
local function TogglePanel()
    db.hidden=panel:IsShown()
    panel:SetShown(not db.hidden)
end

local function PositionMinimapButton()
    if not minimapButton or not Minimap then return end
    local angle = math.rad(db.minimapAngle or 220)
    local halfWidth, halfHeight = Minimap:GetWidth()/2, Minimap:GetHeight()/2
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle)*(halfWidth+10), math.sin(angle)*(halfHeight+10))
end

local function MakeMinimapButton()
    if not Minimap then return end
    minimapButton=CreateFrame("Button", "ProfessionPaceMinimapButton", Minimap)
    minimapButton:SetSize(32,32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(Minimap:GetFrameLevel()+8)
    minimapButton:EnableMouse(true)
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    local icon=minimapButton:CreateTexture(nil,"BACKGROUND")
    icon:SetTexture(136241)
    icon:SetSize(20,20)
    icon:SetPoint("CENTER")
    local border=minimapButton:CreateTexture(nil,"OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54,54)
    border:SetPoint("TOPLEFT")
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    minimapButton:SetScript("OnClick",function(_,button)
        if button == "RightButton" then
            db.locked=not db.locked
            Say(db.locked and "Panel locked." or "Panel unlocked.")
        else
            TogglePanel()
        end
    end)
    minimapButton:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_LEFT")
        GameTooltip:SetText("ProfessionPace")
        GameTooltip:AddLine("Left-click: show/hide professions",1,1,1)
        GameTooltip:AddLine("Right-click: lock/unlock panel",1,1,1)
        GameTooltip:AddLine("Drag: move around the minimap",0.8,0.8,0.8)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave",function() GameTooltip:Hide() end)
    minimapButton:SetScript("OnDragStart",function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate",function()
            local x,y=GetCursorPosition()
            local cx,cy=Minimap:GetCenter()
            local scale=Minimap:GetEffectiveScale()
            db.minimapAngle=math.deg(math.atan2(y/scale-cy,x/scale-cx))
            PositionMinimapButton()
        end)
    end)
    minimapButton:SetScript("OnDragStop",function(self) self:SetScript("OnUpdate",nil) end)
    PositionMinimapButton()
    minimapButton:SetShown(not db.minimapHidden)
end

Say = function(text)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd7b76dProfessionPace:|r " .. text)
end

local function ReadProfessions()
    local found = {}
    local function Add(id, name, rank, maxRank, icon, modifier)
        if not id or found[id] or not rank or rank <= 0 then return end
        local p = known[id]
        if not p then return end
        found[id] = {id=id, name=name or p[2], rank=rank, maxRank=maxRank,
            icon=icon or p[3], modifier=modifier or 0}
    end
    -- Forever: läs per ID, även om yrkesrubriken i Skills är hopfälld.
    if C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID then
        for _, p in ipairs(professions) do
            local ok, info = pcall(C_SkillInfo.GetSkillLineInfoByID, p[1])
            if ok and type(info) == "table" and not info.isHeader then
                Add(p[1], info.name, info.rank, info.maxRank or info.maxSkillRank,
                    p[3], info.modifier or info.skillModifier)
            end
        end
    end
    -- Alternativ API för klienter som exponerar professionerna direkt.
    if GetProfessions and GetProfessionInfo then
        local slots = {GetProfessions()}
        for i = 1, 6 do
            if slots[i] then
                local name, icon, rank, maxRank, _, _, id, modifier = GetProfessionInfo(slots[i])
                Add(id, name, rank, maxRank, icon, modifier)
            end
        end
    end
    -- Fallback, utan att ändra spelarens öppna/stängda Skills-rubriker.
    local modern = C_SkillInfo and C_SkillInfo.GetNumSkillLines and C_SkillInfo.GetSkillLineInfo
    local count = modern and C_SkillInfo.GetNumSkillLines() or (GetNumSkillLines and GetNumSkillLines() or 0)
    for i = 1, count do
        if modern then
            local info = C_SkillInfo.GetSkillLineInfo(i)
            if info and not info.isHeader then
                Add(info.skillID, info.name, info.rank, info.maxRank or info.maxSkillRank, nil,
                    info.modifier or info.skillModifier)
            end
        elseif GetSkillLineInfo then
            local name, header, _, rank, _, modifier, maxRank = GetSkillLineInfo(i)
            local p = names[name]
            if not header and p then Add(p[1], name, rank, maxRank, p[3], modifier) end
        end
    end
    local result = {}
    for _, p in ipairs(professions) do
        if found[p[1]] then result[#result + 1] = found[p[1]] end
    end
    return result
end

local function Text(parent, size, color)
    local f = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size)
    f:SetTextColor(unpack(color or {0.9, 0.91, 0.94}))
    f:SetJustifyH("LEFT")
    return f
end

local function RestorePosition()
    panel:ClearAllPoints()
    if db.point and db.x and db.y then
        panel:SetPoint(db.point, UIParent, db.point, db.x, db.y)
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    end
end

local function MakePanel()
    panel = CreateFrame("Frame", "ProfessionPaceFrame", UIParent, "BackdropTemplate")
    panel:SetSize(560, 280)
    panel:SetFrameStrata("MEDIUM")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    panel:SetBackdropColor(0.035, 0.045, 0.065, 0.96)
    panel:SetBackdropBorderColor(0.45, 0.36, 0.18, 1)
    panel:SetScript("OnDragStart", function(self) if not db.locked then self:StartMoving() end end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        db.point, db.x, db.y = point, x, y
    end)
    local title = Text(panel, 19, {0.91, 0.76, 0.43})
    title:SetPoint("TOPLEFT", 18, -17)
    title:SetText("ProfessionPace")
    subtitle = Text(panel, 12)
    subtitle:SetPoint("TOPLEFT", 18, -44)
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    close:SetScript("OnClick", function() db.hidden=true; panel:Hide() end)
    local headings = {{"PROFESSION",18}, {"SKILL",202}, {"TARGET",293}, {"AHEAD / BEHIND",376}}
    for _, item in ipairs(headings) do
        local t = Text(panel, 10, {0.56, 0.61, 0.69})
        t:SetPoint("TOPLEFT", item[2], -74); t:SetText(item[1])
    end
    footer = Text(panel, 11, {0.62, 0.66, 0.73})
    footer:SetPoint("BOTTOMLEFT", 18, 14)
    footer:SetWidth(520)
    footer:SetText("* Guideline: level × 5, max 300. Skinning: beasts at your level.\nDrag to move. /pp toggles this panel. /pp help lists commands.")
    rows = {}
    RestorePosition()
end

local function Refresh()
    if not panel then return end
    local level = UnitLevel("player")
    local list = ReadProfessions()
    subtitle:SetText(("Level %d  •  %d learned professions"):format(level, #list))
    panel:SetHeight(148 + math.max(1, #list) * 55)
    for _, row in ipairs(rows) do row:Hide() end
    for i, p in ipairs(list) do
        local row = rows[i]
        if not row then
            row = CreateFrame("Frame", nil, panel)
            row:SetSize(524, 52)
            row:EnableMouse(true)
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(24,24); row.icon:SetPoint("TOPLEFT",0,-3)
            row.name = Text(row, 13); row.name:SetPoint("TOPLEFT",32,-3); row.name:SetWidth(147)
            row.skill = Text(row, 13); row.skill:SetPoint("TOPLEFT",184,-3)
            row.target = Text(row, 13); row.target:SetPoint("TOPLEFT",275,-3)
            row.delta = Text(row, 13); row.delta:SetPoint("TOPLEFT",358,-3)
            row.detail = Text(row, 11, {0.62,0.67,0.75})
            row.detail:SetPoint("TOPLEFT",32,-25); row.detail:SetWidth(490)
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
                GameTooltip:SetText(self.data.name)
                GameTooltip:AddLine("Uses your base skill without temporary bonuses.",1,1,1,true)
                if self.data.id == 393 then
                    GameTooltip:AddLine("Skinning is compared with the requirement for beasts at your level. Some beasts may be exceptions.",0.9,0.8,0.5,true)
                else
                    GameTooltip:AddLine("Level × "..db.factor.." is your chosen guideline, not a game requirement. Recipes, nodes and fishing areas have their own requirements.",0.9,0.8,0.5,true)
                end
                if self.data.modifier ~= 0 then
                    GameTooltip:AddLine("Reported skill bonus: "..self.data.modifier,0.5,0.8,1)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            rows[i] = row
        end
        row:SetPoint("TOPLEFT",18,-95-(i-1)*55)
        row.data=p; row.icon:SetTexture(p.icon); row.name:SetText(p.name)
        row.skill:SetText(p.maxRank and (p.rank.."/"..p.maxRank) or tostring(p.rank))
        local target, delta, exact = L.Assess(p.id,p.rank,level,db.factor)
        row.target:SetText(target..(exact and "" or "*"))
        if delta < 0 then
            row.delta:SetTextColor(1,0.43,0.35); row.delta:SetText((-delta).." behind")
        elseif delta > 0 then
            row.delta:SetTextColor(0.4,0.88,0.64); row.delta:SetText(delta.." ahead")
        else
            row.delta:SetTextColor(0.91,0.76,0.43); row.delta:SetText("On track")
        end
        local detail = exact and ("Can skin beasts up to level "..L.SkinningMaxLevel(p.rank)) or "Approximate guideline for your level"
        if p.maxRank and p.rank >= p.maxRank and p.maxRank < 300 then
            detail = detail.."  •  Skill cap reached: check your trainer"
        elseif p.maxRank and target > p.maxRank then
            detail = detail.."  •  Target requires a higher profession rank"
        end
        row.detail:SetText(detail); row:Show()
    end
    if #list == 0 then
        subtitle:SetText("No professions found yet. Open Skills and try /pp refresh.")
    end
    footer:SetText(("* Guideline: level × %g, max 300. Skinning: beasts at your level.\nDrag to move. /pp toggles this panel. /pp help lists commands."):format(db.factor))
end

SLASH_PROFESSIONPACE1 = "/pp"
SLASH_PROFESSIONPACE2 = "/professionpace"
SlashCmdList.PROFESSIONPACE = function(message)
    if not db then return end
    local cmd = (message or ""):lower():match("^%s*(.-)%s*$")
    local factor = cmd:match("^target%s+([%d%.]+)$") or cmd:match("^mål%s+([%d%.]+)$") or cmd:match("^mal%s+([%d%.]+)$")
    if factor then
        factor = tonumber(factor)
        if not factor or factor < 1 or factor > 10 then Say("Enter a guideline between 1 and 10, e.g. /pp target 5."); return end
        db.factor=factor; Refresh(); Say("Guideline: level × "..factor..". Skinning still uses the beast requirement.")
    elseif cmd == "uppdatera" or cmd == "refresh" then Refresh()
    elseif cmd == "lås" or cmd == "las" or cmd == "lock" then
        db.locked = not db.locked; Say(db.locked and "Panel locked." or "Panel unlocked.")
    elseif cmd == "minimap" then
        db.minimapHidden=not db.minimapHidden
        if minimapButton then minimapButton:SetShown(not db.minimapHidden) end
    elseif cmd == "reset" then
        db.point,db.x,db.y=nil,nil,nil; db.hidden=false; db.locked=false
        RestorePosition(); panel:Show(); Refresh()
    elseif cmd == "" then
        db.hidden=panel:IsShown(); panel:SetShown(not db.hidden); Refresh()
    else
        Say("/pp: show/hide • /pp refresh • /pp lock • /pp reset • /pp target 5 • /pp minimap")
    end
end

local pending = false
local function QueueRefresh()
    if pending then return end
    pending=true
    C_Timer.After(0.2,function() pending=false; Refresh() end)
end
events:SetScript("OnEvent",function(_,event,arg)
    if event == "ADDON_LOADED" then
        if arg ~= ADDON then return end
        ProfessionPaceDB = type(ProfessionPaceDB) == "table" and ProfessionPaceDB or {}
        db = ProfessionPaceDB
        if type(db.factor) ~= "number" or db.factor < 1 or db.factor > 10 then db.factor=5 end
        MakePanel(); panel:SetShown(not db.hidden)
        MakeMinimapButton()
    elseif db then QueueRefresh() end
end)
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("SKILL_LINES_CHANGED")
events:RegisterEvent("CHAT_MSG_SKILL")
events:RegisterEvent("TRADE_SKILL_SHOW")
