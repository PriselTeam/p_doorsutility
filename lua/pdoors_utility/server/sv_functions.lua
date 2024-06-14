Prisel.DoorsUtility.Zones = Prisel.DoorsUtility.Zones or {}

function Prisel.DoorsUtility:Initialize()
    if not sql.TableExists("prisel_doorsutility") then
        sql.Query("CREATE TABLE prisel_doorsutility (id INTEGER PRIMARY KEY AUTOINCREMENT, start_pos TEXT, end_pos TEXT, doors TEXT, price INT)")
    end
end

function Prisel.DoorsUtility:NewZone(start, endpos, doors, price)
    start = {x = start.x, y = start.y, z = start.z}
    endpos = {x = endpos.x, y = endpos.y, z = endpos.z}
    
    for k, v in pairs(doors) do
        doors[k] = v:EntIndex()
    end
    
    local zone = {
        Start = start,
        End = endpos,
        Doors = doors,
        Price = price
    }

    table.insert(Prisel.DoorsUtility.Zones, zone)

    local query = ("INSERT INTO prisel_doorsutility (start_pos, end_pos, doors, price) VALUES ('%s', '%s', '%s', %i)"):format(util.TableToJSON(start), util.TableToJSON(endpos), util.TableToJSON(doors), price)
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
        local price = v.price

        Prisel.DoorsUtility.Zones[k] = {
            Start = start,
            End = endpos,
            Doors = doors,
            Price = price
        }
    end
end

function Prisel.DoorsUtility:GetOtherDoors(ent)
    local doors = {}
    for k, v in ipairs(Prisel.DoorsUtility.Zones) do
        for u, i in ipairs(v.Doors) do
            if Entity(i) == ent then
                doors = v.Doors
                doors.price = v.Price
            end
        end
    end

    return doors
end

function Prisel.DoorsUtility:playerBuyDoor(ply, ent)
    local doors = Prisel.DoorsUtility:GetOtherDoors(ent)

    if #doors <= 0 then
        return false
    end

    if not ply:canAfford(doors.price) then
        DarkRP.notify(ply, 1, 4, "Vous n'avez pas assez d'argent pour acheter cette maison. [Prix: " .. doors.price .. "€]")
    return end
    
    ply:addMoney(-doors.price)

    for k, v in ipairs(doors) do
        local vent = Entity(v)
        if vent:PRIsDoor() then
            vent:Fire("lock", "", 0)
            vent:Fire("unlock", "", 0)
            vent:keysOwn(ply)
        end
    end

    DarkRP.notify(ply, 0, 4, "Vous avez acheté cette maison pour " .. doors.price .. "€")
    return true
end

function Prisel.DoorsUtility:playerSellDoor(ply, ent)
    local doors = Prisel.DoorsUtility:GetOtherDoors(ent)

    if #doors <= 0 then
        return false
    end

    local price = math.floor(doors.price / 2)

    for k, v in ipairs(doors) do
        local vent = Entity(v)
        if vent:PRIsDoor() then
            vent:Fire("lock", "", 0)
            vent:Fire("unlock", "", 0)
            vent:keysUnOwn(ply)
        end
    end
    
    ply:addMoney(price)
    DarkRP.notify(ply, 0, 4, "Vous avez vendu cette maison pour " .. price .. "€")
    return true
end