-- Copyright © 2008 - 2012 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current distribution permissions only include curse.com, wowinterface.com and their respective addon updaters

if select(2, UnitClass("player")) ~= "SHAMAN" then
    return
end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers")

local Timers = XiTimers.timers
local SpellNames = TotemTimers.SpellNames
local SpellIDs = TotemTimers.SpellIDs
local SpellTextures = TotemTimers.SpellTextures
local AvailableSpells = TotemTimers.AvailableSpells
local AvailableTalents = TotemTimers.AvailableTalents

local earthShieldTarget = UnitName("player")
local earthShieldTargetGUID = nil

local earthshieldTimer = nil
local weapon = nil
local ankh = nil
local shield = nil

local playerName = UnitName("player")

local buttons = { "LeftButton", "RightButton", "MiddleButton", "Button4" }

local function splitString(ustring)
    local c = 0
    local s = ""
    for uchar in string.gmatch(ustring, "([%z\1-\127\194-\244][\128-\191]*)") do
        c = c + 1
        s = s .. uchar
        if c == 4 then
            break
        end
    end
    return s
end

local function AfterDrag()
	TotemTimers.ProcessSetting("SetsBarDirection")
	TotemTimers.ProcessSetting("ESMainTankMenuDirection")
	TotemTimers.ProcessSetting("WeaponBarDirection")
end

