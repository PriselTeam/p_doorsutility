Prisel.DoorsUtility.Zones = Prisel.DoorsUtility.Zones or {}

function Prisel.DoorsUtility:Initialize()
    if not sql.TableExists("prisel_doorsutility") then
        sql.Query("CREATE TABLE prisel_doorsutility (id INTEGER PRIMARY KEY AUTOINCREMENT, start_pos TEXT, end_pos TEXT, doors TEXT)")
    end
end

function Prisel.DoorsUtility:NewZone(start, endpos, doors)
    start = {x = start.x, y = start.y, z = start.z}
    endpos = {x = endpos.x, y = endpos.y, z = endpos.z}
    
    for k, v in pairs(doors) do
        doors[k] = v:EntIndex()
    end
    
    local zone = {
        Start = start,
        End = endpos,
        Doors = doors,
    }

    table.insert(Prisel.DoorsUtility.Zones, zone)

    local query = ("INSERT INTO prisel_doorsutility (start_pos, end_pos, doors) VALUES ('%s', '%s', '%s')"):format(util.TableToJSON(start), util.TableToJSON(endpos), util.TableToJSON(doors))
    sql.Query(query)
end

function Prisel.DoorsUtility:LoadDoors()
    local query = "SELECT * FROM prisel_doorsutility"
    local data = sql.Query(query)
    if not data then return end

    for k, v in pairs(data) do
        local start = util.JSONToTable(v.start_pos)
        local endpos = util.JSONToTable(v.end_pos)
        local doors = util.JSONToTable(v.doors)

        Prisel.DoorsUtility.Zones[k] = {
            Start = start,
            End = endpos,
            Doors = doors,
        }
    end
end

function Prisel.DoorsUtility:GetOtherDoors(ent)
    local doors = {}
    for k, v in ipairs(Prisel.DoorsUtility.Zones) do
        for u, i in ipairs(v.Doors) do
            if Entity(i) == ent then
                doors = v.Doors
            end
        end
    end

    return doors
end

function Prisel.DoorsUtility:playerBuyDoor(ply, ent)
    local doors = Prisel.DoorsUtility:GetOtherDoors(ent)

    for k, v in ipairs(doors) do
        local vent = Entity(v)
        if vent:PRIsDoor() then
            vent:Fire("lock", "", 0)
            vent:Fire("unlock", "", 0)
            vent:keysOwn(ply)
        end
    end
end

function Prisel.DoorsUtility:playerSellDoor(ply, ent)
    local doors = Prisel.DoorsUtility:GetOtherDoors(ent)

    for k, v in ipairs(doors) do
        local vent = Entity(v)
        if vent:PRIsDoor() then
            vent:Fire("lock", "", 0)
            vent:Fire("unlock", "", 0)
            vent:keysUnOwn(ply)
        end
    end
end