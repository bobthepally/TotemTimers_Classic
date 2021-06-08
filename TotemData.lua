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

TotemTimers.SpellTextures = {}
TotemTimers.SpellNames = {}
TotemTimers.NameToSpellID = {}
TotemTimers.TextureToSpellID = {}
TotemTimers.NameToSpellIDL = {}

for k,v in pairs(TotemTimers.SpellIDs) do
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
	[TotemTimers.SpellIDs.Tremor] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 3,
        warningPoint = 2,
    },
    [TotemTimers.SpellIDs.Stoneskin] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.Stoneclaw] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
        warningPoint = 2,
    },
    [TotemTimers.SpellIDs.StrengthOfEarth] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.EarthBind] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 3,
        flashDelay = 1,
        warningPoint = 5,
    },
    [TotemTimers.SpellIDs.EarthElemental] = {
        element = EARTH_TOTEM_SLOT,
        noRangeCheck = true,
	},
	[TotemTimers.SpellIDs.Searing] = {
           element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
        warningPoint = 5,
	},
    [TotemTimers.SpellIDs.FireNova] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
	[TotemTimers.SpellIDs.Magma] = {
		element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
	},
    [TotemTimers.SpellIDs.FrostResistance] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.Flametongue] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.FireElemental] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.Wrath] = {
        element = FIRE_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.HealingStream] = {
		element = WATER_TOTEM_SLOT,
        range = 1600,
		warningPoint = 4,
	},
    [TotemTimers.SpellIDs.ManaTide] = {
        element = WATER_TOTEM_SLOT,
        warningPoint = 2,
    },
    [TotemTimers.SpellIDs.PoisonCleansing] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 5,
    },
    [TotemTimers.SpellIDs.DiseaseCleansing] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = true,
        flashInterval = 5,
    },
    [TotemTimers.SpellIDs.ManaSpring] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.FireResistance] = {
        element = WATER_TOTEM_SLOT,
        noRangeCheck = true,
    },
	[TotemTimers.SpellIDs.Grounding] = {
		element = AIR_TOTEM_SLOT,
        partyOnly = true,
        range = 100,
		warningPoint = 5,
		flashInterval = 10,
	},
    [TotemTimers.SpellIDs.NatureResistance] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.Windfury] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.Sentry] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.Windwall] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.GraceOfAir] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.TranquilAir] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },
    [TotemTimers.SpellIDs.WrathOfAir] = {
        element = AIR_TOTEM_SLOT,
        noRangeCheck = true,
    },

}



TotemTimers.AuraMapToProvider = {
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
local sid = TotemTimers.SpellIDs

TotemTimers.WeaponEnchants = {
    [3] = sid.FlametongueWeapon,
    [4] = sid.FlametongueWeapon,
    [5] = sid.FlametongueWeapon,
    [523] = sid.FlametongueWeapon,
    [1665] = sid.FlametongueWeapon,
    [1666] = sid.FlametongueWeapon,
    [2634] = sid.FlametongueWeapon,
    [3779] = sid.FlametongueWeapon,
    [3780] = sid.FlametongueWeapon,
    [3781] = sid.FlametongueWeapon,
    [1] = sid.RockbiterWeapon,
    [6] = sid.RockbiterWeapon,
    [29] = sid.RockbiterWeapon,
    [503] = sid.RockbiterWeapon,
    [504] = sid.RockbiterWeapon,
    [683] = sid.RockbiterWeapon,
    [1663] = sid.RockbiterWeapon,
    [1664] = sid.RockbiterWeapon,
    [2632] = sid.RockbiterWeapon,
    [2633] = sid.RockbiterWeapon,
    [3018] = sid.RockbiterWeapon,
    [283] = sid.WindfuryWeapon,
    [284] = sid.WindfuryWeapon,
    [525] = sid.WindfuryWeapon,
    [1669] = sid.WindfuryWeapon,
    [2636] = sid.WindfuryWeapon,
    [3785] = sid.WindfuryWeapon,
    [3786] = sid.WindfuryWeapon,
    [3787] = sid.WindfuryWeapon,
    [2] = sid.FrostbrandWeapon,
    [12] = sid.FrostbrandWeapon,
    [5244] = sid.FrostbrandWeapon,
    [1667] = sid.FrostbrandWeapon,
    [1668] = sid.FrostbrandWeapon,
    [2635] = sid.FrostbrandWeapon,
    [3782] = sid.FrostbrandWeapon,
    [3783] = sid.FrostbrandWeapon,
    [3784] = sid.FrostbrandWeapon,
}
for i = 3018, 3044 do TotemTimers.WeaponEnchants[i] = sid.RockbiterWeapon end