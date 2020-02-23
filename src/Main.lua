local next_event = 0
local next_frequency_update = 0
local initial_height = 600
local initial_width = 800
local max_points = 999
local points = max_points
local frequency_offset = 87.5
local frequency_max = 108.0
local current_frequency = 0
local target_frequency = 0
local start_rect = {
    width = 80,
    height = 30,
    x = initial_width / 2 - 40,
    y = initial_height - 40
}
local directions = {
    max_y = initial_height * 0.2,
    min_y = initial_height + 10,
    y = initial_height + 10,
    notes = {

    }
}

local update_loop
local draw_loop

local car_image

function Reset_dad()
    return {
        last_candy = nil,
        expecting_candy = false,
        prompting_for_directions = false
    }
end

local dad = Reset_dad()

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

local scale_x = 1
local scale_y = 1
local debug = true

function love.load()
    car_image = love.graphics.newImage("car.png")
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

function Game_loop(delta)
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
            print("Chocolate")
        end
        if Is_inside({x = x, y = y}, licorice_collision_box) then
            print("Licorice")
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
    love.graphics.draw(car_image, 0, 0)

    if debug then
        love.graphics.print(math.floor(points), 5, 5)
        Draw_outline(chocolate_collision_box)
        Draw_outline(licorice_collision_box)
    end

    love.graphics.rectangle("fill", initial_width / 4, directions.y, 400, initial_height - 120)

    local freq = Frequency()
    if freq > 100 then
        print(freq % 1)
    end
    if freq % 1 == 0 then
        freq = freq .. ".0"
    end
    love.graphics.print(freq, 50, 50)
end

function Fail_draw()
    love.graphics.print("Dad got mad. You failed.", (initial_width / 2 - 80)  * scale_x, (initial_height / 2) * scale_y)
end

function Fail_loop(delta)
    -- TODO
end

function Frequency()
    return (current_frequency + frequency_offset)
end

function Update_frequency(add_freq)
    current_frequency = (current_frequency + add_freq) % (frequency_max - frequency_offset)
end

function Mouse_coordinates()
    local x, y = love.mouse.getPosition()
    return x * scale_x, y * scale_y
end