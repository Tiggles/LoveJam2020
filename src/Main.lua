local next_event = love.timer.getTime() + 10
local initial_height = 600
local initial_width = 800
local points = 9999
local max_points = 999
local frequency_range = 1037 - 887
local current_frequency = 0
local frequency_offset = 887
local frequency_max = 1037
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
end

function Menu_update(delta)
    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        if Is_inside({x = x, y = y}, start_rect) then
            update_loop = Game_loop
            draw_loop = Game_draw
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
        love.graphics.print(frequency_range, 15, 10)
        Draw_outline(chocolate_collision_box)
        Draw_outline(licorice_collision_box)
    end
end

function Fail_draw()

end