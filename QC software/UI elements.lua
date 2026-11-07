--most of this is also re-used code from previous projects, up until ~line 509

local pages = 1
local itemsPerPage = 33
local loglimit = 1200 --how much to store inside of the log before deleting entries

local LogScroll = 0 --storing scroll progress
local LogScrollBarSize = 250
local logitems = {}
local logitemscolors = {}
local lastpages = pages

White = Color(255, 255, 255)
Black = Color(0, 0, 0)
errorcolor = Color(255, 70, 100)
TextLightBlue = Color(0,191,255)
TransWhite = Color(255,255,255,100)
logcolor = Color(50,200,70)
nonexistentcolor = Color(255,0,255) -- color for log items that don't have a valid color entry

function LogString(str,color) --takes string and color, and prints it to the log
    table.insert(logitems, 1, str)
    table.insert(logitemscolors, 1, Check(color,color,White))

    local len = #logitems
    if len>loglimit then
        local item = olditems[loglimit+1]
        logitems[loglimit + 1] = nil
        logitemscolors[loglimit + 1] = nil
    end

    pages = math.floor(len/itemsPerPage) + 1
    LogScrollBarSize = ((elements.console.maxes[2] - elements.console.mins[2]) - 25)/pages

    if (pages ~= lastpages) and elements.console_scrollbar then
        local rawpos = LogScroll + (elements.console.maxes[2] - LogScrollBarSize)
        elements.console_scrollbar.mins = {elements.console.maxes[1] - 25, rawpos}
        elements.console_scrollbar.maxes = {elements.console.maxes[1] - 25, rawpos + LogScrollBarSize}
    end
    elements.console.timeOnUpdate = getTime()
    lastpages = pages
end

function ClearLog() 
    logitems = {}
    logitemscolors = {}
    local len = 0

    pages = math.floor(len/itemsPerPage) + 1
    LogScrollBarSize = ((elements.console.maxes[2] - elements.console.mins[2]) - 25)/pages

    if (pages ~= lastpages) and elements.console_scrollbar then
        --[[
        local a = maxes[2] - LogScrollBarSize --common variable
        local rawpos = clamp(a - (a - elements.console_scrollbar.initialMinsY) - (elements.console_scrollbar.firstHeldPos - my), mins[2] + 25, a)

        LogScroll = rawpos - a
        mins[2] = rawpos
        ]]
        local rawpos = LogScroll + (elements.console.maxes[2] - LogScrollBarSize)
        elements.console_scrollbar.mins = {elements.console.maxes[1] - 25,rawpos}
        elements.console_scrollbar.maxes = {elements.console.maxes[1] - 25,rawpos + LogScrollBarSize}
    end
    elements.console.timeOnUpdate = getTime()
    lastpages = pages
end

function explode(str, seperator)
    local result = {}
    for match in (str..seperator):gmatch("(.-)"..seperator) do
        table.insert(result, match)
    end
    return result
end