function TotemTimers.CreateTrackers()
	-- ankh tracker
    ankh = XiTimers:new(1)
    shield = XiTimers:new(1)
    earthshieldTimer = XiTimers:new(1)
    weapon = XiTimers:new(2)

	ankh.button:SetScript("OnEvent", TotemTimers.AnkhEvent)
	ankh.button.icons[1]:SetTexture(SpellTextures[SpellIDs.Ankh])
	ankh.events[1] = "SPELL_UPDATE_COOLDOWN"
	ankh.events[2] = "BAG_UPDATE"
	ankh.button.anchorframe = TotemTimers_TrackerFrame
	ankh.showCooldown = true
	ankh.dontAlpha = true
	ankh.button.icons[1]:SetAlpha(1)
	ankh.timeStyle = "blizz"
	ankh.Activate = function(self) 
        XiTimers.Activate(self) 
        TotemTimers.AnkhEvent(ankh.button, "SPELL_UPDATE_COOLDOWN")
        TotemTimers.AnkhEvent(ankh.button, "BAG_UPDATE")
        --TotemTimers.ProcessSetting("TimerSize")
    end
	ankh.button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    ankh.Deactivate = function(self)
        XiTimers.Deactivate(self)
        --TotemTimers.ProcessSetting("TimerSize")
    end
    ankh.button.cooldown.noCooldownCount = true
    ankh.button.cooldown.noOCC = true
    ankh.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
	    if TotemTimers.ActiveProfile.TrackerArrange == "free" then
			TotemTimers.ProcessSetting("SetsBarDirection")
		else
			AfterDrag()
		end
    end)
		
	shield.button.icons[1]:SetTexture(SpellTextures[SpellIDs.LightningShield])
	shield.button.anchorframe = TotemTimers_TrackerFrame
	shield.button:SetScript("OnEvent", TotemTimers.ShieldEvent)
	shield.events[1] = "UNIT_SPELLCAST_SUCCEEDED"
	shield.events[2] = "UNIT_AURA"
	shield.timeStyle = "blizz"
	shield.Activate = function(self)
        XiTimers.Activate(self)
        TotemTimers.ShieldEvent(self.button, "UNIT_AURA")
        if not TotemTimers.ActiveProfile.ShieldTracker then
            self.button:Hide()
        end
      end
	shield.button:SetAttribute("*type*", "spell")
    shield.button:SetAttribute("*unit*", "player")
	shield.button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    shield.button:SetAttribute("*spell1", SpellNames[SpellIDs.LightningShield])
    shield.button:SetAttribute("*spell2", SpellNames[SpellIDs.WaterShield])
    shield.button:SetAttribute("*spell3", SpellNames[SpellIDs.TotemicCall])
	shield.button.ShowTooltip = TotemTimers.ShieldTooltip
	shield.button.HideTooltip = TotemTimers.HideTooltip
	shield.button:SetAttribute("_onenter", [[ if self:GetAttribute("tooltip") then control:CallMethod("ShowTooltip") end]])
	shield.button:SetAttribute("_onleave", [[ control:CallMethod("HideTooltip") ]])
	
    shield.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
    end)


    earthshieldTimer.button.icons[1]:SetTexture(SpellTextures[SpellIDs.EarthShield])
    earthshieldTimer.button.anchorframe = TotemTimers_TrackerFrame
    earthshieldTimer.button:SetScript("OnEvent", TotemTimers.EarthShieldEvent)
    earthshieldTimer.events[1] = "COMBAT_LOG_EVENT_UNFILTERED"
    earthshieldTimer.events[2] = "UNIT_AURA"
    earthshieldTimer.events[3] = "GROUP_ROSTER_UPDATE"
    earthshieldTimer.events[4] = "PLAYER_REGEN_ENABLED"
    earthshieldTimer.events[5] = "PARTY_LEADER_CHANGED"
    earthshieldTimer.events[6] = "PLAYER_ENTERING_WORLD"
    earthshieldTimer.playerEvents[1] = "UNIT_SPELLCAST_SUCCEEDED"
    earthshieldTimer.events[7] = "UNIT_SPELLCAST_SENT"
    earthshieldTimer.timeStyle = "blizz"
    earthshieldTimer.button:SetAttribute("*type*", "spell")
    earthshieldTimer.Activate = function(self)
        XiTimers.Activate(self)
        self.button:SetAttribute("*spell*", SpellNames[SpellIDs.EarthShield])
        if not TotemTimers.ActiveProfile.EarthShieldTracker then
            self.button:Hide()
        end
    end
    earthshieldTimer.button:RegisterForClicks("LeftButtonDown", "RightButtonDown", "MiddleButtonDown", "Button4Down")
    earthshieldTimer.manaCheck = SpellNames[SpellIDs.EarthShield]
	earthshieldTimer.button.ShowTooltip = TotemTimers.ShieldTooltip
	earthshieldTimer.button.HideTooltip = TotemTimers.HideTooltip
	earthshieldTimer.button:SetAttribute("_onenter", [[ if self:GetAttribute("tooltip") then control:CallMethod("ShowTooltip") end]])
	earthshieldTimer.button:SetAttribute("_onleave", [[ control:CallMethod("HideTooltip") ]])
    earthshieldTimer.nameframe = CreateFrame("Frame", earthshieldTimer.button)
    earthshieldTimer.nameframe:SetParent(earthshieldTimer.button)
    earthshieldTimer.nameframe:SetPoint("TOPLEFT", earthshieldTimer.button)
    earthshieldTimer.nameframe:SetPoint("BOTTOMRIGHT", earthshieldTimer.button)
    earthshieldTimer.name = earthshieldTimer.nameframe:CreateFontString("TotemTimers_EarthShieldName")
    earthshieldTimer.name:SetPoint("TOP", earthshieldTimer.nameframe)
    earthshieldTimer.name:SetFont(earthshieldTimer.button.hotkey:GetFont())
    earthshieldTimer.nameframe:SetFrameLevel(10)

    earthshieldTimer.expirationMsgs[1] = "EarthShield"
    earthshieldTimer.earlyExpirationMsgs[1] = "EarthShield"
    earthshieldTimer.warningIcons[1] = SpellTextures[SpellIDs.EarthShield]
    earthshieldTimer.warningSpells[1] = SpellNames[SpellIDs.EarthShield]
    earthshieldTimer.warningPoint = 0

    earthshieldTimer.Stop = function(self, nr)
        XiTimers.Stop(self, nr)
        if earthShieldTarget then
            self.name:SetText(splitString(earthShieldTarget))
        end
    end

    earthshieldTimer.Start = function(self, nr, time, duration)
        XiTimers.Start(self, nr, time, duration)
        if earthShieldTarget then
            self.name:SetText(splitString(earthShieldTarget))
        end
    end

    --create maintank bar for es
    earthshieldTimer.actionBar = TTActionBars:new(4, earthshieldTimer.button, nil, TotemTimers_TrackerFrame)

    for i = 1, 4 do
        earthshieldTimer.button:WrapScript(earthshieldTimer.actionBar.buttons[i], "PostClick", [[
                local p = self:GetParent()
                local nr = p:GetAttribute("RecastButton")
                if nr then
                    p:SetAttribute("*unit"..nr, self:GetAttribute("*unit1"))
                    control:CallMethod("UpdateESName")
                end
        ]])
    end
    earthshieldTimer.button.UpdateESName = function(self)
        if self.timer.timers[1] <= 0 then
            local button = self:GetAttribute("RecastButton")
            if button then
                local unit = self:GetAttribute("*unit" .. button)
                if unit and UnitExists(unit) then
                    self.timer.name:SetText(splitString(UnitName(unit)))
                end
            end
        end
    end

    TotemTimers.SetEarthShieldMainTankList()

    earthshieldTimer.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
		if TotemTimers.ActiveProfile.TrackerArrange == "free" then
        TotemTimers.ProcessSetting("ESMainTankMenuDirection")
		else
			AfterDrag()
		end
        if not InCombatLockdown() then
            earthshieldTimer.button:SetAttribute("hide", true)
        end
    end)




    weapon.button.icons[1]:SetTexture(SpellTextures[SpellIDs.RockbiterWeapon])
