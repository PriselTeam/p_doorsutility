util.AddNetworkString("Prisel::DoorsUtility::SaveZone")

net.Receive("Prisel::DoorsUtility::SaveZone", function(len, ply)
    if not Prisel.DoorsUtility.StaffLists[ply:GetUserGroup()] then return end

    local start = net.ReadVector()
    local endpos = net.ReadVector()
    local price = net.ReadUInt(32)

    local doors = {}
    for k, v in pairs(ents.FindInBox(start, endpos)) do
        if Prisel.DoorsUtility.DoorList[v:GetClass()] then
            table.insert(doors, v)
        end
    end

    if #doors == 0 then return end

    Prisel.DoorsUtility:NewZone(start, endpos, doors, price)
end)