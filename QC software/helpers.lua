
function clamp(val, min, max) 
    return math.max(math.min(val,max),min) 
end

function round(val) 
    return math.floor(val + 0.5) 
end

function Check(bool, ifTrue, ifFalse) if bool then return ifTrue else return ifFalse end end

function Color(R, G, B, A)
	return {R/255, G/255, B/255, Check(A,A,255)/255}
end


local stringchar=string.char
local bitband=bit.band
local lshift=bit.lshift
local rshift=bit.rshift
local stringbyte=string.byte

function intToStr1(int) --1byte, 8bits
    return stringchar(int)
end

function intToStr2(int) --2bytes, 16bits
    str=stringchar(bitband(int,255))..stringchar(rshift(bitband(int,65280),8))
    return str
end

function intToStr3(int) --3bytes, 24bits
    str=stringchar(bitband(int,255))..stringchar(rshift(bitband(int,65280),8))..stringchar(rshift(bitband(int,16711680),16))
    return str
end

function intToStr4(int) --4bytes, 32bits
    str=stringchar(bitband(int,255))..stringchar(rshift(bitband(int,65280),8))..stringchar(rshift(bitband(int,16711680),16))..stringchar(rshift(bitband(int,4278190080),24))
    return str
end

function strToInt1(str) --character,1byte
    return stringbyte(str)
end

function strToInt2(str) --characters,2bytes
    return stringbyte(str,1,1)+lshift(stringbyte(str,2,2),8)
end

function strToInt3(str) --characters,3bytes
    return stringbyte(str,1,1)+lshift(stringbyte(str,2,2),8)+lshift(stringbyte(str,3,3),16)
end

function strToInt4(str) --characters,4bytes
    return stringbyte(str,1,1)+lshift(stringbyte(str,2,2),8)+lshift(stringbyte(str,3,3),16)+lshift(stringbyte(str,4,4),24)
end


local recursions = 0
local table_recursion_limit = 20 --how detailed a table can be 
local last_key_len = 0
function prnttbllmtd(tbl,originkey) 
    local originkeys = originkey
    for k,v in pairs(tbl) do
        if (type(v) == "table") and (k~="_G") then
            recursions = recursions + 1
            if recursions > table_recursion_limit then
                print(originkeys.." -> "..k..": recursion limit reached")
                return false
            else
                local len = #("."..k)
                originkeys = originkeys .. "."..k
                prnttbllmtd(v,originkeys)
                originkeys = string.sub(originkeys, 1, (#originkeys) - len)
            end
        else
            print(originkeys.."."..k.." = "..tostring(v))
        end
    end
    recursions = recursions - 1
end

function printTable(tbl) --prints a table
    if type(tbl) ~= "table" then 
        error("printTable: expected table, got "..type(tbl).."!")
    end
    for k,v in pairs(tbl) do
        recursions = 0
        if (type(v) == "table") and (k~="_G") then
            recursions = recursions + 1
            prnttbllmtd(v,k)
        else
            recursions = 0
            print(k.." = "..tostring(v))
        end
    end
end
