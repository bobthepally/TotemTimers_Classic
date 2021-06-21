-- Copyright © 2008 - 2012 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current distribution permissions only include curse.com, wowinterface.com and their respective addon updaters

if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers", true)

local buttonlocations = {
	{"BOTTOM", "TOP"},
	{"BOTTOMLEFT", "TOPRIGHT"},
	{"LEFT", "RIGHT"},
	{"TOPLEFT", "BOTTOMRIGHT"},
	{"TOP", "BOTTOM"},
	{"TOPRIGHT", "BOTTOMLEFT"},
	{"RIGHT", "LEFT"},
	{"BOTTOMRIGHT", "TOPLEFT"},
}

local ankh = nil

function TotemTimers.InitSetButtons()
    ankh = XiTimers.timers[5].button 
    ankh:SetScript("OnClick", TotemTimers.SetAnchor_OnClick)
    if not ankh.buttons then  ankh.buttons = {} end
    TotemTimers.ProgramSetButtons()
    ankh:WrapScript(XiTimers.timers[5].button, "OnClick",
                                                            [[ if button == "LeftButton" then
                                                                control:ChildUpdate("toggle")
                                                            end ]])
    ankh.HideTooltip = TotemTimers.HideTooltip
    ankh.ShowTooltip = TotemTimers.SetTooltip
    ankh:SetAttribute("_onleave", [[ control:CallMethod("HideTooltip") ]])
    ankh:SetAttribute("_onenter", [[ if self:GetAttribute("tooltip") then control:CallMethod("ShowTooltip") end ]])
    ankh:SetAttribute("_onattributechanged", [[ if name=="hide" then
                                                    control:ChildUpdate("show", false)
                                                    self:SetAttribute("open", false)
                                                elseif name=="state-invehicle" then
                                                    if value == "show" and self:GetAttribute("active") then
                                                        self:Show()
                                                    else
                                                        self:Hide()
                                                    end
                                                end]])
end

function TotemTimers.ProgramSetButtons()
    ankh = XiTimers.timers[5].button
    local Sets = TotemTimers.ActiveProfile.TotemSets
	local nr = 0
--	local lastButton = ankh --LaYt
	for i=1,8 do
        local b = _G["TotemTimers_SetButton"..i]
        if not b then
            b = CreateFrame("Button", "TotemTimers_SetButton"..i, ankh, "TotemTimers_SetButtonTemplate")
            b:SetAttribute("_childupdate-show", [[ if message and not self:GetAttribute("inactive") then self:Show() else self:Hide() end ]])
            b:SetAttribute("_childupdate-toggle", [[ if not self:GetAttribute("inactive") then if self:IsVisible() then self:Hide() else self:Show() end end ]])
            b:SetAttribute("_onleave", [[ control:CallMethod("HideTooltip")  ]]) 
            b:SetAttribute("_onenter", [[ control:CallMethod("ShowTooltip") ]])
            b.nr = i
            b.HideTooltip = TotemTimers.HideTooltip
            b.ShowTooltip = TotemTimers.SetButtonTooltip
            b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            b:SetParent(ankh)
            table.insert(ankh.buttons,b)
        end
--[[        b:ClearAllPoints()
        --b:SetPoint(buttonlocations[i][1], lastButton, buttonlocations[i][2])
		b:SetPoint("BOTTOM", lastButton, "TOP") --LaYt
        lastButton = b
]] 
        if Sets[i] then
            for k = 1,4 do
                local icon = _G[b:GetName().."Icon"..k]
                if type(Sets[i][k]) == "string" or Sets[i][k] > 0 then
                    icon:SetTexture(GetSpellTexture(Sets[i][k]))
                end     
            end
            b:SetAttribute("inactive", false)            
        else
            b:SetAttribute("inactive", true)
            b:Hide()
        end
	end
end

