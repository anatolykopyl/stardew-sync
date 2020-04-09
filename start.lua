#!/usr/local/bin/lua

fl = require('moonfltk')
lfs = require('lfs')

function to_pc(button)
    print(button:label())
    if selected_device ~= '' then
        os.execute('cp -rv '..selected_path..'/. '..local_dir)
    end
end

function to_phone(button)
    print(button:label())
    if selected_device ~= '' then
        os.execute('cp -rv '..local_dir..'/. '..selected_path)
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

    if win then
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
local_dir = '/home/victoria/.config/StardewValley/Saves'
mount_point = '/run/user/1000/gvfs'

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

title = fl.box(0, 10, W, 30, 'Выберите устройство:')
refresh_img = fl.png_image(my_dir..'/img/refresh.png')
refresh_btn = fl.button(10, 50, 30, 30)
refresh_btn:callback(refresh_devices)
refresh_btn:image(refresh_img)
device_choice = fl.input_choice(50, 50, W-60, 30)
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

