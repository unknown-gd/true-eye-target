local _G = _G
local players = {}
do

    local table_remove = _G.table.remove

    local function removeFromList( entity )
        for i = #players, 1, -1 do
            if players[ i ][ 1 ] == entity then
                table_remove( players, i )
                break
            end
        end
    end

    -- ULib support ( I really don't like this )
    if _G.file.Exists( "ulib/shared/hook.lua", "LUA" ) then
        _G.include( "ulib/shared/hook.lua" )
    end

    --- Srlion's Hook Library ( https://github.com/Srlion/Hook-Library )
    ---@diagnostic disable-next-line: undefined-field
    local PRE_HOOK = _G.PRE_HOOK or -2
    local Vector = _G.Vector

    hook.Add( "OnEntityCreated", "True Eye Target", function( entity )
        if entity:IsPlayer() and not entity:IsBot() then
            removeFromList( entity )
            players[ #players + 1 ] = { entity, Vector( 0, 0, 0 ) }
        end

        ---@diagnostic disable-next-line: redundant-parameter
    end, PRE_HOOK )

    hook.Add( "EntityRemoved", "True Eye Target", function( entity )
        if entity:IsPlayer() then
            removeFromList( entity )
        end

        ---@diagnostic disable-next-line: redundant-parameter
    end, PRE_HOOK )

end

local VECTOR_SetUnpacked, VECTOR_Unpack
do
    local VECTOR = _G.FindMetaTable( "Vector" )
    VECTOR_SetUnpacked, VECTOR_Unpack = VECTOR.SetUnpacked, VECTOR.Unpack
end

local ENTITY_SetEyeTarget = _G.FindMetaTable( "Entity" ).SetEyeTarget
local PLAYER_GetAimVector = _G.FindMetaTable( "Player" ).GetAimVector
local util_TraceLine = _G.util.TraceLine

local trace_result = {}
local trace = {
    collisiongroup = _G.COLLISION_GROUP_PLAYER,
    mask = _G.MASK_PLAYERSOLID,
    output = trace_result
}

_G.timer.Create( "True Eye Target", 0.05, 0, function()
    for i = 1, #players, 1 do
        local data = players[ i ]

        local ply = data[ 1 ]
        if ply:Alive() then
            trace.start = ply:EyePos()
            trace.endpos = trace.start + PLAYER_GetAimVector( ply ) * 128
            trace.filter = ply

            util_TraceLine( trace )

            local eye_target = data[ 2 ]
            local from_x, from_y, from_z = VECTOR_Unpack( eye_target )
            local to_x, to_y, to_z = VECTOR_Unpack( trace_result.HitPos )

            VECTOR_SetUnpacked( eye_target,
                from_x + ( to_x - from_x ) * 0.25,
                from_y + ( to_y - from_y ) * 0.25,
                from_z + ( to_z - from_z ) * 0.25
            )

            ENTITY_SetEyeTarget( ply, eye_target )
        end
    end
end )