function TotemTimers.SetAnchor_OnClick(self, button)
    if InCombatLockdown() then return end
	if button == "RightButton" then
		if #TotemTimers.ActiveProfile.TotemSets >= 8 then return end
        local set = {}
		for i=1,4 do
            local nr = XiTimers.timers[i].nr
            local spell = XiTimers.timers[i].button:GetAttribute("*spell1")
            if not spell then spell = 0 end
			set[nr] = spell
		end
        table.insert(TotemTimers.ActiveProfile.TotemSets, set)
		self:Execute([[ owner:ChildUpdate("show", false) ]])
		TotemTimers.ProgramSetButtons()
    end
end

function TotemTimers.SetButton_OnClick(self, button)
    if InCombatLockdown() then return end
    --XiTimers.timers[5].button:SetAttribute("hide", true)
    self:GetParent():Execute([[ owner:ChildUpdate("show", false) ]])
	if button == "RightButton" then
		local popup = StaticPopup_Show("TOTEMTIMERS_DELETESET", self.nr)
		popup.data = self.nr
    elseif button == "LeftButton" then
        local set = TotemTimers.ActiveProfile.TotemSets[self.nr]
        if set then 
            for i=1,4 do
                XiTimers.timers[i].button:SetAttribute("*spell1", set[XiTimers.timers[i].nr])
            end            
        end
	end
end

local function TotemTimers_DeleteSet(self, nr)
	if not InCombatLockdown() then
		table.remove(TotemTimers.ActiveProfile.TotemSets,nr)
		TotemTimers.ProgramSetButtons()
	end
end

StaticPopupDialogs["TOTEMTIMERS_DELETESET"] = {
  text = L["Delete Set"],
  button1 = OKAY,
  button2 = CANCEL,
  whileDead = 1,
  hideOnEscape = 1,
  timeout = 0,
  OnAccept = TotemTimers_DeleteSet,
}
local CastButtonPositions = {
	["horizontal"] = {
		["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"},
	},
	["vertical"] = {
		["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"},
		
	},
    ["free"] = {
 		["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"},
		["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"},
   },
}
CastButtonPositions.horizontal.left = CastButtonPositions.horizontal.up
CastButtonPositions.horizontal.right = CastButtonPositions.horizontal.up
CastButtonPositions.vertical.up = CastButtonPositions.vertical.right
CastButtonPositions.vertical.down = CastButtonPositions.vertical.right

TotemTimers.CalcSMenuDirection = function(dir, parentdir, freenotself)
    if dir == "auto" then
        local p,_,_,x,y = TotemTimers_TrackerFrame:GetPoint()
        if parentdir == "free" and not freenotself then p,_,_,x,y = XiTimers.timers[5].button:GetPoint() end
        if not p then return "up" end
		if parentdir == "horizontal" then
            if ((p == "LEFT" or p == "RIGHT" or p == "CENTER") and y < 0)
              or (string.sub(p,1,6) == "BOTTOM") then
				dir = "up"
			else
				dir = "down"
			end
		else
			if ((p == "TOP" or p == "BOTTOM" or p == "CENTER") and x < 0)
              or (string.find(p,"LEFT")) then
				dir = "right"
			else
				dir = "left"
			end
		end
    end
    return dir
end

TotemTimers.SetSMenuDirection = function(dir, parentdir, freenotself)
    local self = XiTimers.timers[5].button
	self.direction = dir
    self.parentdirection = parentdir
    dir = TotemTimers.CalcSMenuDirection(dir, parentdir, freenotself)
    self.actualDirection = dir
    local x = 0
    local y = 0
    local anchor = self
    for i = 1, 8 do
		local button = self.buttons[i]
		button:ClearAllPoints()
		if i==1 then
			button:SetPoint(CastButtonPositions[parentdir][dir][1], anchor, CastButtonPositions[parentdir][dir][2])
		else
			button:SetPoint(CastButtonPositions[parentdir][dir][3], self.buttons[i-1], CastButtonPositions[parentdir][dir][4],x,y)
		end
        button:SetFrameStrata("HIGH")
    end
end