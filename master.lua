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
# This file is to be put on a turtle equipped with a modem and a pickaxe, the turtle should be fueled prior to the execution of this script. This script's main purpose is to use a
# turtle to setup a mining operation, which it will deploy 'slaves' or 'workers' at. During the setup of the mining operation, now referred to as FOB, it'll place down either
# four chests or two ender chests. The top chest will consist of fuel, which will be partially filled by the turtle it self, the remaining fuel should be deposited by either the
# workers or the user of the script. The bottom chest will be the 'Ore chest,' this will be items defined by the goodOres array which is located within the worker script.
# It is to be noted that the ender chests that are to be used are not regular ender chests, this has been made and tested with EnderStorage chests, two seperate chest codes.
# The last block to be placed will be a disk drive, which will have a disk inserted into it by the 'master turtle.' This disk drive is used to automatically load the worker
# script onto the turtles, aiding in the automation process this script strives for.
#
# After the deployment routine is done the master will than enter a waiting state, in this state it'll wait for messages from the worker turtles for them to retrieve data after
# finishing the strip mining. After all turtles are accounted for the master turtle will retrieve the disk drive, and ender chests if used, than return up to the surface.
#
# This file might be updated will general improvements or commenting, any updates will be posted to the github repo.
# If you'd like to make your own modifications you can make a pull request if you'd like the changes to be pushed to the main branch.
# Make sure to identify yourself on your revisions, a comment to show you are who changed the piece of code.
# If you'd like to take this project and take it your own way, making your own repo that's perfectly fine but do be aware this script is licened under the GPL-2.0 license.
# The copyright information in this script or the license may not be removed, but the code can be freely modified beyond that and distributed. If you're curious about the license
# there is a link further up this copyright header.
#
# If there happens to be an issue you come across you can either fix it yourself or post a issue on the 'Issues' tab of the repository this is derived from.
# (This does not always apply if this script is from a repository other than the one that is listed above.)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--]]

--These comments are random things for me to keep track of things.

--script to be put on master turtle

--slot 1: turtles
--slot 2: fuel
--slot 3: disk
--slot 4: disk drive
--slot 5: 4 chests
--slot 13-16: fuel

--IF stack isn't being used, use the following setup.
--slot 1: fuel
--slot 3: disk
--slot 4: disk drive
--slot 5: 4 chests
--slot 13-16: fuel

--If using enderchests, use these edits
--slot 5: Ender chest A (Goods chest)
--slot 6: Ender chest B (Fuel)


local x,y,z

local digInput

local modem = peripheral.wrap("left")
local event, _, senderChannel, replyChannel, message
local channel
local serverChannel
local goUpGrab
local goUpGrabLegacy

local wantedItems = {
"minecraft:coal",
"minecraft:coal_block"
}

term.clear()
term.setCursorPos(1,1)

print("Make sure to fuel this turtle!")
print("Make sure to fuel this turtle!")
print("Make sure to fuel this turtle!")
print("Make sure to fuel this turtle!")
print("Make sure to fuel this turtle!")
print("Make sure to fuel this turtle!")
print("To refuel, hold Ctrl+T and type 'refuel all'")
print("With fuel in the first slot.")
print("Press enter to continue.")

read()

local gpsAns
local gpsLoop = true

while gpsLoop do
    local trigger = false
    term.clear()
    term.setCursorPos(1,1)
    print("Notice:")
    print("GPS is a system that must be made in the world.")
    print("(Google this if you're curious)")
    print("\n")
    io.write("Are you using GPS? (Y/N): ")
    gpsAns = string.lower(read())
    if(gpsAns == "y") then 
        gpsAns = 1 
        gpsLoop = false 
        trigger = true
    end

    if(gpsAns == "n") then 
        gpsAns = 2 
        gpsLoop = false
        trigger = true
    end

    if(stackPlace ~= "y" and trigger == false) then print("Invalid selection.") end
    if(stackPlace ~= "n" and trigger == false) then print("Invalid selection.") end

end

if(gpsAns == 2) then
    while not y do
        term.clear()
        term.setCursorPos(1,1)
        io.write("What's my Y level?: ")
        y = tonumber(read())
        if not y then print ("Please input a valid number!") sleep(2) end
    end
else
    x,y,z = gps.locate()
end

local enderPlace
local enderLoop = true

while enderLoop do
    local trigger = false
    term.clear()
    term.setCursorPos(1,1)
    print("Warning:")
    print("This does not work with normal ender chests.")
    print("This will only work with EnderStorage ender chests.")
    io.write("Are you using ender chests? (Y/N): ")
    enderPlace = string.lower(read())
    if(enderPlace == "y") then 
        enderPlace = 1 
        enderLoop = false 
        trigger = true
        read()
    end

    if(enderPlace == "n") then 
        enderPlace = 2 
        enderLoop = false
        trigger = true
    end

    if(enderPlace ~= "y" and trigger == false) then print("Invalid selection.") end
    if(enderPlace ~= "n" and trigger == false) then print("Invalid selection.") end

