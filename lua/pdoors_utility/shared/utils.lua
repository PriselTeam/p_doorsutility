local ENTITY = FindMetaTable("Entity")

function ENTITY:PRIsDoor()
    if not IsValid(self) then return false end
    return Prisel.DoorsUtility.DoorList[self:GetClass()]
end