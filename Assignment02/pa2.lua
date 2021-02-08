#!/usr/bin/env lua
-- pa2.lua
-- Andrew S. Ng
-- Started: 2021-02-06
-- Updated: 2021-02-07
-- 
-- For CS 331 Spring 2021
-- Module for Assignment 2 Functions

local pa2 = {}


function pa2.filterArray(p, t)
    local filtered = {}
    
    for i, v in ipairs(t) do
        if p(t[i]) then
            table.insert(filtered, v)
        end
    end
        
    return filtered
end


function pa2.concatMax(str, n)
    local concat = ""
    
    while (#concat + #str <= n) do
        concat = concat .. str
    end
    
    return concat
end


function pa2.collatz(k)
    local done = false
    local function iter(dummy1, dummy2)
        if done then
            return nil
        end
        
        local save_k = k
        if k == 1 then
            done = true
        elseif (k % 2) == 0 then
            k = k / 2
        else
            k = 3 * k + 1
        end
        
        return save_k
    end
    
    return iter, nil, nil
end


function pa2.substrings(s)
    coroutine.yield("")
    for len = 1, #s do
        for i = 1, #s - len + 1 do
            coroutine.yield(s:sub(i, i + len - 1))
        end
    end
end


return pa2