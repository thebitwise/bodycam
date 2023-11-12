--$$\        $$$$$$\  $$\   $$\  $$$$$$\  $$$$$$$$\ 
--$$ |      $$  __$$\ $$$\  $$ |$$  __$$\ $$  _____|
--$$ |      $$ /  $$ |$$$$\ $$ |$$ /  \__|$$ |      
--$$ |      $$$$$$$$ |$$ $$\$$ |$$ |      $$$$$\    
--$$ |      $$  __$$ |$$ \$$$$ |$$ |      $$  __|   
--$$ |      $$ |  $$ |$$ |\$$$ |$$ |  $$\ $$ |      
--$$$$$$$$\ $$ |  $$ |$$ | \$$ |\$$$$$$  |$$$$$$$$\ 
--\________|\__|  \__|\__|  \__| \______/ \________|
-- coded by Lance/stonerchrist on Discord
pluto_use "0.5.0"
util.require_natives("2944a", "g")

local resources_dir =  filesystem.resources_dir() .. '\\bodycam\\'
if not filesystem.is_dir(resources_dir) then
    util.toast("Resources dir is missing. The script will now exit.")
    util.stop_script()
end

local shader_ref = menu.ref_by_path("Game>Rendering>Shader Override")
local initial_shader_int = menu.get_value(shader_ref)


local axon_logo = directx.create_texture(resources_dir .. '\\axon.png')
local root = menu.my_root()
local bodycam_active = false 
local axon_scale = 0.02
local hud_x = 0.985
local hud_y = 0.05
local text_scale = 0.6
local white = {r = 1, g = 1, b = 1, a = 1}
local cam = nil 
local rand_id = "AXON BODY " .. tostring(players.user() + 1) .. ' X' .. tostring(math.random(00000000, 99999999))

util.create_tick_handler(function()
    local date =  os.date("%Y-%m-%d T%H:%M:%SZ")
    local line1_w, line1_h = directx.get_text_size(date, text_scale)
    if bodycam_active then 
        local angs = GET_ENTITY_ROTATION(players.user_ped(), 3)
        SET_CAM_ROT(cam, angs.x, angs.y, angs.z, 3)
        directx.draw_texture(axon_logo, axon_scale, axon_scale, 0.5, 0.5, hud_x, hud_y, 0, white)
        directx.draw_text(hud_x - (axon_scale + 0.005), hud_y - line1_h / 2, date, 6, text_scale, white, true, nil)
        directx.draw_text(hud_x - (axon_scale + 0.005), hud_y + line1_h / 2, rand_id, 6, text_scale, white, true, nil)
        SET_FOLLOW_PED_CAM_VIEW_MODE(3)
    end
end)

root:toggle("Bodycam", {}, '', function(on) 
    bodycam_active = on
    if on then
        local c = players.get_position(players.user())
        cam = CREATE_CAM_WITH_PARAMS('DEFAULT_SCRIPTED_CAMERA', c.x, c.y, c.z, -90.0, 0.0, 0.0, 120, true, 0) 
        SET_CAM_NEAR_CLIP(cam, 0.01) 
        RENDER_SCRIPT_CAMS(true, false, 0, true, true, 0)
        ATTACH_CAM_TO_PED_BONE(cam, players.user_ped(), 35731, 0.0, 0.15, 0.12, true)
        SET_CAM_FOV(cam, 120)
        SET_CAM_ROT(cam, 0.0, 0.0, 0.0)
        menu.trigger_commands("shader v_dark")
    else 
        DESTROY_CAM(cam, false) 
        RENDER_SCRIPT_CAMS(false, false, 0, true, true, 0)
        menu.set_value(shader_ref, initial_shader_int)
    end 
end)

root:slider_float("Scale", {}, '', 1, 1000, 2, 1, function(val) 
    axon_scale = val * 0.01
end)


root:action("Debug: kill rendering cam", {}, 'If the script has been turned off and some camera still exists, spam this until normal.', function() 
    DESTROY_CAM(GET_RENDERING_CAM(), false) 
end)


menu.my_root():divider('')
menu.my_root():hyperlink('Join Discord', 'https://discord.gg/zZ2eEjj88v', '')
