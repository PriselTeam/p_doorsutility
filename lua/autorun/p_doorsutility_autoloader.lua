local basePath = "pdoors_utility/"

local function AddSVFile(path)
    if SERVER then
        include(basePath .. path)
    end
end

local function AddSHFile(path)
    AddCSLuaFile(basePath .. path)
    include(basePath .. path)
end

AddSHFile("config.lua")
AddSHFile("shared/utils.lua")

AddSVFile("server/sv_utils.lua")
AddSVFile("server/sv_functions.lua")
AddSVFile("server/sv_hooks.lua")
AddSVFile("server/sv_nets.lua")