consoleOpen = true
elements.console = {
    ["beingHeld"] = false,
    ["timeOnOpen"] = getTime(), --(element local variable) time of which the console was opened
    ["timeOnUpdate"] = getTime(),
    ["history"] = {},

    ["fadeouttime"] = 2, --(element local variable) fade out time for hint text
    ["initialHeldPos"] = {0,0},
    ["initialMins"] = {0,0},

    ["detect"] = true, --should it be detected by checkPos()? any functions (other than render) will NOT be called if this is set to false.
    --"detect" can also be a function, that returns true/false and will be called by every checkPos() call.

    ["mins"] = {25,25},

    ["maxes"] = {25 + 800,25 + 600},

    ["sizeX"] = 800,
    ["sizeY"] = 600,

    ["onSingleLeftClick"] = function(mx,my) 
        --elements.holdingDown = "console"
        --render.rectangle("line",maxes[1] - 112,maxes[2] - 35,79,25,1)
        --local sizeX = elements.console.sizeX
        --local sizeY = elements.console.sizeY
        local mins = elements.console.mins
        local maxes = elements.console.maxes
        if inRangeV2Exploded(mx, my, maxes[1] - 112, maxes[2] - 35, maxes[1] - 33, maxes[2] - 10) then --if user clicked the enter button
            if elements.console_textentry then
                elements.console_textentry.on_enter()
                return
            end
        end


        if (my > (elements.console.mins[2] + 25)) then return end
        elements.console.beingHeld = true
        elements.console.initialHeldPos[1] = mx
        elements.console.initialHeldPos[2] = my
        elements.console.initialMins[1] = elements.console.mins[1]
        elements.console.initialMins[2] = elements.console.mins[2]
    end,

    ["onDoubleLeftClick"] = function()
        
    end,

    ["onHolding"] = function(mx,my)
        if (my > (elements.console.mins[2] + 25)) and (not elements.console.beingHeld) then return end --if not holding down the clickable region and is not currently being held
        --otherwise, continue (user is holding down the element on the clickable region)
        local sizeX = elements.console.sizeX
        local sizeY = elements.console.sizeY
        local mins = {elements.console.initialMins[1] + (mx - elements.console.initialHeldPos[1]),elements.console.initialMins[2] + (my - elements.console.initialHeldPos[2])}
        elements.console.mins = mins
        elements.console.maxes[1] = mins[1] + sizeX
        elements.console.maxes[2] = mins[2] + sizeY
        local maxes = elements.console.maxes
        if elements.console_scrollbar then
            elements.console_scrollbar.mins = {elements.console.maxes[1] - 25,(elements.console.maxes[2] - LogScrollBarSize)}
            elements.console_scrollbar.maxes = {elements.console.maxes[1] - 25,elements.console.maxes[2]}
        end
        if elements.console_textentry then
            elements.console_textentry.mins = {elements.console.mins[1] + 7,elements.console.maxes[2] - 35}
            elements.console_textentry.maxes = {elements.console.maxes[1] - 121,elements.console.maxes[2] - 10}
        end
    end,

    ["onHover"] = function(mx,my) --pass true if you want the selection box to show up when it's hovered over, false if to not draw it
        return false 
    end,

    ["onLetGo"] = function() --called when the user is not hovering over the element when they let go, TODO: on rescale console window, update itemsPerPage
        elements.console.beingHeld = false
    end,

    ["onValidLetGo"] = function() --call the onLetGo function, because onLetGo won't be called if the user lets go of the element while hovering over the element
        elements.console.onLetGo()
    end,


    ["render"] = function(mx,my) 
        local sizeX = elements.console.sizeX
        local sizeY = elements.console.sizeY
        local mins = elements.console.mins
        
        local maxes = elements.console.maxes
        consoleOpen = Check(elements.console.hidden, false, true)
        if (not consoleOpen) and (elements.console_scrollbar and (not elements.console_scrollbar.hidden)) then
            --elements.console_enterbutton = nil --delete temporary elements
            --elements.console_scrollbar = nil
            elements.console_scrollbar.first = nil
            elements.console_scrollbar.firstHeldPos = nil
            elements.console_scrollbar.initialMaxesY = 0
            elementslib.hideElement("console_scrollbar",502)
            elementslib.hideElement("console_textentry",503)
        end
        if not elements.console_scrollbar then
            --create if they don't already exist
            elements.console_scrollbar = {
                ["firstHeldPos"] = nil,
                ["initialMaxesY"] = 0,
                ["hidden"] = not consoleOpen, 
                ["detect"] = function() return not elements.console_scrollbar.hidden end,
                ["mins"] = {elements.console.maxes[1] - 25,(elements.console.maxes[2] - LogScrollBarSize)},
                ["maxes"] = {elements.console.maxes[1] - 25,elements.console.maxes[2]},
                ["onHolding"] = function(mx,my)
                    if not elements.console_scrollbar.firstHeldPos then
                        elements.console_scrollbar.firstHeldPos = my
                        elements.console_scrollbar.initialMinsY = elements.console_scrollbar.mins[2]
                        --LogString("initialMinsY: "..elements.console_scrollbar.mins[2]..", initial-my: "..my..", LogScroll: "..LogScroll,logcolor)
                    end
                    local maxes = elements.console.maxes
                    local mins = elements.console.mins
                    local a = maxes[2] - LogScrollBarSize --common variable
                    local rawpos = clamp(a - (a - elements.console_scrollbar.initialMinsY) - (elements.console_scrollbar.firstHeldPos - my), mins[2] + 25, a)

                    LogScroll = rawpos - a
                    --LogScroll = (-rawpos/LogScrollBarSize) * maxes[2]
                    elements.console_scrollbar.mins[2] = rawpos --LogScrollBarSize*(LogScroll + 1)
                    elements.console_scrollbar.maxes[2] = elements.console_scrollbar.mins[2] + LogScrollBarSize
                    --LogString("held down",logcolor)
                end,
                ["onHover"] = function(mx,my) return false end,
                ["onLetGo"] = function() --note: on rescale window, update itemsPerPage
                   elements.console_scrollbar.firstHeldPos = nil
                end,
                ["render"] = function(mx,my)
                    if elements.console_scrollbar.hidden == true then return end
                    if not elements.console_scrollbar.first then 
                        elements.console_scrollbar.first = true
                        LogScroll = 0
                    end

                    local mins = elements.console.mins
                    local maxes = elements.console.maxes
                    local sizeY = maxes[2] - mins[2]
                    LogScrollBarSize = (sizeY - 25)/pages
                    --LogString(elements.console_scrollbar.mins[2],logcolor)
                    
                    render.setColor(Color(255,255,255))
                    render.rectangle("fill",elements.console_scrollbar.mins[1],elements.console_scrollbar.mins[2],25,LogScrollBarSize)
                    render.setColor(Black)
                    render.rectangle("line",elements.console_scrollbar.mins[1],elements.console_scrollbar.mins[2] + 1,24,LogScrollBarSize - 2)
                    elements.console_scrollbar.mins[1] = maxes[1] - 25--,maxes[2] - LogScrollBarSize*(LogScroll + 1)}
                    elements.console_scrollbar.maxes[1] = elements.console_scrollbar.mins[1] + 25 --= {elements.console_scrollbar.mins[1] + 25,elements.console_scrollbar.mins[2] + LogScrollBarSize}
                end,
            }
            elementslib.moveElementToFront("console_scrollbar",414) --register the element
            if consoleOpen then elementslib.showElement("console_scrollbar") else elementslib.hideElement("console_scrollbar") end
        elseif consoleOpen and elements.console_scrollbar.hidden then
            elementslib.showElement("console_scrollbar")--,elements.console_scrollbar.hidden = false
        end

        if (not consoleOpen) and (not elements.console_scrollbar.hidden) then
            --elements.console_enterbutton = nil --delete temporary elements
            --elements.console_scrollbar = nil
            elements.console_scrollbar.first = nil
            elements.console_scrollbar.firstHeldPos = nil
            elements.console_scrollbar.initialMaxesY = 0
            elementslib.hideElement("console_scrollbar",502)
            if enterString == "console_textentry" then
                enterString = nil
                if key_repeat then setKeyRepeat(false) end
            end
            elementslib.hideElement("console_textentry",503)
        end
        if not elements.console_textentry then
            --create if they don't already exist 
            elements.console_textentry = {
                ["editable_text"] = true,
                ["firstHeldPos"] = nil,
                ["initialMaxesY"] = 0,
                ["contained_text"] = "",
                ["local_blink"] = false,
                ["local_blink_start"] = getTime(),
                
                ["selectionStart"] = 0,
                ["selectionEnd"] = 3,
                ["selectionAvailable"] = false,
                ["typeCursorIndex"] = 0,
                ["text_with_font"] = render.newTextBatch(monospaceFont, ""),

                ["on_enter"] = function() --when the user has the entry box selected and hits enter
                    local rawtext = elements.console_textentry.contained_text
                    if #rawtext == 0 then 
                        return
                    end
                    table.insert(elements.console.history, rawtext)
                    if #elements.console.history > 10 then
                        table.remove(elements.console.history, 1)
                    end
                    LogString("\""..rawtext.."\"", Color(50,255,100)) --show what they typed
                    local commands = explode(rawtext,";")
                    if #commands == 0 then 
                        commands = {rawtext}
                    end
                    for i=1, #commands do
                        local rawtext = commands[i]
                        local command = string.find(rawtext," ")
                        if command then --if not just the command name is present
                            command = string.sub(rawtext,1,command - 1)
                        else --just the command
                            command = string.sub(rawtext,1,#rawtext)
                        end

                        local command_function = console_func_list[command]

                        if not command_function then
                            LogString("Command \""..tostring(command).."\" not found.",Color(255,160,160))
                        else
                            --parse arguments
                            local arguments = {}
                            local arg_index = 1 --string.find(rawtext," ") --help m1 m2 m3 m4 m5
                            local last_arg_index = arg_index
                            for _=1, 200 do
                                local curr_find = string.find(rawtext," ",arg_index)
                                local next_find = string.find(rawtext," ",(curr_find or #rawtext) + 1) or (#rawtext + 1)
                                if next_find and curr_find then
                                    arg_index = curr_find + 1
                                    arguments[#arguments + 1] = stringsub(rawtext,curr_find + 1,next_find - 1)
                                else
                                    break
                                end
                            end
                            command_function(arguments)
                        end
                    end

                    elements.console_textentry.contained_text = "" --clear for next use
                    elements.console_textentry.typeCursorIndex = 0
                    enterString = nil
                    enterNum = "none"
                end,

                ["onClickOff"] = function(mx,my)
                    local mins = elements.console.mins
                    local maxes = elements.console.maxes
                    if inRangeV2Exploded(mx, my, maxes[1] - 112, maxes[2] - 35, maxes[1] - 33, maxes[2] - 10) then --if user clicked the enter button
                        if elements.console_textentry then
                            elements.console_textentry.on_enter()
                            return
                        end
                    end
                end,

                ["onSingleLeftClick"] = function() 
                    enterString = "console_textentry"
                    enterNum = enterString
                end,
                ["hidden"] = not consoleOpen, 
                ["detect"] = function() return not elements.console_textentry.hidden end,
                ["mins"] = {elements.console.mins[1] + 7,elements.console.maxes[2] - 35},
                ["maxes"] = {elements.console.mins[1] + (maxes[1] - 146),elements.console.maxes[2] - 10},
                ["onHolding"] = function(mx,my)
                    --local maxes = elements.console.maxes
                    --local mins = elements.console.mins
                end,
                ["onHover"] = function(mx,my) return false end,
                ["onLetGo"] = function() 
                end,
                ["render"] = function(mx,my) --uses blink parameter
                    if elements.console_textentry.hidden == true then return end
                    local element = elements.console_textentry
                    local mins = element.mins
                    local maxes = element.maxes
                    local active = enterString == "console_textentry"
                    local sizeX = maxes[1] - mins[1]
                    local sizeY = maxes[2] - mins[2]
                    local sel_active = elements.console_textentry.selectionAvailable
                    local blink = math.floor(((elements.console_textentry.local_blink_start - getTime())*2)%2) == 1

                    render.setColor(White)
                    render.rectangle("line",mins[1],mins[2],sizeX,sizeY,1)

                    element.text_with_font:set(element.contained_text)

                    render.draw(element.text_with_font,mins[1] + 4, mins[2] + 7)
                    if sel_active then
                        render.setColor(TransWhite)
                        render.rectangle("fill",mins[1] + 4 + element.selectionStart * font_width,mins[2] + 3,2 + (element.selectionEnd - element.selectionStart) * font_width,sizeY - 6)
                        render.setColor(White)
                    end

                    if not (key_repeat == active) then 
                        setKeyRepeat(active)
                    end

                    if blink and active then
                        render.rectangle("fill",mins[1] + 4 + element.typeCursorIndex * font_width,mins[2] + 3,2,sizeY - 6)
                    end
               end,
            }
            elementslib.moveElementToFront("console_textentry",622) --register the element
            if consoleOpen then elementslib.showElement("console_textentry") else elementslib.hideElement("console_textentry") end
        elseif consoleOpen and elements.console_textentry.hidden then
            elementslib.showElement("console_textentry")--,elements.console_scrollbar.hidden = false
        end

        if not consoleOpen then 
            return false 
        end --leave if we dont have to run

        render.setColor(Color(10,10,10,125))
        --[[local mins = elements.console.mins
        local maxes = elements.console.maxes
        local sizeX = maxes[1] - mins[1]
        local sizeY = maxes[2] - mins[2] --]]
        render.rectangle("fill",mins[1],mins[2],sizeX - 25,sizeY)--mins[1],mins[2],maxes[3],maxes[4])
        
        for i=1,#logitems do 
            local color = logitemscolors[i]
            local ypos = maxes[2] - bit.lshift(i + 3,4) - LogScroll * pages
            if (ypos > (mins[2] + 16)) and (ypos < (maxes[2] - 20)) then --out of the display range of console
                render.setColor(color or nonexistentcolor)--,(color[4] or 255) - 170*Check(i>16,1,0))) 
                render.print(logitems[i],mins[1] + 16,ypos)
            end
        end

        render.setColor(Color(5,5,5))
        render.rectangle("fill",mins[1],maxes[2] - 40,sizeX,40)

        render.setColor(Color(60,60,60))        
        render.rectangle("fill",maxes[1] - 25,mins[2],25,sizeY)

        render.setColor(White)
        render.rectangle("fill",mins[1],mins[2],sizeX,25) 

        for i=0,pages - 1 do
            local ypos = maxes[2] - LogScrollBarSize * i - 1
            render.rectangle("fill",maxes[1] - 25,ypos,25,1)
        end

        --590
        render.setColor(Color(220,255,220)) --enter button
        render.rectangle("line",maxes[1] - 112,maxes[2] - 35,79,25,1) --was maxes[1] - 88     36 - 25 = 11, 825 - 11 = 814, 814 - 735 = 79
        render.print("Enter",maxes[1] - 90,maxes[2] - 32)
        
        local localvar = elements.console.timeOnOpen
        if localvar then
            local fadeouttime = elements.console.fadeouttime
            local fade = clamp(255 - (getTime() - localvar - fadeouttime)*255,0,255)
            render.setColor(Color(20,20,255,fade))
            render.print("<-- Most recent", maxes[1] - 128, maxes[2] - 64)
            --render.print("^^^    ^^^\n     Older", maxes[1] - 120, maxes[2] - 120)
            if fade < 0.01 then 
                elements.console.timeOnOpen = nil
            end
        end

        local localvar = elements.console.timeOnUpdate
        if localvar then
            local fadeouttime = elements.console.fadeouttime
            local fade = clamp(255 - (getTime() - localvar - fadeouttime)*255,0,255)
            local count = #logitems
            local offsetX = 10
            local offsetY = 0
            render.setColor(Color(20,20,20,fade))
            render.rectangle("fill",maxes[1] - 165 - offsetX, mins[2] + 35 - offsetY,140,25)
            render.setColor(Color(20,255,255,fade))
            render.print("Pages: "..pages..", Items: ".. count, maxes[1] - 160 - offsetX, mins[2] + 40 - offsetY)
            if fade < 0.01 then 
                elements.console.timeOnUpdate = nil
            end
        end

    end, 
}
elementslib.moveElementToFront("console")
elementslib.hideElement("console")

