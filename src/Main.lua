local next_event = love.timer.getTime() + 10
local initial_height = 600
local initial_width = 800
local points = 9999
local max_points = 999
local frequency_range = 1037 - 887
local current_frequency = 123

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

--[[
    TODO: Start screen
]]

--[[
    TODO: Fail state
]]

function love.update(delta)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    Set_points(-delta * 10)
end

function love.resize(width, height)
    scale_x = width / initial_width
    scale_y = height / initial_height
end

function love.draw()
    if debug then
        love.graphics.print(math.floor(points), 5, 5)
        love.graphics.print(frequency_range, 15, 10)
        Draw_outline(chocolate_collision_box)
        Draw_outline(licorice_collision_box)
    end
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