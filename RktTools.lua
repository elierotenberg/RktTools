RktTools = {
    isDebug = true,
    debug = function (message)
        if RktTools.isDebug then
            print(message)
        end
    end,
    getPlayerEnglishClass = function ()
        local _localizedClass, englishClass = UnitClass("player")
        return englishClass
    end
}