--    if TotemTimers.ActiveProfile.LastWeaponEnchant == 5 or TotemTimers.ActiveProfile.LastWeaponEnchant == 6 then
--        weapon.button.icons[1]:SetTexture(SpellTextures[SpellIDs.WindfuryWeapon])
--        weapon.button.icons[2]:SetTexture(SpellTextures[TotemTimers.ActiveProfile.LastWeaponEnchant == 5 and SpellIDs.FlametongueWeapon or SpellIDs.FrostbrandWeapon])
--    else
        if TotemTimers.ActiveProfile.LastWeaponEnchant then
            local texture = SpellTextures[TotemTimers.NameToSpellID[TotemTimers.StripRank(TotemTimers.ActiveProfile.LastWeaponEnchant)]]
            weapon.button.icons[1]:SetTexture(texture)
            
        end
		if TotemTimers.ActiveProfile.LastWeaponEnchant2 then
            local texture = SpellTextures[TotemTimers.NameToSpellID[TotemTimers.StripRank(TotemTimers.ActiveProfile.LastWeaponEnchant2)]]
            weapon.button.icons[2]:SetTexture(texture)
            
        end
		
--    end
    weapon.button.anchorframe = TotemTimers_TrackerFrame
    weapon.timeStyle = "blizz"
    weapon.button:SetAttribute("*type*", "spell")
    weapon.button:SetAttribute("ctrl-spell1", ATTRIBUTE_NOOP)
    --weapon.button:RegisterEvent("PLAYER_ALIVE")
    weapon.Update = TotemTimers.WeaponUpdate
    weapon.button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    weapon.timerBars[1]:SetMinMaxValues(0, 1800)
    weapon.flashall = true
    weapon.Activate = function(self)
        XiTimers.Activate(self)
        if not TotemTimers.ActiveProfile.WeaponTracker then
            self.button:Hide()
        end
    end
    TotemTimers.SetNumWeaponTimers()

    weapon.button.HideTooltip =  TotemTimers.HideTooltip
    weapon.actionBar = TTActionBars:new(7, weapon.button, nil, TotemTimers_TrackerFrame, "weapontimer")
    weapon.button.ShowTooltip = TotemTimers.WeaponButtonTooltip
    weapon.button.SaveLastEnchant = function(self, name)
	--	_G.DevTools_Dump(name)
        if name == "spell1" and self:GetAttribute("spell1") then
            TotemTimers.ActiveProfile.LastWeaponEnchant = self:GetAttribute("spell1")
        elseif name == "spell2" or name == "spell3" then
            TotemTimers.ActiveProfile.LastWeaponEnchant2 = self:GetAttribute("spell2") or self:GetAttribute("spell3")
		elseif name == "doublespell1" and self:GetAttribute("doublespell1") then
			TotemTimers.ActiveProfile.LastWeaponEnchant = self:GetAttribute("doublespell1")
		elseif name == "doublespell2" and self:GetAttribute("doublespell2") then
			TotemTimers.ActiveProfile.LastWeaponEnchant2 = self:GetAttribute("doublespell2")
 --[[
            local ds1 = self:GetAttribute("doublespell1")
            local ds2 = self:GetAttribute("doublespell2")
            if ds2 then
                if ds1~=ds2 and ds2 == SpellNames[SpellIDs.FlametongueWeapon] then
                    TotemTimers.ActiveProfile.LastWeaponEnchant = 5
                elseif ds1~=ds2 and ds2 == SpellNames[SpellIDs.FrostbrandWeapon] then
                    TotemTimers.ActiveProfile.LastWeaponEnchant = 6
				else
					TotemTimers.ActiveProfile.LastWeaponEnchant = ds1
                end
            end
]]
        end
	TotemTimers.UpdateMacro()
    end
    weapon.button:SetAttribute("_onattributechanged", [[ if name == "spell1" or name == "doublespell1" or name == "doublespell2" or name == "spell2" or name == "spell3" then
                                                             control:CallMethod("SaveLastEnchant", name)
                                                           end]])
    -- weapon.button:WrapScript(weapon.button, "PostClick", [[ if button == "LeftButton" then
                                                                -- local ds1 = self:GetAttribute("doublespell1")
                                                                -- if ds1 then
                                                                    -- if IsControlKeyDown() or self:GetAttribute("ds") ~= 1 then
                                                                        -- self:SetAttribute("macrotext", "/cast [@none] ".. ds1 .."\n/use 16\n/click StaticPopup1Button1")
																		-- self:SetAttribute("ds",1)
                                                                    -- else
                                                                        -- self:SetAttribute("macrotext", "/cast [@none] "..self:GetAttribute("doublespell2").."\n/use 17\n/click StaticPopup1Button1")
																		-- self:SetAttribute("ds",2)
                                                                    -- end
                                                                -- end
                                                           -- end]])

    weapon.button:SetAttribute("ctrl-type1", "cancelaura")
    weapon.button:SetAttribute("ctrl-target-slot1", GetInventorySlotInfo("MainHandSlot"))
    weapon.button:SetAttribute("ctrl-type2", "cancelaura")
    weapon.button:SetAttribute("ctrl-target-slot2", GetInventorySlotInfo("SecondaryHandSlot"))
    weapon.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
        if not InCombatLockdown() then
            --self:SetAttribute("hide", true)
        end
		if TotemTimers.ActiveProfile.TrackerArrange == "free" then
        TotemTimers.ProcessSetting("WeaponBarDirection")
		else
			AfterDrag()
		end
    end)
    weapon.nobars = true
    weapon.Stop = function(self, timer)
        XiTimers.Stop(self, timer)
        self.button.bar:Show()
    end
    weapon.button.bar:Show()
    weapon.button.bar:SetStatusBarColor(0.7, 1, 0.7, 0.7)

    weapon.Start = function(self, ...)
        XiTimers.Start(self, ...)
        self.running = 1
    end
    weapon.Stop = function(self, ...)
        XiTimers.Stop(self, ...)
        self.running = 1
    end
    weapon.running = 1
