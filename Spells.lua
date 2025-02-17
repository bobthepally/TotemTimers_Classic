-- Copyright © 2008 - 2012 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current distribution permissions only include curse.com, wowinterface.com and their respective addon updaters

if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local TotemTimers = TotemTimers
local SpellNames = TotemTimers.SpellNames
local SpellIDs = TotemTimers.SpellIDs

--[[ local function GetSpellTab(tab)
    local _, _, offset, numSpells = GetSpellTabInfo(tab)
    local AvailableSpells = TotemTimers.AvailableSpells
    for s = offset + 1, offset + numSpells do 
        local spelltype, spell = GetSpellBookItemInfo(s, BOOKTYPE_SPELL)
        if spelltype == "SPELL" then
            AvailableSpells[spell] = true
        end
    end
end  ]]

local GetSpellInfo = GetSpellInfo
local IsPlayerSpell = IsPlayerSpell

function TotemTimers.GetSpells()
    local AvailableSpells = TotemTimers.AvailableSpells
    wipe(AvailableSpells)
    for _,s in pairs(SpellIDs) do
        -- get spell info by name, returns spell info of the spell with the highest rank,
        -- if that spell is learned; check with IsPlayerSpell probably not necessary anymore
        -- but stays in just in case
        local _,_,_,_,_,_,id = GetSpellInfo(SpellNames[s])
        if id ~= nil then
		    AvailableSpells[s] = IsPlayerSpell(id)
		end
    end
    --[[if AvailableSpells[TotemTimers.SpellIDs.PrimalStrike] and UnitLevel("player") > 10 then
        AvailableSpells[TotemTimers.SpellIDs.StormStrike] = true
    end]]
    return true
end

function TotemTimers.GetTalents()
    wipe(TotemTimers.AvailableTalents)
    TotemTimers.AvailableTalents.TotemicMastery = select(5, GetTalentInfo(3,8)) * 10
    TotemTimers.AvailableTalents.DualWield = select(5, GetTalentInfo(2, 18)) > 0

    --if select(5, GetTalentInfo(2,17))>0 then TotemTimers.AvailableTalents.Maelstrom = true end
    --if select(5, GetTalentInfo(1,18))>0 then TotemTimers.AvailableTalents.LavaSurge = true end
    --if select(5, GetTalentInfo(1,13))>0 then TotemTimers.AvailableTalents.Fulmination = true end
end


function TotemTimers.LearnedSpell(spell,tab)
	if spell then TotemTimers.AvailableSpells[spell] = true end
    TotemTimers.SetCastButtonSpells()
    TotemTimers.SetWeaponTrackerSpells()
    TotemTimers.ProcessSetting("AnkhTracker")
    TotemTimers.ProcessSetting("ShieldTracker")
    -- TotemTimers.ProcessSetting("EarthShieldTracker")
    -- TotemTimers.ProcessSetting("EnhanceCDs")
    TotemTimers.ProcessSetting("Show")
	-- TotemTimers.ProcessSetting("LongCooldowns")
    TotemTimers.ProgramSetButtons()
end
local function UpdateRank(button)
    for i = 1,3 do
        for _,type in pairs({"*spell", "spell", "doublespell"}) do
            local spell = button:GetAttribute(type..i)
            if spell then
                button:SetAttribute(type..i, TotemTimers.GetMaxRank(spell))
            end
        end
    end
end

function TotemTimers.UpdateSpellRanks()
    for _,timer in pairs(XiTimers.timers) do
        UpdateRank(timer.button)
        if timer.actionBar then
            for _,actionButton in pairs(timer.actionBar.buttons) do
                UpdateRank(actionButton)
            end
        end
    end
end

function TotemTimers.ChangedTalents()
	TotemTimers.GetSpells()
    TotemTimers.GetTalents()
    TotemTimers.SelectActiveProfile()
    TotemTimers.ExecuteProfile()
    TotemTimers.UpdateSpellRanks()
end
