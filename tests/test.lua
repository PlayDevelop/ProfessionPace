local ns = {}
assert(load(logicSource, "Logic.lua"))("ProfessionPace", ns)
local L = ns.Logic
local checks = 0
local function eq(actual, expected)
    assert(actual == expected, tostring(actual).." ~= "..tostring(expected))
    checks = checks + 1
end
eq(L.SkinningRequired(10),1)
eq(L.SkinningRequired(11),10)
eq(L.SkinningRequired(19),90)
eq(L.SkinningRequired(20),100)
eq(L.SkinningRequired(21),105)
eq(L.SkinningRequired(24),120)
eq(L.SkinningMaxLevel(87),18)
eq(L.SkinningMaxLevel(99),19)
eq(L.SkinningMaxLevel(100),20)
eq(L.SkinningMaxLevel(104),20)
eq(L.SkinningMaxLevel(105),21)
eq(L.SkinningMaxLevel(300),60)
for rank=1,300 do
    local level=L.SkinningMaxLevel(rank)
    assert(L.SkinningRequired(level)<=rank)
    if level<60 then assert(L.SkinningRequired(level+1)>rank) end
end
local target,delta,exact=L.Assess(393,87,24,5)
eq(target,120); eq(delta,-33); eq(exact,true)
target,delta,exact=L.Assess(165,150,24,5)
eq(target,120); eq(delta,30); eq(exact,false)
eq(L.Target(60,10),300)
eq(L.Target(24,4),96)

-- Lätt WoW-UI-mock: kör hela addonen och verifiera vad spelaren ser.
local objects, frames, timers = {}, {}, {}
local Methods = {}
function Methods:SetText(value) self.text=value end
function Methods:SetShown(value) self.shown=value end
function Methods:Show() self.shown=true end
function Methods:Hide() self.shown=false end
function Methods:IsShown() return self.shown end
function Methods:SetScript(event,fn) self.scripts[event]=fn end
function Methods:GetPoint() return "CENTER",nil,"CENTER",12,34 end
function Methods:CreateFontString() local o=setmetatable({scripts={}}, {__index=Methods}); objects[#objects+1]=o; return o end
Methods.CreateTexture=Methods.CreateFontString
setmetatable(Methods,{__index=function() return function() end end})
function CreateFrame(_,name)
    local frame=setmetatable({scripts={},shown=true,name=name},{__index=Methods})
    frames[#frames+1]=frame
    if name then _G[name]=frame end
    return frame
end
function UnitLevel() return 24 end
UIParent={}; SlashCmdList={}; DEFAULT_CHAT_FRAME=setmetatable({},{__index=Methods})
Minimap=setmetatable({},{__index=Methods})
function Minimap:GetWidth() return 140 end
function Minimap:GetHeight() return 140 end
function Minimap:GetFrameLevel() return 2 end
GameTooltip=setmetatable({},{__index=Methods})
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
C_SkillInfo={GetSkillLineInfoByID=function(id)
    if id==393 then return {name="Skinning",rank=87,maxRank=150} end
    if id==165 then return {name="Leatherworking",rank=75,maxRank=75} end
    if id==185 then return {name="Cooking",rank=1,maxRank=75} end
end}
unpack=table.unpack
assert(load(addonSource,"ProfessionPace.lua"))("ProfessionPace",ns)
local events=frames[1]
events.scripts.OnEvent(events,"ADDON_LOADED","ProfessionPace")
events.scripts.OnEvent(events,"PLAYER_ENTERING_WORLD")
local function flush() local t=timers; timers={}; for _,fn in ipairs(t) do fn() end end
flush()
local function visibleText(text)
    for _,o in ipairs(objects) do if o.text==text then return true end end
    return false
end
eq(visibleText("33 behind"),true)
eq(visibleText("Can skin beasts up to level 18"),true)
eq(visibleText("75/75"),true)
eq(visibleText("Level 24  •  3 learned professions"),true)
SlashCmdList.PROFESSIONPACE("")
eq(ProfessionPaceFrame:IsShown(),false)
SlashCmdList.PROFESSIONPACE("reset")
eq(ProfessionPaceFrame:IsShown(),true)
SlashCmdList.PROFESSIONPACE("target 4")
eq(ProfessionPaceDB.factor,4)
eq(visibleText("33 behind"),true) -- skinning-målet ändras inte
SlashCmdList.PROFESSIONPACE("target 0")
eq(ProfessionPaceDB.factor,4)
SlashCmdList.PROFESSIONPACE("lock")
eq(ProfessionPaceDB.locked,true)
-- Profession-API med tomma platser: Cooking/Fishing får inte hoppas över.
C_SkillInfo=nil
function GetProfessions() return 1,nil,3,4,5 end
function GetProfessionInfo(index)
    local ids={[1]=393,[3]=129,[4]=185,[5]=356}
    return "Yrke"..index,nil,100,150,nil,nil,ids[index],0
end
SlashCmdList.PROFESSIONPACE("refresh")
eq(visibleText("Level 24  •  4 learned professions"),true)
-- Inget skilltak får hittas på när API:t inte ger det.
C_SkillInfo={GetSkillLineInfoByID=function(id)
    if id==393 then return {name="Skinning",rank=87} end
end}
GetProfessions=nil; GetProfessionInfo=nil
SlashCmdList.PROFESSIONPACE("refresh")
eq(visibleText("87"),true)
-- Leveluppdatering använder den nya leveln behind eventets fördröjning.
function UnitLevel() return 25 end
events.scripts.OnEvent(events,"PLAYER_LEVEL_UP",25)
flush()
eq(visibleText("38 behind"),true)
local button=ProfessionPaceMinimapButton
eq(button:IsShown(),true)
local wasShown=ProfessionPaceFrame:IsShown()
button.scripts.OnClick(button,"LeftButton")
eq(ProfessionPaceFrame:IsShown(),not wasShown)
button.scripts.OnClick(button,"RightButton")
eq(ProfessionPaceDB.locked,false)
SlashCmdList.PROFESSIONPACE("minimap")
eq(button:IsShown(),false)
SlashCmdList.PROFESSIONPACE("minimap")
eq(button:IsShown(),true)
print("OK: "..checks.." kontroller + 300 skinning-gränsfall; UI och API-fallback körda.")
