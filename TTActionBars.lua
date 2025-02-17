-- Copyright © 2008-2014 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current distribution permissions only include curse.com, wowinterface.com and their respective addon updaters

if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers")

TTActionBars = {}
TTActionBars.bars = {}
TTActionBars.numbars = 0
TTActionBars.__index = TTActionBars

local _G = getfenv()


function TTActionBars:new(numbuttons, parent, secondanchor, directionanchor, bartype)
	local self = {}
	setmetatable(self, TTActionBars)
	TTActionBars.numbars = TTActionBars.numbars + 1
	
    self.secondanchor = secondanchor
    self.parent = parent
    self.directionanchor = directionanchor
    self.numbuttons = numbuttons
    self.numspells = 0
    self.order = TTActionBars.numbars
    if self.order > 4 then self.order = 1 end
    
	self.buttons = {}
	for i=1,numbuttons do	
		local b = CreateFrame("Button", "TT_ActionButton"..TTActionBars.numbars..i, parent, "TTActionBarButtonTemplate")
        table.insert(self.buttons,b)
		b.icon = _G["TT_ActionButton"..TTActionBars.numbars..i.."Icon"]
		b.icon2 = _G["TT_ActionButton"..TTActionBars.numbars..i.."Icon2"]
        b.hotkey = _G["TT_ActionButton"..TTActionBars.numbars..i.."HotKey"]
        b.MiniIcons = {_G["TT_ActionButton"..TTActionBars.numbars..i.."MiniIcon1"],
                       _G["TT_ActionButton"..TTActionBars.numbars..i.."MiniIcon2"],
                       _G["TT_ActionButton"..TTActionBars.numbars..i.."MiniIcon3"],
                       _G["TT_ActionButton"..TTActionBars.numbars..i.."MiniIcon4"]}
        for i=1,4 do b.MiniIcons[i]:Hide() end
                       
        b.icons = {b.icon, b.icon2}
        b.cooldown = _G["TT_ActionButton"..TTActionBars.numbars..i.."Cooldown"]
		b.cooldown:SetSwipeColor(0, 0, 0)
        b.bar = self
        if secondanchor then b:SetAttribute("secondanchor", secondanchor) end
		b:Hide()
		b:ClearAllPoints()
		b:SetWidth(36)
		b:SetHeight(36)
            b:SetNormalTexture(nil)
        b.icon:Show()

		b:SetAttribute("_childupdate-show", [[if self:GetAttribute("alwaysshow") or self:GetAttribute("inactive") then return end
                                               if message then 
                                                   self:Show()
                                               else
                                                   self:Hide()
                                               end ]])
		b:SetAttribute("_childupdate-toggle", [[if self:GetAttribute("alwaysshow") or self:GetAttribute("inactive") then return end
                                               if self:IsVisible() then
                                                   self:Hide()
                                               else
                                                   self:Show()
                                               end ]])


		b:SetAttribute("_onshow", [[if self:GetAttribute("alwaysshow") or self:GetAttribute("inactive") then return end
									local b = self:GetAttribute("binding")
                                    if b then
                                        self:SetBindingClick(true, b, self:GetName())
                                    end
                                    control:CallMethod("OnShow")]])

        parent:SetAttribute("_onenter", [[ control:CallMethod("ShowTooltip")
                                              if self:GetAttribute("OpenMenu") == "mouseover" then
                                                  control:ChildUpdate("show", true)
                                              end ]])

        parent:SetAttribute("_onleave", [[ owner:CallMethod("HideTooltip")
            if not self:IsUnderMouse(true) then
                owner:ChildUpdate("show", false)
            end]])

        parent:WrapScript(parent, "OnClick", [[ if button == self:GetAttribute("OpenMenu") then
                                                       control:ChildUpdate("show", true)
                                                   elseif button == "close" or button == "Button5" then
                                                       control:ChildUpdate("show", false)
                                                   end
                                                 ]])

        b:SetAttribute("_onhide", [[self:ClearBindings() self:GetParent():SetAttribute("open", false) control:CallMethod("HideTooltip")]])
        b:SetAttribute("_onenter", [[ if self:GetAttribute("tooltip") then control:CallMethod("ShowTooltip") end]])
        b:SetAttribute("_onleave", [[ control:CallMethod("HideTooltip") if not self:GetParent():IsUnderMouse(true) then self:GetParent():ChildUpdate("show", false) end]])
        b.OnShow = function(self) end -- override if button should do additional stuff on show
        
		b:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
		b:SetAttribute("*type1", "spell")
        b:SetAttribute("*type2", nil)
		
        if bartype ~= "weapontimer" then
			b.ShowTooltip = TotemTimers.TotemTooltip
		else
            b.ShowTooltip = TotemTimers.WeaponBarTooltip
		end
        b.HideTooltip = function(self) GameTooltip:Hide() end
        
        b:SetAttribute("_onattributechanged", [[ if name=="inactive" then 
                                                     if not value and self:GetAttribute("alwaysshow") then
                                                         self:Show()
                                                     elseif value then
                                                         self:Hide()
                                                     end
                                                 elseif name=="alwaysshow" then
                                                     if value then
                                                         if not self:GetAttribute("inactive") then self:Show() end
                                                         local b = self:GetAttribute("binding")
                                                         if b then self:ClearBinding(b) end
                                                     else
                                                         self:Hide()
                                                     end
                                                  end                                                         
                                                  ]])                                                    
        b:SetScript("OnDragStop", function(self) 
                    if self.bar.secondanchor then
                        self.bar.secondanchor:StopMovingOrSizing()
                    end
                    TotemTimers.SaveFramePositions()
                end)
        --b:WrapScript(b, "OnDragStart", [[ print("drag") control:CallMethod("StartBarDrag")]])        
        b:SetAttribute("_ondragstart", [[ control:CallMethod("StartBarDrag")]])
        b.StartBarDrag = function(self)
                if not IsModifierKeyDown() and self.bar.alwaysvisible 
                    and not TotemTimers.ActiveProfile.Lock and self.bar.secondanchor and not InCombatLockdown() then
                    self.bar.secondanchor:StartMoving()
                end
            end
        b:RegisterForDrag("LeftButton")
        b:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        b:SetScript("OnEvent", function(self)            
                local spell = self:GetAttribute("*spell1")
                if spell then
                    local start, duration, enable = GetSpellCooldown(spell)
                        if start and duration then CooldownFrame_Set(self.cooldown, start, duration, enable) end
                    end
                end)  
        if bartype ~= "weapontimer" then 
            parent:WrapScript(b, "OnClick", [[  if button ~= "LeftButton" then
                                                    if self:GetAttribute("*spell1") then
                                                        self:GetParent():SetAttribute("*type1", "spell")
                                                        self:GetParent():SetAttribute("*spell1", self:GetAttribute("*spell1"))
                                                    end
                                                end
                                                if not self:GetAttribute("alwaysshow") then
                                                    self:GetParent():ChildUpdate("show", false)
                                                end]])
        else
            parent:WrapScript(b, "OnClick", [[  
				if IsShiftKeyDown() and not self:GetAttribute("spell1") then
					if button == "LeftButton" then
						
							self:GetParent():SetAttribute("doublespell1", self:GetAttribute("doublespell1"))
							self:GetParent():SetAttribute("type1", "macro")
                            self:GetParent():SetAttribute("macrotext1", "/cast [@none] "..self:GetAttribute("doublespell1").."\n/use 16\n/click StaticPopup1Button1")

					elseif button == "RightButton" then

							self:GetParent():SetAttribute("doublespell2", self:GetAttribute("doublespell2"))
							self:GetParent():SetAttribute("type2", "macro")
                            self:GetParent():SetAttribute("macrotext2", "/cast [@none] "..self:GetAttribute("doublespell2").."\n/use 17\n/click StaticPopup1Button1")

                                                            end
                                                        end
				if button ~= "LeftButton" and self:GetAttribute("spell1") then
					self:GetParent():SetAttribute("type1", "spell")
                    self:GetParent():SetAttribute("spell1", self:GetAttribute("spell1"))
                                                            self:GetParent():SetAttribute("doublespell1", nil)
                                                            self:GetParent():SetAttribute("doublespell2", nil)
                                                        end
                                                if not self:GetAttribute("alwaysshow") then
                    self:GetParent():ChildUpdate("show", false)
              end]])
	end
            
	end
	table.insert(TTActionBars.bars, self)
	return self
