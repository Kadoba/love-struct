---------------------------------------------------------------------------------------------------
-- queue.lua
---------------------------------------------------------------------------------------------------
local Queue = {}
Queue.__index = Queue

---------------------------------------------------------------------------------------------------
-- Creates and returns a new queue
function Queue:new()
	local queue = {}
	queue.values = {}
	queue.left = 0
	queue.right = -1
	return setmetatable(queue,Queue)
end

---------------------------------------------------------------------------------------------------
-- Creates a copy of the queue
function Queue:copy()
	local queue = Queue:new()
	for k,v in pairs(self.values) do
		queue.values[k] = v
	end
	queue.left = self.left
	queue.right = self.right
	return queue
end

---------------------------------------------------------------------------------------------------
-- Clears the queue
function Queue:clear()
	self.values = {}
	self.left = 0
	self.right = -1
end

---------------------------------------------------------------------------------------------------
-- Returns the size of the queue
function Queue:size()
	return self.right - self.left + 1
end

---------------------------------------------------------------------------------------------------
-- Pushes a value to the right of the queue
function Queue:pushRight(...)
	for k, value in pairs({...}) do
		self.right = self.right + 1
		self.values[self.right] = value
	end
end

---------------------------------------------------------------------------------------------------
-- Pushes a value to the left of the queue
function Queue:pushLeft(...)
	for k, value in pairs({...}) do
		self.left = self.left - 1
		self.values[self.left] = value
	end
end

---------------------------------------------------------------------------------------------------
-- Pops a value from the right of the queue
function Queue:popRight()
	if self.right < self.left then return nil end
	local value = self.values[self.right]
	self.values[self.right] = nil
	self.right = self.right - 1
	return value
end

---------------------------------------------------------------------------------------------------
-- Pops a value from the left of the queue
function Queue:popLeft()
	if self.right < self.left then return nil end
	local value = self.values[self.left]
	self.values[self.left] = nil
	self.left = self.left + 1
	return value
end

---------------------------------------------------------------------------------------------------
-- Return the right value without removing it
function Queue:peekRight()
	return self.values[self.right]
end	

---------------------------------------------------------------------------------------------------
-- Returns the left value without removing it
function Queue:peekLeft()
	return self.values[self.left]
end	

---------------------------------------------------------------------------------------------------
-- Easier syntax for one-way queues
Queue.push = Queue.pushRight
Queue.pop = Queue.popLeft
Queue.peek = Queue.peekLeft

---------------------------------------------------------------------------------------------------
-- Iterates over all values in the queue. By default, this pops and returns all values from left to 
-- right. The retain parameter can be set to true to prevent the iteration from removing values.
-- The start parameter is the end of the queue to start the iteration from (either "left" or "right") 
function Queue:iterate(retain, start)
	if self:size() < 1 then return end
	start = start or 'left'
	local val = 0
	if start~= 'left' and start ~= 'right' then
		error( string.format('Queue:iterate(start, retain) - Unknown starting end %s.' ..
							 'Must be nil "right" or "left"', tostring(start)) )
	end
	if not retain then
		if start == 'right' then
			return function() 
				if self.left < self.right then 
					val = val+1 
					return val, self:popRight() 
				end 
			end
		else
			return function() 
				if self.left < self.right then 
					val = val+1 
					return val, self:popLeft() 
				end 
			end
		end
	else
		local current = start == 'right' and self.right or self.left
		local stop = start == 'right' and self.left or self.right
		local step = start == 'right' and -1 or 1
		stop = stop + step
		return function() 
			if current ~= stop then 
				current = current + step
				val = val + 1
				return val, self.values[current - step] 
			end 
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Returns the queue class
return Queue

---------------------------------------------------------------------------------------------------
-- By Casey Baxter (Kadoba) Casey_Baxter@Hotmail.com, 2012
--
-- CC0 Public Domain Dedication 
-- To the extent possible under law, the author(s) have dedicated all copyright and related and 
-- neighboring rights to this software to the public domain worldwide. This software is distributed 
-- without any warranty. 
----------------------------------------------------------------------------------------------------	
