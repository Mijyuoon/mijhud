-- Default settings
local MOD = {}
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
	})
	MijHUD.ColorScheme("Warn", {
		ColA = Color(255, 230, 50),
	})
	MijHUD.ColorScheme("Crit", {
		Back = Color(200, 30, 30),
		ColA = Color(255, 50, 50),
	})
	MijHUD.ColorScheme("Radar", {
		B = Color(0, 255, 155),
		N = Color(100, 100, 100),
		F = Color(50, 50, 255),
		D = Color(255, 50, 50),
		S = Color(220, 190, 50),
		U = Color(190, 50, 220),
	})
	
	MijHUD.Options.Items = {
		ClipSizes = {
			weapon_pistol = 18,
			weapon_357 = 6,
			weapon_smg1 = 45,
			weapon_ar2 = 30,
			weapon_shotgun = 6,
			weapon_crossbow = 1,
			weapon_nomad = 50,
			fnp90 = 50,
		}
	}
	
	do -- Get CW and FA:S clip sizes
		local wp_patt = { "^cstm_", "^fas2_" }
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
			local hid = MijHUD.GetUniqueID()
			hook.Add("InitPostEntity", hid, function()
				dump_clipsizes()
				hook.Remove("InitPostEntity", hid)
			end)
		end
	end
	
	MijHUD.Options.Radar = {
		ShowNpcs = true,
		SnowPlayers = true,
		MaxRange = 3000,
		NpcIdents = {
			npc_alyx = "F",
			npc_barney = "F",
			npc_breen = "F",
			npc_citizen = "F",
			npc_dog = "F",
			npc_kleiner = "F",
			npc_mossman = "F",
			npc_magnusson = "F",
			npc_eli = "F",
			npc_vortigaunt = "F",
		
			npc_antlion = "D",
			npc_antlionguard = "D",
			npc_antlion_worker = "D",
			npc_combine_s = "D",
			npc_fastzombie = "D",
			npc_fastzombie_torso = "D",
			npc_headcrab = "D",
			npc_headcrab_black = "D",
			npc_headcrab_fast = "D",
			npc_hunter = "D",
			npc_metropolice = "D",
			npc_poisonzombie = "D",
			npc_zombie = "D",
			npc_zombie_torso = "D",
			
			npc_manhack = "S",
			npc_rollermine = "S",
			npc_turret_ceiling = "S",
			npc_turret_floor = "S",
			
			npc_combinegunship = "U",
			npc_helicopter = "U",
			npc_strider = "U",
			
			npc_barnacle = "??",
			npc_barnacle_tongue_tip = "??",
		};
	}
	
	MijHUD.Options.Battery = {
		MaxCharge = 7290,
		CritLevel = 0.05,
		ChargeRate = 17.6,
		DrainRate = 5.7,
	}
end