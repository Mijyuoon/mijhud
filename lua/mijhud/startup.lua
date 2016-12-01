-- Startup sequence
local MOD = {
	--LoadIndex = 1,
	LoadName = "Startup",
	UseOffline = true,
}
MijHUD.LoadModule(MOD)

MOD.BootSequence = {
	Done = 30,
	Snd = {},
	Lf = {
		Ena = 1,
		Dis = 30,
		"CPU CHECK",
		"MEMORY SET",
		"D-BUS CLEAR",
		"ROM LOADED",
		"STATUS CHK",
		"OK"
	};
	Rt = {
		Ena = 7,
		Dis = 30,
		"CHECKSUMS",
		"-ROM F2h-",
		"92C2A508", 
		"133C81F7", 
		"622094BE", 
		"63D6C6A9", 
		"CA8257D2"
	};
	Mx = {
		Ena = 14, Dis = 30,
		{"MijHUD v1.792 initializing", false};
		{"Primary system startup:", false};
		{"\t# Verifying hardware integrity", "[OK]"};
		{"\t# Loading initial RAM image", "[OK]"};
		{"\t# Loading common runtime code", "[OK]"};
		{"\t# Initializing /proc structure", "[OK]"};
		{"\t# Mounting default filesystem", "[OK]"};
		{"\t# Starting primary services", "[OK]"};
		{"Auxiliary system startup:", false};
		{"\t# Initializing I/O controller", "[OK]"};
		{"\t# Loading ext. device drivers", "[OK]"};
		{"\t# Initializing user monitor", "[OK]"};
		{"\t# Initializing sensor array", "[OK]"};
		{"\t# Loading user configuration", "[OK]"};
		{"MijHUD initialization completed", false};
	};
}

local function addsounds(lst)
	for _, tbl in ipairs(lst) do
		for i = tbl[1], tbl[2] do
			MOD.BootSequence.Snd[i] = tbl[3]
		end
	end
end

local snd_boot1a = Sound("mijhud/boot-1a.mp3")
local snd_boot1b = Sound("mijhud/boot-1b.mp3")
local snd_boot2a = Sound("mijhud/boot-2a.mp3")
local snd_boot2b = Sound("mijhud/boot-2b.mp3")

addsounds {
	{2, 7, snd_boot1a};
	{8, 14, snd_boot1b};
	{18, 23, snd_boot2a};
	{25, 29, snd_boot2a};
	{30, 30, snd_boot2b};
}

local floor = math.floor
local clamp = math.Clamp
local cp_list = {}

local function mx_setmaxlen(nx)
	local maxlen = 0
	local font = MijHUD.GetFont("HUD_Txt26")
	for _, vt in ipairs(MOD.BootSequence.Mx) do
		if not vt[2] then continue end
		local vtx = scr.TextSize(vt[1], font)
		if maxlen < vtx then maxlen = vtx end
	end
	MOD.BootSequence.Mx.LenX = maxlen + nx
end

local hud_hide = MijHUD.Core.List_HideHUD
function MOD.DrawBaseHUD(item)
	if not MijHUD.IsStarting then return end
	if hud_hide[item] == 1 then return false end
end

function MOD.Initialize()
	MijHUD.IsStarting = false
	MijHUD.LoadTextures("HUD", {
		BootLf = "mijhud/boot_lf.png",
		BootRt = "mijhud/boot_rt.png",
		BootMx = "mijhud/boot_mx.png",
	})
	MijHUD.CreateFont("HUD", {
		Name = "Txt26",
		Font = "OCR A Extended",
		Size = 26,
	})
	
	timer.Create("MijHUD.Startup", 0.22, 0, MOD.DoStartup)
	
	local mhud = MijHUD.Basic.UtilsDispLf
	An_DeltaX = ScrW()/2 - (mhud.W + 10)
	An_DeltaY = ScrH()/2 - (mhud.H + 10)
	An_Scale = mhud.H / mhud.W
	An_FinalSz = mhud.W
	
	local boot_lf = MijHUD.NewComponent(true)
	MOD.StartupDispLf = boot_lf
	function boot_lf:OnRender(x,y,w,h)
		local dats = MOD.BootSequence.Lf
		local mval = MijHUD.IsStarting - dats.Ena
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local tex = MijHUD.GetTexture("HUD_BootLf")
		local font = MijHUD.GetFont("HUD_Txt26")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		for i = 1, clamp(mval, 0, #dats) do
			scr.DrawText(x+w+4, y+4+26*(i-1), dats[i], -1, -1, col_m, font)
		end
	end
	boot_lf:SetViewport(50,-40,36,180)
	
	local boot_rt = MijHUD.NewComponent(true)
	MOD.StartupDispRt = boot_rt
	function boot_rt:OnRender(x,y,w,h)
		local dats = MOD.BootSequence.Rt
		local mval = MijHUD.IsStarting - dats.Ena
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local tex = MijHUD.GetTexture("HUD_BootRt")
		local font = MijHUD.GetFont("HUD_Txt26")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		for i = 1, clamp(mval, 0, #dats) do
			scr.DrawText(x-4, y+4+26*(i-1), dats[i], 1, -1, col_m, font)
		end
	end
	boot_rt:SetViewport(-50,-160,36,210)
	
	local boot_mx = MijHUD.NewComponent(true)
	MOD.StartupDispMx = boot_mx
	function boot_mx:OnRender(x,y,w,h)
		local dats = MOD.BootSequence.Mx
		local mval = MijHUD.IsStarting - dats.Ena
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local tex = MijHUD.GetTexture("HUD_BootMx")
		local font = MijHUD.GetFont("HUD_Txt26")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		for i = 1, clamp(mval, 0, #dats) do
			local txti, stsi = dats[i][1], dats[i][2]
			scr.DrawText(x+w+4, y+4+26*(i-1), txti, -1, -1, col_m, font)
			if stsi and i < mval then
				local mlen = dats.LenX + 4
				scr.DrawText(x+w+mlen, y+4+26*(i-1), stsi, -1, -1, col_m, font)
			end
		end
	end
	boot_mx:SetViewport(30,20,36,416)
	
	table.insert(cp_list, boot_lf)
	table.insert(cp_list, boot_rt)
	table.insert(cp_list, boot_mx)
end

function MOD.ToggleHUD()
	---[[
	if MijHUD.IsShown or MijHUD.IsStarting then
		MijHUD.IsStarting = false
		MijHUD.IsShown = false
	else
		MOD.BeginStartup()
	end
	return true
	--]]
end

function MOD.BeginStartup()
	MijHUD.IsStarting = 0
	mx_setmaxlen(30)
end

function MOD.RenderHUD(ofln)
	if not (ofln and MijHUD.IsStarting) then return end
	for i = 1, #cp_list do
		cp_list[i]:CallRender()
	end
end

function MOD.Interval(ofln)
	if not (ofln and MijHUD.IsStarting) then return end
	for i = 1, #cp_list do
		cp_list[i]:CallInterval()
	end
end

function MOD.DoStartup()
	local startval = MijHUD.IsStarting
	if not startval then return end
	local startval_n = startval + 1
	local bootseq = MOD.BootSequence
	local sndpath = bootseq.Snd[startval_n]
	if sndpath then
		LocalPlayer():EmitSound(sndpath)
	end
	MijHUD.IsStarting = startval_n
	if startval_n == bootseq.Done then
		MijHUD.IsStarting = false
		MijHUD.IsShown = true
	end
end
