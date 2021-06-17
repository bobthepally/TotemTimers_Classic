-- Copyright © 2008 - 2012 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current distribution permissions only include curse.com, wowinterface.com and their respective addon updaters

if select(2,UnitClass("player")) ~= "SHAMAN" then return end

TotemTimers = {}


TotemTimers.AvailableSpells = {}
TotemTimers.AvailableSpellIDs = {}
TotemTimers.AvailableTalents = {}

TotemTimers.SpellIDs = {

    Tremor = 8143, --
    Stoneskin = 8071, --
    Stoneclaw = 5730, --
    StrengthOfEarth = 8075, --
    EarthBind = 2484, --
    EarthElemental = 2062,

    Searing = 3599, --
    FireNova = 1535, --
    Magma = 8190, --
    FrostResistance = 8181, --
    Flametongue = 8227, --
    FireElemental = 2894,
    Wrath = 30706,
    
    HealingStream = 5394, --
    ManaTide = 16190, --
    PoisonCleansing = 8166, --
    DiseaseCleansing = 8170, --
    ManaSpring = 5675, --
    FireResistance = 8184, --
    
    Grounding = 8177, --
    NatureResistance = 10595, --
    Windfury = 8512, --
    Sentry = 6495, --
    Windwall = 15107, --
    GraceOfAir = 8835, --
    TranquilAir = 25908, --
    WrathOfAir = 3738,
	
    
    Ankh = 20608,
    TotemicCall = 36936,
    LightningShield = 324,
    WaterShield = 24398,
    EarthShield = 974,

    RockbiterWeapon = 8017,
    FlametongueWeapon = 8024,
    FrostbrandWeapon = 8033,
    WindfuryWeapon = 8232,

    EarthShock = 8042,
    FrostShock = 8056,
    FlameShock = 8050,
    StormStrike = 17364,

    --EnamoredWaterSpirit = 24854 -- Water Totem trinket
    --[[
    PrimalStrike = 73899,
    LavaLash = 60103,
    LightningBolt = 403,
    ChainLightning = 421,
    LavaBurst = 51505,
    Maelstrom = 51530,
    WindShear = 57994,
    ShamanisticRage = 30823,
    FeralSpirit = 51533,
    ElementalMastery = 16166,
    Thunderstorm = 51490,
    HealingRain = 73920,
    Riptide = 61295,
    UnleashElements = 73680,
	UnleashLife = 73685,
    SpiritwalkersGrace = 79206,
    Ascendance = 114049,
	AscendanceEnhancement = 114051,
	AscendanceElemental = 114050,
	AscendanceRestoration = 114052,
     
    CallOfElements = 108285,
    SpiritWalk = 58875,
    AstralShift = 108271,
    TotemicProjection = 108287,
    AncestralSwiftness = 16188,
    AncestralGuidance = 108281,
    ElementalBlast = 117014,
    
    LiquidMagma = 152255,
    LavaSurge = 77762,
    
    Hex = 51514,
    
    UnleashFlame = 73683,
	UnleashFlameEle = 165462,
    Volcano = 99207,
	
	Bloodlust = 2825,
	Heroism = 32182,
	AstralShift = 108271,
	Stormblast = 115356,
	PurifySpirit = 77130,
	
	ChainHeal = 1064, ]]
	
}

local SpellIDs = TotemTimers.SpellIDs

TotemTimers.SpellTextures = {}
TotemTimers.SpellNames = {}
TotemTimers.NameToSpellID = {}
TotemTimers.TextureToSpellID = {}
TotemTimers.NameToSpellIDL = {}

for k,v in pairs(SpellIDs) do
    local n,_,t = GetSpellInfo(v)
    TotemTimers.SpellTextures[v] = t
    TotemTimers.SpellNames[v] = n
    if n then
        TotemTimers.NameToSpellID[n] = v
        TotemTimers.NameToSpellIDL[string.lower(n)] = v
    end
    if t then
        TotemTimers.TextureToSpellID[t] = v
    end
end



