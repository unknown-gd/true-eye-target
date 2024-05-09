local IsBot, Alive, GetAimVector
do
	local _obj_0 = FindMetaTable("Player")
	IsBot, Alive, GetAimVector = _obj_0.IsBot, _obj_0.Alive, _obj_0.GetAimVector
end
local SetEyeTarget = FindMetaTable("Entity").SetEyeTarget
local vector_origin = vector_origin
local Iterator = player.Iterator
local TraceLine = util.TraceLine
local LerpVector = LerpVector
local traceResult = { }
local trace = {
	collisiongroup = COLLISION_GROUP_PLAYER,
	mask = MASK_PLAYERSOLID,
	output = traceResult
}
return timer.Create("True Eye Target", 0.05, 0, function()
	for _, ply in Iterator() do
		if not IsBot(ply) and Alive(ply) then
			trace.start = ply:EyePos()
			trace.endpos = trace.start + GetAimVector(ply) * 128
			trace.filter = ply
			TraceLine(trace)
			local eyeTarget = LerpVector(0.25, ply.m_vLastEyeTarget or vector_origin, traceResult.HitPos)
			ply.m_vLastEyeTarget = eyeTarget
			SetEyeTarget(ply, eyeTarget)
		end
	end
end)
