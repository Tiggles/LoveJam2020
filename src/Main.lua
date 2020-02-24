local some_val = 0
local next_event = 0
local distance_to_next_directions = 1200
local next_frequency_update = 0
local initial_height = 600
local initial_width = 800
local max_points = 999
local points = max_points
local frequency_offset = 87.5
local frequency_max = 108.0
local current_frequency = 6.7
local target_frequency = current_frequency
local start_rect = {
    width = 80,
    height = 30,
    x = initial_width / 2 - 40,
    y = initial_height - 40
}
local directions = {
    max_y = initial_height * 0.6,
    min_y = initial_height + 10,
    y = initial_height + 10,
    notes = {}
}
local current_music = math.random(1, 2)

local static
local music = {}

local RIGHT = 0
local LEFT = 1

local point_of_reference_images = {}

local point_of_reference_options = {
    "water tower",
    "tree",
    "gas station",
    "hotel",
    "windmill",
    "barn",
    "lighthouse",
    "woods",
    "train"
}

local update_loop
local draw_loop

local stripes = {}
local stripes_anim_count = 22
local stripes_anim_current = 0
local strips_anim_length = 0.001
local anim_tick_counter = 0
local car_image
local wind_shield
local arm_image

function Initial_dad()
    return {
        last_candy = nil,
        expecting_candy = false,
        prompting_for_directions = false
    }
end

local dad = Initial_dad()

local chocolate_collision_box = {
    x = 160,
    y = 428,
    width = 50,
    height = 60
}

local licorice_collision_box = {
    x = 586,
    y = 425,
    width = 52,
    height = 60
}

local stripes_img = love.graphics.newImage("stripes.png")

local scale_x = 1
local scale_y = 1
local debug = true

function love.load()
    Populate_Directions()
    car_image = love.graphics.newImage("car.png")
    wind_shield = love.graphics.newImage("windshield.png")
    arm_image = love.graphics.newImage("arm.png")

    music[0] = love.audio.newSource("rock1.wav", "static")
    music[1] = love.audio.newSource("rock2.mp3", "static")
    music[0]:setLooping(false)
    music[1]:setLooping(false)
    static = love.audio.newSource( "static.wav", "static")
    point_of_reference_images["water tower"] = love.graphics.newImage("watertower.png")
    for i = 0, stripes_anim_count do
        stripes[i] = love.graphics.newQuad(30 * i, 0, 30, 60, stripes_img:getDimensions())
    end
    update_loop = Menu_update
    draw_loop = Menu_draw
    love.window.setTitle("Road trip")
    love.window.setMode(initial_width, initial_height, {
        vsync = 1,
        resizable  = true
    })
end

function love.update(delta)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    update_loop(delta)
end

function Game_loop(delta)
    static:play()
    if not music[0]:isPlaying() and not music[1]:isPlaying() then
        current_music = current_music % 2
        music[current_music]:play()
    end

    if target_frequency ~= current_frequency then
        static:setVolume(math.min(0.5, math.abs(target_frequency - current_frequency)))
    else
        static:setVolume(0)
    end

    local frequency_diff = math.abs(target_frequency - current_frequency)

    if frequency_diff == 0 then
        music[current_music]:setVolume(1)
    else
        music[current_music]:setVolume(1 - frequency_diff * 2)
    end

    some_val = some_val + 0.1 * delta
    next_event = next_event - delta
    if next_event < love.timer.getTime() then
        Set_event(dad)
        next_event = love.timer.getTime() + math.random(15, 20)
    end
    
    -- TODO, Wraparound
    Set_points(-delta * 10 - math.abs(target_frequency - current_frequency) * delta)
    if points < 0 then
        update_loop = Fail_loop
        draw_loop = Fail_draw
    end

    if love.keyboard.isDown("space") then
        directions.y = math.max(directions.y - (delta * 700), directions.max_y)
    else
        directions.y = math.min(directions.y + (delta * 700), directions.min_y)
    end

    if love.mouse.isDown(1) then
        local x, y = Mouse_coordinates()
        if Is_inside({x = x, y = y}, chocolate_collision_box) then
            if dad.expecting_candy then
                Give_candy(dad, "chocolate")
            end
        end
        if Is_inside({x = x, y = y}, licorice_collision_box) then
            if dad.expecting_candy then
                Give_candy(dad, "licorice")
            end
        end
    end


    if next_frequency_update < love.timer.getTime() then
        if love.keyboard.isDown("up") then
            Update_frequency(0.1)
            next_frequency_update = love.timer.getTime() + 0.1
        elseif love.keyboard.isDown("down") then
            Update_frequency(-0.1)
            next_frequency_update = love.timer.getTime() + 0.1
        end
    end
    anim_tick_counter = anim_tick_counter + delta
    if anim_tick_counter > strips_anim_length then
        stripes_anim_current = (stripes_anim_current + 1) % stripes_anim_count
    end
    anim_tick_counter = anim_tick_counter % strips_anim_length
