-- Copyright © 2008 - 2014 Xianghar
-- All Rights Reserved.


--[[ Credits for localization go to
        Sayclub (koKR), StingerSoft (ruRU), a9012456 (zhTW),
        Sabre (zhCN), vanilla_snow (zhCN), tnt2ray (zhCN),
        Vante (esES), DonSlonik (ruRU), Оригинал (ruRU),
        natural_leaf (zhTW), ckeurk (frFR), oXid_FoX (frFR),
        Hemathio (ruRU), wowuicn (zhCN), laincat (zhTW),
        provirus111 (ruRU), lsjyzjl (zhCN), Rubapowa (esES),
        BNSSNB (zhTW), cebolaassassina (ptBR)
]]


if select(2,UnitClass("player")) ~= "SHAMAN" then return end

TotemTimers.timers = XiTimers
TotemTimers.party = {}  --LaYt

local warnings = nil

local PlayerName = UnitName("player")

local zoning = false
local updateAfterCombat = false

local macroNeedsUpdate = false

local function TotemTimers_OnEvent(self, event, ...)
    if zoning and event ~= "PLAYER_ENTERING_WORLD" then return
	elseif event == "PLAYER_ENTERING_WORLD" then 
        if zoning then
            TotemTimersFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            zoning = false
            return
        end
		TotemTimers.SetupGlobals()
    elseif event == "LEARNED_SPELL_IN_TAB" then 
        if InCombatLockdown() then
			updateAfterCombat = true
		else
			TotemTimers.LearnedSpell(...)
		end
    elseif event == "PLAYER_REGEN_ENABLED" then
        --TotemTimers_ProcessQueue()
		if updateAfterCombat then
			TotemTimers.ChangedTalents()
			updateAfterCombat = false
		end
		if macroNeedsUpdate then
		    TotemTimers.UpdateMacro()
		end
    --elseif event == "PLAYER_ALIVE" then
        -- TotemTimers.ProcessSetting("EnhanceCDs")
        --TotemTimers.options.args.enhancecds.args["2"].name = select(2,GetSpecializationInfo(2)) or "Enhancement"
        --TotemTimers.options.args.enhancecds.args["1"].name = select(2,GetSpecializationInfo(1)) or "Elemental"
        --TotemTimers.options.args.enhancecds.args["3"].name = select(2,GetSpecializationInfo(3)) or "Restoration"
    --[[elseif event == "CHARACTER_POINTS_CHANGED" then
        local nr = select(1,...)
        if nr > 1 then
            TotemTimers.ChangedTalents()
        elseif nr == -1 then
            TotemTimers.LearnedSpell()
            TotemTimers.GetTalents()
        end]]
	--[[ elseif event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "SPELLS_CHANGED" then
		if InCombatLockdown() then
			updateAfterCombat = true
		else
			TotemTimers.ChangedTalents()        
		end --]]
    elseif event == "SPELLS_CHANGED" then
        if InCombatLockdown() then
            updateAfterCombat = true
        else
            TotemTimers.ChangedTalents()
        end
    elseif event == "PLAYER_LEAVING_WORLD" then
        zoning = true
        TotemTimersFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "UPDATE_BINDINGS" then
        ClearOverrideBindings(TotemTimersFrame)
        TotemTimers.InitializeBindings()
	elseif event == "CHAT_MSG_ADDON" then --LaYt
		local pfx = select(1, ...)
		if pfx == "WF_STATUS" then TotemTimers.onWF_STATUS(...) end
	elseif event == "GROUP_ROSTER_UPDATE" then
		TotemTimers.UpdateParty()
	end

end

TotemTimersFrame:SetScript("OnEvent", TotemTimers_OnEvent)


