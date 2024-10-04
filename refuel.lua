--[[
    Turtle Refuel Program
    
    Iterates over the entire inventory and refuels using the item in the slot.
    Place fuel source in all inventory slots and start the program.
    Support for adding automatic refueling with arguments and storage underneath.

    Features/Roadmap:
    - [X] Working refuel operation, regardless of fuel source.
    - [X] Print current fuel level. If all fuel sources have not been consumed, fuel limit has been reached and can be verified more seamlessly.
    - [X] Provide argument for turtle to pull items from connected inventory, removing the need for player intervention.

    Example Usage:
    `refuel.lua`
    Refuels turtle using provided fuel items. Does nothing with them afterwards (assumes they are totally consumed).

    `refuel.lua restock`
    Continues until fuel level = fuel limit. Takes items from storage underneath.

    `refuel.lua restock buckets`
    Pushes item back to storage above turtle if refueling with buckets (or any fuel not totally consumed from mods) and collects fuel from storage under the turtle.
--]]

-- hasArgument: Checks if a specific argument exists within the argument list.
local function hasArgument(argList, searchArg)
    for _, arg in ipairs(argList) do
        if arg == searchArg then
            return true
        end
    end
    return false
end

-- refuel: Refuels the turtle using items from all the turtle's slots.
local function refuel()
    for i = 1, 16 do
        turtle.select(i)
        turtle.refuel()
    end
end

-- pullFromStorage: Continue getting items from the storage underneath the turtle.
local function pullFromStorage()
    for i = 1, 16 do
        turtle.suckDown() -- Assume the storage unit is under the turtle
    end
end

-- pushToStorage: Push buckets back to storage above (in case of a bucket-based refueling mechanism)
local function pushToStorage()
    for i = 1, 16 do
        turtle.select(i)
        turtle.dropUp() -- Assume storage is above the turtle
    end
end

-- Main function
local function main()
    local needsStorageSupport = hasArgument(arg, "restock")
    local handleBuckets = hasArgument(arg, "buckets")

    refuel()

    if handleBuckets then
        pushToStorage()
    end

    if needsStorageSupport then
        local fuelLimit = turtle.getFuelLimit()

        while turtle.getFuelLevel() < fuelLimit do
            pullFromStorage()
            refuel()

            if handleBuckets then
                pushToStorage()
            end

        end
    end

    print("Current fuel: " .. turtle.getFuelLevel())
end

main()
