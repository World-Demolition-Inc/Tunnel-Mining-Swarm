--[[
 _ _ _         _   _    ____                   _____           
| | | |___ ___| |_| |  |    \ ___ _____ ___   |     |___ ___   
| | | | . |  _| | . |  |  |  | -_|     | . |  |-   -|   |  _|_ 
|_____|___|_| |_|___|  |____/|___|_|_|_|___|  |_____|_|_|___|_|
                                                               
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Author: Captain Oppai
# Author Discord: Jisatsu#1987
# Github Project Repo: https://github.com/World-Demolition-Inc/Tunnel-Mining-Swarm
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright 2021 Captain-Oppai
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# File description and information:
#
# This file is to be put onto a disk which will then be given to the master turtle during setup. The disk is used to automatically boot this script onto workers being deployed
# in a mining operation. This script contains 5 major routines, after the completion of these 5 routines it'll repeat again if there are more tunnels needed to be mined.
# I will not be able to put as much description in this script as it is a lot more vast compared to the others, I'll try to comment functions within this code and explain what they do.
#
# This file might be updated will general improvements or commenting, any updates will be posted to the github repo.
# If you'd like to make your own modifications you can make a pull request if you'd like the changes to be pushed to the main branch.
# Make sure to identify yourself on your revisions, a comment to show you are who changed the piece of code.
# If you'd like to take this project and take it your own way, making your own repo that's perfectly fine but do be aware this script is licensed under the GPL-2.0 license.
# The copyright information in this script or the license may not be removed, but the code can be freely modified beyond that and distributed. If you're curious about the license
# there is a link further up this copyright header.
#
# If there happens to be an issue you come across you can either fix it yourself or post an issue on the 'Issues' tab of the repository this is derived from.
# (This does not always apply if this script is from a repository other than the one that is listed above.)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--]]

--Script to be put onto a disk

turtle.refuel(1)

local modem = peripheral.wrap("left")

local masterChannel = 11
local serverChannel = 10

modem.open(masterChannel)
modem.open(serverChannel)

local event, _, senderChannel, replyChannel, message

local messageArray

local sideBool
local tunnelNumber

local digBuffer = 2
local moveForward

local digSide

local moveForward
local returnForward

local digLoop

local bool, table

local miningDepth

-- !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! !ALERT! 
-- Make sure to add the items you'd like the workers to keep in this list here. If you do not then the worker will drop it.
-- This includes the ore version and mined version of it (assuming it has one, ores like diamonds and redstone.)

local goodOres = {
"minecraft:iron_ore",
"minecraft:diamond_ore",
"minecraft:diamond",
"minecraft:gold_ore",
"minecraft:redstone_ore",
"minecraft:coal_ore",
"minecraft:coal",
"minecraft:emerald_ore",
"minecraft:emerald",
"minecraft:lapis_ore",
"minecraft:lapis_lazuli"}

-- Add items that are fuel, these will be deposited into the fuel chest rather than the 'goodOres' chest.

local fuel = {"minecraft:coal",
"minecraft:coal_block"}

-- There are some redundant functions here I know, haven't gotten around cleaning it up.

-- These movement protect functions are for ensuring the worker moves forward,
-- it does this by checking to see if the movement has completed and if it has not
-- then it will attack and dig, it'll repeat this until the worker returns true
-- to moving.

local function moveForwardProtect()
    local loop = true
    local bool, string = turtle.forward()
    if(bool == false) then
        while loop do    
            bool, string = turtle.forward()
            turtle.attack()
            sleep(1)
            if(bool == false) then loop = true else loop = false end
        end
    end
end

local function moveUpProtect()
    local loop = true
    local bool, string = turtle.up()
    if(bool == false) then
        while loop do    
            bool, string = turtle.up()
            turtle.attackUp()
            turtle.digUp()
            sleep(1)
            if(bool == false) then loop = true else loop = false end
        end
    end
end

local function moveDownProtect()
    local loop = true
    local bool, string = turtle.down()
    if(bool == false) then
        while loop do    
            bool, string = turtle.down()
            turtle.attackDown()
            turtle.digDown()
            sleep(1)
            if(bool == false) then loop = true else loop = false end
        end
    end
end

local function moveForwardProtectDig()
    local loop = true
    local bool, string = turtle.forward()
    if(bool == false) then
        while loop do    
            local bool2, table2 = turtle.inspect()
            if(table["name"] ~= "computercraft:turtle_expanded") then
                bool, string = turtle.forward()
                turtle.attack()
                turtle.dig()
                sleep(1)
                if(bool == false) then loop = true else loop = false end
            end
        end
    end
end

-- This function will check the list 'goodOres' and return true if the value is within the list.

local function contain(element)
    for _, value in pairs(goodOres) do
        if value == element then
            return true
        end
    end
    return false
end

-- This function is the same as the above but checks if it is in the 'fuel' list.

local function containFuel(element)
    for _, value in pairs(fuel) do
        if value == element then
            return true
        end
    end
    return false
end

-- This routine will check all the slots in the turtle and drop the item if it's not within the goodOre list.

local function blacklistRoutine()
    for i = 1, 16 do
        turtle.select(i)
        if(turtle.getItemCount() >= 1) then
            local data = turtle.getItemDetail()
            if(contain(data["name"]) == false) then
                turtle.drop(64)
            end
        end
    end
end

-- To make sure that workers do not destroy each other this routine will activate before moving.

local function waitForBrother()
    local wait = true
    local wait2 = true
    while wait do
        bool, table = turtle.inspect()
        if(table["name"] == "computercraft:turtle_expanded") then sleep(1) else wait = false end
    end
    while wait2 do
        bool, table = turtle.inspectUp()
        if(table["name"] == "computercraft:turtle_expanded") then sleep(1) else wait2 = false end
    end
end

local function waitForBrotherDown()
    local wait = true
    local wait2 = true
    local wait3 = true
    while wait do
        bool, table = turtle.inspect()
        if(table["name"] == "computercraft:turtle_expanded") then sleep(1) else wait = false end
    end
    while wait2 do
        bool, table = turtle.inspectUp()
        if(table["name"] == "computercraft:turtle_expanded") then sleep(1) else wait2 = false end
    end
    while wait3 do
        bool, table = turtle.inspectDown()
        if(table["name"] == "computercraft:turtle_expanded") then sleep(1) else wait3 = false end
    end
end

-- This is used for when the tunnel has been labeled as complete, most likely will be changed
-- when id persistence is not required, or it'll be kept for legacy use.
-- This routine will also make sure the master turtle returns when everything is done.

local function returnUp()
    print("Returning to surface.")
    modem.transmit(masterChannel, masterChannel, "return")
    event, _, senderChannel, replyChannel, message = os.pullEvent("modem_message")
    waitForBrother()
    turtle.digUp()
    moveUpProtect()
    turtle.turnRight()
    turtle.turnRight()
    waitForBrother()
    moveForwardProtect()
    blacklistRoutine()
    for i = 1, message do
        moveUpProtect()
    end
    modem.transmit(masterChannel, masterChannel, "retrieve")
    os.reboot()
end

-- This'll get data from the server and then sort the data into the required variables.

local function getData()
    local loop = true
    while loop do
        modem.transmit(serverChannel, serverChannel, "Get Data")
        event, _, senderChannel, replyChannel, message = os.pullEvent("modem_message")
        if(message ~= nil) then
            loop = false
        end
        if(loop == false) then
            messageArray = textutils.unserialise(message)
            print(message)
            sideBool = messageArray[1]
            tunnelNumber = messageArray[2]
            miningDepth = messageArray[3]
            if(tunnelNumber == "done") then 
                returnUp()
            end
            if (sideBool == false) then digSide = "Left" 
            else digSide = "Right" end

            moveForward = (tunnelNumber * 3) + digBuffer
            returnForward = (tunnelNumber * 3) - 1
        end
    end

end

-- Simply declares if the tunnel is done.

local function markDone()
    modem.transmit(serverChannel, serverChannel, "Mark done")
end

-- Inspect functions just to sort it into separate vars.

local function inspect()
    bool, table = turtle.inspect()
end

local function inspectUp()
    bool, table = turtle.inspectUp()
end

local function inspectDown()
    bool, table = turtle.inspectDown()
end

-- This is just a mess... It works as-is, it probably can be optimized a lot but as of now... here it is.

local function miningRoutine()
    turtle.digDown()
    for i = 1, miningDepth do
        turtle.dig()
        moveForwardProtectDig()
        turtle.digDown()
        turtle.turnLeft()
        inspect()
        if(contain(table["name"])) then turtle.dig() end
        turtle.turnRight()
        inspectUp()
        if(contain(table["name"])) then
            turtle.digUp() 
            moveUpProtect()
            turtle.turnRight()
            inspect()
            if(contain(table["name"])) then 
                turtle.dig()
                moveForwardProtectDig()
                inspect()
                if(contain(table["name"])) then
                    turtle.dig()
                    moveForwardProtectDig()
                    inspect()
                    if(contain(table["name"])) then turtle.dig() end
                    inspectUp()
                    if(contain(table["name"])) then turtle.digUp() end
                    turtle.back()
                end
                inspectUp()
                if(contain(table["name"])) then turtle.digUp() end
                turtle.back()
            end
            turtle.turnLeft()
            inspectUp()
            if(contain(table["name"])) then
                turtle.digUp() 
                moveUpProtect()
                turtle.turnRight()
                inspect()
                if(contain(table["name"])) then 
                    turtle.dig()
                    moveForwardProtectDig()
                    inspect()
                    if(contain(table["name"])) then 
                        turtle.dig()
                        moveForwardProtectDig()
                        inspect()
                        if(contain(table["name"])) then
                            turtle.dig()
                            moveForwardProtectDig()
                            inspect()
                            if(contain(table["name"])) then turtle.dig() end
                            inspectUp()
                            if(contain(table["name"])) then turtle.digUp() end
                            turtle.back()
                        end
                        inspectUp()
                        if(contain(table["name"])) then turtle.digUp() end
                        turtle.back()
                    end
                    inspectUp()
                    if(contain(table["name"])) then turtle.digUp() end
                    turtle.back()
                end
                turtle.turnLeft()
                inspectUp()
                if(contain(table["name"])) then turtle.digUp() end
                turtle.turnLeft()
                inspect()
                if(contain(table["name"])) then 
                    turtle.dig()
                    moveForwardProtectDig()
                    inspect()
                    if(contain(table["name"])) then turtle.dig() end
                    inspectUp()
                    if(contain(table["name"])) then turtle.digUp() end
                    turtle.back()
                end
                turtle.turnRight()
                moveDownProtect()
            end
            turtle.turnLeft()
            inspect()
            if(contain(table["name"])) then 
                turtle.dig()
                moveForwardProtectDig()
                inspect()
                if(contain(table["name"])) then turtle.dig() end
                inspectUp()
                if(contain(table["name"])) then turtle.digUp() end
                turtle.back()
            end
            turtle.turnRight()
            moveDownProtect()
        end
        turtle.turnRight()
        inspect()
        if(contain(table["name"])) then turtle.dig() end
        moveDownProtect()
        inspect()
        if(contain(table["name"])) then turtle.dig() end
        turtle.turnLeft()
        inspectDown()
        if(contain(table["name"])) then
            turtle.digDown() 
            moveDownProtect()
            turtle.turnRight()
            inspect()
            if(contain(table["name"])) then 
                turtle.dig()
                moveForwardProtectDig()
                inspectDown()
                if(contain(table["name"])) then turtle.digDown() end
                inspect()
                if(contain(table["name"])) then
                    turtle.dig()
                    moveForwardProtectDig()
                    inspect()
                    if(contain(table["name"])) then
                        turtle.dig()
                        moveForwardProtectDig()
                        inspect()
                        if(contain(table["name"])) then turtle.dig() end
                        inspectUp()
                        if(contain(table["name"])) then turtle.digUp() end
                        turtle.back()
                    end
                    inspectUp()
                    if(contain(table["name"])) then turtle.digUp() end
                    turtle.back()
                end
                inspectUp()
                if(contain(table["name"])) then turtle.digUp() end
                turtle.back()
            end
            turtle.turnLeft()
            inspectDown()
            if(contain(table["name"])) then 
                turtle.digDown() 
                moveDownProtect()
                inspect()
                if(contain(table["name"])) then turtle.dig() end
                turtle.turnRight()
                inspect()
                if(contain(table["name"])) then
                    turtle.dig()
                    moveForwardProtectDig()
                    inspectDown()
                    if(contain(table["name"])) then turtle.digDown() end
                    inspect()
                    if(contain(table["name"])) then
                        turtle.dig()
                        moveForwardProtectDig()
                        inspectDown()
                        if(contain(table["name"])) then turtle.digDown() end
                        inspect()
                        if(contain(table["name"])) then turtle.dig() end
                        inspectUp()
                        if(contain(table["name"])) then turtle.digUp() end
                        turtle.back()
                    end
                    inspectUp()
                    if(contain(table["name"])) then turtle.digUp() end
                    turtle.back()
                end
                turtle.turnLeft()
                inspectDown()
                if(contain(table["name"])) then turtle.digDown() end
                turtle.turnLeft()
                inspect()
                if(contain(table["name"])) then
                    turtle.dig()
                    moveForwardProtectDig()
                    inspect()
                    if(contain(table["name"])) then
                        turtle.dig()
                        moveForwardProtectDig()
                        inspect()
                        if(contain(table["name"])) then turtle.dig() end
                        inspectUp()
                        if(contain(table["name"])) then turtle.digUp() end
                        turtle.back()
                    end
                    inspectUp()
                    if(contain(table["name"])) then turtle.digUp() end
                    turtle.back()
                end
                turtle.turnRight()
                moveUpProtect()
            end
            turtle.turnLeft()
            inspect()
            if(contain(table["name"])) then 
                turtle.dig()
                moveForwardProtectDig()
                inspect()
                if(contain(table["name"])) then turtle.dig() end
                inspectUp()
                if(contain(table["name"])) then turtle.digUp() end
                turtle.back()
            end
            turtle.turnRight()
            moveUpProtect()
        end
        turtle.turnLeft()
        inspect()
        if(contain(table["name"])) then turtle.dig() end
        moveUpProtect()
        turtle.turnRight()
        blacklistRoutine()
    end
end

-- When the tunnel is done this function will be called to have the turtle return to the main operation point.
-- Also deposits all the goodies the worker has.

local function returnRoutine()
    moveDownProtect()
    turtle.turnLeft()
    turtle.turnLeft()

    local miningDepthMod = miningDepth

    for i = 1, miningDepthMod do
        digLoop = true
        while digLoop do
            if(turtle.detect()) then
                waitForBrother()
                turtle.dig()
            else
                waitForBrother()
                moveForwardProtectDig()
                digLoop = false
            end
        end
    end

    if(digSide == "Right") then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end

    for i = 1, returnForward do
        digLoop = true
        while digLoop do
            if(turtle.detect()) then
                waitForBrother()
                turtle.dig()
            else
                waitForBrother()
                moveForwardProtect()
                digLoop = false
            end
        end
    end

    waitForBrother()
    turtle.digUp()
    waitForBrother()
    moveUpProtect()
    waitForBrother()
    moveForwardProtect()
    
    for i = 1, 16 do
        turtle.select(i)
        if(turtle.getItemCount() >= 1) then
            local data = turtle.getItemDetail()
            if(contain(data["name"]) == true and containFuel(data["name"]) == false) then
                turtle.dropDown(64)
            end
        end
    end

    turtle.select(1)
    turtle.turnRight()
    waitForBrother()
    turtle.dig()
    waitForBrother()
    moveForwardProtect()
    turtle.turnLeft()
    for i = 1, 3 do
        digLoop = true
        while digLoop do
            if(turtle.detect()) then
                waitForBrother()
                turtle.dig()
            else
                waitForBrother()
                moveForwardProtect()
                digLoop = false
            end
        end
    end

    turtle.turnLeft()
    waitForBrother()
    turtle.digUp()
    moveUpProtect()
    waitForBrother()
    sleep(1)
    moveForwardProtect()
    turtle.turnLeft()

end

-- This is the bot getting ready to start it's tunnel, fueling up and going to the designated tunnel.

local function robotReset()
    waitForBrother()
    moveForwardProtectDig()
    turtle.select(16)
    turtle.suckDown(64)
    turtle.refuel(64)
    if(turtle.getFuelLevel() <= 1000) then
        local fuelLoop = true
        while fuelLoop do
            print("Out of fuel!")
            sleep(10)
            turtle.suckDown(64)
            turtle.refuel(64)
            if(turtle.getFuelLevel() >= 1000) then fuelLoop = false end
        end
    end
    for i = 1, 16 do
        turtle.select(i)
        if(turtle.getItemCount() >= 1) then
            local data = turtle.getItemDetail()
            if(containFuel(data["name"]) == true) then
                turtle.dropDown(64)
            end
        end
    end

    for i = 1, moveForward do
        digLoop = true
        while digLoop do
            if(turtle.detect()) then
                waitForBrother()
                turtle.dig()
            else
                waitForBrother()
                moveForwardProtectDig()
                digLoop = false
            end
        end
    end

    if(digSide == "Right") then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end

    waitForBrotherDown()
    turtle.digDown()
    moveDownProtect()
--    turtle.dig()   
--    moveForwardProtectDig()
end

while true do
    getData()
    robotReset()
    miningRoutine()
    markDone()
    returnRoutine()
end

