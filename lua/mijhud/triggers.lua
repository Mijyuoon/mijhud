-- Trigger_* detector
local MOD = {
	LoadName = "Triggers",
	LastQuery = 0.0,
	--UseOffline = true,
}
MijHUD.LoadModule(MOD)

local function genBeams(mins, maxs)
	return {
		Vector(mins.x, mins.y, mins.z),
		Vector(mins.x, mins.y, maxs.z),

		Vector(mins.x, mins.y, mins.z),
		Vector(mins.x, maxs.y, mins.z),

		Vector(mins.x, mins.y, mins.z),
		Vector(maxs.x, mins.y, mins.z),

		Vector(maxs.x, maxs.y, maxs.z),
		Vector(maxs.x, maxs.y, mins.z),

		Vector(maxs.x, maxs.y, maxs.z),
		Vector(maxs.x, mins.y, maxs.z),

		Vector(maxs.x, maxs.y, maxs.z),
		Vector(mins.x, maxs.y, maxs.z),

		Vector(mins.x, mins.y, mins.z),
		Vector(maxs.x, maxs.y, maxs.z),
	}
end

function MOD.Initialize()
	MijHUD.LoadTextures("Utl", {
		Beam3D = "mijhud/beam",
	})

	net.Receive("MijHUD.Triggers", MOD.OnReceiveData)
	local packet = adv.NetStruct "#{pos:v ang:*Ang mins:v maxs:v kind:s parent:i16}"
	MOD.NetPacket = packet
	function packet.Readers.Ang()
		local f = net.ReadBool()
		return f and net.ReadAngle() or Angle()
	end
end

function MOD.OnReceiveData()
	local lst = MOD.NetPacket:ReadStruct()
	for _, x in ipairs(lst) do
		x.beams = genBeams(x.mins, x.maxs)
	end
	MOD.TriggerList = lst
end

function MOD.QueryData()
	net.Start("MijHUD.Triggers")
	net.SendToServer()
end

function MOD.Interval()
	if not MijHUD.Options("Trigger.AutoQuery") then return end
	local delay = MijHUD.Options("Trigger.QueryTimer")
	if RealTime() > MOD.LastQuery + delay then
		MOD.LastQuery = RealTime()
		MOD.QueryData()
	end
end

function MOD.Render3D()
	if not MOD.TriggerList then return end
	if not MijHUD.Options("Show.Triggers") then return end

	local trigs = MOD.TriggerList
	local my_pos = LocalPlayer():GetPos()
	local range = MijHUD.Options("Trigger.MaxRange")
	render.SetMaterial(MijHUD.GetTexture("Utl_Beam3D"))
	for iKey = #trigs, 1, -1 do
		local tr = trigs[iKey]
		local pos, ang = tr.pos, tr.ang
		local pt = Entity(tr.parent)
		if IsValid(pt) then
			pos = pt:LocalToWorld(pos)
			ang = pt:LocalToWorldAngles(ang)
			tr.had_parent = true
		elseif tr.parent > -1 then
			if tr.had_parent then
				table.remove(trigs, iKey)
			end
			continue
		end
		if my_pos:Distance(pos) > range then continue end

		local vecs = tr.beams
		local col = MijHUD.GetColor("Trig_"..tr.kind)
		for i = 1, #vecs, 2 do
			local p0, p1 = vecs[i]*1, vecs[i+1]*1
			p0:Rotate(ang); p1:Rotate(ang)
			p0, p1 = p0 + pos, p1 + pos
			render.DrawBeam(p0, p1, 2, 0, 1, col)
		end
	end
end
