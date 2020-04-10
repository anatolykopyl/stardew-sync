#!/usr/local/bin/lua

lfs = require('lfs')
require('lib/getOS')
require('settings')

OS = getOS()
print('Detected OS: ' .. OS)

arg = {...}

silent_mode = arg[1] == '-s'
if silent_mode then
    print("silent_mode")
else
    fl = require('moonfltk')
end

function to_pc(button)
    if button then
        print(button:label())
    end
    if selected_device ~= '' then
        if OS ~= 'Windows' then
            os.execute('cp -rv '..selected_path..'/. '..local_dir)
        end
    end
end

function to_phone(button)
    if button then
        print(button:label())
    end

    if selected_device ~= '' then
        if OS ~= 'Windows' then
            os.execute('cp -rv '..local_dir..'/. '..selected_path)
        end
    end
end

function input_choice_cb(_, ic)
    selected_device = ic:value()
    selected_path = mount_point..'/'..selected_device..'/Внутренняя\\ память/StardewValley'
    print('Selected path: '..selected_path)
    
    to_pc_btn:activate()
    to_phone_btn:activate()
end

function refresh_devices()
    handle = io.popen('ls '..mount_point)
    phone_dir_output = handle:read('*a')
    handle:close()

    phone_dir = {}
    for i in string.gmatch(phone_dir_output, '%S+') do
        phone_dir[#phone_dir + 1] = i
    end

    if win then     -- If fltk window created
        if #phone_dir == 0 then
	        device_choice:clear()
            device_choice:deactivate()
            to_pc_btn:deactivate()
            to_phone_btn:deactivate()
        else
	        device_choice:activate()
	        to_pc_btn:activate()
	        to_phone_btn:activate()
            for i = 1, #phone_dir do
                device_choice:add(phone_dir[i])
            end
	    end
    end
end

selected_device = ''
selected_path = ''
my_dir = lfs.currentdir()
if OS ~= 'Windows' then
    local_dir = settings.local_dir or '~/.config/StardewValley/Saves'
    mount_point = '/run/user/1000/gvfs'
end

if not silent_mode then
    W, H = 320, 360

    fl.visual('rgb')
    win = fl.double_window(W, H, 'Синхронизатор')
    win:color(fl.WHITE)
    icon_img = fl.png_image(my_dir..'/img/icon.png')
    win:icon(icon_img)
    fl.background(240, 240, 240)

    bg_img = fl.png_image(my_dir..'/img/bg.png')
    bg_box = fl.box(1, 1, W, H)
    bg_box:image(bg_img)

    fl.box(0, 70, W, 30, 'Выберите устройство:')
    refresh_img = fl.png_image(my_dir..'/img/refresh.png')
    refresh_btn = fl.button(10, 100, 30, 30)
    refresh_btn:callback(refresh_devices)
    refresh_btn:image(refresh_img)
    device_choice = fl.input_choice(50, 100, W-60, 30)
    device_choice:callback(input_choice_cb, device_choice)

    to_pc_btn = fl.button(50, H/2, W-100, 30, 'На ПК')
    to_pc_btn:callback(to_pc)
    to_pc_btn:deactivate()
    to_phone_btn = fl.button(50, H/2+40, W-100, 30, 'На телефон') 
    to_phone_btn:callback(to_phone)
    to_phone_btn:deactivate()

    refresh_devices()

    win:done()
    win:show(arg[0], arg)

    return fl.run()
else
    selected_path = mount_point..'/'..phone_dir[1]..'/Внутренняя\\ память/StardewValley'

    if arg[2] == 'tophone' then
        to_phone()
    elseif arg[2] == 'topc' then
        to_pc()
    end
end

