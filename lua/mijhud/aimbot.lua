local MOD = {
	LoadName = "Aimbot",

	LockedEntity = false,
	MaxLockDist  = 7500,
	MaxLockAngle = 5.0,

	ToggleKey = KEY_I,
}
MijHUD.LoadModule(MOD)

function MOD.Initialize()
	if not MijHUD.Options.Aimbot then
		MijHUD.Options.Aimbot = {
			InterpRate = 20,
			AutoRelock = false,
		}
	end

	local lockhud = MijHUD.NewComponent(1)
	MOD.LockIndicator = lockhud
	function lockhud:OnRender(x,y,w,h)
		local col = MijHUD.GetColor("Sec_ColA")
		for i = 1, 3 do
			local ofx, dh = w+(i-1)*5, math.floor(h*(i/3))
			--local ofy, dw = h+(i-1)*5, math.floor(w*(i/3))
			scr.DrawLine(x-ofx, y-dh, x-ofx, y+dh, col, 2)
			scr.DrawLine(x+ofx, y-dh, x+ofx, y+dh, col, 2)
			--scr.DrawLine(x-dw, y-ofy, x+dw, y-ofy, col, 2)
		end
	end
	function lockhud:OnInterval()
		self.Visible = IsValid(MOD.LockedEntity)
	end	
	lockhud:SetViewport(ScrW()/2, ScrH()/2, 16, 12)
	lockhud.Visible = false
end

function MOD.FindTarget()
	local aimpos = ply:GetShootPos()
	local aimvec = ply:GetAimVector()

	local entlist = ents.FindInCone(aimpos, aimvec,
		MOD.MaxLockDist, math.rad(MOD.MaxLockAngle))

	table.sort(entlist,
	function(e1, e2)
		local ev1 = (e1:GetPos() - aimpos):GetNormal()
		local ev2 = (e2:GetPos() - aimpos):GetNormal()
		return ev1:Dot(aimvec) > ev2:Dot(aimvec)
	end)

	local selent = false
	for _, ent in ipairs(entlist) do
		if (ent:IsPlayer() or ent:IsNPC())
		and (ent ~= ply) then
			selent = ent
			break
		end
	end

	return selent
end

function MOD.Interval()
	local ply = LocalPlayer()

	if MijHUD.IsKeyPressed(MOD.ToggleKey) then
		if not IsValid(MOD.LockedEntity) then
			MOD.LockedEntity = MOD.FindTarget()
		else
			MOD.LockedEntity = false
		end
	elseif IsValid(MOD.LockedEntity) then
		local rate = MijHUD.Options("Aimbot.InterpRate")/100

		local ent = MOD.LockedEntity
		local aimtgt = ent:LocalToWorld(ent:OBBCenter())
		local aimang = (aimtgt - ply:GetShootPos()):Angle()
		local pvang = LerpAngle(rate, ply:EyeAngles(), aimang)
		ply:SetEyeAngles(pvang)
	elseif MOD.LockedEntity
	and MijHUD.Options("Aimbot.AutoRelock") then
		MOD.LockedEntity = MOD.FindTarget()
	end
end