end

function Menu_update(delta)
    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        if Is_inside({x = x, y = y}, {x = start_rect.x * scale_x, y = start_rect.y * scale_y, width = start_rect.width, height = start_rect.height}) then
            update_loop = Game_loop
            draw_loop = Game_draw
            next_event = love.timer.getTime() + 2
        end
    end

    if love.keyboard.isDown("return") then
        update_loop = Game_loop
        draw_loop = Game_draw
        next_event = love.timer.getTime() + 2
    end
end

function love.resize(width, height)
    scale_x = width / initial_width
    scale_y = height / initial_height
end

function love.draw()
    draw_loop()
end

function Draw_outline(box)
    love.graphics.rectangle(
        "line",
        box.x * scale_x,
        box.y * scale_y,
        box.width * scale_x,
        box.height * scale_y
    )
end

function Draw_filled(box)
    love.graphics.rectangle(
        "fill",
        box.x * scale_x,
        box.y * scale_y,
        box.width * scale_x,
        box.height * scale_y
    )
end

function Set_points(extra_points)
    points = math.max(math.min(points + extra_points, max_points), -1)
end

function Is_inside(vec, rect)
    return vec.x > rect.x and vec.x < rect.x + rect.width and vec.y > rect.y and vec.y < rect.y + rect.height
end

function Menu_draw()
    Draw_filled(start_rect)
end

function Game_draw()
    love.graphics.draw(car_image, 0, 0, 0, scale_x, scale_y)
    love.graphics.draw(wind_shield, 0, 0, 0, scale_x, scale_y)

    if debug then
        Draw_outline(chocolate_collision_box)
        Draw_outline(licorice_collision_box)
    end

    love.graphics.print("Remaining happiness: " .. math.floor(points), 5 * scale_x, 5 * scale_y, 0, scale_x, scale_y)

    if dad.expecting_candy then
        love.graphics.draw(arm_image, 0, 4, 0, scale_x, scale_y)
    end

    love.graphics.draw(point_of_reference_images["water tower"], 404 * scale_x, 143 * scale_y, 0, scale_x * some_val, scale_y  * some_val, 51, 86)

    love.graphics.draw(stripes_img, stripes[stripes_anim_current], 391 * scale_y, 143 * scale_y, 0, scale_x, scale_y)

    -- Draw directions
    love.graphics.rectangle("fill", (initial_width / 4) * scale_x, directions.y * scale_y, 400 * scale_x, (initial_height - 120) * scale_y, 0, scale_x, scale_y)
    love.graphics.setColor(0, 0, 0)
    for i = 0, #directions.notes -1 do
        local note = directions.notes[i]
        love.graphics.print(Direction_to_string(note.direction) .. " at " .. note.point_of_reference, (initial_width / 4 + 30) * scale_x, (directions.y + 30 + 20 * i) * scale_y, 0, scale_x, scale_y)
    end

    local freq = Frequency()
    love.graphics.print(freq, 379 * scale_x, 327 * scale_y, 0, scale_y, scale_y)
    love.graphics.setColor(1, 1, 1)
end

function Fail_draw()
    love.graphics.print("Dad got mad. You failed.", (initial_width / 2 - 80) * scale_x, (initial_height / 2) * scale_y)
    love.graphics.print("Press space to try again.", (initial_width / 2 - 80) * scale_x, (initial_height / 2) + 20 * scale_y)
end

function Fail_loop()
    if love.keyboard.isDown("return") then
        love.event.quit("restart")
    end
end

function Frequency()
    return (current_frequency + frequency_offset)
end

function Update_frequency(add_freq)
    current_frequency = math.min(math.max(current_frequency + add_freq, 0), (frequency_max - frequency_offset))
end

function Mouse_coordinates()
    local x, y = love.mouse.getPosition()
    return x * scale_x, y * scale_y
end

function New_dir_pair()
    return {
        direction = Random_Direction(),
        point_of_reference = Random_PoI()
    }
end

function Random_Direction()
    if math.random() > 0.5 then
        return LEFT
    else
        return RIGHT
    end
end

function Random_PoI()
    return point_of_reference_options[math.random(1, #point_of_reference_options)]
end

function Populate_Directions()
    for i = 0, 8 do
        directions.notes[i] = New_dir_pair()
    end
end

function Direction_to_string(dir)
    if dir == LEFT then
        return "Left"
    else
        return "Right"
    end
end

function Set_event(dad)
    dad.expecting_candy = true
end

function Give_candy(dad, candy)
    if dad.last_candy == candy then
        Set_points(-200)
    else
        Set_points(50)
    end
    dad.last_candy = candy
    dad.expecting_candy = false
end