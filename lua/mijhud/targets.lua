-- Target detector
local MOD = {
	LoadName = "Targets",
}
MijHUD.LoadModule(MOD)

local sin, cos = math.sin, math.cos
local rad, pi = math.rad, math.pi

function MOD.Initialize()
	MijHUD.LoadTextures("HUD", {
		Radar = "mijhud/radar.png",
	})
	
	timer.Create("MijHUD.Targets", 0.1, 0, MOD.UpdateTargets)
	
	local vradar = MijHUD.NewComponent()
	MOD.RadarDisp = vradar
	function vradar:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Stencil = scr.Poly(self.X, self.Y, {
			--[[
			5, 240, 5, 44, 44, 5,
			240, 5, 240, 201, 201, 240,
			--]]
			6, 240, 6, 45, 45, 6,
			240, 6, 240, 202, 202, 240,
		})
	end
	function vradar:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_Radar")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Sec_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilReferenceValue(10)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.OverrideColorWriteEnable(true, false)
		scr.DrawPoly(self.Pg_Stencil, color_white)
		render.OverrideColorWriteEnable(false)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		self:DispTargets(self.NpcTargets, self.NpcDisp, x, y, w, h)
		self:DispTargets(self.PlyTargets, self.PlyDisp, x, y, w, h)
		render.SetStencilEnable(false)
	end
	function vradar:IsValidTgt(vtgt)
		if not IsValid(vtgt) then 
			return false
		elseif vtgt:IsPlayer() then
			return (vtgt ~= LocalPlayer())
		end
		return true
	end
	function vradar:DispTargets(targets, func, ...)
		if not targets then return end
		local ppos = LocalPlayer():GetPos()
		local pyaw = LocalPlayer():EyeAngles().y
		local range = self.MaxRange or 1000
		for ikey = 1, #targets do
			local vtgt = targets[ikey]
			if not self:IsValidTgt(vtgt) then return end
			local cpos = (vtgt:GetPos()-ppos)
			local ang = rad(pyaw-cpos:Angle().y)
			local dist = cpos:Length2D()/range
			if dist > 1.6 then continue end
			local offx = sin(ang) * dist
			local offy = -cos(ang) * dist
			func(self, vtgt, offx, offy, ...)
		end
	end
	function vradar:NpcDisp(targ, offx, offy, x, y, w, h)
		local col_a = MijHUD.GetColor("Radar_B")
		local key = self.NpcIdents[targ:GetClass()]
		if key == "??" then return end
		local col_b = MijHUD.GetColor("Radar_"..(key or "N"))
		offx, offy = x+(1+offx)*w/2, y+(1+offy)*h/2
		scr.DrawRect(offx-4, offy-4, 8, 8, col_a)
		scr.DrawRect(offx-2, offy-2, 4, 4, col_b)
	end
	function vradar:PlyDisp(_, offx, offy, x, y, w, h)
		local col_a = MijHUD.GetColor("Radar_B")
		offx, offy = x+(1+offx)*w/2, y+(1+offy)*h/2
		scr.DrawRect(offx-3, offy-3, 6, 6, col_a)
	end
	local utl = MijHUD.Basic.UtilsDispLf
	local pos_y = utl.Y + utl.H - 32
	vradar:SetViewport(utl.X, pos_y, 246, 246)
end

function MOD.UpdateTargets()
	if not MijHUD.IsShown then return end
	local vradar = MOD.RadarDisp
	local range = MijHUD.Options("Radar.MaxRange")
	local idents = MijHUD.Options("Radar.NpcIdents")
	vradar.NpcIdents = idents or {}
	vradar.MaxRange = range or 1000
	if MijHUD.Options("Radar.ShowNpcs") then
		local npcs = ents.FindByClass("npc_*")
		vradar.NpcTargets = npcs
	else
		vradar.NpcTargets = false
	end
	if MijHUD.Options("Radar.SnowPlayers") then
		local plys = player.GetAll()
		vradar.PlyTargets = plys
	else
		vradar.PlyTargets = false
	end
end