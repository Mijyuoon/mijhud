-- Basic elements
local MOD = {
	LoadIndex = 1,
	LoadName = "Basic",
}
MijHUD.LoadModule(MOD)

function MijHUD.GetProperAmmoData(wep)
	local add = false
	if wep.CustomAmmoDisplay then
		add = wep:CustomAmmoDisplay()
	end
	if add and add.Draw then
		local c1 = add.PrimaryClip
		local c2 = add.SecondaryClip
		local a1 = add.PrimaryAmmo
		local a2 = add.SecondaryAmmo
		return c1, c2, a1, a2
	elseif add and not add.Draw then
		return -1, -1, -1, -1
	elseif not add then
		local ply = LocalPlayer()
		local c1, c2 = wep:Clip1(), wep:Clip2()
		local ammo1 = wep:GetPrimaryAmmoType()
		local ammo2 = wep:GetSecondaryAmmoType()
		local a1 = (ammo1 > -1) and ply:GetAmmoCount(ammo1)
		local a2 = (ammo2 > -1) and ply:GetAmmoCount(ammo2)
		return c1, c2, (a1 or -1), (a2 or -1)
	end
end

function MOD.Initialize()
	local ScW, ScH = ScrW()/2, ScrH()/2
	MijHUD.LoadTextures("HUD", {
		TopLeft		= "mijhud/hud_tl.png",
		TopRight	= "mijhud/hud_tr.png",
		BotLeft		= "mijhud/hud_bl.png",
		BotRight	= "mijhud/hud_br.png",
		MsgSmall	= "mijhud/msg_sm.png",
	})
	MijHUD.CreateFont("HUD", {
		Name = "Txt30",
		Font = "OCR A Extended",
		Size = 30,
	})
	MijHUD.CreateFont("HUD", {
		Name = "Txt54",
		Font = "OCR A Extended",
		Size = 54,
		Bold = true,
	})
	
	local health = MijHUD.NewComponent()
	health:AnimBlink("Wh", 5.0):StartAnim()
	MOD.HealthDisp = health
	function health:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Alert = scr.Poly(self.X, self.Y, {
			246, 142, 246, 70, 318, 142,
		})
		self.Pg_Left = scr.Poly(self.X, self.Y, {
			9, 20, 33, 44, 33, 140, 9, 116,
		})
	end
	function health:OnInterval()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		self.Health = math.Clamp(ply:Health(), 0, 10000)
		self.Armor = math.Clamp(ply:Armor(), 0, 10000)
		self.LowHlth = MijHUD.Options("Basic.LowHealth") or 0
	end
	function health:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_BotLeft")
		local font = MijHUD.GetFont("HUD_Txt30")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		local col_s = MijHUD.GetColor("Pri_ColB")
		local col_w = MijHUD.GetColor("Crit_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		
		local hp_txt = "HEALTH ????"
		local hp_bar = MijHUD.MapRange(self.Health, 0, self.MaxHealth, 0, 200, true)
		if self.Health < 10000 then
			hp_txt = Format("HEALTH %04d", self.Health)
		end
		scr.DrawText(x+38, y+40, hp_txt, -1, -1, col_m, font)
		scr.DrawRect(x+40, y+70, hp_bar, 20, col_m)
		if self.Health > self.MaxHealth then
			local h2_bar = MijHUD.MapRange(self.Health, self.MaxHealth, 9999, 0, 192, true)
			scr.DrawRect(x+44, y+74, h2_bar, 12, col_s)
		end
		
		local ap_txt = "SHIELD ????"
		local ap_bar = MijHUD.MapRange(self.Armor, 0, self.MaxArmor, 0, 200, true)
		if self.Armor < 10000 then
			ap_txt = Format("SHIELD %04d", self.Armor)
		end
		scr.DrawText(x+38, y+90, ap_txt, -1, -1, col_m, font)
		scr.DrawRect(x+40, y+120, ap_bar, 20, col_m)
		if self.Armor > self.MaxArmor then
			local a2_bar = MijHUD.MapRange(self.Armor, self.MaxArmor, 9999, 0, 192, true)
			scr.DrawRect(x+44, y+124, a2_bar, 12, col_s)
		end
		
		if self.Health > self.LowHlth then
			scr.DrawPoly(self.Pg_Alert, col_m)
		elseif self.Anim_Wh.Value then
			scr.DrawPoly(self.Pg_Alert, col_w)
		end
		scr.DrawPoly(self.Pg_Left, col_m)
	end
	health:SetViewport(10, -10, 340, 154)
	health.MaxHealth, health.Health = 150, 0
	health.MaxArmor, health.Armor = 200, 0
	health.LowHlth = 0
	
	local weapon = MijHUD.NewComponent()
	weapon:AnimBlink("Wh", 5.0):StartAnim()
	function weapon:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Alert = scr.Poly(self.X, self.Y, {
			94, 142, 94, 70, 22, 142,
		})
		self.Pg_Left = scr.Poly(self.X, self.Y, {
			307, 44, 331, 20, 331, 116, 307, 140,
		})
	end
	function weapon:OnInterval()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		if not self.ClipSizes then
			local sizes = MijHUD.Options("Items.ClipSizes")
			self.ClipSizes = sizes or {}
		end
		local wpn = ply:GetActiveWeapon()
		self.HasWeapon = ply:Alive() and IsValid(wpn)
		if self.HasWeapon then
			local c1, _, a1, a2 = MijHUD.GetProperAmmoData(wpn)
			self.PriClip, self.AmmoPri, self.AmmoSec = c1, a1, a2
			self.MaxPriClip = self.ClipSizes[wpn:GetClass()] or 1
		end
		self.LowClip = MijHUD.Options("Basic.LowPrClip") or 0
	end
	function weapon:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_BotRight")
		local font = MijHUD.GetFont("HUD_Txt30")
		local fbig = MijHUD.GetFont("HUD_Txt54")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		local col_s = MijHUD.GetColor("Pri_ColB")
		local col_w = MijHUD.GetColor("Crit_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		
		local alert_mode = false
		if self.HasWeapon then
			local cp_txt = "PR.CLIP ???"
			local cp_bar = MijHUD.MapRange(self.PriClip, 0, self.MaxPriClip, 0, 200, true)
			if self.PriClip < 0 then
				cp_txt = "PR.CLIP ---"
			elseif self.PriClip < 1000 then
				cp_txt = Format("PR.CLIP %03d", self.PriClip)
			end
			scr.DrawText(x+w-38, y+40, cp_txt, 1, -1, col_m, font)
			scr.DrawRect(x+w-40-cp_bar, y+70, cp_bar, 20, col_m)
			if self.PriClip > self.MaxPriClip then
				local c2_bar = MijHUD.MapRange(self.PriClip, self.MaxPriClip, 999, 0, 192, true)
				scr.DrawRect(x+w-44-c2_bar, y+74, c2_bar, 12, col_s)
			end
			
			local ap_txt, sp_txt = " ???", " ???"
			if self.AmmoPri < 0 then
				ap_txt = " ---"
			elseif self.AmmoPri < 1000 then
				ap_txt = Format(" %03d", self.AmmoPri)
			end
			if self.AmmoSec < 0 then
				sp_txt = " ---"
			elseif self.AmmoSec < 1000 then
				sp_txt = Format(" %03d", self.AmmoSec)
			end
			local at_txt = "P/S"..ap_txt..sp_txt
			scr.DrawText(x+w-38, y+90, at_txt, 1, -1, col_m, font)
			
			local low_clip = self.LowClip * self.MaxPriClip
			alert_mode = self.PriClip <= low_clip and self.PriClip >= 0
		else
			scr.DrawText(x+204, y+94, "ERROR", 0, 0, col_m, fbig)
		end
		
		if not alert_mode then
			scr.DrawPoly(self.Pg_Alert, col_m)
		elseif self.Anim_Wh.Value then
			scr.DrawPoly(self.Pg_Alert, col_w)
		end
		scr.DrawPoly(self.Pg_Left, col_m)
	end
	weapon:SetViewport(-10, -10, 340, 154)
	weapon.PriClip, weapon.MaxPriClip = 0, 1
	weapon.AmmoPri, weapon.AmmoSec = 0, 0
	weapon.LowClip, weapon.HasWeapon = 0, true
	
	local utils_lf = MijHUD.NewComponent()
	MOD.UtilsDispLf = utils_lf
	function utils_lf:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Left = scr.Poly(self.X, self.Y, {
			33, 14, 9, 38, 9, 134, 33, 110,
		})
		
		if self.CustomViewport then
			self:CustomViewport()
		end
	end
	function utils_lf:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_TopLeft")
		local font = MijHUD.GetFont("HUD_Txt30")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		
		if self.CustomDrawFunc then
			local ret = self:CustomDrawFunc(x,y,w,h)
			if ret then return end
		end
		
		local date = os.date("%d %b %Y"):upper()
		local time = os.date("%I:%M:%S %p"):upper()
		scr.DrawText(x+38, y+58, time, -1, -1, col_m, font)
		scr.DrawText(x+38, y+82, date, -1, -1, col_m, font)
		scr.DrawPoly(self.Pg_Left, col_m)
	end
	utils_lf:SetViewport(10, 10, 340, 154)
	
	local utils_rt = MijHUD.NewComponent()
	MOD.UtilsDispRt = utils_rt
	function utils_rt:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Left = scr.Poly(self.X, self.Y, {
			331, 38, 307, 14, 307, 110, 331, 134,
		})
		
		if self.CustomViewport then
			self:CustomViewport()
		end
	end
	function utils_rt:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_TopRight")
		local font = MijHUD.GetFont("HUD_Txt30")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Pri_ColA")
		scr.DrawTexRect(x,y,w,h,tex,col_b)
		
		if self.CustomDrawFunc then
			local ret = self:CustomDrawFunc(x,y,w,h)
			if ret then return end
		end
		
		scr.DrawPoly(self.Pg_Left, col_m)
	end
	utils_rt:SetViewport(-10, 10, 340, 154)
	
	deadmsg = MijHUD.NewComponent()
	deadmsg:AnimBlink("Ln", 4.0):StartAnim()
	MOD.DeathMsg = deadmsg
	function deadmsg:OnInterval()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		self.Visible = not ply:Alive()
	end
	function deadmsg:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_MsgSmall")
		local font = MijHUD.GetFont("HUD_Txt54")
		local col_b = MijHUD.GetColor("Crit_Back")
		local col_m = MijHUD.GetColor("Crit_ColA")
		scr.DrawTexRect(x-w/2, y-h/2, w, h, tex, col_b)
		local line, hpos, wr = w/2-10, 30, 6
		scr.DrawLine(x-line, y-hpos, x+line, y-hpos, col_m, wr)
		scr.DrawLine(x-line, y+hpos, x+line, y+hpos, col_m, wr)
		if self.Anim_Ln.Value then
			scr.DrawText(x, y, "USER DEAD", 0, 0, col_m, font)
		end
	end
	deadmsg:SetViewport(ScW, ScH, 326, 178)
	deadmsg.Visible = false
	
	crosshair = MijHUD.NewComponent(1)
	MOD.CrossHair = crosshair
	function crosshair:OnRender(x,y,w,h)
		local col = MijHUD.GetColor("Sec_ColA")
		scr.DrawLine(x-w, y, x+w, y, col, 2)
		scr.DrawLine(x, y-h, x, y+h, col, 2)
	end
	crosshair:SetViewport(ScW, ScH, 12, 8)
end
