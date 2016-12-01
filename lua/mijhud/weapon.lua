-- Weapon selector
local MOD = {
	LoadName = "Weapon",
	PickupMsgs = 7,
	PickupTime = 3.5,
	SelHideTime = 3.0,
	PickupInfo = {},
}
MijHUD.LoadModule(MOD)

function MOD.PickupInfo.Weap(itm)
	local txt_a = "WEAPON PICKED UP"
	local txt_b = MijHUD.GetItemName(itm.N, itm.P)
	return txt_a, txt_b:upper()
end

function MOD.PickupInfo.Ammo(itm)
	local txt_a = Format("AMMO PICKED UP *%d", itm.S)
	local txt_b = MijHUD.GetItemName(itm.N.."_ammo")
	return txt_a, txt_b:upper()
end

function MOD.PickupInfo.Misc(itm)
	local txt_a = "MISC ITEM PICKED UP"
	local txt_b = MijHUD.GetItemName(itm.N)
	return txt_a, txt_b:upper()
end

local function trimlength(str, len)
	if #str > len then
		return str:sub(1, len-1).."\226\128\166"
	end
	return str
end

local function wrapidx(tab, idx)
	return ((idx - 1) % #tab) + 1
end

local function fixkeys(tbl)
	local ret, num = {}, 1
	for _, val in pairs(tbl) do
		ret[num] = val
		num = num + 1
	end
	return ret
end

function MOD.Initialize()
	hook.Add("HUDWeaponPickedUp", "MijHUD.Pickup", MOD.PickupWeap)
	hook.Add("HUDAmmoPickedUp", "MijHUD.Pickup", MOD.PickupAmmo)
	hook.Add("HUDItemPickedUp", "MijHUD.Pickup", MOD.PickupItem)
	
	hook.Add("PlayerBindPress", "MijHUD.WepSel", MOD.BindPress)
	MijHUD.Core.List_HideHUD["CHudWeaponSelection"] = 1
	
	MijHUD.LoadTextures("HUD", {
		Pickup	= "mijhud/pickup.png",
		WeapSel	= "mijhud/weapsel.png",
	})
	MijHUD.CreateFont("HUD", {
		Name = "Txt24",
		Font = "OCR A Extended",
		Size = 24,
	})
	
	local pickups = MijHUD.NewComponent()
	MOD.PickupNotify = pickups
	function pickups:OnRender(x,y,w,h)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		local tex = MijHUD.GetTexture("HUD_Pickup")
		local font = MijHUD.GetFont("HUD_Txt24")
		local col_b = MijHUD.GetColor("Sec_Back")
		local col_m = MijHUD.GetColor("Sec_ColA")
		--for ik, item in ipairs(self.Items) do
		local itemtbl = self.Items
		for ik = 1, #itemtbl do
			local item = itemtbl[ik]
			local move = (h+10)*(ik-1)
			local anm = item.An_Fade.Value
			local text_a = trimlength(item.Ms1, 20)
			local text_b = trimlength(item.Ms2, 20)
			scr.DrawTexRect(x+anm, y+move, w, h, tex, col_b)
			scr.DrawText(x+56+anm, y+4+move, text_a, -1, -1, col_m, font)
			scr.DrawText(x+w-56+anm, y+h-6+move, text_b, 1, 1, col_m, font)
		end
	end
	function pickups:AddNotify(kind, data)
		local func = MOD.PickupInfo[kind]
		local ms1, ms2 = nil, nil
		if func then
			ms1, ms2 = func(data)
		else			
			ms1 = "??unknown?? PICKED UP"
			ms2 = "$"..(data.N or "")
		end
		local entry = { Ms1 = ms1, Ms2 = ms2 }
		local an_fade = MijHUD.AnimFade(360, 0, -20, 40.0)
		self:AddAnimHandler(an_fade)
		an_fade:StartAnim()
		local self_u = self.Items
		function an_fade:OnFadeEnd()
			if self.IsHiding then
				table.RemoveByValue(self_u, entry)
			else
				timer.Simple(MOD.PickupTime, function()
					self.Step = -self.Step
					self.IsHiding = true
					self:StartAnim()
				end)
			end
		end
		entry.An_Fade = an_fade
		table.insert(self.Items, 1, entry)
		local maxs = MOD.PickupMsgs
		local curs = #self.Items
		if curs > maxs then
			for i = maxs+1, curs do
				self.Items[i] = nil
			end
		end
	end
	function pickups:WeapNotify(weap)
		self:AddNotify("Weap", { N=weap:GetClass(), P=weap.PrintName })
	end
	function pickups:AmmoNotify(ammo, count)
		self:AddNotify("Ammo", { N=ammo, S=count })
	end
	function pickups:MiscNotify(item)
		self:AddNotify("Misc", { N=item })
	end
	local utl = MijHUD.Basic.UtilsDispRt
	local pos_y = utl.Y + utl.H + 16
	pickups:SetViewport(-10, pos_y, 350, 56)
	pickups.Items = {}
	
	local weapsel = MijHUD.NewComponent()
	MOD.WeapSelDisp = weapsel
	function weapsel:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_WeapSel")
		local fbig = MijHUD.GetFont("HUD_Txt30")
		local fsml = MijHUD.GetFont("HUD_Txt24")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor(self.CurWeapColor)
		local col_lf = MijHUD.GetColor(self.WeapLfColor)
		local col_rt = MijHUD.GetColor(self.WeapRtColor)
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		scr.DrawText(x+w/2, y+7, self.CurWeapName, 0, -1, col_m, fbig)
		scr.DrawText(x+34, y+87, self.WeapLfName, -1, -1, col_lf, fsml)
		scr.DrawText(x+46, y+67, self.WeapLfAmmo, -1, -1, col_lf, fsml)
		scr.DrawText(x+58, y+47, self.WeapLfClip, -1, -1, col_lf, fsml)
		scr.DrawText(x+w-34, y+87, self.WeapRtName, 1, -1, col_rt, fsml)
		scr.DrawText(x+w-46, y+67, self.WeapRtAmmo, 1, -1, col_rt, fsml)
		scr.DrawText(x+w-58, y+47, self.WeapRtClip, 1, -1, col_rt, fsml)
	end
	function weapsel:OnInterval()
		local weapon = LocalPlayer():GetActiveWeapon()
		if not (MijHUD.IsShown and IsValid(weapon)) then
			self.Visible = false
		end
		if self.Visible and RealTime() >= self.HideTime then
			self.Visible = false
		end
	end
	function weapsel:GetWeapName(wpn)
		if not IsValid(wpn) then
			return "<INVALID WPN>"
		end
		local class, pname = wpn:GetClass(), wpn.PrintName
		return MijHUD.GetItemName(class, pname):upper()
	end
	function weapsel:GetWeapAmmo(c1, a1, a2)
		local clip = "???"
		if c1 < 0 then
			clip = "---"
		elseif c1 < 1000 then
			clip = Format("%03d", c1)
		end
		local ammo1, ammo2 = "???", " ???"
		if a1 < 0 then
			ammo1 = "---"
		elseif a1 < 1000 then
			ammo1 = Format("%03d", a1)
		end
		if a2 < 0 then
			ammo2 = " ---"
		elseif a2 < 1000 then
			ammo2 = Format(" %03d", a2)
		end
		return clip, ammo1..ammo2
	end
	function weapsel:ScrollToIndex(index)
		local weaplst = self.WeapList
		self.CurWeapIndex = index
		local w_cur = weaplst[index]
		local c1, _, a1, _ = w_cur:GetProperAmmoData()
		self.CurWeapName = trimlength(self:GetWeapName(w_cur), 18)
		if (c1 < 0 and a1 == 0) or c1 == 0 then
			self.CurWeapColor = "Crit_ColA"
		elseif a1 == 0 then
			self.CurWeapColor = "Warn_ColA"
		else
			self.CurWeapColor = "Pri_ColA"
		end
		local w_prev = weaplst[wrapidx(weaplst, index-1)]
		self.WeapLfName = trimlength(self:GetWeapName(w_prev), 18)
		if IsValid(w_prev) then
			local c1, _, a1, a2 = w_prev:GetProperAmmoData()
			local clip, ammo = self:GetWeapAmmo(c1, a1, a2)
			self.WeapLfClip = "CLIP "..clip
			self.WeapLfAmmo = "AMMO "..ammo
			if (c1 < 0 and a1 == 0) or c1 == 0 then
				self.WeapLfColor = "Crit_ColA"
			elseif a1 == 0 then
				self.WeapLfColor = "Warn_ColA"
			else
				self.WeapLfColor = "Pri_ColA"
			end
		else
			self.WeapLfClip = "CLIP ---"
			self.WeapLfAmmo = "AMMO --- ---"
			self.WeapLfColor = "Pri_ColA"
		end
		local w_next = weaplst[wrapidx(weaplst, index+1)]
		self.WeapRtName = trimlength(self:GetWeapName(w_next), 18)
		if IsValid(w_next) then
			local c1, _, a1, a2 = w_next:GetProperAmmoData()
			local clip, ammo = self:GetWeapAmmo(c1, a1, a2)
			self.WeapRtClip = clip.." CLIP"
			self.WeapRtAmmo = ammo.." AMMO"
			if (c1 < 0 and a1 == 0) or c1 == 0 then
				self.WeapRtColor = "Crit_ColA"
			elseif a1 == 0 then
				self.WeapRtColor = "Warn_ColA"
			else
				self.WeapRtColor = "Pri_ColA"
			end
		else
			self.WeapRtClip = "--- CLIP"
			self.WeapRtAmmo = "--- --- AMMO"
			self.WeapRtColor = "Pri_ColA"
		end
	end
	function weapsel:ScrollNext(prev)
		self.HideTime = RealTime() + MOD.SelHideTime
		local index = self.CurWeapIndex + (prev and -1 or 1)
		self:ScrollToIndex(wrapidx(self.WeapList, index))
	end
	function weapsel:StartSelect()
		local ply = LocalPlayer()
		local weap = ply:GetActiveWeapon()
		self.WeapList = fixkeys(ply:GetWeapons())
		if not IsValid(weap) then return end
		local wepidx = table.KeyFromValue(self.WeapList, weap)
		self:ScrollToIndex(wepidx)
		self.HideTime = RealTime() + MOD.SelHideTime
		self.Visible = true
	end
	function weapsel:FinishSelect(sts)
		self.Visible = false
		if not sts then return end
		local wpn = self.WeapList[self.CurWeapIndex]
		RunConsoleCommand("use", wpn:GetClass())
	end
	weapsel:SetViewport(ScrW()/2-280, 10, 560, 116)
	weapsel.Visible, weapsel.HideTime = false, 0
end

function MOD.PickupWeap(weap)
	if not MijHUD.IsShown then return end
	MOD.PickupNotify:WeapNotify(weap)
	--[[
	if MOD.WeapSelDisp.Visible then
		MOD.WeapSelDisp:StartSelect()
	end
	--]]
	return false
end

function MOD.PickupAmmo(ammo, cnt)
	if not MijHUD.IsShown then return end
	MOD.PickupNotify:AmmoNotify(ammo, cnt)
	return false
end

function MOD.PickupItem(item)
	if not MijHUD.IsShown then return end
	MOD.PickupNotify:MiscNotify(item)
	return false
end

function MOD.BindPress(ply, key, st)
	if not (MijHUD.IsShown and st) then return end
	local weapsel = MOD.WeapSelDisp
	if weapsel.Visible then
		if key == "+attack2" then
			weapsel:FinishSelect(false)
			return true
		elseif key == "+attack" then
			weapsel:FinishSelect(true)
			return true
		elseif key == "invprev" then
			weapsel:ScrollNext(true)
			return true
		elseif key == "invnext" then
			weapsel:ScrollNext(false)
			return true
		end
	elseif (key == "invnext" or key == "invprev")
	and not LocalPlayer():KeyDown(IN_ATTACK) then
		weapsel:StartSelect()
		return true
	end
end