end

local AnkhName = SpellNames[SpellIDs.Ankh]
local AnkhID = SpellIDs.Ankh
local AnkhItem = 17030

function TotemTimers.AnkhEvent(self, event)
    if event == "SPELL_UPDATE_COOLDOWN" then
        if not AvailableSpells[SpellIDs.Ankh] then
            return
        end
        local start, duration, enable = GetSpellCooldown(AnkhID)
        if duration == 0 then
            self.timer:Stop(1)
        elseif self.timer.timers[1] <= 0 and duration > 2 then
            self.timer:Start(1, start + duration - floor(GetTime()), duration)
        end
    else
        self.count:SetText(GetItemCount(AnkhItem))
    end
end

local shieldtable = {SpellNames[SpellIDs.LightningShield], SpellNames[SpellIDs.WaterShield]} --, SpellNames[SpellIDs.EarthShield]}

local ShieldChargesOnly = false

function TotemTimers.ShieldEvent(self, event, unit)
	if event=="UNIT_SPELLCAST_SUCCEEDED" and unit=="player" then
		for i=1,2 do
			local start, duration, enable = GetSpellCooldown(shieldtable[i])
		if start and duration and (not self.timer.timerOnButton or self.timer.timers[1]<=0) then
            CooldownFrame_Set(self.cooldown, start, duration, enable)
        end
	end
	elseif unit == "player" then
		self.count:SetText("")
        local hasBuff = false
		local buffs = TotemTimers.UnitBuffs(unit)
		for j, buff in pairs(buffs) do	
            if buff.name == shieldtable[1] or buff.name == shieldtable[2] then
                hasBuff = true
                local timeleft = buff.expTime - GetTime()
                if buff.name ~= self.shield or timeleft > self.timer.timers[1] then
                    self.icons[1]:SetTexture(buff.texture)
                    self.timer.expirationMsgs[1] = "Shield"
                    self.timer.earlyExpirationMsgs[1] = "Shield"
                    self.timer.warningIcons[1] = buff.texture
                    self.timer.warningSpells[1] = buff.name
                    self.shield = buff.name
                    if not ShieldChargesOnly then
                        self.timer:Start(1, timeleft, buff.duration)
                    else
                        self.timer:Start(1, buff.count, 3)
                    end
                end
                if not ShieldChargesOnly then
                    if buff.count and buff.count > 0 then
                        self.count:SetText(buff.count)
                    else
                        self.count:SetText("")
                    end
                end
                break
            end
        end
        if not hasBuff and self.timer.timers[1] > 0 then
			self.timer:Stop(1)
		end
	end  
