-- Startup sequence
local MOD = {
	--LoadIndex = 1,
	LoadName = "Startup",
	UseOffline = true,
}
MijHUD.LoadModule(MOD)

MOD.BootSequence = {
	Done = 32,
	Act = {},
	Snd = {},
	Lf = {
		Sub = 1,
		Dis = 30,
		"CPU CHECK",
		"MEMORY SET",
		"D-BUS CLEAR",
		"ROM LOADED",
		"STATUS CHK",
		"OK"
	};
	Rt = {
		Sub = 7,
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
		Sub = 14, Dis = 30,
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
	An = {
		Sub = 30, Dis = 99,
	};
}

MOD.BootSequence.Act[30] = function()
	MOD.StartupDispAn.Anim_Mv:StartAnim()
end
MOD.BootSequence.Act[31] = function()
	return true
end

local snd_boot1a = Sound("mijhud/boot-1a.mp3")
local snd_boot1b = Sound("mijhud/boot-1b.mp3")
local snd_boot2a = Sound("mijhud/boot-2a.mp3")
local snd_boot2b = Sound("mijhud/boot-2b.mp3")

local function setsnd(kf, kt, snd)
	for i = kf, kt do
		MOD.BootSequence.Snd[i] = snd
	end
end

setsnd(2, 7, snd_boot1a)
setsnd(8, 14, snd_boot1b)
setsnd(18, 23, snd_boot2a)
setsnd(25, 29, snd_boot2a)
setsnd(30, 30, snd_boot2b)

local An_InitSz = 125
local An_Scale, An_FinalSz, An_DeltaX, An_DeltaY

local floor = math.floor
local clamp = math.Clamp
local ins = table.insert
local cp_list = {}

local function mx_setmaxlen(nx)
	local maxlen = 0
	local font = MijHUD.GetFont("HUD_Txt26")
	for _, vt in ipairs(MOD.BootSequence.Mx) do
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
		local mval = MijHUD.IsStarting - dats.Sub
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local tex = MijHUD.GetTexture("HUD_BootLf")
		local font = MijHUD.GetFont("HUD_Txt26")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		for i = 1, clamp(mval, 0, #dats) do
			scr.DrawText(x+w+4, y+4+26*(i-1), dats[i], 0, 0, col_m, font)
		end
	end
	boot_lf:SetViewport(50,-40,36,180)
	
	local boot_rt = MijHUD.NewComponent(true)
	MOD.StartupDispRt = boot_rt
	function boot_rt:OnRender(x,y,w,h)
		local dats = MOD.BootSequence.Rt
		local mval = MijHUD.IsStarting - dats.Sub
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local tex = MijHUD.GetTexture("HUD_BootRt")
		local font = MijHUD.GetFont("HUD_Txt26")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		for i = 1, clamp(mval, 0, #dats) do
			scr.DrawText(x-4, y+4+26*(i-1), dats[i], 2, 0, col_m, font)
		end
	end
	boot_rt:SetViewport(-50,-160,36,210)
	
	local boot_mx = MijHUD.NewComponent(true)
	MOD.StartupDispMx = boot_mx
	function boot_mx:OnRender(x,y,w,h)
		local dats = MOD.BootSequence.Mx
		local mval = MijHUD.IsStarting - dats.Sub
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local tex = MijHUD.GetTexture("HUD_BootMx")
		local font = MijHUD.GetFont("HUD_Txt26")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		for i = 1, clamp(mval, 0, #dats) do
			local txti, stsi = dats[i][1], dats[i][2]
			scr.DrawText(x+w+4, y+4+26*(i-1), txti, 0, 0, col_m, font)
			if stsi and i < mval then
				local mlen = dats.LenX + 4
				scr.DrawText(x+w+mlen, y+4+26*(i-1), stsi, 0, 0, col_m, font)
			end
		end
	end
	boot_mx:SetViewport(30,20,36,416)
	
	local boot_an = MijHUD.NewComponent(true)
	local anim = boot_an:AnimFade("Mv", 0, 1, 0.05, 40.0)
	MOD.StartupDispAn = boot_an
	function boot_an:OnRender(x,y,w,h)
		local dats = MOD.BootSequence.An
		local mval = MijHUD.IsStarting - dats.Sub
		local dval = MijHUD.IsStarting - dats.Dis
		if mval < 0 or dval > -1 then return end
		local t_tl = MijHUD.GetTexture("HUD_TopLeft")
		local t_tr = MijHUD.GetTexture("HUD_TopRight")
		local t_bl = MijHUD.GetTexture("HUD_BotLeft")
		local t_br = MijHUD.GetTexture("HUD_BotRight")
		local col_b = MijHUD.GetColor("Pri_Back")
		
		local sx = Lerp(self.Anim_Mv.Value, An_InitSz, An_FinalSz)
		local sy = floor(sx * An_Scale)
		local mx = self.Anim_Mv.Value * An_DeltaX
		local my = self.Anim_Mv.Value * An_DeltaY
		scr.DrawTexRect(x-sx-mx, y-sy-my, sx, sy, t_tl, col_b)
		scr.DrawTexRect(x+mx, y-sy-my, sx, sy, t_tr, col_b)
		scr.DrawTexRect(x-sx-mx, y+my, sx, sy, t_bl, col_b)
		scr.DrawTexRect(x+mx, y+my, sx, sy, t_br, col_b)
	end
	function anim:OnFadeEnd()
		MijHUD.IsStarting = MijHUD.IsStarting + 1
		MOD.DoStartup(true)
	end
	boot_an:SetViewport(ScrW()/2, ScrH()/2, 0, 0)
	
	ins(cp_list, boot_lf)
	ins(cp_list, boot_rt)
	ins(cp_list, boot_mx)
	ins(cp_list, boot_an)
end

function MOD.ToggleHUD()
	if MijHUD.IsShown or MijHUD.IsStarting then
		MijHUD.IsStarting = false
		MijHUD.IsShown = false
	else
		MOD.BeginStartup()
	end
	return true
end

function MOD.BeginStartup()
	MOD.StartupDispAn.Anim_Mv:StopAnim(true)
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
	local noincrement = false
	if bootseq.Act[startval_n] then
		noincrement = bootseq.Act[startval_n]()
	end
	if not noincrement then
		MijHUD.IsStarting = startval_n
	end
	if startval_n == bootseq.Done then
		MijHUD.IsStarting = false
		MijHUD.IsShown = true
	end
end