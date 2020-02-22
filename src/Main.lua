local next_event = 0
local next_frequency_update = 0
local initial_height = 600
local initial_width = 800
local max_points = 999
local points = max_points
local frequency_offset = 88.7
local frequency_max = 103.7
local frequency_range = frequency_max - frequency_offset
local current_frequency = 0
local start_rect = {
    width = 80,
    height = 30,
    x = initial_width / 2 - 40,
    y = initial_height - 40
}

local update_loop
local draw_loop

local dad = {
    last_candy = nil,
    expecting_candy = false,
    prompting_for_directions = false
}

local chocolate_collision_box = {
    x = 20,
    y = initial_height - 40,
    width = 80,
    height = 30
}

local licorice_collision_box = {
    x = initial_width - 80 - 20,
    y = initial_height - 40,
    width = 80,
    height = 30
}

local scale_x = 1
local scale_y = 1
local debug = true

function love.load()

    update_loop = Menu_update
    draw_loop = Menu_draw
    love.window.setTitle("Road trip")
    love.window.setMode(initial_width, initial_height, {
        vsync = 1,
        resizable  = true
    })

    --[[
        TODO: Add music
        TODO: Add static
    ]]
end

function love.update(delta)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    update_loop(delta)
end

function Fail_loop(delta)
    -- TODO
end

function Game_loop(delta)
    Set_points(-delta * 10)
    if next_frequency_update < love.timer.getTime() then
        if love.keyboard.isDown("up") then
            Update_frequency(0.1)
            next_frequency_update = love.timer.getTime() + 0.1
        elseif love.keyboard.isDown("down") then
            Update_frequency(-0.1)
            next_frequency_update = love.timer.getTime() + 0.1
        end
    end
end

function Menu_update(delta)
    if love.mouse.isDown(1) or love.keyboard.isDown("return") then
        local x, y = love.mouse.getPosition()
        if Is_inside({x = x, y = y}, start_rect) then
            update_loop = Game_loop
            draw_loop = Game_draw
            next_event = love.timer.getTime() + 10
        end
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
    if debug then
        love.graphics.print(math.floor(points), 5, 5)
        Draw_outline(chocolate_collision_box)
        Draw_outline(licorice_collision_box)
    end

    local freq = Frequency()
    if freq % 1 == 0 then
        freq = freq .. ".0"
    end
    love.graphics.print(freq, 50, 50)
end

function Fail_draw()
    love.graphics.print("Dad got mad. You failed.")
end

function Frequency()
    return (current_frequency + frequency_offset)
end

function Update_frequency(add_freq)
    current_frequency = (current_frequency + add_freq) % (frequency_max - frequency_offset)
end