function TotemTimers.SetupGlobals()
	if TotemTimers_IsSetUp then
		return
	end
	if select(2,UnitClass("player")) == "SHAMAN" then
		TotemTimers.GetSpells()
        TotemTimers.GetTalents()
		TotemTimers.UpdateProfiles()
        TotemTimers.SelectActiveProfile()
        
        
        local sink = LibStub("LibSink-2.0")
        if sink then
            sink.SetSinkStorage(TotemTimers,TotemTimers_GlobalSettings.Sink)
        end
		TotemTimers.CreateTimers()
		TotemTimers.CreateTrackers()
        TotemTimers.SetWeaponTrackerSpells()
        -- TotemTimers.CreateEnhanceCDs()
        -- TotemTimers.CreateCrowdControl()
		-- TotemTimers.CreateLongCooldowns()
        TotemTimers.InitSetButtons()
        
        TotemTimers.ProcessAllSettings()
        
		TotemTimers.OrderTimers()
		--TotemTimers_OrderTrackers()
		TotemTimersFrame:Show()
        
		--set the slashcommand
		SLASH_TOTEMTIMERS1 = "/totemtimers";
		SLASH_TOTEMTIMERS2 = "/tt";
		SlashCmdList["TOTEMTIMERS"] = TotemTimers_Slash

		--TotemTimers_LastGUIPane = TotemTimers_GUI_General

        TotemTimers.InitializeBindings()
        -- hooksecurefunc("SaveBindings", function() ClearOverrideBindings(TotemTimersFrame) TotemTimers.InitializeBindings() end)
            
		
        TotemTimersFrame:RegisterEvent("SPELLS_CHANGED")
        TotemTimersFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        TotemTimersFrame:RegisterEvent("ADDON_LOADED")
        TotemTimersFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
        TotemTimersFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
		-- TotemTimersFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
        TotemTimersFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
        TotemTimersFrame:RegisterEvent("UPDATE_BINDINGS")
        -- TotemTimersFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
--		TotemTimersFrame:RegisterEvent("CHAT_MSG_ADDON") --LaYt

        --TotemTimers_UpdateRaid()
		TotemTimers.InitMasque()
		-- TotemTimers.RangeFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        -- TotemTimers.RangeFrame:Show()
        TotemTimers.SetCastButtonSpells()
        -- activate shield timer after reloading ui
        if XiTimers.timers[6].active then
            TotemTimers.ShieldEvent(XiTimers.timers[6].button, "", "player")
        end  

        --TotemTimers.OrderCDs("2")
        --TotemTimers.OrderCDs("1")
        
        TotemTimers_OnEvent("PLAYER_ALIVE") -- simulate PLAYER_ALIVE event in case the ui is reloaded
        XiTimers.invokeOOCFader()
        TotemTimersFrame:SetScript("OnUpdate", XiTimers.UpdateTimers)
		TotemTimersFrame:EnableMouse(false)
        XiTimers.InitWarnings(TotemTimers.ActiveProfile.Warnings)
        TotemTimers.SetEarthShieldButtons()
        -- TotemTimers.LayoutCrowdControl()
        --TotemTimers.ApplySkin()
        XiTimers.SaveFramePositions = TotemTimers.SaveFramePositions
	else
		TotemTimersFrame:Hide()
	end
	TotemTimers.UpdateMacro()
	TotemTimers_IsSetUp = true
    TotemTimersFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function TotemTimers_Slash(msg)
	if InCombatLockdown() then
		DEFAULT_CHAT_FRAME:AddMessage("Can't open TT options in combat.")
		return
	end
	--[[if msg == "i" or msg == "inspect" then
        InterfaceOptionsFrame_OpenToCategory(TotemTimers_GUI_Inspect.name)
    else
        InterfaceOptionsFrame_OpenToCategory(TotemTimers_LastGUIPane.name)
    end]]

    local lastGUIPanel = TotemTimers.LastGUIPanel

    InterfaceOptionsFrame_OpenToCategory("TotemTimers")

    if lastGUIPanel then
        InterfaceOptionsFrame_OpenToCategory(lastGUIPanel)
    else
        InterfaceOptionsFrame_OpenToCategory(TotemTimers.TimersGUIPanel)
        InterfaceOptionsFrame_OpenToCategory("TotemTimers")
    end