--[[
1 - Melee
2 - Ranged
3 - Caster
4 - Healer
5 - Hybrid (mostly Enh. Shaman)
]]


TotemData = {
	[SpellIDs.Tremor] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 3,
        warningPoint = 2,
        rangeCheck = 30,
    },
    [SpellIDs.Stoneskin] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = false,
    },
    [SpellIDs.Stoneclaw] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
 --       warningPoint = 2,
    },
    [SpellIDs.StrengthOfEarth] = {
        element = EARTH_TOTEM_SLOT,
         noRangeCheck = false,
    },
    [SpellIDs.EarthBind] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 3,
        flashDelay = 1,
        warningPoint = 5,
    },
    [SpellIDs.EarthElemental] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
	},
	[SpellIDs.Searing] = {
           element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
        warningPoint = 5,
	},
    [SpellIDs.FireNova] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
	[SpellIDs.Magma] = {
		element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
	},
    [SpellIDs.FrostResistance] = {
        element = FIRE_TOTEM_SLOT,
         noRangeCheck = false,
    },
    [SpellIDs.Flametongue] = {
        element = FIRE_TOTEM_SLOT,
         noRangeCheck = false,
    },
    [SpellIDs.FireElemental] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [SpellIDs.Wrath] = {
        element = FIRE_TOTEM_SLOT,
         noRangeCheck = false,
    },
    [SpellIDs.HealingStream] = {
		element = WATER_TOTEM_SLOT,
		warningPoint = 4, 
		noRangeCheck = false,
	},
    [SpellIDs.ManaTide] = {
        element = WATER_TOTEM_SLOT,
        warningPoint = 2,
		noRangeCheck = false,
        rangeCheck = 20,
    },
    [SpellIDs.PoisonCleansing] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 5,
        rangeCheck = 20,
    },
    [SpellIDs.DiseaseCleansing] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 5,
        rangeCheck = 20,
    },
    [SpellIDs.ManaSpring] = {
        element = WATER_TOTEM_SLOT,
         noRangeCheck = false,
    },
    [SpellIDs.FireResistance] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = false,
    },
	[SpellIDs.Grounding] = {
		element = AIR_TOTEM_SLOT,
--     partyOnly = true,
--    range = 100,
--		warningPoint = 5,
--		flashInterval = 10,
		noRangeCheck = false,
	},
    [SpellIDs.NatureResistance] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = false,
    },
    [SpellIDs.Windfury] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = false,
		flashInterval = 10,
		warningPoint = 5,
    },
    [SpellIDs.Sentry] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [SpellIDs.Windwall] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = false,
    },
    [SpellIDs.GraceOfAir] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = false,
    },
    [SpellIDs.TranquilAir] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = false,
    },
    [SpellIDs.WrathOfAir] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = false,
    },

}
local TotemCount = {}
for k,v in pairs(TotemData) do
    TotemCount[v.element] = (TotemCount[v.element] or 0) + 1
end
TotemTimers.TotemCount = TotemCount

local amtp = {
	[30708] = 30706,
	[25909] = 25908,
	[5677] = 5675,
	[10491] = 10495,
	[10493] = 10496,
	[10494] = 10497,
	[25569] = 25570,
	[5672] = 5394,
	[6371] = 6375,
	[6372] = 6377,
	[10460] = 10462,
	[10461] = 10463,
	[25566] = 25567,
	[8072] = 8071,
	[8156] = 8154,
	[8157] = 8155,
	[10403] = 10406,
	[10404] = 10407,
	[10405] = 10408,
	[25506] = 25508,
	[25507] = 25509,
	[8836] = 8835,
	[10626] = 10627,
	[25360] = 25359,
	[8076] = 8075,
	[8162] = 8160,
	[8163] = 8161,
	[10441] = 10442,
	[25362] = 25361,
	[25527] = 25528,
	[8182] = 8181,
	[10476] = 10478,
	[10477] = 10479,
	[25559] = 25560,
	[8185] = 8184,
	[10534] = 10537,
	[10535] = 10538,
	[25562] = 25563,
	[10596] = 10595,
	[10598] = 10600,
	[10599] = 10601,
	[15108] = 15107,
	[15109] = 15111,
	[15110] = 15112,
	[25576] = 25577,
	[2895] = 3738,
	[8178] = 8177,
	[25573] = 25574,
	
}

