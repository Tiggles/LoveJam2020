local next_event = love.timer.getTime() + 10
local initial_height = 600
local initial_width = 800

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
end

function love.update(delta)

end

function love.resize(width, height)
    scale_x = width / initial_width
    scale_y = height / initial_height
end

function love.draw()
    if debug then
        draw_outline(chocolate_collision_box)
        draw_outline(licorice_collision_box)
    end
end

function draw_outline(box)
    love.graphics.rectangle(
        "line",
        box.x * scale_x,
        box.y * scale_y,
        box.width * scale_x,
        box.height * scale_y
    )
end