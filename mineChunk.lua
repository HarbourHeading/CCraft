--[[
    Turtle Mining Program
    
    This Lua script controls a turtle from the ComputerCraft mod to perform automated mining operations.
    The turtle digs in a zigzag pattern along the X, Z axes, while moving vertically along the Y axis.

    Features/Roadmap:
    - [X] Error free XYZ operation.
    - [X] Efficient movement logic.
    - [X] Automatic fuel level checks before mining begins.
    - [ ] Inventory checks to ensure sufficient space. If not, place chest and send coords through rednet.
    - [ ] Provide option for auto refuel on operation requiring more than fuel limit.

    Example Usage:
    mine.lua <x_range> <y_range> <z_range> <turn_direction> <y_direction>
    
    Command example:
    `mine.lua 16 65 16 left down`
    This will dig a chunk-sized (16x16) area up to 65 blocks deep, turning left when moving horizontally and going down vertically.

    `mine.lua 16 65 16 right up`
    Gives the same result as above, but from the bottom-up and to the right instead.
--]]


local function moveForward(steps)
    for _ = 1, steps do
        turtle.digDown()
        turtle.digUp()

        repeat
            turtle.dig()
        until turtle.forward()
    end
end

local function moveUp(steps)
    turtle.digDown()
    for _ = 1, steps do
        repeat
            turtle.digUp()
        until turtle.up()
    end
end

local function moveDown(steps)
    turtle.digUp()
    for _ = 1, steps do
        repeat
            turtle.digDown()
        until turtle.down()
    end
end

local function turn(direction)
    if direction == "left" then
        turtle.turnLeft()
    elseif direction == "right" then
        turtle.turnRight()
    else
        error("Invalid turn direction: must be 'left' or 'right'.")
    end
end

local function toggleTurnDirection(current)
    return current == "left" and "right" or "left"
end

-- startMining: Dig in X, Y, Z directions
local function startMining(x_range, y_range, z_range, turn_direction, y_direction)
    x_range = x_range - 1

    for y = 1, y_range, 1 do
        for z = 1, z_range, 1 do

            moveForward(x_range)

            -- Turn and move forward for the next row unless it's the last row
            if z ~= z_range then
                turn(turn_direction)
                moveForward(1)
                turn(turn_direction)
                turn_direction = toggleTurnDirection(turn_direction)
            end


        end

        -- Move up or down between layers unless it's the last layer
        if y ~= y_range then
            if y_direction == "up" then
                moveUp(3)
            else
                moveDown(3)
            end

            -- Turn 180 degrees. Left or right does not matter
            turtle.turnRight()
            turtle.turnRight()
        end
    end

    -- Remove blocks above and under stop position 
    turtle.digDown()
    turtle.digUp()
end

local function validateArgs()
    if tonumber(arg[1]) == nil then
        error("X range is invalid or not specified (must be a number).", 0)
    end

    if tonumber(arg[2]) == nil then
        error("Y range is invalid or not specified (must be a number).", 0)
    end

    if tonumber(arg[3]) == nil then
        error("Z range is invalid or not specified (must be a number).", 0)
    end

    if arg[4] ~= "left" and arg[4] ~= "right" then
        error("Turn direction is invalid (must be 'left' or 'right').", 0)
    end

    if arg[5] ~= "up" and arg[5] ~= "down" then
        error("Y direction is invalid (must be 'up' or 'down').", 0)
    end
end

local function main()
    validateArgs()

    term.clear()
    term.setCursorPos(1,1)
    term.write("Note: Place turtle inside mining zone!")

    term.setCursorPos(1,2)

    local fuel_cost = tonumber(arg[1]) * tonumber(arg[2]) * tonumber(arg[3])
    local current_fuel = turtle.getFuelLevel()

    if current_fuel < fuel_cost then
        error("Current fuel is insufficient for this operation. Fuel: " .. current_fuel, 0)
    end

    startMining(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]), arg[4], arg[5])
end

main()