end

local function EmptyUpdate()
end

function TotemTimers.SetShieldUpdate()
    ShieldChargesOnly = TotemTimers.ActiveProfile.ShieldChargesOnly
    if ShieldChargesOnly then
        Timers[6].Update = EmptyUpdate
        Timers[6].prohibitCooldown = true
        Timers[6].timeStyle = "sec"
        Timers[6].button.count:SetText("")
    else
        Timers[6].Update = nil
        Timers[6].prohibitCooldown = false
        Timers[6].timeStyle = TotemTimers.ActiveProfile.TimeStyle --"blizz"
    end
    TotemTimers.ShieldEvent(Timers[6].button, "UNIT_AURA", "player")
end

local ButtonPositions = {
    ["box"] = { { "CENTER", 0, "CENTER" }, { "LEFT", 1, "RIGHT" }, { "TOP", 2, "BOTTOM" }, { "LEFT", 1, "RIGHT" } },
    ["horizontal"] = { { "CENTER", 0, "CENTER" }, { "LEFT", 1, "RIGHT" }, { "LEFT", 1, "RIGHT" }, { "LEFT", 1, "RIGHT" } },
    ["vertical"] = { { "CENTER", 0, "CENTER" }, { "TOP", 1, "BOTTOM" }, { "TOP", 1, "BOTTOM" }, { "TOP", 1, "BOTTOM" } }
}

local TrackerOptions = {
    [5] = "AnkhTracker",
    [6] = "ShieldTracker",
}

function TotemTimers.OrderTrackers()
	local arrange = TotemTimers.ActiveProfile.TrackerArrange
    for e = 5, 8 do
		Timers[e]:ClearAnchors()
		Timers[e].button:ClearAllPoints()
	end
    if arrange == "free" then
        for i = 5,8 do
            Timers[i].savePos = true
            local pos = TotemTimers.ActiveProfile.TimerPositions[i]            
            if not pos or not pos[1] then
                pos = { "CENTER", "UIParent", "CENTER", 0, 0 }
            end
            Timers[i].button:ClearAllPoints()
            Timers[i].button:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
        end
    else
    	local counter = 0
    	local buttons = {}
        for i = 5, 8 do
            Timers[i].savePos = false
    		--if Timers[i].active then
            if Timers[i].button:IsVisible() then
    			counter = counter + 1
    			if counter == 1 then
    				Timers[i]:SetPoint(ButtonPositions[arrange][1][1], TotemTimers_TrackerFrame, ButtonPositions[arrange][1][3])
    			else
                    Timers[i]:Anchor(buttons[counter - ButtonPositions[arrange][counter][2]], ButtonPositions[arrange][counter][1])
    			end
    			buttons[counter] = Timers[i]
    		end
    	end
    end