TotemTimers.AuraMapToProvider = {}

for k,v in pairs(amtp) do
    local n,_,t = GetSpellInfo(v)
    TotemTimers.AuraMapToProvider[k] = TotemTimers.NameToSpellID[n]
end

for k,v in pairs(amtp) do
    if  TotemData[v] ~= nil then TotemData[v].buffName = GetSpellInfo(k) end
end


TotemTimers.WEMapToProvider = {
 -- Windfury Totem
        [564] = 8512,
		[563] = 8512,
		[1783] = 8512,
		[2638] = 8512,
		[2639] = 8512,
 -- Flametongue Totem
        [124] = 8227, 
		[285] = 8227, 
		[543] = 8227, 
		[1683] = 8227,
		[2637] = 8227,
}


TotemTimers.WeaponEnchants = {
    [3] = SpellIDs.FlametongueWeapon,
    [4] = SpellIDs.FlametongueWeapon,
    [5] = SpellIDs.FlametongueWeapon,
    [523] = SpellIDs.FlametongueWeapon,
    [1665] = SpellIDs.FlametongueWeapon,
    [1666] = SpellIDs.FlametongueWeapon,
    [2634] = SpellIDs.FlametongueWeapon,
    [3779] = SpellIDs.FlametongueWeapon,
    [3780] = SpellIDs.FlametongueWeapon,
    [3781] = SpellIDs.FlametongueWeapon,
    [1] = SpellIDs.RockbiterWeapon,
    [6] = SpellIDs.RockbiterWeapon,
    [29] = SpellIDs.RockbiterWeapon,
    [503] = SpellIDs.RockbiterWeapon,
    [504] = SpellIDs.RockbiterWeapon,
    [683] = SpellIDs.RockbiterWeapon,
    [1663] = SpellIDs.RockbiterWeapon,
    [1664] = SpellIDs.RockbiterWeapon,
    [2632] = SpellIDs.RockbiterWeapon,
    [2633] = SpellIDs.RockbiterWeapon,
    [3018] = SpellIDs.RockbiterWeapon,
    [283] = SpellIDs.WindfuryWeapon,
    [284] = SpellIDs.WindfuryWeapon,
    [525] = SpellIDs.WindfuryWeapon,
    [1669] = SpellIDs.WindfuryWeapon,
    [2636] = SpellIDs.WindfuryWeapon,
    [3785] = SpellIDs.WindfuryWeapon,
    [3786] = SpellIDs.WindfuryWeapon,
    [3787] = SpellIDs.WindfuryWeapon,
    [2] = SpellIDs.FrostbrandWeapon,
    [12] = SpellIDs.FrostbrandWeapon,
    [5244] = SpellIDs.FrostbrandWeapon,
    [1667] = SpellIDs.FrostbrandWeapon,
    [1668] = SpellIDs.FrostbrandWeapon,
    [2635] = SpellIDs.FrostbrandWeapon,
    [3782] = SpellIDs.FrostbrandWeapon,
    [3783] = SpellIDs.FrostbrandWeapon,
    [3784] = SpellIDs.FrostbrandWeapon,
}

for i = 3018, 3044 do TotemTimers.WeaponEnchants[i] = SpellIDs.RockbiterWeapon end

function TotemTimers.GetMaxRank(spell)
	local maxspell
	if type(spell) == "number" then
		maxspell = select(1,GetSpellInfo(spell))
	else
		maxspell = spell
	end
	local spellId = select(7, GetSpellInfo(maxspell))
	local rank = GetSpellSubtext(spellId)
	if rank then 
		maxspell = maxspell .. "(" .. rank ..")"
	end
	return maxspell
end