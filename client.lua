-------- CONFIGURABLE --------
local COMPONENT_HAIR = 2

local function get_tied_hair_style()
    local player_ped = PlayerPedId()
    if IsPedMale(player_ped) then
        -- Male Hair
        --  Bold 0
        --  Super short 1
        return {
            drawable = 1,
            texture = 0,
            palette = 0,
            color = GetPedHairColor(player_ped),
            highlight_color = GetPedHairHighlightColor(player_ped)
        }
    else
        -- Female Hair
        --  Bold 0
        --  Ponytail 4
        --  Low bun 11
        --  High bun 14
        --  Fancy ponytail 31
        return {
            drawable = 11,
            texture = 0,
            palette = 0,
            color = GetPedHairColor(player_ped),
            highlight_color = GetPedHairHighlightColor(player_ped)
        }
    end
end

local function set_hair_style(hair_style)
    local player_ped = PlayerPedId()
    if hair_style and hair_style.drawable and hair_style.texture and hair_style.palette and hair_style.color then
        SetPedComponentVariation(player_ped, COMPONENT_HAIR, hair_style.drawable, hair_style.texture, hair_style.palette)
        SetPedHairTint(player_ped, hair_style.color, hair_style.highlight_color)
    end
end

local tie_hair_anim_dict = 'clothingtie'
local tie_hair_anim = 'check_out_a'
local tie_hair_duration = 2700


-------- LOGIC --------

local active = false
local hair_is_tied = false
local hair_when_opened = nil
local hair_when_tied = nil

local function play_animation()
    RequestAnimDict(tie_hair_anim_dict)

    local timeout = 0 -- 900ms
    while not HasAnimDictLoaded(tie_hair_anim_dict) and timeout < 30 do
        Wait(30)
        timeout = timeout + 1
    end
    if HasAnimDictLoaded(tie_hair_anim_dict) then
        TaskPlayAnim(PlayerPedId(), tie_hair_anim_dict, tie_hair_anim, 3.0, -3.0, tie_hair_duration, 49, 1.0, false, false, false)
        Wait(tie_hair_duration)
        RemoveAnimDict(tie_hair_anim_dict)
    end
end

local function get_current_hair_style()
    local player_ped = PlayerPedId()
    return {
        drawable = GetPedDrawableVariation(player_ped, COMPONENT_HAIR),
        texture = GetPedTextureVariation(player_ped, COMPONENT_HAIR),
        palette = GetPedPaletteVariation(player_ped, COMPONENT_HAIR),
        color = GetPedHairColor(player_ped),
        highlight_color = GetPedHairHighlightColor(player_ped)
    }
end

local function has_hair_changed()
    local actual_hair = get_current_hair_style()
    local should_hair
    if hair_is_tied then
        should_hair = hair_when_tied
    else
        should_hair = hair_when_opened
    end

    return should_hair == nil
        or should_hair.drawable ~= actual_hair.drawable
        or should_hair.texture ~= actual_hair.texture
        or should_hair.palette ~= actual_hair.palette
        or should_hair.color ~= actual_hair.color
        or should_hair.highlight_color ~= actual_hair.highlight_color
end

local function toggle_hair_tie()
    if not has_hair_changed() and hair_is_tied and hair_when_opened ~= nil then
        set_hair_style(hair_when_opened)
        hair_when_tied = nil
        hair_when_opened = nil
        hair_is_tied = false
    else
        hair_is_tied = true
        hair_when_opened = get_current_hair_style()
        hair_when_tied = get_tied_hair_style()
        set_hair_style(hair_when_tied)
    end
end

RegisterNetEvent('hairtie:use', function()
    if active then return end
    active = true
    play_animation()
    toggle_hair_tie()
    active = false
end)

AddEventHandler('onResourceStop', function(resource_name)
    if GetCurrentResourceName() ~= resource_name then return end

    if not has_hair_changed() and hair_is_tied and hair_when_opened ~= nil then
        toggle_hair_tie()
    end
end)