end

function TotemTimers.SetWeaponTrackerSpells()
    weapon.actionBar:ResetSpells()
	
    if  AvailableSpells[SpellIDs.WindfuryWeapon] then
        if not AvailableTalents.DualWield then 
			weapon.actionBar:AddSpell(SpellIDs.WindfuryWeapon)
		else
			weapon.actionBar:AddDoubleSpell(SpellIDs.WindfuryWeapon, SpellIDs.WindfuryWeapon)
		end
    end
    if AvailableSpells[SpellIDs.RockbiterWeapon] then
        weapon.actionBar:AddSpell(SpellIDs.RockbiterWeapon, false)
    end
    if  AvailableSpells[SpellIDs.FlametongueWeapon] then
		if not AvailableTalents.DualWield then 
			weapon.actionBar:AddSpell(SpellIDs.FlametongueWeapon)
		else
			weapon.actionBar:AddDoubleSpell(SpellIDs.FlametongueWeapon, SpellIDs.FlametongueWeapon)
		end
    end
    if  AvailableSpells[SpellIDs.FrostbrandWeapon] then
		if not AvailableTalents.DualWield then 
			weapon.actionBar:AddSpell(SpellIDs.FrostbrandWeapon)
		else
			weapon.actionBar:AddDoubleSpell(SpellIDs.FrostbrandWeapon, SpellIDs.FrostbrandWeapon)
    end

    end
--[[
    if AvailableTalents.DualWield then
        if  AvailableSpells[SpellIDs.WindfuryWeapon] and AvailableSpells[SpellIDs.FlametongueWeapon] then
			weapon.actionBar:AddDoubleSpell(SpellNames[SpellIDs.WindfuryWeapon], SpellNames[SpellIDs.FlametongueWeapon])
    end
    if  AvailableSpells[SpellIDs.WindfuryWeapon] and AvailableSpells[SpellIDs.FrostbrandWeapon] then
			weapon.actionBar:AddDoubleSpell(SpellNames[SpellIDs.WindfuryWeapon], SpellNames[SpellIDs.FrostbrandWeapon])
        end
    end
]]
end

local mainMsg = ""
local offMsg = ""
local GetWeaponEnchantInfo = GetWeaponEnchantInfo

function TotemTimers.WeaponUpdate(self, elapsed)
    local enchant, expiration, _, mainID, offenchant, offExpiration, _, offID = GetWeaponEnchantInfo()
	local WeaponEnchants = TotemTimers.WeaponEnchants
    for k, v in pairs({ { enchant, expiration, mainID }, { offenchant, offExpiration, offID } }) do
        if v[1] then
            if v[2] / 1000 > self.timers[k] then
                local texture, spell
                self:Start(k, v[2] / 1000, 1800)
                if WeaponEnchants[v[3]] then
                    texture = SpellTextures[WeaponEnchants[v[3]]]
                    spell = SpellNames[WeaponEnchants[v[3]]]
                else
                    spell, _, _, _, _, _, _, _, _, texture = GetItemInfo(GetInventoryItemID("player", 15 + k))
            end
                self["enchant"..k] = spell
                self.button.icons[k]:SetTexture(texture)
                self.warningIcons[k] = texture
                self.warningSpells[k] = spell
                self.expirationMsgs[k] = "Weapon"
        end
            if v[2] == 0 then
                self:Stop(k)
        else
                self.timers[k] = v[2] / 1000
            end
        elseif self.timers[k] > 0 then
            self:Stop(k)
        end
    end
    XiTimers.Update(self, 0)
end

