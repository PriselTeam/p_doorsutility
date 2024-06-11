hook.Add("InitPostEntity", "Prisel::DoorsUtility::InitPostEntity", function()
    Prisel.DoorsUtility:Initialize()
    Prisel.DoorsUtility:LoadDoors()
end)

hook.Add("playerBuyDoor", "Prisel::DoorsUtility::playerBuyDoor", function(ply, ent)
    Prisel.DoorsUtility:playerBuyDoor(ply, ent)

    return false
end)

hook.Add("playerSellDoor", "Prisel::DoorsUtility::playerSellDoor", function(ply, ent)
    Prisel.DoorsUtility:playerSellDoor(ply, ent)

    return false
end)