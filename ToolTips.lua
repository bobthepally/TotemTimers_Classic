-- Copyright © 2008 - 2012 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current distribution permissions only include curse.com, wowinterface.com and their respective addon updaters

if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers", true)

local SpellNames = TotemTimers.SpellNames

local r = 0
local g = 0.9
local b = 1


local function SetTooltipSpellID(id)
    local name = GetSpellInfo(id)
    local _,_,_,_,_,_,maxSpellID = GetSpellInfo(name)
    if GetCVar("UberTooltips") == "1" then
         GameTooltip:SetSpellByID(maxSpellID)
    else
        GameTooltip:ClearLines()
        GameTooltip:AddLine(SpellNames[id],1,1,1)
    end
end

function TotemTimers.PositionTooltip(self)
    if not TotemTimers.ActiveProfile.TooltipsAtButtons then 
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
    else
        local left = self:GetLeft()
        if left<UIParent:GetWidth()/2 then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        else			
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        end
    end
end

function TotemTimers.HideTooltip(self)
    GameTooltip:Hide()
end

function TotemTimers.timerTooltip(self)
    if false and self.timer and self.element and not IsModifierKeyDown() and TotemTimers.ActiveProfile.ShowRaidRangeTooltip then
        if self.timer.timers[1] <= 0 then return end
        local count = TotemTimers.GetOutOfRange(self.element)
        if count <= 0 then return end
        local missingBuffGUIDs, names, classes = TotemTimers.GetOutOfRangePlayers(self.element)
        GameTooltip:ClearLines()
        TotemTimers.PositionTooltip(self)
        for guid,_ in pairs(missingBuffGUIDs) do
            GameTooltip:AddLine(names[guid], RAID_CLASS_COLORS[classes[guid]].r, RAID_CLASS_COLORS[classes[guid]].g, RAID_CLASS_COLORS[classes[guid]].b)
        end
        GameTooltip:Show()
    elseif self:GetAttribute("tooltip") then
        local spell = self:GetAttribute("*spell1")
		if spell and type(spell) == "string" then spell = select(7, GetSpellInfo(spell)) end
        if spell and spell > 0 then
            TotemTimers.PositionTooltip(self)
            SetTooltipSpellID(spell)
			local rank = GetSpellSubtext(spell)
			if rank and rank ~= "" then 
				GameTooltip:AddLine( "(" .. rank ..")" )
			end
        end
    end
end


function TotemTimers.TotemTooltip(self)
    if not self:GetAttribute("tooltip") then return end
    local spell = self:GetAttribute("*spell1")
    if spell and type(spell) == "string" then spell = select(7, GetSpellInfo(spell)) end
    TotemTimers.PositionTooltip(self)
    if spell and spell > 0 then
        SetTooltipSpellID(spell)
		local rank = GetSpellSubtext(spell)
		if rank and rank ~= "" then 
			GameTooltip:AddLine( "(" .. rank ..")" )
		end
    end
    GameTooltip:AddLine(" ")
	local name,_,texture = GetSpellInfo(spell)
	if name ~= nil then
		GameTooltip:AddLine(format(L["Leftclick: %s"], "|T"..texture..":0|t "..name),r,g,b,1)
	end
    GameTooltip:AddLine(L["Rightclick to assign totem to timer button"],r,g,b,1)
    GameTooltip:Show()
end


function TotemTimers.SetTooltip(self)
    if not self:GetAttribute("tooltip") then return end
    TotemTimers.PositionTooltip(self)
    GameTooltip:AddLine(L["Leftclick to open totem set menu"],r,g,b,1)
    GameTooltip:AddLine(L["Rightclick to save active totem configuration as set"],r,g,b,1)
    GameTooltip:Show()
end

function TotemTimers.SetButtonTooltip(self)
    TotemTimers.PositionTooltip(self)
	GameTooltip:AddLine("Totem Set "..self.nr,1,1,1,1)
	local set = TotemTimers.ActiveProfile.TotemSets[self.nr]

	if set then 
		for i=1,4 do
			local name,_,texture = GetSpellInfo(set[i])

			GameTooltip:AddLine("|T"..texture..":0|t "..name,1,1,1,1)
			
		end            
	end
    GameTooltip:AddLine(L["Leftclick to load totem set"],r,g,b,1)
    GameTooltip:AddLine(L["Rightclick to delete totem set"],r,g,b,1)
    GameTooltip:Show()
end

