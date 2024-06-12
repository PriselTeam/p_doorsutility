util.AddNetworkString("Prisel::DoorsUtility::SaveZone")
util.AddNetworkString("Prisel::DoorsUtility::ViewZones")

local cooldown = {}

net.Receive("Prisel::DoorsUtility::SaveZone", function(len, ply)
    if not Prisel.DoorsUtility.StaffLists[ply:GetUserGroup()] then return end

    if cooldown[ply] and cooldown[ply] > CurTime() then return end

    cooldown[ply] = CurTime() + 1

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

net.Receive("Prisel::DoorsUtility::ViewZones", function(len, ply)
    if not Prisel.DoorsUtility.StaffLists[ply:GetUserGroup()] then return end
    if cooldown[ply] and cooldown[ply] > CurTime() then return end

    cooldown[ply] = CurTime() + 1

    net.Start("Prisel::DoorsUtility::ViewZones")
        net.WriteTable(Prisel.DoorsUtility.Zones)
    net.Send(ply)
end)