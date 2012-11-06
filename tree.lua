---------------------------------------------------------------------------------------------------
-- tree.lua
---------------------------------------------------------------------------------------------------
-- Trees are data structures that consist of hierarchical linked nodes with numerical indexes. 
-- They have a wide range of applications.
---------------------------------------------------------------------------------------------------
-- Example:
-- tree = Tree:new(2)           -- Create a tree with a width of 2
-- tree(1)(2)(1)(2):set("hi")   -- Calling the tree like a function will create and return nodes.    
-- tree[1][2][1][2]:get()       -- Returns "hi"
---------------------------------------------------------------------------------------------------

local Tree = {}
Tree.__index = Tree

---------------------------------------------------------------------------------------------------
-- Creates and returns a new tree node. All parameters are optional.
function Tree:new(width, value, parent, index)
    local tree = setmetatable({}, Tree)
    tree.width = width     -- The maximum index of children. Used in iterating
    tree.value = value     -- The value of the node
    tree.parent = parent   -- The parent node
    tree.index = index     -- The index of this node in its parent
    tree.iter = nil        -- Value used internally when iterating
    return tree
end

----------------------------------------------------------------------------------------------------
-- Sets the value for the tree node
function Tree:set(value)
    self.value = value
end

----------------------------------------------------------------------------------------------------
-- Gets the value for the tree node
function Tree:get()
    return self.value
end

----------------------------------------------------------------------------------------------------
-- Copies the tree and returns it. Optionally also attaches it to a parent.
function Tree:copy(parent, i)
    local tree = Tree:new(self.width, self.value, parent, i)
    for i=1,(self.width or #self) do
        if self[i] then 
            self[i]:copy(tree, i)
        end
    end
    return tree
end

----------------------------------------------------------------------------------------------------
-- Sets the width of the tree
function Tree:setWidth(width)
    for i = 1,self.width do
        if self[i] then self[i]:setWidth(width) end
    end
    self.width = width
end

----------------------------------------------------------------------------------------------------
-- Returns the width of the tree
function Tree:getWidth(width)
    return self.width
end

----------------------------------------------------------------------------------------------------
-- Returns the root of the tree
function Tree:getRoot()
    local node = self
    while node.parent do
        node = node.parent
    end
    return node  
end

----------------------------------------------------------------------------------------------------
-- Creates children and returns them
function Tree:newChild(i, value, i2, ...)
    i = i or #self+1
    if self[i] then self[i]:remove() end
    self[i] = Tree:new(self.width, value, self, i)
    return self[i], i2 and self:newChild(i2, ...) or nil
end

----------------------------------------------------------------------------------------------------
-- Removes the tree node from its parent and returns it
function Tree:remove()
    if self.parent then
        self.parent[self.index] = nil
        self.parent = nil
        self.index = nil
    end
    return self
end

----------------------------------------------------------------------------------------------------
-- Returns the depth of the node. Direction can be "up" or "down". Depth param is used resursively.
function Tree:getDepth(direction, depth)
    local depth = depth or 0
    if direction == "down" or direction == nil then
        local oldDepth, tmpDepth = depth
        for i=1,self.width or #self do
            if self[i] then 
                tmpDepth = self[i]:getDepth("down", oldDepth+1)
                if tmpDepth > depth then depth = tmpDepth end
            end
        end
    elseif direction == "up" then
        local node = self
        while node.parent do
            node = node.parent
            depth = depth + 1
        end
    end
    return depth
end

----------------------------------------------------------------------------------------------------
-- Moves the tree node to another parent and position. If there exists a node at the position then
-- the two nodes are swapped.
function Tree:move(parent, i)
    i = i or #parent+1
    if parent[i] then
        local other = parent[i]
        if self.parent then
            self.parent[self.index] = other
            other.parent = self.parent
            other.index = self.index
            if self.parent.width ~= other.width then other:setWidth(self.parent.width) end
        else
            parent[i]:remove()
        end
    else
        self:remove()
    end
    parent[i] = self
    self.parent = parent
    self.index = i
    if parent.width ~= self.width then self:setWidth(parent.width) end
end

----------------------------------------------------------------------------------------------------
-- Rotates the node out with its parent
function Tree:rotate(i)
    self.parent[self.index] = self[i]
    self[i] = self.parent
    self.parnet.index = self.index, self.index, self.parent.index
    self.parent.parent, self.parent = self, self.parent.parent
end

----------------------------------------------------------------------------------------------------
-- Calling the tree like a function will create and return children if they are not found.
function Tree:__call(i,...)
    if not self[i] then self:newChild(i,...) end
    return self[i]
end

----------------------------------------------------------------------------------------------------
-- Iterates over a tree. The mode can be "preorder", "inorder", "postorder" and "depth-order"
function Tree:iterate(mode, includeNil)
    local mode = mode or "inorder"  -- The traversal mode
    local n = {}                    -- return nodes
    local d = {}                    -- return depth values
    local k,i = 0,0                 -- start and end index
    local depth = -1                -- the current depth
    local traverse                  -- traversal function
    
    -- Preordered traverse. Root, Left, Right
    if mode == "preorder" then
        function traverse(node)
            if node == nil then return end
            depth = depth+1
            i = i+1
            n[i] = node
            d[i] = depth
            for j=1,node.width or #node do
                traverse(node[j])
            end
            depth = depth-1
        end
        
    -- Inordered traverse. Left, Root, Right
    elseif mode == "inorder" then
        function traverse(node)
            if node == nil then return end
            depth = depth+1
            traverse(node[1])
            i = i+1
            n[i] = node
            d[i] = depth
            for j=2,node.width or #node do
                traverse(node[j])
            end
            depth = depth-1
        end

    -- Postordered traverse. Left, Right, Root
    elseif mode == "postorder" then
        function traverse(node)
            if node == nil then return end
            depth = depth+1
            for j=1,node.width or #node do
                traverse(node[j])
            end
            i = i+1
            n[i] = node
            d[i] = depth
            depth = depth-1
        end
    
    -- Depth ordered traverse
    elseif mode == "depth-order" then
        function traverse(node)
            n[1] = node
            d[1] = 0
            k,i = 1,1
            depth = 1
            local newdepth = 0
            while k <= i do
                node = n[k]
                k = k+1
                for j=1,node.width or #node do
                    if node[j] then 
                        i = i+1
                        n[i] = node[j] 
                        d[i] = depth
                    end
                end
                if k >= newdepth then
                    depth = depth+1
                    newdepth = i+1
                end
            end
        end
        
    -- Unknown traversal mode
    else
        error('Tree:iterate() - Unknown traversal mode: ' .. mode .. 
                '\n Acceptable modes are "preorder", "inorder", "postorder", and "depth-order".')
    end
    
    -- Perform the traverse
    traverse(self)
    k = 0
    
    -- Return the iterator
    return function()
        if k >= i then return nil end
        k = k+1
        return d[k], n[k]
    end
end

return Tree