function TotemTimers.WeaponButtonTooltip(self)
    if not self:GetAttribute("tooltip")  then return end

    GameTooltip:ClearLines()
    TotemTimers.PositionTooltip(self)
	GameTooltip:AddLine("Weapon buffs:")
    local we = TotemTimers.WeaponEnchants
	local enchant, expiration, _, mainID, offenchant, offExpiration, _, offID = GetWeaponEnchantInfo()
	if enchant and expiration > 0 then
		local spell, _, icon = GetSpellInfo(we[mainID])
		if spell then
			GameTooltip:AddLine("MainHand: |T"..icon..":0|t "..spell)
		end
	end
	if offenchant and offExpiration > 0 then
		local spell, _, icon = GetSpellInfo(we[offID])
		if spell then
			GameTooltip:AddLine("OffHand: |T"..icon..":0|t "..spell)
		end
	end
	
		GameTooltip:AddLine(" ")
    local s = self:GetAttribute("spell1")
	
    if s and not self:GetAttribute("doublespell1") then
        local name,_,texture = GetSpellInfo(s)
        if name ~= nil then
            text = format(L["Leftclick: %s"], "|T"..texture..":0|t "..name)
            GameTooltip:AddLine(text,r,g,b,1)
	end
    else
		local ds1 = self:GetAttribute("doublespell1")
		local ds2 = self:GetAttribute("doublespell2")
		if ds1 then
			local name,_,texture = GetSpellInfo(ds1)
			ds1 = "|T"..texture..":0|t "..name
			GameTooltip:AddLine(format(L["Leftclick MainHand: %s"], ds1),r,g,b,1)
		end
		if ds2 then
			name,_,texture = GetSpellInfo(ds2)
			ds2 = "|T"..texture..":0|t "..name
			GameTooltip:AddLine(format(L["Rightclick OffHand: %s"], ds2),r,g,b,1)
	end
	end
	GameTooltip:AddLine(L["Ctrl-Leftclick remove MainHand buff"],r,g,b,1)
	GameTooltip:AddLine(L["Ctrl-Rightclick remove OffHand buff"],r,g,b,1)
	GameTooltip:Show()
end

function TotemTimers.WeaponBarTooltip(self)

    if not self:GetAttribute("tooltip")   then return end

    GameTooltip:ClearLines()
    TotemTimers.PositionTooltip(self)
	local spell = self:GetAttribute("spell1")
--	_G.DevTools_Dump(spell)
    if spell and not self:GetAttribute("doublespell1") then
		if spell and type(spell) == "string" then spell = select(7, GetSpellInfo(spell)) end
        local name,_,texture = GetSpellInfo(spell)
        if name ~= nil then
			SetTooltipSpellID(spell)
			GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["Leftclick apply to MainHand"],r,g,b,1)
			GameTooltip:AddLine(L["Rightclick assign spell to MainHand buff timer"],r,g,b,1)
			
        end
    else
 		local ds1 = self:GetAttribute("doublespell1")
		local ds2 = self:GetAttribute("doublespell2")
		if ds1 and type(ds1) == "string" then ds1 = select(7, GetSpellInfo(ds1)) end
		if ds1 then
			SetTooltipSpellID(ds1)
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(L["Leftclick apply to MainHand"],r,g,b,1)
		GameTooltip:AddLine(L["Rightclick apply to Offhand"],r,g,b,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Shift-Leftclick assign spell to MainHand buff timer"],r,g,b,1)
		GameTooltip:AddLine(L["Shift-Rightclick assign spell to Offhand buff timer"],r,g,b,1)
    end
	GameTooltip:Show()
end

function TotemTimers.ShieldTooltip(self)
	if not self:GetAttribute("tooltip")  then return end
    GameTooltip:ClearLines()
    TotemTimers.PositionTooltip(self)
	
	local aspell = self.shield
	local spell1 = self:GetAttribute("*spell1")
	local spell2 = self:GetAttribute("*spell2")
	if aspell and type(aspell) == "string" then aspell = select(7, GetSpellInfo(aspell)) end
	if aspell ~= nil then
		SetTooltipSpellID(aspell)
		GameTooltip:AddLine(" ")
		end
	if spell1 and type(spell1) == "string" then spell1 = select(7, GetSpellInfo(spell1)) end
	local name,_,texture = GetSpellInfo(spell1)
	if name ~= nil then
		GameTooltip:AddLine(format(L["Leftclick: %s"], "|T"..texture..":0|t "..name),r,g,b,1)
	end
	if spell2 and type(spell2) == "string" then spell2 = select(7, GetSpellInfo(spell2)) end
	local name,_,texture = GetSpellInfo(spell2)
        if name ~= nil then
		GameTooltip:AddLine(format(L["Rightclick: %s"], "|T"..texture..":0|t "..name),r,g,b,1)
        end
    GameTooltip:Show()
end
