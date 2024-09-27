--[[
    Turtle Refuel Program
    
    Iterates over entire inventory and refuels using the item in the slot.
    Place fuel source in all inventory slots and start the program.

    Features/Roadmap:
    - [X] Working refuel operation, regardless of fuel source.
    - [X] Print current fuel level. If all fuel sources have not been consumed, fuel limit has been reached and can be verified more seamlessly.
    - [ ] Provide argument for turtle to pull items from connected inventory, removing the need for player intervention.

    Example Usage:
    `refuel.lua`
    With inventory of lava buckets, turtle gets 16000 (1000 per bucket) fuel.
--]]

for i = 1, 16, 1 do
    turtle.select(i)
    turtle.refuel()
end

print(turtle.getFuelLevel())