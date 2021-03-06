-- interpit.lua
-- Andrew S. Ng
-- Started: 2021-04-08
-- Updated: 2021-04-11
--
-- For CS 331 Spring 2021
-- Interpret AST from parseit.parse
-- Solution to Assignment 6, Exercise 2
--
-- Original interpit.lua by
-- Glenn G. Chappell
-- 2021-03-31


-- *** To run a Caracal program, use caracal.lua, which uses this file.


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local interpit = {}  -- Our module


-- *********************************************************************
-- Symbolic Constants for AST
-- *********************************************************************


local STMT_LIST    = 1
local WRITE_STMT   = 2
local RETURN_STMT  = 3
local ASSN_STMT    = 4
local FUNC_CALL    = 5
local FUNC_DEF     = 6
local IF_STMT      = 7
local FOR_LOOP     = 8
local STRLIT_OUT   = 9
local CR_OUT       = 10
local DQ_OUT       = 11
local CHAR_CALL    = 12
local BIN_OP       = 13
local UN_OP        = 14
local NUMLIT_VAL   = 15
local BOOLLIT_VAL  = 16
local READNUM_CALL = 17
local SIMPLE_VAR   = 18
local ARRAY_VAR    = 19


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    assert(type(s) == "string")

    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return tonumber(s) end)

    -- Return integer value, or 0 on error.
    if success then
        if value == nil then
            return 0
        else
            return numToInt(value)
        end
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    assert(type(n) == "number")

    return tostring(n)
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end


-- astToStr
-- Given an AST, produce a string holding the AST in (roughly) Lua form,
-- with numbers replaced by names of symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
--
-- THIS FUNCTION IS INTENDED FOR USE IN DEBUGGING ONLY!
-- IT SHOULD NOT BE CALLED IN THE FINAL VERSION OF THE CODE.
function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "WRITE_STMT", "RETURN_STMT", "ASSN_STMT",
        "FUNC_CALL", "FUNC_DEF", "IF_STMT", "FOR_LOOP", "STRLIT_OUT",
        "CR_OUT", "DQ_OUT", "CHAR_CALL", "BIN_OP", "UN_OP",
        "NUMLIT_VAL", "BOOLLIT_VAL", "READNUM_CALL", "SIMPLE_VAR",
        "ARRAY_VAR"
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end


