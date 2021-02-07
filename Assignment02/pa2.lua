#!/usr/bin/env lua
-- pa2.lua
-- Andrew S. Ng
-- 2021-06-02
-- 
-- For CS 331 Spring 2021
-- Module for Assignment 2 Functions

local pa2 = {}


function pa2.filterArray(p, t)
    filtered = {}
    
    for i, v in ipairs(t) do
        if p(t[i]) then
            table.insert(filtered, v)
        end
    end
        
    return filtered
end


function pa2.concatMax(str, n)
    concat = ""
    
    while (#concat + #str <= n) do
        concat = concat .. str
    end
    
    return concat
end
    

return pa2