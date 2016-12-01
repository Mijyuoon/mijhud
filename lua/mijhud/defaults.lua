-- Default settings
local MOD = {
	LoadIndex = 1,
	LoadName = "Defaults",
}
MijHUD.LoadModule(MOD)

function MOD.Initialize()
	MijHUD.ColorScheme("Pri", {
		Back = Color(0, 90, 190),
		ColA = Color(0, 155, 255),
		ColB = Color(180, 180, 80),
	})
	MijHUD.ColorScheme("Sec", {
		Back = Color(0, 190, 90),
		ColA = Color(0, 255, 155),
		ColB = Color(80, 130, 80),
	})
	MijHUD.ColorScheme("Warn", {
		ColA = Color(255, 230, 50),
	})
	MijHUD.ColorScheme("Crit", {
		Back = Color(200, 30, 30),
		ColA = Color(255, 50, 50),
	})
	MijHUD.ColorScheme("Radar", {
		Fill = Color(0, 255, 155),

		N = Color(100, 100, 100),
		F = Color(50, 50, 255),
		D = Color(255, 50, 50),
		S = Color(190, 160, 30),
		U = Color(175, 55, 195),
	})
	MijHUD.ColorScheme("Trig", {
		TELE = Color(30, 90, 255),
		ONCE = Color(255, 160, 30),
		MULT = Color(255, 160, 30),
		HURT = Color(255, 30, 30),
		PUSH = Color(150, 60, 255),
		LOOK = Color(90, 200, 30),
	})

	MijHUD.Options.Basic = {
		LowHealth = 20,
		LowPrClip = 0.2,
	}

	MijHUD.Options.Items = {
		ClipSizes = {
			weapon_pistol   = 18,
			weapon_357      = 6,
			weapon_smg1     = 45,
			weapon_ar2      = 30,
			weapon_shotgun  = 6,
			weapon_crossbow = 1,
			weapon_nomad    = 50,
			fnp90           = 50,
		};
	}

	do -- Get CW and FA:S clip sizes --------
		local wp_patt = { "^cw_", "^fas2_" }
		local function dump_clipsizes()
			local _, weps = debug.getupvalue(weapons.GetStored, 1)
			local clips = MijHUD.Options.Items.ClipSizes
			for name, wep in pairs(weps) do
				for _, patt in ipairs(wp_patt) do
					if name:match(patt) then
						clips[name] = wep.Primary.ClipSize
						break
					end
				end
			end
		end

		if MijHUD_Loaded then
			dump_clipsizes()
		else
			MijHUD.OneTimeHook("InitPostEntity", dump_clipsizes)
		end
	end -------------------------------------

	MijHUD.Options.Radar = {
		VisShowGates = false,
		VisShowNpcs  = true,
		VisShowPlys  = true,
		HudShowGates = false,
		HudShowNpcs  = true,
		HudShowPlys  = true,
		HudMaxRange  = 10000,
		VisMaxRange  = 10000,

		NpcIdents = {
			npc_alyx       = "F",
			npc_barney     = "F",
			npc_breen      = "F",
			npc_citizen    = "F",
			npc_dog        = "F",
			npc_eli        = "F",
			npc_kleiner    = "F",
			npc_mossman    = "F",
			npc_magnusson  = "F",
			npc_vortigaunt = "F",

			npc_antlion          = "D",
			npc_antlionguard     = "D",
			npc_antlion_worker   = "D",
			npc_combine_s        = "D",
			npc_fastzombie       = "D",
			npc_fastzombie_torso = "D",
			npc_headcrab         = "D",
			npc_headcrab_black   = "D",
			npc_headcrab_poison  = "D",
			npc_headcrab_fast    = "D",
			npc_hunter           = "D",
			npc_metropolice      = "D",
			npc_poisonzombie     = "D",
			npc_zombie           = "D",
			npc_zombie_torso     = "D",
			npc_zombine          = "D",

			npc_barnacle       = "S",
			npc_manhack        = "S",
			npc_rollermine     = "S",
			npc_turret_ceiling = "S",
			npc_turret_floor   = "S",

			npc_combinegunship = "U",
			npc_helicopter     = "U",
			npc_strider        = "U",

			npc_barnacle_tongue_tip = false,
		};
	}

	MijHUD.Options.Trigger = {
		MaxRange   = 2000,
		AutoQuery  = false,
		QueryTimer = 30,
	}

	MijHUD.Options.Battery = {
		MaxCharge  = 7290,
		CritLevel  = 0.05,
		ChargeRate = 17.6,
		DrainRate  = 3.1,
		--DrainRate = 0.01,
	}

	MijHUD.Options.Show = {
		EntClass = true,
		HudRadar = false,
		VisRadar = true,
		Triggers = false,
	}

	MijHUD.Options.OptionMenu = {
		{Name = "HUD Components", Type = "Goto", Data = {
			{Type = "Back"};
			{Name = "Radar Overlay", Type = "Chk", Var = "Show.VisRadar"};
			{Name = "Radar HUD", Type = "Chk", Var = "Show.HudRadar"};
			{Name = "Entity Class", Type = "Chk", Var = "Show.EntClass"};
			{Name = "Triggers", Type = "Chk", Var = "Show.Triggers"};
		}};
		{Name = "Radar Display", Type = "Goto", Data = {
			{Type = "Back"};
			{Name = "Range (HUD)", Type = "Num", Var = "Radar.HudMaxRange",
				Min = 500, Max = 30000, Step = 500};
			{Name = "Range (Overlay)", Type = "Num", Var = "Radar.VisMaxRange",
				Min = 500, Max = 30000, Step = 500};
		}};
		{Name = "Trigger Display", Type = "Goto", Data = {
			{Type = "Back"};
			{Name = "Range", Type = "Num", Var = "Trigger.MaxRange",
				Min = 500, Max = 30000, Step = 500};
			{Name = "Query Trigger Data", Type = "Btn", Fn = "Triggers:QueryData"};
			{Name = "Periodic Querying", Type = "Chk", Var = "Trigger.AutoQuery"};
			{Name = "Query Interval", Type = "Num", Var = "Trigger.QueryTimer",
				Min = 10, Max = 180, Step = 10};
		}};
		{Name = "Save Settings", Type = "Btn", Fn = "OptionMenu:SaveSettings"};
	}
end
