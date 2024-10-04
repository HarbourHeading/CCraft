--[[
    Turtle Bridge Builder Program

    Builds a bridge beneath the turtle for a specified distance, optionally extending to the left and/or right.
    Blocks must be placed in the turtle's inventory before starting.

    Features/Roadmap:
    - [X] Allow for bridging with side support.
    - [X] Allow for building a tunnel (space for 2-wide).
    - [ ] Add support for automatic refueling during bridging.

    Example Usage:
    `bridge.lua 32`
    Builds a bridge underneath the turtle for 32 blocks.

    `bridge.lua 32 left`
    Builds a bridge underneath and to the left for 32 blocks. Options: 'left', 'right', or both.
--]]

-- moveForwardAndBridge: Moves forward one step while placing a block underneath and clearing any obstacles.
local function moveForwardAndBridge()
    turtle.digUp()

    while not turtle.placeDown() do
    
        if turtle.getItemCount() == 0 then
            error("Out of blocks to place. Operation stopped.", 0)
        end

        turtle.digDown()
    end

    while not turtle.forward() do
        turtle.dig()
    end
end

-- buildSideBridge: Builds a bridge on the side (left or right) of the turtle.
local function buildSideBridge(direction)
    if direction == "left" then
        turtle.turnLeft()
    elseif direction == "right" then
        turtle.turnRight()
    end

    -- Place a block to the side
    while not turtle.place() do

        if turtle.getItemCount() == 0 then
            error("Out of blocks to place. Operation stopped.", 0)
        end

        turtle.dig()
    end

    -- Turn back to the original direction
    if direction == "left" then
        turtle.turnRight()
    elseif direction == "right" then
        turtle.turnLeft()
    end
end

-- startBridging: Main function to build the bridge over the specified distance with optional side extensions.
local function startBridging(distance, buildLeft, buildRight)
    for _ = 1, distance do
        if buildLeft then
            buildSideBridge("left")
        end

        if buildRight then
            buildSideBridge("right")
        end

        moveForwardAndBridge()
    end

    -- Clean up to avoid leaving a block above the final position
    turtle.digUp()
end

-- hasArgument: Checks if a specific argument exists within the argument list.
local function hasArgument(argList, searchArg)
    for _, arg in ipairs(argList) do
        if arg == searchArg then
            return true
        end
    end
    return false
end

-- validateArgs: Validates the arguments passed to the program.
local function validateArgs()
    if tonumber(arg[1]) == nil then
        error("Distance is invalid or not specified (must be a number).", 0)
    end
end

local function main()
    validateArgs()
    local buildLeft = hasArgument(arg, "left")
    local buildRight = hasArgument(arg, "right")

    if turtle.getFuelLevel() < tonumber(arg[1]) then
        error("Not enough fuel for operation. Refuel.", 0)
    end

    print("Note: Place the turtle at the start of the bridge area.")

    while true do
        print("Put blocks in inventory, then type 'done' when ready.")
        local reply = read()
        if reply:lower() == "done" then break end
    end

    startBridging(tonumber(arg[1]), buildLeft, buildRight)
end

main()
