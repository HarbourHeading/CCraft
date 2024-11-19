--[[
    Turtle Mining Program
    
    Mines a specified zone, moving 3 blocks vertically per step on the X axis.
    The turtle digs in a zigzag pattern along the X and Z axes, while moving vertically along the Y axis.
    Places chests for storage if "storage" argument is provided.

    Features/Roadmap:
    - [X] Error-free XYZ operation.
    - [X] Efficient movement logic.
    - [X] Fuel level checks before mining begins.
    - [X] Inventory checks to ensure sufficient space. Places a storage unit for item drop-off.
    - [ ] Send coordinates of placed storage unit through rednet/modem.
    - [ ] Provide option for auto-refuel on operations requiring more than fuel limit.

    Example Usage:
    mine.lua <x_range> <y_range> <z_range> <turn_direction> <y_direction> [storage]

    Command example:
    `mine.lua 16 65 16 left down`
    Digs a chunk-sized (16x16) area up to 65 blocks deep, turning left at the end of each horizontal row and going down vertically.

    `mine.lua 16 65 16 right up storage`
    Same as above but goes bottom-up, turns right, and uses a storage unit.
--]]

-- moveForward: Moves forward a given number of steps, clearing blocks in the way.
local function moveForward(steps)
    for _ = 1, steps do

        turtle.digUp()
        turtle.digDown()

        while not turtle.forward() do
            turtle.dig()
        end
    end
end

-- moveUp: Moves up a given number of steps, clearing any obstacles.
local function moveUp(steps)
    turtle.digDown() -- Otherwise last block ignored in operation
    for _ = 1, steps do
        while not turtle.up() do
            turtle.digUp()
        end
    end
end

-- moveDown: Moves down a given number of steps, clearing any obstacles.
local function moveDown(steps)
    turtle.digUp() -- Otherwise last block ignored in operation
    for _ = 1, steps do
        while not turtle.down() do
            turtle.digDown()
        end
    end
end

-- turn: Turns the turtle in the specified direction (left or right).
local function turn(direction)
    if direction == "left" then
        turtle.turnLeft()
    elseif direction == "right" then
        turtle.turnRight()
    else
        error("Invalid turn direction: must be 'left' or 'right'.")
    end
end

-- toggleTurnDirection: Switches the current turn direction.
local function toggleTurnDirection(current)
    return current == "left" and "right" or "left"
end

-- nearFullInventory: Checks if the turtle's inventory is near full capacity.
local function nearFullInventory()
    turtle.select(15)
    if turtle.getItemDetail() ~= nil then
        turtle.select(1)
        return true
    end
    turtle.select(1)
    return false
end

-- placeAndEmptyStorage: Places a storage unit, empties inventory into it, then collects it back.
local function placeAndEmptyInventory()
    if not turtle.place() then
        error("Unable to place storage unit. Ensure space is available.", 0)
    end

    for slot = 2, 16 do
        turtle.select(slot)
        turtle.drop()
    end

    turtle.select(1)
end

local function turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
end

-- startMining: Main function for mining the specified area in XYZ directions.
local function startMining(x_range, y_range, z_range, turn_direction, y_direction, need_storage_support)
    for y = 1, y_range do
        for z = 1, z_range do
            moveForward(x_range)

            if need_storage_support and nearFullInventory() then
                turnAround()
                placeAndEmptyInventory()
                turnAround()
            end

            -- Turn and move forward for the next row unless it's the last row in this layer
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
            turnAround()
        end
    end

    -- Cleanup to not leave any blocks above or under.
    turtle.digDown()
    turtle.digUp()
end

-- validateArgs: Validates the arguments passed to the program.
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
    local need_storage_support = arg[6] == "storage"

    print("Note: Place turtle inside the mining zone!")

    local fuel_cost = tonumber(arg[1]) * tonumber(arg[2]) * tonumber(arg[3])
    local current_fuel = turtle.getFuelLevel()

    if current_fuel < fuel_cost then
        error("Current fuel is insufficient for this operation. Fuel: " .. current_fuel, 0)
    end

    if need_storage_support then
        turtle.select(1)
        print("Provide storage unit in slot 1.")
        while turtle.getItemDetail() == nil do
            sleep(2)
        end
    end

    startMining(tonumber(arg[1]) - 1, tonumber(arg[2]), tonumber(arg[3]), arg[4], arg[5], need_storage_support)
end

main()