end


function TTActionBars:SetInactive(nr)
    local button = self.buttons[nr]
	button:SetAttribute("inactive", true)
    button:SetAttribute("*spell1", nil)
	button:SetAttribute("doublespell1", nil)
    button:SetAttribute("doublespell2", nil)
    button.icon:SetTexture(nil)
    button.icon2:SetTexture(nil)
    TotemTimers.SetDoubleTexture(button)
    local f = button:GetScript("OnEvent")
    if f then f(button) end
end

function TTActionBars:ResetSpells()
	for i = 1,self.numbuttons do
        self:SetInactive(i)
    end
    self.numspells = 0
end


function TTActionBars:SetSpell(nr, spell, asname)
    if nr > self.numbuttons then return end
    local button = self.buttons[nr]
    local texture = "Interface\\Buttons\\UI-TotemBar"
	local _
    if type(spell)~="number" or spell~=0 then _,_,texture = GetSpellInfo(spell) end
    if type(spell)=="number" then button:SetAttribute("spellname", GetSpellInfo(spell)) end
	if asname and type(spell) == "number" then
		button:SetAttribute("spellid", spell)
		spell = TotemTimers.GetMaxRank(spell)		-- LaYt 1.26
	end
	button:SetAttribute("*spell1", spell)
    button:SetAttribute("*spell2", spell)    
	button:SetAttribute("inactive", false)
    button.icon:SetTexture(texture)
    local f = button:GetScript("OnEvent")
    if f then f(button) end