end


local text

local function addVar(var, indent)
    if type(var) == "table" then
        text = text.." {|n"
        for k,v in pairs(var) do
            for i=1,indent+4 do text = text.." " end
            text = text..'["'..k..'"] = '
            addVar(v, indent+4)
        end
        for i=1,indent do text = text.." " end
        text = text.."}|n"
    else
        text = text..tostring(var).."|n"
    end
end

local DebugText = ""

function TotemTimers.ResetDebug()
end

function TotemTimers.AddDebug(text)
    DebugText = DebugText..text.."|n"
end

function TotemTimers.ShowDebug()
	--text = ""
	--[[text = text.."Settings:|n"
	for k,v in pairs(TotemTimers_Settings) do
		text = text..'    ["'..k..'"] = '
        addVar(v, 4)
	end
	text=text.."|n|n"
    text=text.."Available spells:|n"
	for k,v in pairs(TotemTimers_Spells) do
		text = text..'    ["'..k..'"] = '
        addVar(v, 4)
	end  ]]
	--[[text = "EnhanceCDs option: "..tostring(TotemTimers_Settings["EnhanceCDs"]).."|n"
	local name,_,_,_,rank = GetTalentInfo(2,28)
	text = text..tostring(name)..": "..tostring(rank).."|n"
    name,_,_,_,rank = GetTalentInfo(2,21)
	text = text..tostring(name)..": "..tostring(rank).."|n"
    name,_,_,_,rank = GetTalentInfo(2,23)
	text = text..tostring(name)..": "..tostring(rank).."|n"
	text = text.."SS-Timer: "..tostring(XiTimers.timers[9].active).."|n"
	text = text.."ES-Timer: "..tostring(XiTimers.timers[10].active).."|n"
	text = text.."LL-Timer: "..tostring(XiTimers.timers[11].active).."|n"
	text = text.."EC Pos: "
	local a,b,c,d,e = TotemTimers_EnhanceCDsFrame:GetPoint(1)
	if a then
		text=text..a.." "
		if b then text = text..b:GetName() else text = text.."nil " end
		text = text..tostring(c).." "..tostring(d).." "..tostring(e)
	end
	text=text.."|n"]]
	TotemTimers_Debug:SetText(DebugText)
	TotemTimers_Debug:HighlightText()
end

local skin = false
local mask = nil

local DoubleIcons = {}

