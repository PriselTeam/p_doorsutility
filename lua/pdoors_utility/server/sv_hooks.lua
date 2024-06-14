hook.Add("InitPostEntity", "Prisel::DoorsUtility::InitPostEntity", function()
    Prisel.DoorsUtility:Initialize()
    Prisel.DoorsUtility:LoadDoors()
end)

hook.Add("playerBuyDoor", "Prisel::DoorsUtility::playerBuyDoor", function(ply, ent)

    if Prisel.DoorsUtility:playerBuyDoor(ply, ent) then
        return false
    end

end)

hook.Add("playerSellDoor", "Prisel::DoorsUtility::playerSellDoor", function(ply, ent)

    if Prisel.DoorsUtility:playerSellDoor(ply, ent) then
        return false
    end

end)