LogScrollBarSize = ((elements.console.maxes[2] - elements.console.mins[2]) - 25)/pages

console_func_list = { --COMMANDS FUNCTION LIST [command name] = function(table containing supplied arguments)
    ["help"] = function(val2)
        local val = val2[1]
        if val and (#val > 0) then
            if console_func_list[val] then
                local desc
                local clr = Color(255,120,120)
                local func = console_description_list[val]
                local args
                if func then 
                    desc, clr, args = func()
                end
                if not desc then 
                    desc = "No description provided."
                end
                LogString(" - "..val.." "..(args or ""),Color(233,200,200))
                LogString("    - "..desc,clr)
                LogString(" ")
            else
                LogString("No such command \""..tostring(val).."\".",Red)
            end
        else
            local finalstr = "Commands list: "
            LogString(finalstr,logcolor)
            for k,v in pairs(console_func_list) do
                --if k~="help" then
                    local desc
                    local clr = Color(255,120,120)
                    local func = console_description_list[k]
                    local args
                    if func then 
                        desc,clr,args = func()
                    end
                    if not desc then 
                        desc = "No description provided."
                    end
                    LogString(" - "..k.." "..(args or ""),Color(233,200,200))
                    LogString("    - "..desc,clr)
                    LogString(" ")
                --end
            end
        end
    end,
}

console_description_list = { --[command name] = function that returns description + color of description
    ["help"] = function()
        return "lists all commands along with their description, or, prints details of a specified command",Color(200,200,200),"<optional command>"
    end,
}

--monospaced font, mostly for the console element
local monospaceFontTTF, err = love.filesystem.openNativeFile("C:\\Windows\\Fonts\\consola.ttf", "r")
if err then LogString("Could not open monospace font! error: "..err, errorcolor) end
monospaceFontTTF = monospaceFontTTF:read()
monospaceFont = love.graphics.newFont(love.filesystem.newFileData(monospaceFontTTF, "monospacefontdata")) --font with equal letter widths
local text = render.newTextBatch(monospaceFont, string.rep("A",100))
font_width = text:getWidth() / 100
local text = nil




------------------------                                                                   ------------------------
------------------------------------------------QC MACHINE ELEMENTS------------------------------------------------
------------------------                                                                   ------------------------

local ButtonHoverColor = Color(100,100,255) --what color should the hover indicator be?
local ButtonDefaultColor = Color(50,50,255) --what color should the border of buttons be?
elements.menu = { --menu bar on the top right
    ["detect"] = true,
    ["height_due_to_mouse"] = 0,
    ["buttons_hovered_over"] = 0, --ID of button being hovered over
    ["mins"] = {0, 0},
    ["maxes"] = {300, 25},
    ["onHover"] = function(mx, my)
        
    end,

    ["onHolding"] = function()
        
    end,


    ["render"] = function(mx,my)
        if elements.menu.hidden then 
            elements.menu.buttons_hovered_over = 0
            return 
        end

        local mins = elements.menu.mins
        local maxes = elements.menu.maxes
        elements.menu.height_due_to_mouse = clamp(elements.menu.height_due_to_mouse + (inRangeV2(mpos, mins, maxes) and (-dt * 200) or (dt * 200)), 0, 26)

        local xpos = mins[1]
        local ypos = mins[2] - math.floor(elements.menu.height_due_to_mouse)
        local sizeX = maxes[1] - mins[1]
        local sizeY = maxes[2] - mins[2]

        if (ypos + sizeY) < 0 then --menu is not visible, avoid draw calls
            return
        end

        local old = render.getLineStyle()
        render.setLineStyle("rough")
        render.setLineWidth(1) --set line width to 1 pixel

        --main menu bar
        render.setColor(White)
        render.rectangle("fill",xpos,ypos,sizeX,sizeY)

        render.setColor(ButtonDefaultColor)
        --render.rectangle("line",xpos + 1,ypos + 1,sizeX - 1,sizeY - 1)
        
        --buttons
        local button_spacing = sizeX / 3
        local button_x_size = button_spacing - 1
        if hoverelement == "menu" then --if mouse is on top of the menu bar
            --check which button is being hovered over
            if inRangeV2Exploded(mx, my, xpos, ypos, xpos + button_x_size, ypos + sizeY) then --button ID 1
                elements.menu.buttons_hovered_over = 1
            elseif inRangeV2Exploded(mx, my, xpos + button_spacing, ypos, xpos + button_spacing + button_x_size, ypos + sizeY) then --button ID 2
                elements.menu.buttons_hovered_over = 2
            elseif inRangeV2Exploded(mx, my, xpos + button_spacing * 2, ypos, xpos + button_spacing * 2 + button_x_size, ypos + sizeY) then --button ID 3
                elements.menu.buttons_hovered_over = 3
            else
                elements.menu.buttons_hovered_over = 0 --no button
            end
        else --mouse is not ontop of the menu
            elements.menu.buttons_hovered_over = 0 --no button
        end

        local hovered_over = elements.menu.buttons_hovered_over

        --button #1 (File) ID = 1
        local button_x, button_y = xpos, ypos
        render.rectangle("line", button_x + 1, button_y + 1, button_spacing - 1, sizeY - 1)
        render.print("File..", button_x + button_spacing / 2 - 15, button_y + 3)
        if hovered_over == 1 then 
            render.setColor(ButtonHoverColor)
            render.rectangle("fill", button_x + 1, button_y + 20, button_spacing - 2, 5)
            render.setColor(ButtonDefaultColor)
        end

        --button #2 (View) ID = 2
        button_x, button_y = xpos + button_spacing, ypos
        render.rectangle("line", button_x + 1, button_y + 1, button_spacing - 1, sizeY - 1)
        render.print("View..", button_x + button_spacing / 2 - 15, button_y + 3)
        if hovered_over == 2 then 
            render.setColor(ButtonHoverColor)
            render.rectangle("fill", button_x + 1, button_y + 20, button_spacing - 2, 5)
            render.setColor(ButtonDefaultColor)
        end

        --button #3 (Tuning) ID = 3
        button_x, button_y = xpos + button_spacing * 2, ypos
        render.rectangle("line", button_x + 1, button_y + 1, button_spacing - 1, sizeY - 1)
        render.print("Tuning..", button_x + button_spacing / 2 - 20, button_y + 3)
        if hovered_over == 3 then 
            render.setColor(ButtonHoverColor)
            render.rectangle("fill", button_x + 1, button_y + 20, button_spacing - 2, 5)
            render.setColor(ButtonDefaultColor)
        end

        render.setLineStyle(old) --reset line
    end,
}
elementslib.moveElementToFront("menu")