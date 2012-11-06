---------------------------------------------------------------------------------------------------
-- bag.lua
---------------------------------------------------------------------------------------------------
-- Bags are unordered data structures with fast access. It can only contain a value once.
---------------------------------------------------------------------------------------------------
local Bag = {}
Bag.__index = Bag

---------------------------------------------------------------------------------------------------
-- Creates and returns a new bag
function Bag:new(item, ...)
    local bag = setmetatable({}, Bag)
    bag.items = {}
    bag._size = 0
    if item then bag:insert(item, ...) end
    return bad
end

---------------------------------------------------------------------------------------------------
-- Copies and returns a new bag
function Bag:copy()
    local bag = setmetatable({items={}}, Bag)
    for k,v in pairs(self.items) do
        bag.items[k] = v
    end
    bag._size = self._size
    return bag
end

---------------------------------------------------------------------------------------------------
-- Clears the bag of all values.
function Bag:clear()
    self.items = {}
    self._size = 0
end

---------------------------------------------------------------------------------------------------
-- Returns the number of values in the bag.
function Bag:size()
    return self._size
end


---------------------------------------------------------------------------------------------------
-- Inserts new values in the bag
function Bag:insert(item, item2, ...)
    if not self.items[item] then
        self.items[item] = true
        self._size = self._size + 1
    end
    if item2 then self:insert(item2, ...)
end

---------------------------------------------------------------------------------------------------
-- Removes values from the bag.
function Bag:remove(item, item2, ...)
    if self.items[item] then
        self.items[item] = nil
        self._size = self._size - 1
    end
    if item2 then self:remove(item2, ...) end
end

---------------------------------------------------------------------------------------------------
-- Toggles values
function Bad:toggle(item, item2, ...)
    self.items[item] = not self.items[item]
    self._size = self._size + self.items[item] and 1 or -1
    if item2 then self:toggle(item2, ...) end
end

---------------------------------------------------------------------------------------------------
-- Checks if the bag contains a single value
function Bag:contains(item)
    return self.items[item]
end

---------------------------------------------------------------------------------------------------
-- Checks if the bag contains one or more values
function Bag:containsOne(...)
    for _,item in pairs({...}) do
        if self.items[item] then return true end
    end
    return false
end

---------------------------------------------------------------------------------------------------
-- Checks if the bag contains all of set of values
function Bag:containsAll(...)
    for _,item in pairs({...}) do
        if not self.items[item] then return false end
    end
    return true
end

---------------------------------------------------------------------------------------------------
-- Combines two or more bags into a new bag
function Bag:combine(...)
    local newbag = self:copy()
    for k,bag in pairs({...}) do
        for item,_ in pairs(bag.items) do
            if not self.items[item] then
                self.items[item] = true
                self._size = self._size - 1
            end
        end
    end
    return newbag
end

---------------------------------------------------------------------------------------------------
-- Iterate over all values
function Bag:iterate(retain)
    return pairs(self.items)
end

---------------------------------------------------------------------------------------------------
-- Returns the bag class
return Bag

---------------------------------------------------------------------------------------------------
-- By Casey Baxter (Kadoba) Casey_Baxter@Hotmail.com, 2012
--
-- CC0 Public Domain Dedication 
-- To the extent possible under law, the author(s) have dedicated all copyright and related and 
-- neighboring rights to this software to the public domain worldwide. This software is distributed 
-- without any warranty. 
----------------------------------------------------------------------------------------------------    
