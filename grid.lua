---------------------------------------------------------------------------------------------------
-- grid.lua
---------------------------------------------------------------------------------------------------
local Grid = {}
Grid.__index = Grid 

---------------------------------------------------------------------------------------------------
-- Creates and returns a new grid
function Grid:new()
	local grid = {}
	grid.cells = {}
	return setmetatable(grid, Grid)
end

---------------------------------------------------------------------------------------------------
-- Creates a copy of the grid and returns it
function Grid:copy()
	local grid = Grid:new()
	for x,y,v in self:iterate() do
		grid:set(x,y,v)
	end
	return grid
end

---------------------------------------------------------------------------------------------------
-- Clears the grid
function Grid:clear()
	self.cells = {}
end

---------------------------------------------------------------------------------------------------
-- Returns the number of grid elements
function Grid:size()
	local count = 0
	for _,cell in pairs(self.cells) do
		if type(cell) == "number" then
			for _,_ in pairs(cell) do
				count = count+1
			end
		end
	end
	return count
end

---------------------------------------------------------------------------------------------------
-- Gets the value of a single cell
function Grid:get(x, y)
	return self.cells[x] and self.cells[x][y] or nil
end

---------------------------------------------------------------------------------------------------
-- Sets the value of a single cell
function Grid:set(x, y, value)
	if not self.cells[x] then 
		self.cells[x] = setmetatable({}, self.cells.mt)
	end
	self.cells[x][y] = value
end


---------------------------------------------------------------------------------------------------
-- Iterate over all values in the grid using a for loop
-- Example:
-- for x, y, v in grid:iterate() do grid2:set(x, y, v) end
function Grid:iterate()
	local x, row = next(self.cells)
	if x == nil then return function() end end
	local y, val
	return function()
		repeat
			y,val = next(row,y)
			if y == nil then x,row = next(self.cells, x) end
		until (val and x and y) or (not val and not x and not y)
		return x,y,val
	end
end

---------------------------------------------------------------------------------------------------
-- Iterate over a rectangle shape. Gauranteed to be left-to-right, top-to-bottom order.
function Grid:rectangle(startX, startY, width, height, includeNil)
	local x, y = startX, startY
	return function()
		while y < startX + height do
			while x < startY + width do
				x = x+1
				if self(x-1,y) ~= nil or includeNil then 
					return x-1, y, self(x-1,y)
				end
			end
			x = startX
			y = y+1
		end
		return nil
	end
end

---------------------------------------------------------------------------------------------------
-- Iterate over a line.
function Grid:line(startX, startY, endX, endY, includeNil)	
    local dx = math.abs(endX - startX)
    local dy = math.abs(endY - startY)
    local x = startX
    local y = startY
    local incrX = endX > startX and 1 or -1 
    local incrY = endY > startY and 1 or -1 
    local err = dx - dy
	local err2 = err*2
	local i = 1+dx+dy
	local rx,ry,rv 
	local checkX = false
	return function()
		while i>0 do 
			rx,ry,rv = x,y,self(x,y)
			err2 = err*2
			checkX = not checkX		
			if err2 > -dy then
				err = err - dy
				x = x + incrX
				i = i-1
			end
			if err2 < dx then
				err = err + dx
				y = y + incrY
				i = i-1
			end
			if rx == endX and ry == endY then i = 0 end
			if rv ~= nil or includeNil then return rx,ry,rv end
		end
		return nil
	end
end

---------------------------------------------------------------------------------------------------
-- Iterates over a circle of cells
function Grid:circle(cx, cy, r, includeNil)
	cx,cy,r = math.floor(cx), math.floor(cy), math.floor(r)
	local x, y = 0, r
	local err = 1 - r
	local errX = 1
	local errY = -2 * r
	local points = {}
	local blank = {}

	local function addPoint(x,y)
		if not points[x] then points[x] = {} end
		points[x][y] = true
	end
	
	for i = cx-r, cx+r do
		addPoint(i, cy)
	end
	
	while(x < y) do
		if(err >= 0)  then
			y = y-1
			errY = errY + 2
			err = err + errY
		end
		x = x+1
		errX = errX + 2;
		err = err + errX;    
			
		for i = cx - x, cx + x do
			addPoint(i, cy + y)
			addPoint(i, cy - y)
		end
		for i = cx - y, cx + y do
			addPoint(i, cy + x)
			addPoint(i, cy - x)
		end
	end
	
	x = next(points)
	y = next(points[x])
	
	return function()
		while(x) do
			while(y) do
				cy = y
				y = next(points[x], y)
				print( "returning " .. x or "nil" .. "," .. y or "nil")
				if includeNil or self(x,cy) ~= nil then return x, cy, self(x,cy) end
			end
			x = next(points, x)
			y = next(points[x] or blank)
		end
		return nil
	end
	
end

---------------------------------------------------------------------------------------------------
-- Cleans the grid of empty rows. 
function Grid:clean()
	for key,row in pairs(self.cells) do
		if not next(row) then self.cells[key] = nil end
	end
end

---------------------------------------------------------------------------------------------------
-- This makes calling the grid as a function act like Grid.get or Grid.set depending on the number
-- of parameters.
function Grid:__call(x, y, v)
	if v == nil then
		return self:get(x,y)
	else
		self:set(x,y,v)
	end
end 

---------------------------------------------------------------------------------------------------
-- Returns the grid class
return Grid

---------------------------------------------------------------------------------------------------
-- By Casey Baxter (Kadoba) Casey_Baxter@Hotmail.com, 2012
--
-- CC0 Public Domain Dedication 
-- To the extent possible under law, the author(s) have dedicated all copyright and related and 
-- neighboring rights to this software to the public domain worldwide. This software is distributed 
-- without any warranty. 
----------------------------------------------------------------------------------------------------	