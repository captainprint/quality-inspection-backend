--this is mostly re-used code from my previous projects
elementslib = {} --elements module
elements = {} --the elements themselves

doubleClickThreshold = 0.3 --in seconds, how long between two clicks to register as a double click


getTime = love.timer.getTime

local elementRenderOrder = {}
elements.holdingDown = false
local eroc = 0

function inRangeV2(vec,min,max) --checks if a 2d vector is inside the range of a minimum 2d vector and maximum 2d vector, takes 3 tables structued like so: vector2D = {x, y}
    return vec[1]>=min[1] and vec[2]>=min[2] and vec[1]<=max[1] and vec[2]<=max[2] 
end

--useful if you want to avoid creating a new table for every inRangeV2 call
function inRangeV2Exploded(vecX, vecY, minX, minY, maxX, maxY) --checks if a 2d vector is inside the range of a minimum 2d vector and maximum 2d vector, without utilizing tables
    return vecX>=minX and vecY>=minY and vecX<=maxX and vecY<=maxY
end

function checkPos(pos)
    for i=1,eroc do
        local k = elementRenderOrder[tostring(i)]
        local v = elements[k or ""]
        if v then
            local detected = false
            local istbl = type(v)=="table"
            if istbl and (type(v.detect) == "function") then 
                detected = v.detect()
            elseif istbl then
                detected = v.detect
            end
            if v.hidden then
                detected = false
            end
            if detected and inRangeV2(pos,v.mins,v.maxes) then 
                return k
            end
        end
    end
    return false
end

local stringsub = string.sub

function elementslib.moveElementToFront(e) --changes render order of a specific element, call traceback for debugging
    local newOrder = {}
    eroc = eroc + 1
    for i=1,eroc do
        if elementRenderOrder[tostring(i)] == e then
            newOrder[tostring(1)] = e
        else
            newOrder[tostring(i+1)] = elementRenderOrder[tostring(i)]
        end
    end
    if newOrder[tostring(1)] ~= e then
        newOrder[tostring(1)] = e
    end
    elementRenderOrder = newOrder
end

function elementslib.hideElement(e)
    if elements[e] then
        elements[e].hidden = true
    end
end

function elementslib.showElement(e)
    if elements[e] then
        elements[e].hidden = false
    end
end

function elementslib.isHidden(e)
    return elements[e].hidden
end

function elementslib.removeElement(e) --removes an element from the render order
    local removalindex
    for i=1,eroc do
        if elementRenderOrder[tostring(i)] == e then 
            removalindex = i
        elseif removalindex and (removalindex < i) then
            elementRenderOrder[tostring(i - 1)] = elementRenderOrder[tostring(i)]
        end
    end
    eroc = eroc - 1
end

function elementslib.toggleElement(e)
    if elements[e] and (e ~= "holdingDown") then
        if elementslib.isHidden(e) then
            elementslib.showElement(e)
        else
            elementslib.hideElement(e)
        end
    else
        LogString("Cannot toggle show/hide attribute of element \""..tostring(e).."\", element does not exist or is invalid.", errorcolor)
    end
end

elementslib.key_repeat = false
setKeyRepeat = function(val) 
    elementslib.key_repeat = val
    love.keyboard.setKeyRepeat(val)
end

lastleftclicktime = 0
lastleftclick = false
enterNum = "none"
lastclick = "none"
lastsingleleftclicked = ""
function checkSingleLeftClick()
    local elmnt = checkPos(mpos) 
    local lclickfunc = elmnt and (elements[elmnt].onSingleLeftClick) or nil
    if lclickfunc then 
        lclickfunc(mpos[1],mpos[2])
    end
    if lastsingleleftclicked ~= elmnt then --user clicked off
        
        if elements[lastsingleleftclicked or ""] and elements[lastsingleleftclicked].onClickOff then
            elements[lastsingleleftclicked].onClickOff(mpos[1],mpos[2])

        end
        lastsingleleftclicked = elmnt
    end
    
    return elmnt
end


function checkDoubleLeftClick()
    local elmnt = checkPos(mpos) 
    local lclickfunc = elmnt and (elements[elmnt].onDoubleLeftClick) or nil
    if lclickfunc then 
        lclickfunc(mpos[1],mpos[2])
    end
    return elmnt
end

function checkNotValidLeftClick(elmnt)
    return not (checkPos(mpos) == elmnt)