function TotemTimers.SetNumWeaponTimers()
    local button = Timers[8].button
    local name, _, _, _, rank = GetTalentInfo(2, 18)
    TotemTimers.SetDoubleTexture(button, rank and rank > 0, true)
    Timers[8].numtimers = (rank and rank > 0) and 2 or 1
	Timers[8]:SetTimerBarPos(Timers[8].timerBarPos)
end

local earthShieldRecast = false

function TotemTimers.SetEarthShieldButtons()
    local Settings = TotemTimers.ActiveProfile
    local recastbutton = nil
    local menubutton = nil
    earthShieldRecast = false
    earthshieldTimer.button:SetAttribute("OpenMenu", nil)
    earthshieldTimer.button:SetAttribute("RecastButton", nil)

    for k,v in pairs({"EarthShieldLeftButton", "EarthShieldRightButton", "EarthShieldMiddleButton", "EarthShieldButton4"}) do
        if Settings[v] == "recast" then
            recastbutton = k
            earthShieldRecast = true
            earthshieldTimer.button:SetAttribute("*spell"..k, SpellIDs.EarthShield)
        elseif Settings[v] == "menu" and not menubutton then
            menubutton = k
            earthshieldTimer.button:SetAttribute("*spell"..k, nil)
        else
            earthshieldTimer.button:SetAttribute("*unit"..k, Settings[v])
            earthshieldTimer.button:SetAttribute("*spell"..k, SpellIDs.EarthShield)
        end
    end

    if not menubutton and Settings.ESMainTankMenu then
        earthshieldTimer.button:SetAttribute("OpenMenu", "mouseover")
    end
    if menubutton then
        earthshieldTimer.button:SetAttribute("OpenMenu", buttons[menubutton])
    end
    earthshieldTimer.button:SetAttribute("RecastButton", recastbutton)
end


-- This frame is activated if the class of a unit cannot be determined at the time the unit enters the group
local MainTankUpdateTimer = 5
local MainTankListUpdateFrame = CreateFrame("Frame")
MainTankListUpdateFrame:Hide()
MainTankListUpdateFrame:SetScript("OnShow", function(self)
    MainTankUpdateTimer = 5
end)
MainTankListUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
    MainTankUpdateTimer = MainTankUpdateTimer - elapsed
    if MainTankUpdateTimer <= 0 then
        if InCombatLockdown() then
            MainTankUpdateTimer = 5
        else
            self:Hide()
            TotemTimers.SetEarthShieldMainTankList()
        end
    end
end)

local function SetUnit(unit, button)
    button:SetAttribute("*unit1", unit)
    button.hotkey:SetText(splitString(UnitName(unit)))
    local _, class = UnitClass(unit)
    if class then
        if RAID_CLASS_COLORS[class] then
            button.hotkey:SetTextColor(RAID_CLASS_COLORS[class]:GetRGB())
        end
		--_G.DevTools_Dump(class)
		local t = CLASS_ICON_TCOORDS[class]
		--_G.DevTools_Dump(t)
        button.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        button.icon:SetTexCoord(unpack(t))
    else
        MainTankListUpdateFrame:Show()
    end
end

function TotemTimers.SetEarthShieldMainTankList()
    earthshieldTimer.actionBar:ResetSpells()

    if GetNumGroupMembers() > 0 then
        local b = 0
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) then
                if (GetPartyAssignment("MAINTANK", unit)) and b < 4 then
                    b = b + 1
                    earthshieldTimer.actionBar:AddSpell(SpellIDs.EarthShield, true)
                    SetUnit(unit, earthshieldTimer.actionBar.buttons[b])
                end
            end
        end
        if b < 4 then
            earthshieldTimer.actionBar:AddSpell(SpellIDs.EarthShield, true)
            SetUnit("player", earthshieldTimer.actionBar.buttons[b + 1])
        end
    else
        earthshieldTimer.actionBar:AddSpell(SpellIDs.EarthShield, true)
        SetUnit("player", earthshieldTimer.actionBar.buttons[1])
    end
end

function TotemTimers.ChangeEarthShieldTarget()
    for k, v in pairs(buttons) do
        if TotemTimers.ActiveProfile["EarthShield" .. v] == "recast" then
            earthshieldTimer.button:SetAttribute("*unit" .. k, earthShieldTarget)
        end
    end