-- *********************************************************************
-- Primary Function for Client Code
-- *********************************************************************


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding Caracal variables & functions
--             - AST for function xyz is in state.f["xyz"]
--             - Value of simple variable xyz is in state.v["xyz"]
--             - Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             - incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             - outcall(str) outputs str with no added newline
--             - To print a newline, do outcall("\n")
-- Return Value:
--   state, updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.


    -- Forward declare local functions
    local interp_stmt_list
    local interp_stmt
    local eval_expr
    local get_lvalue
    local set_lvalue


    -- interp_stmt_list
    -- Given the ast for a statement list, execute it.
    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end


    -- interp_stmt
    -- Given the ast for a statement, execute it.
    function interp_stmt(ast)
        if ast[1] == WRITE_STMT then
            for i = 2, #ast do
                if ast[i][1] == STRLIT_OUT then
                    local str = ast[i][2]
                    outcall(str:sub(2, str:len()-1))
                elseif ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == DQ_OUT then
                    outcall("\"")
                elseif ast[i][1] == CHAR_CALL then
                    local n = eval_expr(ast[i][2])
                    if (n < 0) or (n > 255) then
                        n = 0
                    end
                    outcall(string.char(n))
                else  -- Expression
                    local val = eval_expr(ast[i])
                    outcall(numToStr(val))
                end
            end
        elseif ast[1] == RETURN_STMT then
            state.v["return"] = eval_expr(ast[2])
        elseif ast[1] == FUNC_DEF then
            local funcname = ast[2]
            local funcbody = ast[3]
            state.f[funcname] = funcbody
        elseif ast[1] == FUNC_CALL then
            local funcname = ast[2]
            local funcbody = state.f[ast[2]]
            if funcbody == nil then
                funcbody = { STMT_LIST }
            end
            interp_stmt_list(funcbody)
        elseif ast[1] == ASSN_STMT then
            set_lvalue(ast[2], eval_expr(ast[3]))
        elseif ast[1] == IF_STMT then
            for i = 2, #ast, 2 do
                if ast[i][1] == STMT_LIST then
                    interp_stmt_list(ast[i])
                    break
                elseif eval_expr(ast[i]) ~= 0 then
                    interp_stmt_list(ast[i+1])
                    break
                end
            end
        else  -- For loop
            local init = ast[2]
            local cond = ast[3]
            local inc  = ast[4]
            local body = ast[5]
            if #init ~= 0 then
                interp_stmt(init)
            end
            while true do
                if #cond ~= 0 then
                    if eval_expr(cond) == 0 then
                        break
                    end
                end
                interp_stmt_list(body)
                if #inc ~= 0 then
                    interp_stmt(inc)
                end
            end
        end
    end


    -- eval_expr
    -- Given the AST for an expression, evaluate it and return the
    -- value.
    function eval_expr(ast)
        local result

        if ast[1] == NUMLIT_VAL then
            result = strToNum(ast[2])
        elseif ast[1] == SIMPLE_VAR then
            result = get_lvalue(ast)
        elseif ast[1] == ARRAY_VAR then
            result = get_lvalue(ast)
        elseif ast[1] == BOOLLIT_VAL then
            result = boolToInt(ast[2] == "true")
        elseif ast[1] == FUNC_CALL then
            local funcname = ast[2]
            local funcbody = state.f[ast[2]]
            if funcbody == nil then
                funcbody = { STMT_LIST }
            end
            interp_stmt_list(funcbody)
            result = get_lvalue({ SIMPLE_VAR, "return" })
        elseif ast[1] == READNUM_CALL then
            result = strToNum(incall())
        elseif type(ast[1]) == "table" then
            if ast[1][1] == UN_OP then
                local op = ast[1][2]
                local rhs = eval_expr(ast[2])
                if op == "+" then
                    result = rhs
                elseif op == "-" then
                    result = -rhs
                elseif op == "not" then
                    result = boolToInt(not (rhs ~= 0))
                end
            elseif ast[1][1] == BIN_OP then
                local op = ast[1][2]
                local lhs = eval_expr(ast[2])
                local rhs = eval_expr(ast[3])
                if op == "+" then
                    result = numToInt(lhs + rhs)
                elseif op == "-" then
                    result = numToInt(lhs - rhs)
                elseif op == "*" then
                    result = numToInt(lhs * rhs)
                elseif op == "/" then
                    if rhs == 0 then
                        result = 0
                    else
                        result = numToInt(lhs / rhs)
                    end
                elseif op == "%" then
                    if rhs == 0 then
                        result = 0
                    else
                        result = numToInt(lhs % rhs)
                    end
                elseif op == "and" then
                    result = boolToInt((lhs ~= 0) and (rhs ~= 0))
                elseif op == "or" then
                    result = boolToInt((lhs ~= 0) or (rhs ~= 0))
                elseif op == "==" then
                    result = boolToInt(lhs == rhs)
                elseif op == "!=" then
                    result = boolToInt(lhs ~= rhs)
                elseif op == "<" then
                    result = boolToInt(lhs < rhs)
                elseif op == "<=" then
                    result = boolToInt(lhs <= rhs)
                elseif op == ">" then
                    result = boolToInt(lhs > rhs)
                elseif op == ">=" then
                    result = boolToInt(lhs >= rhs)
                end
            end
        end

        return result
    end
    

    -- get_lvalue
    -- Given the AST of an lvalue, returns its current value or
    -- 0 if it is undefined.
    function get_lvalue(ast)
        local result
        
        if ast[1] == SIMPLE_VAR then
            result = state.v[ast[2]]
            if result == nil then
                result = 0
            end
        else  -- ARRAY_VAR
            local array = state.a[ast[2]]
            local index = eval_expr(ast[3])
            if array == nil then
                array = {[index]=0}
            end
            result = array[index]
            if result == nil then
                result = 0
            end
        end
        
        return result
    end
    

    -- set_lvalue
    -- Given the AST of an lvalue, and the value it is set to,
    -- updates the state accordingly.
    function set_lvalue(ast, val)
        local var = ast[2]
        if ast[1] == SIMPLE_VAR then
            state.v[var] = val
        else  -- ARRAY_VAR
            if state.a[var] == nil then
                state.a[var] = {}
            end
            local index = eval_expr(ast[3])
            state.a[var][index] = val
        end
    end


    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return interpit