end

unshiftedToShifted = {
	["5"] = "%",
	["6"] = "^",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")",
	["c"] = "C",
	[","] = "<",
	["."] = ">",
	["="] = "+",
    ["-"] = "_",
	["a"] = "A",
	["b"] = "B",
	["c"] = "C",
	["d"] = "D",
	["e"] = "E",
	["f"] = "F",
	["g"] = "G",
	["h"] = "H",
	["i"] = "I",
	["j"] = "J",
	["k"] = "K",
	["l"] = "L",
	["m"] = "M",
	["n"] = "N",
	["o"] = "O",
	["p"] = "P",
	["q"] = "Q",
	["r"] = "R",
	["s"] = "S",
	["t"] = "T",
	["u"] = "U",
	["v"] = "V",
	["w"] = "W",
	["x"] = "X",
	["y"] = "Y",
	["z"] = "Z",
    ["`"] =  "~",
    ["'"] = "\"",
    [";"] = ":",
    ["["] = "{",
    ["]"] = "}",
    ["\\"] = "|",
    ["/"] = "?",
    ["up"] = "up",
    ["down"] = "down",
    ["left"] = "left",
    ["right"] = "right",
}

validNumInputs = {
	["0"] = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true,
	["-"] = true,
	["="] = true,
	["."] = true,
	["*"] = true,
	["/"] = true,
	["space"] = " ",
	["("] = true,
	[")"] = true,
	["a"] = true,
	["b"] = true,
	["c"] = true,
	["d"] = true,
	["e"] = true,
	["f"] = true,
	["g"] = true,
	["h"] = true,
	["i"] = true,
	["j"] = true,
	["k"] = true,
	["l"] = true,
	["m"] = true,
	["n"] = true,
	["o"] = true,
	["p"] = true,
	["q"] = true,
	["r"] = true,
	["s"] = true,
	["t"] = true,
	["u"] = true,
	["v"] = true,
	["w"] = true,
	["x"] = true,
	["y"] = true,
	["z"] = true,
	[","] = true,
    ["`"] = true,
	["'"] = true,
    [";"] = true,
    ["["] = true,
    ["]"] = true,
    ["\\"] = true,
}


keys_held = {}

function elementslib.keyreleased(key)
    keys_held[key] = false
    local chnl = love.thread.getChannel("keys_held")
    chnl:clear()
    chnl:push({keys_held,getTime()}) --tell all threads what keys are held down again

    if (key == "lctrl") or (key == "rctrl") then
		ctrl = false
	elseif (key == "lshift") or (key == "rshift") then
		shift = false
	end
end

