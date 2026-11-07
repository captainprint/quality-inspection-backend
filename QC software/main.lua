--Main code containing all QC processing/logic
--[[
TODO:
    - live camera preview in-app
    - in-app settings (should come with UI elements such as a console), should be able to connect to the microcontroller using the UI
    - establish microcontroller communication (maybe do this after everything else is done), needs compilation of lua-rs232
    - try to find a way to reliably send data to a webpage, likely via websocket(?) (or try to mirror the Figma prototype layout that Nisha proposed in this app's UI system)

ASAP: 
    - work on getting threads to work
    - work on camera live view (see "initial tests/main.lua" for a fast live-view code example)
    - work on camera processing
    - once the 3 above are done, finish UI elements (mainly the menu), as by then, you have a plan of what it should look like
]]


local ffi = require("ffi") --C foreign function interface
local opencv = require("opencv_lua").cv --openCV binding
require("helpers") --contains some general helper functions
require("elements lib") --elements library, for UI
require("UI elements") --contains UI elements for this app 

--some commonly used functions
local render = love.graphics 
local getTime = love.timer.getTime

--colors
Background = Color(12,12,40)

--app-related variables
width, height = love.window.getMode() --grab window dimensions


function love.draw()
    collectgarbage() --prevent memory from growing indefinetely

    --simple background
    render.setColor(Background)
    render.rectangle("fill", 0, 0, width, height)



    elementslib.render() --draw elements to screen
end

function love.resize(w, h)
    width, height = w, h
end

function love.keypressed(key)
    if key == "`" then
        elementslib.toggleElement("console") --hide/show console when user presses the tilde key
    end
    elementslib.keypressed(key)
end

function love.keyreleased(key)
    elementslib.keyreleased(key)
end
