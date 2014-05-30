-- Battery imitation
local MOD = {
	LoadName = "Battery",
	DefOpts = {
		CritLevel = 0.05,
		MaxCharge = 1000,
		ChargeRate = 2.4,
		DrainRate = 1.7,
	};
}
MijHUD.LoadModule(MOD)

local defs = MOD.DefOpts
MOD.Level = defs.MaxCharge
MOD.MaxLvl = defs.MaxCharge
MOD.CritLvl = defs.CritLevel

function MOD.Initialize()
	MijHUD.LoadTextures("HUD", {
		Battery	= "mijhud/battery.png",
	})
	MijHUD.CreateFont("HUD", {
		Name = "Txt36",
		Font = "OCR A Extended",
		Size = 36
	})
	
	timer.Create("MijHUD.Battery", 0.1, 0, MOD.DoBattery)
	
	local battery = MijHUD.NewComponent()
	battery:AnimBlink("Bt", 5.0)
	battery.UseOffline = true
	MOD.BatteryDisp = battery
	function battery:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Crit = scr.Poly(self.X, self.Y, {
			8, 8, 28, 8, 68, 48, 8, 48
		})
	end
	function battery:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_Battery")
		local font = MijHUD.GetFont("HUD_Txt36")
		local col_bs = self.IsCritical
			and "Crit_Back" or "Sec_Back"
		local col_b = MijHUD.GetColor(col_bs)
		local col_ms = self.IsCritical
			and "Crit_ColA" or "Sec_ColA"
		local col_m = MijHUD.GetColor(col_ms)
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		
		if self.IsCritical then
			if self.Anim_Bt.Value then
				scr.DrawPoly(self.Pg_Crit, col_m)
			end
			scr.DrawText(x+w/2, y, "BATTERY LOW", 1, 2, col_m, font)
		else
			local bt_bar = MijHUD.MapRange(self.Percent, 0, 1, 0, 310)
			scr.DrawRect(x+8, y+8, bt_bar, 40, col_m)
			scr.DrawText(x+w/2, y, "BATTERY RECHARGE", 1, 2, col_m, font)
		end
	end
	function battery:OnInterval()
		local bat = MijHUD.Battery
		if MijHUD.IsStarting then
			self.Visible = false
			self.Anim_Bt:StopAnim(true)
		elseif MijHUD.IsShown then
			self.Visible = (bat.Level < bat.CritLvl * bat.MaxLvl)
			self.IsCritical = true
			self.Anim_Bt:StartAnim()
		else
			self.Percent = bat.Level / bat.MaxLvl
			self.Visible = (bat.Level < bat.MaxLvl)
			self.IsCritical = false
			self.Anim_Bt:StopAnim(true)
		end
	end
	battery:SetViewport(ScrW()/2 - 170, -10, 340, 56)
	battery.IsCritical, battery.Percent = false, 0
	
	local utils_lf = MijHUD.Basic.UtilsDispLf
	function utils_lf:CustomViewport()
		self.Pg_Alert = scr.Poly(self.X, self.Y, {
			246, 84, 246, 12, 318, 12,
		})
	end
	function utils_lf:CustomDrawFunc(x,y,w,h)
		local font = MijHUD.GetFont("HUD_Txt30")
		local col_m = MijHUD.GetColor("Pri_ColA")
		
		local percent = MOD.Level / MOD.MaxLvl * 100
		local bt_txt = Format("BATR %03.2f%%", percent)
		local bt_bar = MijHUD.MapRange(percent, 0, 100, 0, 200)
		scr.DrawText(x+38, y+6, bt_txt, 0, 0, col_m, font)
		scr.DrawRect(x+40, y+38, bt_bar, 20, col_m)
		scr.DrawPoly(self.Pg_Alert, col_m)
		return false
	end
	utils_lf:SetViewport()
end

function MOD.DoBattery()
	if MijHUD.IsStarting then return end
	local acti = MijHUD.IsShown
	local incr = MijHUD.Options("Battery.ChargeRate") or defs.ChargeRate
	local decr = MijHUD.Options("Battery.DrainRate") or defs.DrainRate
	MOD.MaxLvl = MijHUD.Options("Battery.MaxCharge") or defs.MaxCharge
	MOD.CritLvl = MijHUD.Options("Battery.CritLevel") or defs.CritLevel
	if not acti and MOD.Level < MOD.MaxLvl then
		MOD.Level = math.Clamp(MOD.Level+incr, 0, MOD.MaxLvl)
	elseif acti and MOD.Level >= 0 then
		MOD.Level = math.Clamp(MOD.Level-decr, 0, MOD.MaxLvl)
		if MOD.Level <= 0 then
			MijHUD.IsShown = false
		end
	end
end
