--[[

Derp

]]
local function NewFaction( data )
	local vec = data:ReadVector()
	print(data:ReadFloat())
	print(data:ReadString())
	print(data:ReadVector())
	print("team.SetUp( " .. math.floor(data:ReadFloat()+0.5).. ", " .. data:ReadString() .. ", " .. "Color( " .. vec.x .. ", " .. vec.y .. ", " .. vec.z .. ", 255 ) )")
	team.SetUp( math.floor(data:ReadFloat()+0.5), data:ReadString(), Color( vec.x, vec.y, vec.z, 255 ) )
end
usermessage.Hook( "NewFaction", NewFaction )