end

while not digInput do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Dig level: ")
    digInput = tonumber(read())
    if not digInput then print ("Please input a valid number!") sleep(2) end
end

local loopChannel = true
while loopChannel do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Transmit channel (Master only): ")
    channel = tonumber(read())
    if(channel >= 65536) then print("Channel number out of bounds, must be within 1-65535") sleep(2) end
    if(channel <= 0) then print("Channel number out of bounds, must be within 1-65535") sleep(2) else loopChannel = false end
end

local loopChannel2 = true
while loopChannel2 do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Transmit channel (Server): ")
    serverChannel = tonumber(read())
    if(serverChannel >= 65536) then print("Channel number out of bounds, must be within 1-65535") sleep(2) end
    if(serverChannel <= 0) then print("Channel number out of bounds, must be within 1-65535") sleep(2) else loopChannel2 = false end
end

local stackPlace
local stackLoop = true

while stackLoop do
    local trigger = false
    term.clear()
    term.setCursorPos(1,1)
    io.write("Are you using stacked turtles?(Y/N): ")
    stackPlace = string.lower(read())
    if(stackPlace == "y") then 
        stackPlace = 1 
        stackLoop = false 
        trigger = true
    end

    if(stackPlace == "n") then 
        stackPlace = 2 
        stackLoop = false
        trigger = true
        print("Make sure to fill a chest left of the turtle with the unstacked, unique turtles.")
        io.write("Press enter to continue.")
        read()
    end

    if(stackPlace ~= "y" and trigger == false) then print("Invalid selection.") end
    if(stackPlace ~= "n" and trigger == false) then print("Invalid selection.") end

end

local useTurtles
while not useTurtles do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Amount of turtles to be used: ")
    useTurtles = tonumber(read())
    if not useTurtles then print ("Please input a valid number!") sleep(2) end
end

if(stackPlace == "n") then
    term.clear()
    term.setCursorPos(1,1)
    print("Slot 1: Fuel (Even to the amount of turtles)")
    print("Slot 3: Disk (loaded with turtle script)")
    print("Slot 4: Disk drive")
    if(enderPlace == 2) then
        print("Slot 5: Chests x4")
    else
        print("Slot 5: Ender chest (Ore)")
        print("Slot 6: Ender chest (Fuel)")
    end
    print("Slot 13-16: Fuel")
    print("(Spread fuel between the slots if needed)")
    io.write("Press enter to continue.")
    read()
    term.clear()
    term.setCursorPos(1,1)
else
    term.clear()
    term.setCursorPos(1,1)
    print("Slot 1: Turtles")
    print("Slot 2: Fuel (even to the amount of turtles.)")
    print("Slot 3: Disk (loaded with turtle script)")
    print("Slot 4: Disk drive")
    if(enderPlace == 2) then
        print("Slot 5: Chests x4")
    else
        print("Slot 5: Ender chest (Ore)")
        print("Slot 6: Ender chest (Fuel)")
    end
    print("Slot 13-16: Fuel")
    print("(Spread fuel between the slots if needed)")
    io.write("Press enter to continue.")
    read()
    term.clear()
    term.setCursorPos(1,1)
end

if(useTurtles <= 15) then
    if(stackPlace == 2) then
        turtle.turnLeft()
        turtle.select(5)
        turtle.place()
        turtle.turnRight()
    end
end

turtle.select(1)

modem.open(channel)

local digDistance = y - digInput

for i=1, digDistance do
    turtle.digDown()
    turtle.down()
end

local function contain(element)
    for _, value in pairs(wantedItems) do
        if value == element then
            return true
        end
    end
    return false
end

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

local function moveForwardProtectDig()
    local loop = true
    local bool, string = turtle.forward()
    if(bool == false) then
        while loop do    
            bool, string = turtle.forward()
            turtle.attack()
            turtle.dig()
            sleep(1)
            if(bool == false) then loop = true else loop = false end
        end
    end
end

turtle.dig()
turtle.up()
turtle.up()
turtle.dig()
moveForwardProtectDig()
turtle.digDown()
turtle.dig()
moveForwardProtectDig()
turtle.digDown()
turtle.down()
turtle.digDown()
turtle.dig()
moveForwardProtectDig()
turtle.digDown()
turtle.dig()
moveForwardProtectDig()
turtle.digDown()
if(enderPlace == 2) then
    turtle.select(5)
    turtle.placeDown()
    turtle.back()
    turtle.placeDown()
    turtle.digUp()
    turtle.up()
    turtle.placeDown()
    turtle.back()
    turtle.placeDown()
    turtle.select(16)
    turtle.dropDown()
    turtle.select(15)
    turtle.dropDown()
    turtle.select(14)
    turtle.dropDown()
    turtle.select(13)
    turtle.dropDown()