function TotemTimers.SetDoubleTexCoord(button, flash) 
    if DoubleIcons[button] then
        button.icons[1]:ClearAllPoints()
        button.icons[1]:SetPoint("RIGHT", button, "CENTER")
        button.icons[2]:Show()
        if not skin then
            button.icons[1]:SetWidth(18)
            button.icons[1]:SetHeight(36)
            button.icons[2]:SetWidth(18)
            button.icons[2]:SetHeight(36)
            button.icons[1]:SetTexCoord(0,0.5,0,1)
            button.icons[2]:SetTexCoord(0.5,1,0,1)
            if flash and button.flash then
                button.flash[1]:SetTexCoord(0,0.5,0,1)
                button.flash[2]:SetTexCoord(0.5,1,0,1)
            end
        else
            local icon = XiTimers.timers[1].button.icons[1]
            local flash = XiTimers.timers[1].button.flash[1]
			local width = icon:GetWidth() / 2
			--local height = icon:GetHeight() / 2
            button.icons[1]:SetWidth(width)
            button.icons[2]:SetWidth(width)
            --button.icons[1]:SetHeight(height)
            --button.icons[2]:SetHeight(height)
            local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = icon:GetTexCoord()
            button.icons[1]:SetTexCoord(ULx, ULy, LLx, LLy, URx/2, URy, LRx/2, LRy)
            button.icons[2]:SetTexCoord((1-ULx)/2, ULy, (1-LLx)/2, LLy, URx, URy, LRx, LRy)
            button.icons[2]:Show()
            if flash and button.flash then
                button.flash[2]:SetTexture(button.flash[1]:GetTexture())
                button.flash[1]:SetTexCoord(0,0.5,0,1)
                button.flash[2]:SetTexCoord(0.5,1,0,1)
            end
        end
    else
        button.icons[1]:ClearAllPoints()
        button.icons[1]:SetPoint("CENTER", button, "CENTER")
        button.icons[2]:Hide()        
        if not skin then
            button.icons[1]:SetWidth(36)
            button.icons[1]:SetHeight(36)
            button.icons[1]:SetTexCoord(0,1,0,1)
            if flash and button.flash then
                button.flash[1]:SetTexCoord(0,1,0,1)
            end           
        else
            local icon = XiTimers.timers[1].button.icons[1]
            button.icons[1]:SetWidth(icon:GetWidth())
            button.icons[1]:SetHeight(icon:GetHeight())
            local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = icon:GetTexCoord()
            button.icons[1]:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
            if flash and button.flash then
                button.flash[1]:SetTexCoord(XiTimers.timers[1].button.flash[1]:GetTexCoord())
            end
        end
    end
end

function TotemTimers.SetDoubleTexture(button, isdouble, flash)
    if isdouble then
        DoubleIcons[button] = true
    else
        DoubleIcons[button] = nil
    end
    TotemTimers.SetDoubleTexCoord(button, flash)
end

function TotemTimers.ApplySkin(hasSkin, newMask)
    skin = hasSkin
    for k,v in pairs(DoubleIcons) do
        TotemTimers.SetDoubleTexCoord(k, k == XiTimers.timers[8].button)
    end
end


function TotemTimers.SaveFramePositions()
    for k,v in pairs(TotemTimers.ActiveProfile.FramePositions) do
        if (_G[k]) then
            local pos = {_G[k]:GetPoint()}
            if not pos[1] then pos = nil end
            if pos[2] then pos[2] = pos[2]:GetName() end
            TotemTimers.ActiveProfile.FramePositions[k] = pos
        end
    end 
    for i = 1, #XiTimers.timers do
        local timer = XiTimers.timers[i]
        if timer.savePos and timer.button:GetNumPoints()>0 then
            local pos = {timer.button:GetPoint(1)}
            if not pos[1] then pos = nil
            elseif pos[2] then
                pos[2] = pos[2]:GetName()
            end
            TotemTimers.ActiveProfile.TimerPositions[timer.nr] = pos
        end
    end
end


local Sink = LibStub:GetLibrary("LibSink-2.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers")

function TotemTimers.ThrowWarning(wtype, object, icon)
    local warning = TotemTimers.ActiveProfile.Warnings[wtype]
    if warning and Sink then
        Sink:Pour(TotemTimers, warning, format(L[wtype],object),warning.r,warning.g,warning.b,
            nil,nil,nil,nil,nil,icon)        
    end
end