function elementslib.keypressed(key)

    if (key == "lctrl") or (key == "rctrl") then
		ctrl = true
	elseif (key == "lshift") or (key == "rshift") then
		shift = true
	end

    keys_held.ctrl = ctrl
    keys_held.shift = shift
    keys_held[key] = true
    local chnl = love.thread.getChannel("keys_held")
    chnl:clear()
    chnl:push({keys_held,getTime()}) --tell all threads what keys are held down again

    if enterString then --if we are in a text entry
        elements[enterString].local_blink_start = getTime()
        if shift then
			if unshiftedToShifted[key] then
                if unshiftedToShifted[key] == "left" then --shift held down + arrow keys
                    elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex - 1
                    elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > 0,elements[enterString].typeCursorIndex,0)
                    if elements[enterString].selectionAvailable ~= "left" then
                        elements[enterString].selectionEnd = elements[enterString].typeCursorIndex + 1
                        elements[enterString].selectionStart = elements[enterString].typeCursorIndex
                        elements[enterString].selectionAvailable = ((elements[enterString].selectionEnd - elements[enterString].selectionStart) ~= 0) and "left"
                    else
                        elements[enterString].selectionStart = elements[enterString].typeCursorIndex
                    end
                elseif unshiftedToShifted[key] == "up" then
                    --elements[enterString].typeCursorIndex = #elements[enterString].contained_text
                    if elements[enterString].selectionAvailable ~= "up" then
                        elements[enterString].selectionEnd = #elements[enterString].contained_text
                        elements[enterString].selectionStart = elements[enterString].typeCursorIndex
                        elements[enterString].selectionAvailable = ((elements[enterString].selectionEnd - elements[enterString].selectionStart) ~= 0) and "up"
                    else
                        --elements[enterString].selectionStart = elements[enterString].typeCursorIndex
                    end
                    elements[enterString].typeCursorIndex = #elements[enterString].contained_text
                elseif unshiftedToShifted[key] == "down" then
                    --elements[enterString].typeCursorIndex = 0
                    if elements[enterString].selectionAvailable ~= "down" then
                        elements[enterString].selectionEnd = elements[enterString].typeCursorIndex
                        elements[enterString].selectionStart = 0
                        elements[enterString].selectionAvailable = ((elements[enterString].selectionEnd - elements[enterString].selectionStart) ~= 0) and "down"
                    else
                        --elements[enterString].selectionStart = elements[enterString].typeCursorIndex
                    end
                    elements[enterString].typeCursorIndex = 0
                elseif unshiftedToShifted[key] == "right" then
                    --[[elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex + 1
                    elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex < #elements[enterString].contained_text,elements[enterString].typeCursorIndex,#elements[enterString].contained_text)
                    ]]
                    if elements[enterString].selectionAvailable ~= "right" then
                        elements[enterString].selectionStart = elements[enterString].typeCursorIndex
                        elements[enterString].typeCursorIndex = math.min(elements[enterString].typeCursorIndex + 1,#elements[enterString].contained_text)
                        elements[enterString].selectionEnd = elements[enterString].typeCursorIndex
                        elements[enterString].selectionAvailable = ((elements[enterString].selectionEnd - elements[enterString].selectionStart) ~= 0) and "right"
                    else
                        elements[enterString].typeCursorIndex = math.min(elements[enterString].typeCursorIndex + 1,#elements[enterString].contained_text)
                        elements[enterString].selectionEnd = elements[enterString].typeCursorIndex
                    end
                else --if not arrow keys, it's likely just an uppercase letter
                    local k = unshiftedToShifted[key] or ""
                    if elements[enterString].selectionAvailable then --replace all text selected with whatever is typed
                        elements[enterString].selectionAvailable = false 
                    end 
                    elements[enterString].contained_text = stringsub(elements[enterString].contained_text,1,elements[enterString].typeCursorIndex) .. k .. stringsub(elements[enterString].contained_text,elements[enterString].typeCursorIndex+1,#elements[enterString].contained_text)
                    elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex + #k
                end
			end
	    elseif validNumInputs[key] then
			local k = Check(type(validNumInputs[key]) == "string",validNumInputs[key],key)
			
            if elements[enterString].selectionAvailable then --delete all text selected, replace with new text
                elements[enterString].contained_text = stringsub(elements[enterString].contained_text,1,elements[enterString].selectionStart) .. k .. stringsub(elements[enterString].contained_text,elements[enterString].selectionEnd + 1,#elements[enterString].contained_text)
                elements[enterString].typeCursorIndex = elements[enterString].selectionEnd - #k
                elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > 0,elements[enterString].typeCursorIndex,0)
                elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > #elements[enterString].contained_text,#elements[enterString].contained_text,elements[enterString].typeCursorIndex)

                elements[enterString].selectionAvailable = false 
            else --no selection
                elements[enterString].contained_text = stringsub(elements[enterString].contained_text,1,elements[enterString].typeCursorIndex) .. k .. stringsub(elements[enterString].contained_text,elements[enterString].typeCursorIndex + 1,#elements[enterString].contained_text)
			    elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex + #k
                elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > 0,elements[enterString].typeCursorIndex,0)
                elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > #elements[enterString].contained_text,#elements[enterString].contained_text,elements[enterString].typeCursorIndex)

            end
        elseif key == "backspace" then
            if (enterNum ~= "Done") and (enterNum ~= "Error") then
                --[[ if elements[enterString] then 
                    elements[enterString].contained_text = ""
                    enterString = ""
                    enterNum = "none"
                else]]
                    --enterString = stringsub(enterString,1,#enterString - 1)
                --elements[enterString].selectionAvailable = true -- if selection available, delete everything selected
                if enterString and elements[enterString].selectionAvailable then --delete all text selected
                    elements[enterString].contained_text = stringsub(elements[enterString].contained_text,1,elements[enterString].selectionStart) .. stringsub(elements[enterString].contained_text,elements[enterString].selectionEnd + 1,#elements[enterString].contained_text)
                    elements[enterString].selectionAvailable = false 
                else --no selection
                    if enterString and (elements[enterString].typeCursorIndex > 0) then
                        elements[enterString].contained_text = stringsub(elements[enterString].contained_text,1,elements[enterString].typeCursorIndex - 1) .. stringsub(elements[enterString].contained_text,elements[enterString].typeCursorIndex + 1,#elements[enterString].contained_text)

                        elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex - 1
                        elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > 0,elements[enterString].typeCursorIndex,0)
                    end
                end
                --end
            else -- if done/error
                elements[enterString].contained_text = ""
                elements[enterString].typeCursorIndex = 0
                enterString = nil
                enterNum = "none"
            end
        elseif key == "return" then
            if enterString then
                if elements[enterString].on_enter then
                    elements[enterString].selectionAvailable = false
                    elements[enterString].on_enter()
                end
            end
        elseif key == "left" then --move cursor left
            elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex - 1
            elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex > 0,elements[enterString].typeCursorIndex,0)
        elseif key == "right" then --move cursor right
            elements[enterString].typeCursorIndex = elements[enterString].typeCursorIndex + 1
            elements[enterString].typeCursorIndex = Check(elements[enterString].typeCursorIndex < #elements[enterString].contained_text,elements[enterString].typeCursorIndex,#elements[enterString].contained_text)
        elseif key == "up" then --move cursor to end
            elements[enterString].typeCursorIndex = #elements[enterString].contained_text
        elseif key == "down" then --move cursor to start
            elements[enterString].typeCursorIndex = 0
        end
    end

end

mpos = {0,0}
one = {1}
two = {2}
if not render then 
    render = love.graphics
end
function elementslib.render()
    timerblink = math.floor((getTime()*2)%2) == 0
    local mx,my = love.mouse.getPosition()
	local mleftclick = love.mouse.isDown(one)
    dt = love.timer.getDelta()
	--local mrightclick = love.mouse.isDown(two)
	mpos[1] = mx
	mpos[2] = my

    
    if enterNum == "none" then
		if mleftclick and (not lastclicked) then
            local local_element
			if (getTime() - lastleftclicktime)>doubleClickThreshold then
				local_element = checkSingleLeftClick()
			else
				local_element = checkDoubleLeftClick()
			end
			lastleftclicktime = getTime()
			lastclicked = true
            if local_element then
                elements.holdingDown = local_element
            end
			--enterNum = "none"
		elseif not mleftclick then
			lastclick = "none"
			lastclicked = false
            --elements.holdingDown = false
		end
		--enterString = false
	else
		if mleftclick and (not lastclicked) then
			lastclicked = true
            local local_element
			if checkNotValidLeftClick(enterNum) then --pass filter to check function, if invalid left click, then escape this branch
				enterNum = "none"
                enterString = nil
			end
			if (getTime() - lastleftclicktime)<doubleClickThreshold then
				local_element = checkDoubleLeftClick()
			end
            if local_element then
                elements.holdingDown = local_element
            end
			lastleftclicktime = getTime()
		elseif not mleftclick then
			--lastclick = "none"
			lastclicked = false
            elements.holdingDown = false
		end
	end

    hoverelement = checkPos(mpos) --get element currently being hovered over
    if hoverelement then --if valid, get mins and maxes, then draw outline
        local h = elements[hoverelement].onHover --hover function
        if h then 
            h(mx,my) 
        end
        if elements[hoverelement].editable_text then
            love.mouse.setCursor(cursor_ibeam)
        else
            love.mouse.setCursor(cursor_normal)
        end
    end

    for k,v in pairs(elements) do  --iterate through all elements
        if (type(v) == "table") and v.render then
            if elements.holdingDown == k then
                if v.onHolding then v.onHolding(mx,my) end
                if not mleftclick then
                    --local element = checkPos(mpos) 
                    if (checkPos(mpos) == k) and v.onValidLetGo then --valid let go on this element
                        v.onValidLetGo()
                    elseif v.onLetGo then
                        v.onLetGo()
                    end
                    elements.holdingDown = false
                end
            end
            --v.render(mx,my)
        end
    end

    for i=0, eroc do
        local k = elementRenderOrder[tostring(eroc - i)]
        if not k then break end
        if elements[k] then
            if elements[k].render then 
                elements[k].render(mx,my,timerblink)
            end
        end
    end

end