else
    turtle.select(5)
    turtle.placeDown()
    turtle.back()
    turtle.digUp()
    turtle.up()
    turtle.back()
    turtle.select(6)
    turtle.placeDown()
end
turtle.back()
turtle.select(4)
turtle.placeDown()
turtle.select(3)
turtle.dropDown()
turtle.turnLeft()
turtle.turnLeft()
turtle.dig()
moveForwardProtectDig()
turtle.turnLeft()
turtle.turnLeft()
turtle.select(1)

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

local goUp = digDistance - 2

local turtleCount = 0

local tripCount = math.ceil(useTurtles / 15)

if(stackPlace == 1) then

    local turtleAmount = turtle.getItemCount()

    for i = 1, turtleAmount do
        local turtleLoop = true
        while turtleLoop do
            local bool, string = turtle.place()
            if(bool == true) then turtleLoop = false end
        end
        turtle.select(2)
        turtle.drop(1)
        local turtlePlaced = peripheral.wrap("front")
        turtlePlaced.turnOn()
        turtle.select(1)
        turtleCount = turtleCount + 1
        sleep(5)
    end
else

    goUpGrab = goUp - 1
    goUpGrabLegacy = goUpGrab
    tripCount = tripCount

    blacklistRoutine()

    if(useTurtles <= 15) then
        for i = 1, goUp do
            turtle.up()
        end

        turtle.turnLeft()

        for i = 2, 16 do
            turtle.select(i)
            turtle.suck()
        end

        turtle.turnRight()

        for i = 1, goUp do
            turtle.down()
        end

        for i = 2, 16 do
            turtle.select(i)
            local data = turtle.getItemDetail()
            if(data == nil) then break end
            local turtleLoop = true
            while turtleLoop do
                local bool, string = turtle.place()
                if(bool == true) then turtleLoop = false end
            end
            turtle.select(1)
            turtle.drop(1)
            local turtlePlaced = peripheral.wrap("front")
            turtlePlaced.turnOn()
            turtleCount = turtleCount + 1
            print(turtleCount)
            sleep(5)
        end
    end

    if(useTurtles > 15) then
        local goUpGrabBuffer = 1
        for i = 1, tripCount do

            goUpGrabBuffer = goUpGrabBuffer + 1

            if(goUpGrabBuffer == 2) then
                goUpGrab = goUpGrab + 1
                goUpGrabBuffer = 0
            end

            for i = 1, goUpGrab do
                turtle.up()
            end

            turtle.turnLeft()

            for i = 2, 16 do
                turtle.select(i)
                turtle.suck()
            end

            turtle.turnRight()

            for i = 1, goUpGrab do
                turtle.down()
            end

            for i = 2, 16 do
                turtle.select(i)
                local data = turtle.getItemDetail()
                if(data == nil) then break end
                local turtleLoop = true
                while turtleLoop do
                    local bool, string = turtle.place()
                    if(bool == true) then turtleLoop = false end
                end
                turtle.select(1)
                turtle.drop(1)
                local turtlePlaced = peripheral.wrap("front")
                turtlePlaced.turnOn()
                turtleCount = turtleCount + 1
                print(turtleCount)
                sleep(5)
            end
        end
    end
end

local function receive()
    print(turtleCount)
    turtleUpMod = turtleCount
    local returnValue
    local loop = true
    while loop do
        returnValue = (digDistance - 3) + turtleUpMod
        print("Waiting for message.")
        event, _, senderChannel, replyChannel, message = os.pullEvent("modem_message")
        print("Got a message.")
        if(message == "return") then modem.transmit(channel, channel, returnValue) turtleUpMod = turtleUpMod - 1 end
        if(message == "retrieve" and turtleUpMod == 0) then loop = false end
    end
end

receive()
moveForwardProtect()
turtle.select(16)
turtle.suckDown(1)
turtle.digDown()
if(enderPlace == 1) then
    moveForwardProtect()
    turtle.digDown()
    turtle.down()
    moveForwardProtect()
    moveForwardProtect()
    turtle.digDown()
    turtle.back()
    turtle.back()
    turtle.up()
    turtle.back()
end
turtle.back()

for i = 1, goUp do
    turtle.up()
end

modem.transmit(serverChannel, serverChannel, "Reboot")

print("Finished!")