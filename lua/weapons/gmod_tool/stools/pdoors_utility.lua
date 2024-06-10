AddCSLuaFile()
TOOL.Category = "Prisel"
TOOL.Name = "Prisel - Doors Utility"
TOOL.Author = "Ekali"

if CLIENT then

    local cooldown = 0

    TOOL.Information = {
		{name = "left"},
		{name = "right"},
		{name = "reload"},
	}

    Prisel.DoorsUtility.ToolSettings = {
        Start = nil,
        End = nil,
        Doors = {}
    }
    
	local function reloadToolInfo()
		language.Add("tool.pdoors_utility.name", "Prisel • Doors Utility")
		language.Add("tool.pdoors_utility.desc", "")
		
		language.Add("tool.pdoors_utility.left", "Début d'une zone")
		language.Add("tool.pdoors_utility.right", "Fin d'une zone")
		language.Add("tool.pdoors_utility.reload", "Reset")
	end

	reloadToolInfo()

    function TOOL:Deploy()
    end

    hook.Add("HUDPaint", "Prisel::DoorsUtility::TOOLPaint", function()

        if not Prisel.DoorsUtility.StaffLists[LocalPlayer():GetUserGroup()] then return end

        if not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" or LocalPlayer():GetActiveWeapon():GetMode() ~= "pdoors_utility" then return end

        local startPos = Prisel.DoorsUtility.ToolSettings.Start
        local endPos = Prisel.DoorsUtility.ToolSettings.End

        if startPos then
            local startScreen = startPos:ToScreen()
            draw.SimpleText("Start", PLib:Font("Bold", 32), startScreen.x, startScreen.y - 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if endPos then
            local endScreen = endPos:ToScreen()
            draw.SimpleText("End", PLib:Font("Bold", 32), endScreen.x, endScreen.y - 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        for k, v in pairs(Prisel.DoorsUtility.ToolSettings.Doors) do
            local entCenter = v.Ent:LocalToWorld(v.Ent:OBBCenter()):ToScreen()

            draw.SimpleText("Door #"..k .. " [" .. v.Ent:EntIndex().."]", PLib:Font("SemiBold", 12), entCenter.x, entCenter.y - 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

    end)

    local x = Vector( 5, 5, 5 )

    hook.Add("PostDrawTranslucentRenderables", "Prisel::DoorsUtility::ToolPDTR", function()
        if not Prisel.DoorsUtility.StaffLists[LocalPlayer():GetUserGroup()] then return end


        if not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" or LocalPlayer():GetActiveWeapon():GetMode() ~= "pdoors_utility" then return end

        local startPos = Prisel.DoorsUtility.ToolSettings.Start
        local endPos = Prisel.DoorsUtility.ToolSettings.End

        if startPos then
            
            render.SetColorMaterial()
            render.DrawBox(startPos, angle_zero, -x, x, PLib.Constants.Colors["blue"], true)
        end

        if endPos then
            render.SetColorMaterial()
            render.DrawBox(endPos, angle_zero, x, -x, PLib.Constants.Colors["blue"], true)
        end

        if startPos and endPos then
            render.SetColorMaterial()
            render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), startPos, endPos, PLib.Constants.Colors["hoverBlue"], true)
        end
        
        for k, v in pairs(Prisel.DoorsUtility.ToolSettings.Doors) do
            local ent = v.Ent
            local pos = ent:GetPos()
            local mins, maxs = ent:LocalToWorld(ent:OBBMins()), ent:LocalToWorld(ent:OBBMaxs())
            render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), mins, maxs, Color(37, 197, 37), true)
        end
	end)
    
	function TOOL:DrawToolScreen(w, h)
		surface.SetDrawColor(PLib.Constants.Colors["background"])
		surface.SetMaterial(Material("vgui/white"))
		surface.DrawTexturedRect(0, 0, w, h)

        if not Prisel.DoorsUtility.StaffLists[LocalPlayer():GetUserGroup()] then 
            draw.SimpleText("PAS ACCÈS", PLib:Font("Bold", 46), w / 2, h / 2, PLib.Constants.Colors["red"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
        return end


        draw.SimpleText("Prisel Doors", PLib:Font("Bold", 46), w / 2, h / 2, PLib.Constants.Colors["blue"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

    function TOOL:LeftClick(trace)

        if cooldown > CurTime() then return end
        cooldown = CurTime() + 0.5

        Prisel.DoorsUtility.ToolSettings.Doors = {}

        Prisel.DoorsUtility.ToolSettings.Start = trace.HitPos
        if Prisel.DoorsUtility.ToolSettings.Start and Prisel.DoorsUtility.ToolSettings.End then
            for k, v in pairs(ents.FindInBox(Prisel.DoorsUtility.ToolSettings.Start, Prisel.DoorsUtility.ToolSettings.End)) do
                if v:PRIsDoor() then
                    table.insert(Prisel.DoorsUtility.ToolSettings.Doors, {Start = v:LocalToWorld(v:OBBMins()), End = v:LocalToWorld(v:OBBMaxs()), Ent = v})
                end
            end
        end

        return true
    end

    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {Text = "Prisel Doors Utility", Description = "Outil de gestion des portes"})

        CPanel:AddControl("Button", {Label = "Reset", Command = "pdoors_utility_reload"})
        CPanel:AddControl("Button", {Label = "Save Zone", Command = "pdoors_utility_svz"})
    end

    concommand.Add("pdoors_utility_svz", function()

        if not Prisel.DoorsUtility.StaffLists[LocalPlayer():GetUserGroup()] then return end

        if not Prisel.DoorsUtility.ToolSettings.Start or not Prisel.DoorsUtility.ToolSettings.End then return end

        if #Prisel.DoorsUtility.ToolSettings.Doors == 0 then return end

        net.Start("Prisel::DoorsUtility::SaveZone")
        net.WriteVector(Prisel.DoorsUtility.ToolSettings.Start)
        net.WriteVector(Prisel.DoorsUtility.ToolSettings.End)
        net.SendToServer()

        Prisel.DoorsUtility.ToolSettings.Start = nil
        Prisel.DoorsUtility.ToolSettings.End = nil
        Prisel.DoorsUtility.ToolSettings.Doors = {}

        notification.AddLegacy("Zone sauvegardée", NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button24.wav")
    end)

    concommand.Add("pdoors_utility_reload", function()
        Prisel.DoorsUtility.ToolSettings.Start = nil
        Prisel.DoorsUtility.ToolSettings.End = nil
        Prisel.DoorsUtility.ToolSettings.Doors = {}

        notification.AddLegacy("Zone Reset", NOTIFY_GENERIC, 5)
    end)

    function TOOL:RightClick(trace)
        if cooldown > CurTime() then return end
        cooldown = CurTime() + 0.5

        Prisel.DoorsUtility.ToolSettings.Doors = {}

        Prisel.DoorsUtility.ToolSettings.End = trace.HitPos
        if Prisel.DoorsUtility.ToolSettings.Start and Prisel.DoorsUtility.ToolSettings.End then
            for k, v in pairs(ents.FindInBox(Prisel.DoorsUtility.ToolSettings.Start, Prisel.DoorsUtility.ToolSettings.End)) do
                if v:PRIsDoor() then
                    table.insert(Prisel.DoorsUtility.ToolSettings.Doors, {Start = v:LocalToWorld(v:OBBMins()), End = v:LocalToWorld(v:OBBMaxs()), Ent = v})
                end
            end
        end
        return true
    end


    function TOOL:Reload()
        Prisel.DoorsUtility.ToolSettings.Start = nil
        Prisel.DoorsUtility.ToolSettings.End = nil
        Prisel.DoorsUtility.ToolSettings.Doors = {}
    end

end