end

local EarthShieldSpellName = SpellNames[SpellIDs.EarthShield]

local ESChargesOnly = false

local function checkESBuff(self)
    local unit = earthShieldTarget

    if UnitGUID("target") == earthShieldTargetGUID then
        unit = "target"
    elseif UnitGUID("focus") == earthShieldTargetGUID then
        unit = "focus"
    elseif UnitGUID("mousover") == earthShieldTargetGUID then
		unit = "mouseover"
    end

    local hasBuff = false
	local buffs = TotemTimers.UnitBuffs(unit)
    for j, buff in pairs(buffs) do	
        if buff.name == EarthShieldSpellName and buff.caster == "player" then
            hasBuff = true
            local timeleft = buff.expTime - GetTime()
            if not ESChargesOnly then
                self.count:SetText(buff.count)
            end
            if timeleft - self.timer.timers[1] > 0.1 then
                if not ESChargesOnly then
                    self.timer:Start(1, timeleft, buff.duration)
                else
                    self.timer:Start(1, count, 9)
                end
            end
            break
        end
    end
    if not hasBuff and self.timer.timers[1] > 0 then
        self.timer:Stop(1)
        self.count:SetText("")
    end
end

lastESCastGUID = nil
lastESCastTarget = nil
lastESCastUnitGUID = nil

function TotemTimers.EarthShieldEvent(self, event, ...)
    if not AvailableSpells[SpellIDs.EarthShield] then
        return
    end
    if event == "UNIT_SPELLCAST_SENT" then
        local _, target, castGUID, spellID = ...
        local spellName = GetSpellInfo(spellID)

        if spellName == EarthShieldSpellName then
            lastESCastTarget = target
            lastESCastGUID = castGUID
            lastESCastUnitGUID = UnitGUID(target)

            if not lastESCastUnitGUID then
                if target == UnitName("target") then lastESCastUnitGUID = UnitGUID("target")
                elseif target == UnitName("focus") then lastESCastUnitGUID = UnitGUID("focus") end
            end
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local start, duration, enable = GetSpellCooldown(EarthShieldSpellName)
        if start and duration and (not self.timer.timerOnButton or self.timer.timers[1] <= 0) then
            CooldownFrame_Set(self.cooldown, start, duration, enable)
        end
        local _, castGUID = ...
        if castGUID == lastESCastGUID then
            earthShieldTarget = lastESCastTarget
            earthShieldTargetGUID = lastESCastUnitGUID

            if earthShieldRecast then
                if not InCombatLockdown() then
                    TotemTimers.ChangeEarthShieldTarget()
                else
                    changeEarthShieldRecast = true
                end
            end
        end
    elseif event == "UNIT_AURA" and earthShieldTargetGUID then
        local unit = ...
        if UnitGUID(unit) == earthShieldTargetGUID then
            checkESBuff(self)
        end
    elseif event == "PLAYER_REGEN_ENABLED" and earthShieldRecast and changeEarthShieldRecast then
        TotemTimers.ChangeEarthShieldTarget()
    elseif (event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
        if earthShieldRecast and earthShieldTarget then
            if InCombatLockdown() then
                changeEarthShieldTarget = true
            else
                TotemTimers.ChangeEarthShieldTarget()
            end
        end
        if not InCombatLockdown() then
            TotemTimers.SetEarthShieldMainTankList()
        else
            MainTankListUpdateFrame:Show()
        end
    end
end

local function EmptyESUpdate()
end

function TotemTimers.SetEarthShieldUpdate()
    ESChargesOnly = TotemTimers.ActiveProfile.ESChargesOnly
    if TotemTimers.ActiveProfile.ESChargesOnly then
        earthshieldTimer.Update = EmptyESUpdate
        earthshieldTimer.prohibitCooldown = true
        earthshieldTimer.timeStyle = "sec"
    else
        earthshieldTimer.Update = nil
        earthshieldTimer.prohibitCooldown = false
        earthshieldTimer.timeStyle = "blizz"
    end
end

