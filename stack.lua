---------------------------------------------------------------------------------------------------
-- stack.lua
---------------------------------------------------------------------------------------------------
local Stack = {}
Stack.__index = Stack

---------------------------------------------------------------------------------------------------
-- Creates and returns a new stack
function Stack:new()
    local stack = {}
    stack._size = 0
    return setmetatable(stack, Stack)
end

---------------------------------------------------------------------------------------------------
-- Copies and returns a new stack.
function Stack:copy()
    local stack = {}
    for k,v in pairs(self) do
        stack[k] = v
    end
    return setmetatable(stack, Stack)
end

---------------------------------------------------------------------------------------------------
-- Clears the stack of all values.
function Stack:clear()
    for k,v in pairs(self) do
        self[k] = nil
    end
    self._size = 0
end

---------------------------------------------------------------------------------------------------
-- Returns the number of values in the stack
function Stack:size()
    return self._size
end


---------------------------------------------------------------------------------------------------
-- Inserts a new value on top of the stack.
function Stack:push(...)
    for k, val in pairs({...}) do
        self._size = self._size + 1
        self[self._size] = val
    end
end

---------------------------------------------------------------------------------------------------
-- Removes the top value in the stack and returns it. Returns nil if the stack is empty
function Stack:pop()
    if self._size <= 0 then return nil end
    local val = self[self._size]
    self[self._size] = nil
    self._size = self._size - 1
    return val
end

---------------------------------------------------------------------------------------------------
-- Returns the top value of the stack without removing it.
function Stack:peek()
    return self[self._size]
end

---------------------------------------------------------------------------------------------------
-- Iterate over all values starting from the top. Set retain to true to keep the values from 
-- being removed.
function Stack:iterate(retain)
    local i = self:size()
    local count = 0
    return function()
        if i > 0 then 
            i = i - 1
            count = count + 1
            return count, not retain and self:pop() or self[i+1]
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Returns the stack class
return Stack

---------------------------------------------------------------------------------------------------
-- By Casey Baxter (Kadoba) Casey_Baxter@Hotmail.com, 2012
--
-- CC0 Public Domain Dedication 
-- To the extent possible under law, the author(s) have dedicated all copyright and related and 
-- neighboring rights to this software to the public domain worldwide. This software is distributed 
-- without any warranty. 
----------------------------------------------------------------------------------------------------    
