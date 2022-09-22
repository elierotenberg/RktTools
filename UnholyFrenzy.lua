local targetMacro = {
    name = "Rkt_UF_Target",
    iconId = 254858,
    body =  function ()
        return "/run RktTools.UnholyFrenzy.setTarget(GetUnitName(\"target\"))"
    end,
    id = nil
}

local unholyFrenzySpellId = 49016
local unholyFrenzySpellName = GetSpellInfo(unholyFrenzySpellId)

local castMacro = {
    name = "Rkt_UF_Cast",
    iconId = 237512,
    body = function (targetName)
        return  "#showtooltip\n" ..
                "/cast [@" .. targetName .. ",help,exists,nodead]" .. unholyFrenzySpellName .. ";" .. unholyFrenzySpellName .. "\n" ..
                "/w " .. targetName .. " " .. unholyFrenzySpellName .. " on YOU!"
    end,
    id = nil
}

local function upsertMacro(macro, bodyArg)
    macro.id = GetMacroIndexByName(macro.name)
    local body = macro.body(bodyArg)
    if macro.id == 0 then
        CreateMacro(macro.name, macro.iconId, body, true)
---@diagnostic disable-next-line: redundant-parameter
    elseif GetMacroBody(macro.id) ~= body then
        EditMacro(macro.id, macro.name, macro.iconId, body)
    end
end


RktTools.UnholyFrenzy = {
    targetName = nil,
    print = function (message)
        print("[UnholyFrenzyHelper] " .. message)
    end,
    isTargetValid = function (targetName)
        if targetName == nil then
            return "No target"
        end
        if not UnitIsFriend("player", targetName) then
            return targetName .. " is not friendly."
        end
        if not UnitIsPlayer(targetName) and not UnitInRaid(targetName) and not UnitInParty(targetName) then
            return targetName .. " is not in your party or raid"
        end
        return true
    end,
    setTarget = function(targetName)
        local isTargetValidResult = RktTools.UnholyFrenzy.isTargetValid(targetName)
        if isTargetValidResult ~= true then
            RktTools.UnholyFrenzy.print(isTargetValidResult)
        else
            RktTools.UnholyFrenzy.targetName = targetName
            RktTools.UnholyFrenzy.print("Unholy Frenzy Helper Target is now " .. targetName)
            upsertMacro(castMacro, targetName)
        end
    end,
    printDiagnostics = function ()
        if RktTools.getPlayerEnglishClass() ~= "DEATHKNIGHT" or not IsSpellKnown(unholyFrenzySpellId) then
            return
        end
        local isTargetValidResult = RktTools.UnholyFrenzy.isTargetValid(RktTools.UnholyFrenzy.targetName)
        if isTargetValidResult ~= true then
            RktTools.UnholyFrenzy.print("Warning: " .. isTargetValidResult)
        end
    end
}


local function main()
    if RktTools.getPlayerEnglishClass() == "DEATHKNIGHT" then
        upsertMacro(targetMacro, nil)
    end
end

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
EventFrame:RegisterEvent("ZONE_CHANGED")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		C_Timer.After(1, main)
	end
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_ENTER_COMBAT" or event == "ZONE_CHANGED" then
        RktTools.UnholyFrenzy.printDiagnostics()
    end
end)