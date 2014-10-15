-- Target detector
local MOD = {
	LoadName = "Targets",
}
MijHUD.LoadModule(MOD)

local sin, cos = math.sin, math.cos
local rad, pi = math.rad, math.pi

local function IsValidTgt(vtgt)
	if not IsValid(vtgt) then 
		return false
	elseif vtgt:IsPlayer() then
		return (vtgt ~= LocalPlayer())
	end
	return true
end

local function DistanceToTarg(targ)
	local ppos = LocalPlayer():GetPos()
	return ppos:Distance(targ:GetPos())
end

local function FmtClass(cname)
	if cname == "class C_BaseEntity" then
		return "FUNC-BUTTON" -- Very ugly hack
	end
	return cname:upper():gsub("_", "-")
end

function MOD.Initialize()
	MijHUD.LoadTextures("HUD", {
		Radar = "mijhud/radar.png",
	})
	MijHUD.CreateFont("HUD", {
		Name = "Txt18",
		Font = "OCR A Extended",
		Size = 18,
	})
	
	timer.Create("MijHUD.Targets", 0.2, 0, MOD.UpdateTargets)
	
	local hradar = MijHUD.NewComponent()
	MOD.HudRadarDisp = hradar
	function hradar:SetViewport(x,y,w,h)
		self.Base.SetViewport(self, x, y, w, h)
		self.Pg_Stencil = scr.Poly(self.X, self.Y, {
			--[[
			5, 240, 5, 44, 44, 5,
			240, 5, 240, 201, 201, 240,
			--]]
			6, 240; 6, 45; 45, 6;
			240, 6; 240, 202; 202, 240;
		})
	end
	function hradar:OnRender(x,y,w,h)
		local tex = MijHUD.GetTexture("HUD_Radar")
		local col_b = MijHUD.GetColor("Pri_Back")
		local col_m = MijHUD.GetColor("Sec_ColA")
		scr.DrawTexRect(x, y, w, h, tex, col_b)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilTestMask(255)
		render.SetStencilWriteMask(255)
		render.SetStencilReferenceValue(10)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.OverrideColorWriteEnable(true, false)
		scr.DrawPoly(self.Pg_Stencil, color_white)
		render.OverrideColorWriteEnable(false)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		self:DispTargets(self.NpcTargets, self.NpcDisp)
		self:DispTargets(self.PlyTargets, self.PlyDisp)
		render.SetStencilEnable(false)
	end
	function hradar:DispTargets(targets, func)
		if not targets then return end
		local ppos = LocalPlayer():GetPos()
		local pyaw = LocalPlayer():EyeAngles().y
		local range = self.MaxRange or 1000
		for ikey = 1, #targets do
			local vtgt = targets[ikey]
			if not IsValidTgt(vtgt) then continue end
			local cpos = (vtgt:GetPos()-ppos)
			local ang = rad(pyaw-cpos:Angle().y)
			local dist = cpos:Length2D()/range
			if dist > 1.6 then continue end
			local offx = sin(ang) * dist
			local offy = -cos(ang) * dist
			func(self, vtgt, offx, offy)
		end
	end
	function hradar:NpcDisp(targ, offx, offy)
		local x, y, w, h = self.X, self.Y, self.W, self.H
		local col_a = MijHUD.GetColor("Radar_B")
		local key = self.NpcIdents[targ:GetClass()]
		if key == "??" then return end
		local col_b = MijHUD.GetColor("Radar_"..(key or "N"))
		offx, offy = x+(1+offx)*w/2, y+(1+offy)*h/2
		scr.DrawRect(offx-4, offy-4, 8, 8, col_a)
		scr.DrawRect(offx-2, offy-2, 4, 4, col_b)
	end
	function hradar:PlyDisp(_, offx, offy)
		local x, y, w, h = self.X, self.Y, self.W, self.H
		local col_a = MijHUD.GetColor("Radar_B")
		offx, offy = x+(1+offx)*w/2, y+(1+offy)*h/2
		scr.DrawRect(offx-3, offy-3, 6, 6, col_a)
	end
	function hradar:OnInterval()
		self.Visible = MijHUD.Options("Show.HudRadar")
	end
	local utl = MijHUD.Basic.UtilsDispLf
	local pos_y = utl.Y + utl.H - 32
	hradar:SetViewport(utl.X, pos_y, 246, 246)
	
	--local vec10z = Vector(0, 0, 10)
	local ptri = { 0, 0; -12, -16; 12, -16; }
	local ntri = { 0, -4; 8, -14; -8, -14; }
	local vradar = MijHUD.NewComponent(1)
	MOD.VisRadarDisp = vradar
	function vradar:OnRender(x,y,w,h)
		self:DispTargets(self.NpcTargets, self.NpcDisp, true)
		self:DispTargets(self.PlyTargets, self.PlyDisp, true)
		self:DispTargets(self.GateTargets, self.GateDisp)
	end
	function vradar:DispTargets(targets, func, offs)
		if not targets then return end
		for ikey = 1, #targets do
			local vtgt, cpos = targets[ikey], nil
			if not IsValidTgt(vtgt) then continue end
			local dist = DistanceToTarg(vtgt)
			if dist > self.MaxRange then continue end
			--[[---- Too slow --------------------------------
			local head = vtgt:LookupBone("ValveBiped.Bip01_Head1")
			if head then
				local phead = vtgt:GetBonePosition(head)
				cpos = (phead + vec10z):ToScreen()
			else
				local obbz = Vector(0, 0, vtgt:OBBMaxs().z)
				cpos = vtgt:LocalToWorld(obbz):ToScreen()
			end
			------------------------------------------------]]
			if offs then
				local obbz = vtgt:OBBMaxs() * vector_up
				cpos = vtgt:LocalToWorld(obbz):ToScreen()
			else
				cpos = vtgt:GetPos():ToScreen()
			end
			func(self, vtgt, cpos.x, cpos.y, dist)
		end
	end
	function vradar:PlyDisp(targ, offx, offy, dist)
		local col_a = MijHUD.GetColor("Radar_B")
		local font = MijHUD.GetFont("HUD_Txt18")
		local dist = tostring(math.Round(dist))
		scr.DrawPoly(scr.Poly(offx, offy, ptri), col_a)
		scr.DrawText(offx, offy-18, dist, 1, 2, col_a, font)
	end
	function vradar:NpcDisp(targ, offx, offy, dist)
		local col_a = MijHUD.GetColor("Radar_B")
		local font = MijHUD.GetFont("HUD_Txt18")
		local key = self.NpcIdents[targ:GetClass()]
		if key == "??" then return end
		local col_b = MijHUD.GetColor("Radar_"..(key or "N"))
		local dist = tostring(math.Round(dist))
		scr.DrawPoly(scr.Poly(offx, offy, ptri), col_a)
		scr.DrawPoly(scr.Poly(offx, offy, ntri), col_b)
		scr.DrawText(offx, offy-18, dist, 1, 2, col_a, font)
	end
	function vradar:GateDisp(targ, offx, offy, dist)
		local col_a = MijHUD.GetColor("Sec_ColA")
		local col_b = MijHUD.GetColor("Sec_ColB")
		local font = MijHUD.GetFont("HUD_Txt18")
		local dist = tostring(math.Round(dist))
		scr.DrawPoly(scr.Circle(offx, offy, 21, 21, 0, 6), col_a)
		scr.DrawPoly(scr.Circle(offx, offy, 18, 18, 0, 6), col_b)
		scr.DrawText(offx, offy-20, dist, 1, 2, col_a, font)
	end
	
	local entcls = MijHUD.NewComponent(2)
	function entcls:OnRender(x,y,w,h)
		local col_m = MijHUD.GetColor("Sec_ColA")
		local font = MijHUD.GetFont("HUD_Txt18")
		local trace = LocalPlayer():GetEyeTraceNoCursor()
		if not IsValid(trace.Entity) then return end
		local ecls = FmtClass(trace.Entity:GetClass())
		scr.DrawText(x, y, ecls, 1, 0, col_m, font)
	end
	function entcls:OnInterval()
		self.Visible = MijHUD.Options("Show.EntClass")
	end
	entcls:SetViewport(ScrW()/2, ScrH()/2 + 10, 0, 0)
