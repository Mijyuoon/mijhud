if SERVER then
	local flist = file.Find("mijhud/*.lua", "LSV")
	for _, fname in ipairs(flist) do
		print("[Mij SV] Loaded mijhud/"..fname)
		AddCSLuaFile("mijhud/"..fname)
	end
end

if CLIENT then
	MijHUD = {
		Version = "v1.7",
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
		MijHUD.CallHookEx("RenderHUD")
	end)
	hook.Add("HUDShouldDraw", "MijHUD", function(val)
		return MijHUD.CallHook("DrawBaseHUD", val)
	end)
	concommand.Add("mijhud_toggle", function()
		if not MijHUD.CallHook("ToggleHUD") then
			MijHUD.IsShown = not MijHUD.IsShown
		end
	end)
	
	include("autorun/client/scrlib.lua")
	local flist = file.Find("mijhud/*.lua", "LCL")
	for _, fname in ipairs(flist) do
		print("[Mij CL] Loaded mijhud/"..fname)
		include("mijhud/"..fname)
	end
	MijHUD.CallHook("Initialize")
	MijHUD_Loaded = true
end