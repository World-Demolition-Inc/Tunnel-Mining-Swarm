--[[
 _ _ _         _   _    ____                   _____           
| | | |___ ___| |_| |  |    \ ___ _____ ___   |     |___ ___   
| | | | . |  _| | . |  |  |  | -_|     | . |  |-   -|   |  _|_ 
|_____|___|_| |_|___|  |____/|___|_|_|_|___|  |_____|_|_|___|_|
                                                               
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Author: Captain Oppai
# Author Discord: Jisatsu#1987
# Github Project Repo: 
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
# This file is to be put onto a computer that is equipped with a modem, now referred to as server, it's preferable that the server's modem is a ender modem rather than a regular
# modem. This will allow the server to be kept in one place and won't have to be moved, can even be used interdimensional. The server is very simple, acting as essentially a
# counter as well as a config relay. The server will count the tunnels assigned, the required amount of tunnels, tunnels completed, the side the turtle has to mine.
# Once the counter for required amount of tunnels is equal to the amount of tunnels assigned, the server will send a complete message rather than the regular data set.
# The complete message will indicate to the turtle that it needs to activate the return routine.
#
# This file might be updated will general improvements or commenting, any updates will be posted to the github repo.
# If you'd like to make your own modifications you can make a pull request if you'd like the changes to be pushed to the main branch.
# Make sure to identify yourself on your revisions, a comment to show you are who changed the piece of code.
# If you'd like to take this project and take it your own way, making your own repo that's perfectly fine but do be aware this script is licened under the GPL-2.0 license.
# The copyright information in this script or the license may not be removed, but the code can be freely modified beyond that and distributed. If you're curious about the license
# there is a link further up this copyright header.
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--]]

local modem = peripheral.wrap("top")

local channel

local loopChannel = true

while loopChannel do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Transmit channel: ")
    channel = tonumber(read())
    if(channel >= 65536) then print("Channel number out of bounds, must be within 1-65535") sleep(2) end
    if(channel <= 0) then print("Channel number out of bounds, must be within 1-65535") sleep(2) else loopChannel = false end
end

local loopDepth = true
local wantedDepth

while loopDepth do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Tunnel depth: ")
    wantedDepth = tonumber(read())
    if(wantedDepth == nil) then print("Input not a number.") else loopDepth = false end
end

local tunnelAmount
local tunnelLoop = true

while tunnelLoop do
    term.clear()
    term.setCursorPos(1,1)
    io.write("Tunnel amount: ")
    tunnelAmount = tonumber(read())
    if(tunnelAmount == nil) then print("Input not a number.") else tunnelLoop = false end
end

term.clear()
term.setCursorPos(1,1)

modem.open(channel)
 
local event, _, senderChannel, replyChannel, message
local sideBool = false
local tunnelNumber = 1
local tunnelBuffer = -1
local tunnelDone = 0
 
local dataArray
local tunnelsAssigned = 0

local function main()
 
    event, _, senderChannel, replyChannel, message = os.pullEvent("modem_message")

    term.clear()
    term.setCursorPos(1,1)
 
    if(message == "Reboot") then
        os.reboot()
    end
    if(message == "Recall") then
        tunnelNumber = "done"
    end
    
    if(message == "Get Data") then

        if(tunnelNumber ~= "done") then
            tunnelBuffer = tunnelBuffer + 1
            sideBool = not sideBool
            if(tunnelBuffer == 2) then
                tunnelNumber = tunnelNumber + 1
                tunnelBuffer = 0
            end

        end
    
        --print(sideBool)
        --print("tunnelNumber: " .. tunnelNumber)
        --print("tunnelBuffer: " .. tunnelBuffer) 
        if(tunnelNumber ~= "done") then
            if(tunnelNumber > tunnelAmount) then tunnelNumber = "done" end
        end
        
        dataArray = {sideBool, tunnelNumber, wantedDepth}
        local dataMessage = textutils.serialise(dataArray)
        
        modem.transmit(channel,channel,dataMessage)
        if(tunnelNumber ~= "done") then
            tunnelsAssigned = tunnelsAssigned + 1
        end

    end

    if(message == "Mark done") then
        tunnelDone = tunnelDone + 1
    end

    local targetTunnels = tunnelAmount * 2

    print("Target tunnels: " .. targetTunnels)
    print("Tunnels assigned: " .. tunnelsAssigned)
    print("Tunnels complete: " .. tunnelDone)
    print("\n")
 
end
 
while true do
    main()
end