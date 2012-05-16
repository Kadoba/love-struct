---------------------------------------------------------------------------------------------------
-- init.lua
---------------------------------------------------------------------------------------------------
-- Returns the classes in a single table
local path = ({...})[1] .. "." 
local struct = {}
struct.grid = require(path .. "grid")
struct.queue = require(path .."queue")
struct.stack = require(path .. "stack")

return struct

---------------------------------------------------------------------------------------------------
-- By Casey Baxter (Kadoba) Casey_Baxter@Hotmail.com, 2012
--
-- CC0 Public Domain Dedication 
-- To the extent possible under law, the author(s) have dedicated all copyright and related and 
-- neighboring rights to this software to the public domain worldwide. This software is distributed 
-- without any warranty. 
----------------------------------------------------------------------------------------------------	