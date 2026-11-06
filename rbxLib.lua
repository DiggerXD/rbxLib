local lib = {}

function wait(r)
    local start = os.clock()
    while (os.clock() - start) < r do end
end
function wrap(r)
    if type(r) == "table" then
        r.ChildAdded = {callbacks = {}}
        r.ChildRemoved = {callbacks = {}}

        function r.ChildRemoved:Connect(callback)
            if #self.callbacks < 1 then
                table.insert(self.callbacks, callback)
            end
        end

        function r.ChildAdded:Connect(callback)
            if #self.callbacks < 1 then
                table.insert(self.callbacks, callback)
            end
        end

        return setmetatable(r, {
            __index = lib,

            __newindex = function(self, key, value)
                local old = rawget(self, key)

                if old ~= nil and value == nil then
                    for _, callback in pairs(self.ChildRemoved.callbacks) do
                        callback(old)
                    end

                elseif old == nil and value ~= nil then
                    for _, callback in pairs(self.ChildAdded.callbacks) do
                        callback(value)
                    end
                end

                rawset(self, key, value)
            end
        })
    else
        local tbl = {
            _Value = r,
            Positive = {callbacks = {}},
            Negative = {callbacks = {}},
            Changed = {callbacks = {}}
        }

        function tbl.Positive:Connect(callback)
            if #self.callbacks < 1 then
                table.insert(self.callbacks, callback)
            end
        end

        function tbl.Negative:Connect(callback)
            if #self.callbacks < 1 then
                table.insert(self.callbacks, callback)
            end
        end

        function tbl.Changed:Connect(callback)
            if #self.callbacks < 1 then
                table.insert(self.callbacks, callback)
            end
        end

        setmetatable(tbl, {
            __index = function(self, key)
                if key == "Value" then
                    return self._Value
                end
            end,

            __newindex = function(self, key, value)
                if key == "Value" then
                    local old = self._Value

                    if old ~= value then
                        for _, callback in pairs(self.Changed.callbacks) do
                            callback(value)
                        end
                    end

                    if old <= 0 and value > 0 then
                        for _, callback in pairs(self.Positive.callbacks) do
                            callback(value)
                        end

                    elseif old > 0 and value <= 0 then
                        for _, callback in pairs(self.Negative.callbacks) do
                            callback(value)
                        end
                    end

                    self._Value = value
                else
                    rawset(self, key, value)
                end
            end
        })

        return tbl
    end
end

function lib:FindFirstChild(r)
    for x, _ in pairs(self) do
        if x == r then
            return self[x]
        end
    end
end

function lib:WaitForChild(x, r)
    wait(r)

    for y, _ in pairs(self) do
        if y == x then
            return self[y]
        end
    end
end
function lib:GetChildren()
    local result = {}

    for key, value in pairs(self) do
        if key ~= "ChildAdded" and key ~= "ChildRemoved" then
            table.insert(result, value)
        end
    end

    return result
end
function lib:SetAttribute(r, x)
    self.Attributes = self.Attributes or {}
    self.Attributes[r] = x
end

function lib:GetAttribute(r)
    if self.Attributes then
        return self.Attributes[r]
    end
end
function lib:GetAttributes()
    if self.Attributes then
        local result = {}
        for key,value in pairs(self.Attributes) do
            result[key] = value
        end
        return result
    end
end
function lib:RemoveAttribute(r)
    if self.Attributes then
        self.Attribute[r] = nil
    end
end
function lib:Clone()
    local result = {}

    for r, x in pairs(self) do
        result[r] = x
    end

    setmetatable(result, getmetatable(self))

    return result
end

function lib:Destroy()
    local keys = {}
    for key in pairs(self) do
        table.insert(keys,key)
    end
    for _,key in pairs(keys) do
        keys[key] = nil
    end
end

function lib:IsA(r)
    if type(self) == r then
        return true
    else
        return false
    end
end
function lib:GetDescendants()
    local result = {}
    local function search(tbl)
        for key,value in pairs(tbl) do
            if key ~= "ChildAdded" and key ~= "ChildRemoved" then
                table.insert(result,value)
                if type(value) == "table" then
                    search(value)
                end
            end
        end
    end
    search(self)
    return result
end
        
        
return lib