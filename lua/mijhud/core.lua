-- Core module
local MOD = { 
	LoadIndex = 0,
	LoadName = "Core",
	UseOffline = true,
}
MijHUD.LoadModule(MOD)

function MijHUD.GetUniqueID()
	return util.CRC(tostring(SysTime()))
end

local options = {}
MOD.List_Options = options

MijHUD.Options = setmetatable({}, {
	__index = function(_, key)
		return options[key]
	end;
	__newindex = function(_, key, val)
		options[key] = val
	end;
	__call = function(_, key, val)
		local curtbl = options
		local keys = string.Split(key, ".")
		local lastkey = keys[#keys]
		for ikey = 1, #keys-1 do
			local tkey = keys[ikey]
			local newtbl = curtbl[tkey]
			if not newtbl then
				curtbl[tkey] = {}
				curtbl = curtbl[tkey]
			else
				curtbl = newtbl
			end
		end
		local value = curtbl[lastkey]
		if val ~= nil then
			curtbl[lastkey] = val
		end
		return value
	end;
})

local hud_hide = {
	CHudDamageIndicator = 2,
	CHudAmmo = 1, CHudSecondaryAmmo = 1, 
	CHudHealth = 1, CHudBattery = 1,
	CHudCrosshair = 1,
}
MOD.List_HideHUD = hud_hide

function MOD.DrawBaseHUD(val)
	if hud_hide[val] == 2 then return false end
	if not MijHUD.IsShown then return nil end
	if hud_hide[val] == 1 then return false end
end

local cp_meta = {}
cp_meta.__index = cp_meta
MOD.Meta_Component = cp_meta

function cp_meta:SetViewport(x,y,w,h)
	x, y = (x or self.X), (y or self.Y)
	w, h = (w or self.W), (h or self.H)
	if x < 1 then x = ScrW() + x - w end
	if y < 1 then y = ScrH() + y - h end
	self.X, self.Y, self.W, self.H = x,y,w,h
end

function cp_meta:CallRender()
	if not self.Visible then return end
	if not self.OnRender then return end
	--[[
	if self.ClipRect then
		scr.PushScissorRect(self.X, self.Y, self.W, self.H)
	end
	--]]
	self:OnRender(self.X, self.Y, self.W, self.H)
	--[[
	if self.ClipRect then
		scr.PopScissorRect()
	end
	--]]
end

function cp_meta:CallInterval()
	local cp_vis = self.Visible
	for _, anim in pairs(self.AnimList) do
		if cp_vis or anim.UseInvisible then
			anim:CallInterval()
		end
	end
	if not self.OnInterval then return end
	self:OnInterval()
end

function cp_meta:AddAnimHandler(anim)
	if not anim.CallInterval then return end
	local uniq_id = MijHUD.GetUniqueID()
	self.AnimList[uniq_id] = anim
	return uniq_id
end

local __weak = { __mode = "v" }
local function weaktbl()
	return setmetatable({}, __weak)
end

local cp_list = {}
MOD.Components = cp_list

function MijHUD.NewComponent(idx)
	local tab = setmetatable({
		Base = table.Copy(cp_meta),
		AnimList = weaktbl(),
		Visible = true,
		ClipRect = false,
	}, cp_meta)
	tab:SetViewport(0,0,0,0)
	if not idx then
		tab.Index = #cp_list+1
		cp_list[tab.Index] = tab
	elseif idx ~= true then
		tab.Index = idx
		table.insert(cp_list, idx, tab)
	end
	return tab
end

local ab_meta = {}
ab_meta.__index = ab_meta
MOD.Meta_AnimBlink = ab_meta

function ab_meta:CallInterval()
	if not self.Enable then return end
	local time = RealTime()
	if time >= self.NextTick then
		self.NextTick = time + self.Rate
		self.Value = not self.Value
		if self.OnToggle then
			self:OnToggle()
		end
	end
end

function ab_meta:StartAnim()
	self.Enable = true
	if self.IsReset then
		self.NextTick = RealTime() + self.Rate
		self.IsReset = false
		self.Value = false
	end
end

function ab_meta:StopAnim(rst)
	self.IsReset = rst and true or false
	self.Enable = false
end

function MijHUD.AnimBlink(rate)
	local tab = setmetatable({
		Base = table.Copy(ab_meta),
		Enable = false,
		IsReset = false,
		NextTick = 0,
		Rate = 1/rate,
	}, ab_meta)
	tab.Value = false
	return tab
end

function cp_meta:AnimBlink(obj, rate)
	local anim = MijHUD.AnimBlink(rate)
	self["Anim_"..obj], self.AnimList[obj] = anim, anim
	return anim
end

local af_meta = {}
af_meta.__index = af_meta
MOD.Meta_AnimFade = af_meta

function af_meta:CallInterval()
	if not self.Enable then return end
	local time = RealTime()
	if time >= self.NextTick then
		self.NextTick = time + self.Rate
		local min, max = self.MinVal, self.MaxVal
		self.Value = math.Clamp(self.Value + self.Step, min, max)
		if self.Value >= max or self.Value <= min then
			self.Enable, self.IsReset = false, true
			if self.OnFadeEnd then
				self:OnFadeEnd()
			end
		end
	end
end

function af_meta:StartAnim()
	self.Enable = true
	if self.IsReset then
		self.Value = (self.Step < 0) 
			and self.MaxVal or self.MinVal
		self.NextTick = RealTime() + self.Rate
		self.IsReset = false
		if self.OnReset then
			self:OnReset()
		end
	end
end

function af_meta:StopAnim(rst)
	self.IsReset = rst and true or false
	self.Enable = false
end

function MijHUD.AnimFade(min, max, step, rate)
	if min > max then
		min, max = max, min
	end
	local tab = setmetatable({
		Base = table.Copy(af_meta),
		Enable = false,
		IsReset = false,
		NextTick = 0,
		Rate = 1/rate,
		MinVal = min,
		MaxVal = max,
		Step = step,
	}, af_meta)
	tab.Value = (step < 0) and max or min
	return tab
end

function cp_meta:AnimFade(obj, min, max, step, rate)
	local anim = MijHUD.AnimFade(min, max, step, rate)
	self["Anim_"..obj], self.AnimList[obj] = anim, anim
	return anim
end

function MOD.RenderHUD()
	local show = MijHUD.IsShown
	--for _, cps in ipairs(cp_list) do
	for ikey = 1, #cp_list do
		local cps = cp_list[ikey]
		if show or cps.UseOffline then
			cps:CallRender()
		end
	end
end

function MOD.Interval()
	local show = MijHUD.IsShown
	--for _, cps in ipairs(cp_list) do
	for ikey = 1, #cp_list do
		local cps = cp_list[ikey]
		if show or cps.UseOffline then
			cps:CallInterval()
		end
	end
end

local tx_list = {}
MOD.UserTextures = tx_list

function MijHUD.LoadTextures(pref, tab)
	if not tab then
		pref, tab = nil, pref
	end
	for tex, path in pairs(tab) do
		if pref then tex = pref.."_"..tex end
		tx_list[tex] = Material(path, "smooth")
	end
end

local errtex = Material("__error")
function MijHUD.GetTexture(name)
	return (tx_list[name] or errtex)
end

local fn_list = {}
MOD.UserFonts = fn_list

function MijHUD.CreateFont(pref, tab)
	local name = tab.Name
	if name and pref then
		name = pref.."_"..name
	end
	local is_bold = tab.Bold and 700 or 400
	scr.CreateFont(name, tab.Font, tab.Size, is_bold)
	fn_list[name] = name
end

local errfnt = scr.CreateFont("HUD_Error", "Arial", 24)
function MijHUD.GetFont(name)
	return (fn_list[name] or errfnt)
end

local cr_list = {}
MOD.UserColors = cr_list

function MijHUD.ColorScheme(pref, tab)
	if not tab then
		pref, tab = nil, pref
	end
	for key, val in pairs(tab) do
		if key and pref then
			key = pref.."_"..key
		end
		cr_list[key] = val
	end
end

local errcol = Color(255, 255, 255)
function MijHUD.GetColor(name)
	return (cr_list[name] or errcol)
end

function MijHUD.MapRange(val, a1, a2, b1, b2, flr)
	local tmp = math.Clamp(math.Remap(val, a1, a2, b1, b2), b1, b2)
	if flr then tmp = math.floor(tmp) end
	return tmp
end

local function patch_camera()
	local gmod_camera = weapons.GetStored("gmod_camera")
	if gmod_camera.MijHUD_Patch then return end
	local old_hud_should_draw = gmod_camera.HUDShouldDraw
	function gmod_camera:HUDShouldDraw(item)
		if item == "CHudGMod" then return true end
		return old_hud_should_draw(self, item)
	end
	gmod_camera.MijHUD_Patch = true
end

if MijHUD_Loaded then
	patch_camera()
else
	local hid = MijHUD.GetUniqueID()
	hook.Add("InitPostEntity", hid, function()
		patch_camera()
		print("[!] Patching gmod_camera...")
		hook.Remove("InitPostEntity", hid)
	end)
end