end


function TTActionBars:AddSpell(spell, act)
    if self.numspells >= self.numbuttons then return end
    self.numspells = self.numspells + 1
	local button = self.buttons[self.numspells]
    local texture = GetSpellTexture(spell)
	spell = TotemTimers.GetMaxRank(spell)
	if act then 
		button:SetAttribute("*spell1", spell)
	else 
		button:SetAttribute("spell1", spell)
	end
	button:SetAttribute("*spell2", nil)
	button:SetAttribute("inactive", false)
	button.icon:SetTexture(texture)
	local f = button:GetScript("OnEvent")
    if f then f(button) end
end

function TTActionBars:SetSpells(spells, asnames)
    for i = 1, #spells do
        self:SetSpell(i,spells[i], asnames)
    end
    for i = #spells+1, self.numbuttons do
        self:SetInactive(i)
    end
    self.numspells = #spells
end

function TTActionBars:AddDoubleSpell(spell1,spell2)
    if self.numspells >= self.numbuttons then return end
    self.numspells = self.numspells+1
    local button = self.buttons[self.numspells]
    local texture = GetSpellTexture(spell1)
    local texture2 = GetSpellTexture(spell2)
	spell1 = TotemTimers.GetMaxRank(spell1)
	spell2 = TotemTimers.GetMaxRank(spell2)
	button:SetAttribute("doublespell1", spell1)
    button:SetAttribute("doublespell2", spell2)
	button:SetAttribute("type1", "macro")
    button:SetAttribute("macrotext1", "/cast [@none] "..spell1.."\n/use 16\n/click StaticPopup1Button1")
    button:SetAttribute("type2", "macro")
    button:SetAttribute("macrotext2", "/cast [@none] "..spell2.."\n/use 17\n/click StaticPopup1Button1")	
	button:SetAttribute("inactive", false)
    button.icon:SetTexture(texture)
    button.icon2:SetTexture(texture2)
    TotemTimers.SetDoubleTexture(button, true)
    local f = button:GetScript("OnEvent")
    if f then f(button) end