end

local function get_targets(opts)
	local npcs, plys, gates
	if opts.VisShowNpcs or opts.HudShowNpcs then
		npcs = ents.FindByClass("npc_*")
	end
	if opts.VisShowPlys or opts.HudShowPlys then
		plys = player.GetAll()
	end
	if opts.VisShowGates or opts.HudShowGates then
		gates = ents.FindByClass("event_horizon")
	end
	return npcs, plys, gates
end

local ET = {}
function MOD.UpdateTargets()
	if not MijHUD.IsShown then return end
	local hradar = MOD.HudRadarDisp
	local vradar = MOD.VisRadarDisp
	local option = MijHUD.Options.Radar or {}
	local npcs, plys, gate = get_targets(option)
	
	hradar.NpcIdents = option.NpcIdents or ET
	hradar.MaxRange = option.HudMaxRange or 1000
	hradar.NpcTargets = option.HudShowNpcs and npcs
	hradar.PlyTargets = option.HudShowPlys and plys
	hradar.GateTargets = option.HudShowGates and gate
	
	vradar.NpcIdents = option.NpcIdents or ET
	vradar.MaxRange = option.VisMaxRange or 1000
	vradar.NpcTargets = option.VisShowNpcs and npcs
	vradar.PlyTargets = option.VisShowPlys and plys
	vradar.GateTargets = option.VisShowGates and gate
end