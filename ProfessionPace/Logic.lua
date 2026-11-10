local _, ns = ...
ns.Logic = {}
local L = ns.Logic

-- Detta är addonens valda riktvärde, inte ett krav från spelet.
function L.Target(level, factor)
    return math.max(1, math.min(300, math.floor(level * (factor or 5))))
end

-- Classic/Forever: nivå 1–10 kräver skill 1; 11–20 har annan formel.
function L.SkinningRequired(level)
    if level <= 10 then return 1 end
    if level <= 20 then return (level - 10) * 10 end
    return level * 5
end

function L.SkinningMaxLevel(skill)
    if skill < 1 then return 0 end
    if skill < 100 then return 10 + math.floor(skill / 10) end
    return math.min(60, math.floor(skill / 5))
end

function L.Assess(id, rank, level, factor)
    local exact = id == 393
    local target = exact and L.SkinningRequired(math.min(level, 60)) or L.Target(level, factor)
    return target, rank - target, exact
end