end

function TTActionBars:SetAlwaysVisible(av)
    self.alwaysvisible = av
    for i=1,self.numbuttons do
        self.buttons[i]:SetAttribute("alwaysshow", av)
    end
    if self.direction and self.parentdirection then self:SetDirection(self.direction, self.parentdirection) end
end

function TTActionBars:SetTooltip(tt)
    for i=1,self.numbuttons do
        self.buttons[i]:SetAttribute("tooltip", tt)
    end
end


local CastButtonPositions = {
	["box"] = {
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"] = {"BOTTOM", "TOP", "LEFT", "RIGHT"}},
		{["left"] = {"BOTTOM", "TOP", "RIGHT", "LEFT"},["right"] = {"LEFT", "RIGHT", "LEFT", "RIGHT"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"] = {"TOP", "BOTTOM", "LEFT", "RIGHT"}},
		{["left"] = {"TOP", "BOTTOM", "RIGHT", "LEFT"},["right"] = {"LEFT", "RIGHT", "LEFT", "RIGHT"}}
	},
	["horizontal"] = {
		{["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
		{["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
		{["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
		{["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
	},
	["vertical"] = {
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"}},
	},
    ["free"] = {
 		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"},
		["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"},
		["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"},
		["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
		{["left"] = {"RIGHT", "LEFT", "RIGHT", "LEFT"},["right"]={"LEFT", "RIGHT", "LEFT", "RIGHT"},
		["up"] = {"BOTTOM", "TOP", "BOTTOM", "TOP"},["down"]={"TOP", "BOTTOM", "TOP", "BOTTOM"}},
   },
}

for i = 1,4 do
    CastButtonPositions.horizontal[i].left = CastButtonPositions.horizontal[i].up
    CastButtonPositions.horizontal[i].right = CastButtonPositions.horizontal[i].up
    CastButtonPositions.vertical[i].up = CastButtonPositions.vertical[i].right
    CastButtonPositions.vertical[i].down = CastButtonPositions.vertical[i].right
    CastButtonPositions.box[i].up = CastButtonPositions.box[i].right
    CastButtonPositions.box[i].down = CastButtonPositions.box[i].right
end



function TTActionBars:CalcDirection(dir, parentdir, freenotself)
    if dir == "auto" then
        local p,_,_,x,y = self.directionanchor:GetPoint()
        if parentdir == "free" and not freenotself then p,_,_,x,y = self.parent:GetPoint() end
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

function TTActionBars:SetDirection(dir, parentdir, freenotself)
    self.direction = dir
    self.parentdirection = parentdir
    if self.alwaysvisible then
        parentdir = "free"
        if dir == "auto" then dir = "right" end
    else
        dir = self:CalcDirection(dir, parentdir, freenotself)
    end
    self.actualDirection = dir
    local x = 0
    local y = 0
    if self.alwaysvisible then
        if dir == "up" then
            y = TotemTimers.ActiveProfile.TotemMenuSpacing
        elseif dir == "down" then
            y = -TotemTimers.ActiveProfile.TotemMenuSpacing
        elseif dir == "left" then
            x = -TotemTimers.ActiveProfile.TotemMenuSpacing
        else
            x = TotemTimers.ActiveProfile.TotemMenuSpacing
        end
    end
    local anchor = self.parent
    if self.alwaysvisible then anchor = self.secondanchor end 
	for i = 1,self.numbuttons do
		local button = self.buttons[i]
		button:ClearAllPoints()
		if i==1 then
			button:SetPoint(CastButtonPositions[parentdir][self.order][dir][1], anchor, CastButtonPositions[parentdir][self.order][dir][2])
		else
			button:SetPoint(CastButtonPositions[parentdir][self.order][dir][3], self.buttons[i-1], CastButtonPositions[parentdir][self.order][dir][4],x,y)
		end
        if self.alwaysvisible then
            button:SetFrameStrata("MEDIUM")
        else
            button:SetFrameStrata("HIGH")
        end
    end
end




