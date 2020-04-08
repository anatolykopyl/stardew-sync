#!/usr/local/bin/lua

fl = require('moonfltk')

function to_pc(button)
    print(button:label())
    if selected_device ~= '' then
        os.execute('cp -r '..selected_path..'/. '..local_dir)
    end
end

function to_phone(button)
    print(button:label())
    if selected_device ~= '' then
        os.execute('cp -r '..local_dir..'/. '..selected_path)
    end
end

function input_choice_cb(_, ic)
    selected_device = ic:value()
    selected_path = mount_point..'/'..selected_device..'/Внутренняя\\ память/StardewValley'
    print('Selected path: '..selected_path)
    
    to_pc_btn:activate()
    to_phone_btn:activate()
end

selected_device = ''
selected_path = ''
my_dir = os.getenv('PWD')
local_dir = '/home/victoria/.config/StardewValley/Saves'
mount_point = '/run/user/1000/gvfs'
handle = io.popen('ls '..mount_point)
--handle = io.popen('ls ~')
phone_dir_output = handle:read('*a')
handle:close()

phone_dir = {}
for i in string.gmatch(phone_dir_output, '%S+') do
    phone_dir[#phone_dir + 1] = i
end

W, H = 320, 360

fl.visual('rgb')
win = fl.double_window(W, H, 'Синхронизатор')
win:color(fl.WHITE)
--fl.background(255, 255, 255)
--fl.set_font(1, ' Roboto')
--fl.font(1, 12)
bg_img = fl.png_image(my_dir..'/img/bg.png')
bg_box = fl.box(1, 1, W, H)
bg_box:image(bg_img)

title = fl.box(0, 10, W, 30, 'Выберите устройство:')
ic = fl.input_choice(10, 50, W-20, 30)
ic:callback(input_choice_cb, ic)

to_pc_btn = fl.button(50, H/2, W-100, 30, 'На ПК')
to_pc_btn:callback(to_pc)
to_pc_btn:deactivate()
to_phone_btn = fl.button(50, H/2+40, W-100, 30, 'На телефон') 
to_phone_btn:callback(to_phone)
to_phone_btn:deactivate()

if #phone_dir == 0 then
    ic:deactivate()
    to_pc_btn:deactivate()
    to_phone_btn:deactivate()
else
    for i = 1, #phone_dir do
        ic:add(phone_dir[i])
    end
end

win:done()
win:show(arg[0], arg)

return fl.run()

