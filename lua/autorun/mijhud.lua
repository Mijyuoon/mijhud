if SERVER then
	local flist = file.Find("mijhud/*.lua", "LSV")
	for _, fname in ipairs(flist) do
		if not fname:find("%.lua$") then continue end
		print("[Mij SV] Transmit mijhud/"..fname)
		AddCSLuaFile("mijhud/"..fname)
	end
end
	
if CLIENT then
	MijHUD = {
		Version = "v1.792",
		Modules = {},
		IsShown = false,
	}
	
	function MijHUD.LoadModule(mod, tab)
		local idx = mod.LoadIndex
		local tab = mod.LoadName
		local mtab = MijHUD.Modules
		if not idx or idx > #mtab then
			table.insert(mtab, mod)
		elseif idx then
			table.insert(mtab, idx+1, mod)
		end
		if tab and not MijHUD[tab] then
			MijHUD[tab] = mod
		end
	end
	function MijHUD.CallHookEx(name, ...)
		local offln = not MijHUD.IsShown
		--for _, mod in ipairs(MijHUD.Modules) do
		local modtbl = MijHUD.Modules
		for ikey = 1, #modtbl do
			local mod = modtbl[ikey]
			if mod[name] and (not offln or mod.UseOffline) then
				local res = mod[name](offln, ...)
				if res ~= nil then
					return res
				end
			end
		end
	end
	function MijHUD.CallHook(name, ...)
		--for _, mod in ipairs(MijHUD.Modules) do
		local modtbl = MijHUD.Modules
		for ikey = 1, #modtbl do
			local mod = modtbl[ikey]
			if mod[name] then
				local res = mod[name](...)
				if res ~= nil then
					return res
				end
			end
		end
	end
	
	hook.Add("Think", "MijHUD", function()
		MijHUD.CallHookEx("Interval")
	end)
	hook.Add("HUDPaint", "MijHUD", function()
		local draw = hook.Run("HUDShouldDraw", "MijHUD.HUD")
		if draw ~= false then MijHUD.CallHookEx("RenderHUD") end
	end)
	hook.Add("PostDrawTranslucentRenderables", "MijHUD", function(_, sky)
		if sky then return end
		local draw = hook.Run("HUDShouldDraw", "MijHUD.3D")
		if draw ~= false then MijHUD.CallHookEx("Render3D") end
	end)
	hook.Add("HUDShouldDraw", "MijHUD", function(val)
		return MijHUD.CallHook("DrawBaseHUD", val)
	end)

	concommand.Add("mijhud_toggle", function()
		if not MijHUD.CallHook("ToggleHUD") then
			MijHUD.IsShown = not MijHUD.IsShown
		end
	end)
	
	include("autorun/advlib.lua")
	include("autorun/client/scrlib.lua")
	local flist = file.Find("mijhud/*.lua", "LCL")
	for _, fname in ipairs(flist) do
		if not fname:find("%.lua$") then continue end
		print("[Mij CL] Loaded mijhud/"..fname)
		include("mijhud/"..fname)
	end
	MijHUD.CallHook("Initialize")
	MijHUD_Loaded = true
end
