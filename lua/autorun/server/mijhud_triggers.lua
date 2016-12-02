local trig_types = adv.TblSet {
	"teleport", "once", "multiple", "push", "hurt", "look"
}

local function getTriggers()
	local trigs = {}
	for _, ent in ipairs(ents.FindByClass("trigger_*")) do
		local class = ent:GetClass():gsub("trigger_", "")
		if not trig_types[class] then continue end

		local parent = ent:GetParent()
		local pos = ent:GetPos()
		local ang = ent:GetAngles()

		local parentId = -1
		if IsValid(parent) then
			pos = parent:WorldToLocal(pos)
			ang = parent:WorldToLocalAngles(ang)
			parentId = parent:EntIndex()
		end

		trigs[#trigs+1] = {
			pos = pos,
			ang = ang,
			mins = ent:OBBMins(),
			maxs = ent:OBBMaxs(),
			kind = class:sub(1,4):upper(),
			parent = parentId,
		}
	end
	return trigs
end

local function zero(x)
	return math.abs(x.p) < 1e-6
		and math.abs(x.y) < 1e-6
		and math.abs(x.r) < 1e-6
end

util.AddNetworkString("MijHUD.Triggers")
local packet = adv.NetStruct "#{pos:v ang:*Ang mins:v maxs:v kind:s parent:i16}"
function packet.Writers.Ang(val)
	local f = zero(val)
	net.WriteBool(f)
	if f then
		net.WriteAngle(val)
	end
end

net.Receive("MijHUD.Triggers",
function()
	local trigs = getTriggers()
	net.Start("MijHUD.Triggers")
		packet:WriteStruct(trigs)
	net.Broadcast()
end)