function TotemTimers.UpdateMacro()
    --if TotemTimers.Settings.Style == "buff" then return end
    if not InCombatLockdown() then
        macroNeedsUpdate = false
        local _, free = GetNumMacros()
        local nrCast = GetMacroIndexByName("TT Cast")
		local nrBuff = GetMacroIndexByName("TT Buff")
		
        if  nrCast~=0 or free<18 then
			local sequence = "/castsequence reset=combat/"..TotemTimers.ActiveProfile.MacroReset.." ";
        local timers = XiTimers.timers
        for i=1,4 do
            local timer = timers[i]
            if timer.active and TotemTimers.ActiveProfile.IncludeInMacro[timer.nr] then
                local spell = timer.button:GetAttribute("*spell1")
                if spell then
                    sequence = sequence .. spell..", "
                end
            end
        end
        sequence = strsub(sequence, 1, strlen(sequence)-2)
        local nr = GetMacroIndexByName("TT Cast")
        if nr == 0 then
				CreateMacro("TT Cast", "INV_MISC_QUESTIONMARK", sequence, true)
        else
            EditMacro(nr, "TT Cast", nil, sequence)
        end
		end 
		_, free = GetNumMacros()
		if nrBuff~=0 or free<18 then
			local we = TotemTimers.ActiveProfile.LastWeaponEnchant
			local we2 = TotemTimers.ActiveProfile.LastWeaponEnchant2
	--		local spell1, spell2
	--		if TotemTimers.AvailableTalents.DualWield then
	--[[			if we == 5 then
					spell1 = TotemTimers.SpellNames[TotemTimers.SpellIDs.WindfuryWeapon]
					spell2 = TotemTimers.SpellNames[TotemTimers.SpellIDs.FlametongueWeapon]
				elseif we == 6 then
					spell1 = TotemTimers.SpellNames[TotemTimers.SpellIDs.WindfuryWeapon]
					spell2 = TotemTimers.SpellNames[TotemTimers.SpellIDs.FrostbrandWeapon]
				else
	]]
	--				spell1 = we 
	--				spell2 = we2
	--			end
	--		else
	--			spell1 = we
	--		end
			sequence = "/castsequence [nomod] reset=combat/5  " .. TotemTimers.ActiveProfile.ShieldLeftButton .. ", " .. we
			if TotemTimers.AvailableTalents.DualWield and we2 then sequence = sequence .. "\n/cast [@none,mod] " .. we2 end
			sequence = sequence .. "\n/use [nomod] 16; [mod] 17\n/click StaticPopup1Button1"
			local nr = GetMacroIndexByName("TT Buff")
			if nr == 0 then
				CreateMacro("TT Buff", "INV_MISC_QUESTIONMARK", sequence, 1)
			else
				EditMacro(nr, "TT Buff", nil, sequence)
			end
			
			
		end
    else
        macroNeedsUpdate = true
    end
end


function TotemTimers.UnitBuffs(unit)
    local buffs = {}
    for i=1, 40 do
        local name, texture, count, _, duration, expTime, caster, _, _, spellId = UnitBuff(unit, i)
        if (name) then
            table.insert(buffs, { 
				["name"] = name,
                ["duration"] = duration,
                ["expTime"] = expTime,
                ["caster"] = caster,
                ["spellId"] = spellId,
				["count"] = count,
				["texture"] = texture,
            })
        end
    end
    return buffs
end

TotemTimers.onWF_STATUS = function(pfx, msg, ch, src, tgt, ...) 
    local tGUID, tID, tExpire, tLag, tExtra = strsplit(':', msg)
    local pty = TotemTimers.party
	local WFtimer = XiTimers.timers[TotemTimers.ActiveProfile.Order[AIR_TOTEM_SLOT]]
	local TotemWeaponEnchants = TotemTimers.WEMapToProvider
	if tID == 'nil' then tID = -1 end
	tID = tonumber(tID)
	if tExpire == 'nil' then tExpire = -1 end
	local playerLag =  0 --select(3, GetNetStats())
	tLag = playerLag + tonumber(tLag)
	tExpire = time() + (tonumber(tExpire) - tLag ) / 1000
	for t = 1,4 do
		if not pty[t] then pty[t] = {} end
		if UnitGUID('party'..t) and tGUID == UnitGUID('party'..t) then
			pty[t].tID = tID
			pty[t].tExpire = tExpire 
			pty[t].tLag = tLag / 1000
			if TotemWeaponEnchants[tID] == TotemTimers.SpellIDs.Windfury then
				UpdatePartyRange(WFtimer,'party'..t)
			end
			break
		end
	end
end