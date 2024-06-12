AddCSLuaFile()
TOOL.Category = "Prisel"
TOOL.Name = "Prisel - Doors Utility"
TOOL.Author = "Ekali"

if CLIENT then

    local cooldown = 0
    local bViewZone = false

    TOOL.Information = {
		{name = "left"},
		{name = "right"},
		{name = "reload"},
	}

    Prisel.DoorsUtility.ToolSettings = {
        Start = nil,
        End = nil,
        Price = 0,
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

        if Prisel.DoorsUtility.Zones then
            for k, v in ipairs(Prisel.DoorsUtility.Zones) do

                local vStart = Vector(v.Start.x, v.Start.y, v.Start.z)
         
                if vStart:DistToSqr(LocalPlayer():GetPos()) > 1024^2 then continue end

                local vecStart = vStart:ToScreen()
                local vecEnd = Vector(v.End.x, v.End.y, v.End.z):ToScreen()

                -- center of the zone
                local center = Vector((v.Start.x + v.End.x) / 2, (v.Start.y + v.End.y) / 2, (v.Start.z + v.End.z) / 2):ToScreen()

                draw.SimpleText("Zone #"..k, PLib:Font("SemiBold", 32), center.x, center.y - 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(DarkRP.formatMoney(tonumber(v.Price)), PLib:Font("SemiBold", 24), center.x, center.y - 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
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

        if Prisel.DoorsUtility.Zones then
            for k, v in ipairs(Prisel.DoorsUtility.Zones) do
                local vecStart = Vector(v.Start.x, v.Start.y, v.Start.z)
                local vecEnd = Vector(v.End.x, v.End.y, v.End.z)

                if not vecStart:ToScreen().visible then
                    continue
                end

                render.SetColorMaterial()
                render.DrawBox(vecStart, angle_zero, -x, x, PLib.Constants.Colors["green"], true)
                render.DrawBox(vecEnd, angle_zero, x, -x, PLib.Constants.Colors["green"], true)
                render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), vecStart, vecEnd, PLib.Constants.Colors["hoverGreen"], true)
            end
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
        draw.SimpleText(DarkRP.formatMoney(tonumber(Prisel.DoorsUtility.ToolSettings.Price)), PLib:Font("SemiBold", 32), w / 2, h / 2 + 50, PLib.Constants.Colors["blue"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

    function Prisel.DoorsUtility:SaveZone()
        if not Prisel.DoorsUtility.StaffLists[LocalPlayer():GetUserGroup()] then return end

        if not Prisel.DoorsUtility.ToolSettings.Start or not Prisel.DoorsUtility.ToolSettings.End then return end

        if #Prisel.DoorsUtility.ToolSettings.Doors == 0 then return end
        if Prisel.DoorsUtility.ToolSettings.Price == 0 then return end
        if not tonumber(Prisel.DoorsUtility.ToolSettings.Price) then return end

        net.Start("Prisel::DoorsUtility::SaveZone")
            net.WriteVector(Prisel.DoorsUtility.ToolSettings.Start)
            net.WriteVector(Prisel.DoorsUtility.ToolSettings.End)
            net.WriteUInt(Prisel.DoorsUtility.ToolSettings.Price, 32)
        net.SendToServer()

        Prisel.DoorsUtility.ToolSettings.Start = nil
        Prisel.DoorsUtility.ToolSettings.End = nil
        Prisel.DoorsUtility.ToolSettings.Price = 0
        Prisel.DoorsUtility.ToolSettings.Doors = {}

        notification.AddLegacy("Zone sauvegardée", NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button24.wav")
    end

    function Prisel.DoorsUtility:ResetZone()
        Prisel.DoorsUtility.ToolSettings.Start = nil
        Prisel.DoorsUtility.ToolSettings.End = nil
        Prisel.DoorsUtility.ToolSettings.Price = 0
        Prisel.DoorsUtility.ToolSettings.Doors = {}

        notification.AddLegacy("Zone Reset", NOTIFY_GENERIC, 5)
    end

    function TOOL.BuildCPanel(CPanel)

        function CPanel:Paint(w, h)
            surface.SetDrawColor(PLib.Constants.Colors["background"])
            surface.SetMaterial(Material("vgui/white"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        local priceEntry = vgui.Create("DTextEntry", CPanel)
        priceEntry:Dock(TOP)
        priceEntry:DockMargin(RX(20), RY(10), RX(20), 0)
        priceEntry:SetPlaceholderText("Prix de la zone")
        priceEntry:SetFont(PLib:Font("Regular", 16))
        priceEntry:SetValue("0")
        priceEntry:SetNumeric(true)
        priceEntry:SetDrawLanguageID(false)

        function priceEntry:OnChange()

            if (not tonumber(self:GetValue())) or self:GetValue() == nil then
                self:SetValue("0")
                Prisel.DoorsUtility.ToolSettings.Price = 0
                return
            end

            Prisel.DoorsUtility.ToolSettings.Price = tonumber(self:GetValue())
        end

        function priceEntry:OnEnter()
            if (not tonumber(self:GetValue())) or self:GetValue() == nil then
                self:SetValue("0")
                Prisel.DoorsUtility.ToolSettings.Price = 0
                return
            end

            Prisel.DoorsUtility.ToolSettings.Price = tonumber(self:GetValue())
        end

        local saveButton = vgui.Create("DButton", CPanel)
        saveButton:Dock(TOP)
        saveButton:DockMargin(RX(20), RY(10), RX(20), 0)
        saveButton:SetText("Sauvegarder la zone")
        saveButton:SetTextColor(color_white)
        saveButton:SetFont(PLib:Font("Bold", 16))
        saveButton.Paint = function(self, w, h)
            surface.SetDrawColor(PLib.Constants.Colors["blue"])
            surface.SetMaterial(Material("vgui/white"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        saveButton.DoClick = function()
            Prisel.DoorsUtility:SaveZone()
        end

        local resetButton = vgui.Create("DButton", CPanel)
        resetButton:Dock(TOP)
        resetButton:DockMargin(RX(20), RY(10), RX(20), RY(10))
        resetButton:SetText("Reset la zone")
        resetButton:SetTextColor(color_white)
        resetButton:SetFont(PLib:Font("Bold", 16))
        resetButton.Paint = function(self, w, h)
            surface.SetDrawColor(PLib.Constants.Colors["red"])
            surface.SetMaterial(Material("vgui/white"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        resetButton.DoClick = function()
            Prisel.DoorsUtility:ResetZone()
        end
        
        local viewZones = vgui.Create("DButton", CPanel)
        viewZones:Dock(TOP)
        viewZones:DockMargin(RX(20), RY(10), RX(20), RY(10))
        viewZones:SetText("Voir toutes les zones")
        viewZones:SetTextColor(color_white)
        viewZones:SetFont(PLib:Font("Bold", 16))
        viewZones.Paint = function(self, w, h)
            surface.SetDrawColor(PLib.Constants.Colors["hoverBlue"])
            surface.SetMaterial(Material("vgui/white"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        viewZones.DoClick = function(self)
            if not bViewZone then
                net.Start("Prisel::DoorsUtility::ViewZones")
                net.SendToServer()
                self:SetText("Cacher toutes les zones")

                net.Receive("Prisel::DoorsUtility::ViewZones", function()
                    local zones = net.ReadTable()
                    Prisel.DoorsUtility.Zones = zones
                end)
                bViewZone = true
            else
                Prisel.DoorsUtility.Zones = {}
                bViewZone = false 
                self:SetText("Voir toutes les zones")
            end
        end
    end

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
        Prisel.DoorsUtility.ToolSettings.Price = 0
        Prisel.DoorsUtility.ToolSettings.Doors = {}
    end

end