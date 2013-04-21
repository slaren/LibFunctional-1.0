local version = 1
local lib = LibStub and LibStub:NewLibrary("LibFunctional-1.0", version) or {}

if not lib then return end

-- globals
local tinsert = table.insert
local tsort = table.sort
local pairs = pairs
local math_min, math_max, math_floor = math.min, math.max, math.floor


-- table functions

--- returns a list of keys in the table t
lib.keys = function(t)
	local r = {}
	for k, _ in pairs(t) do
		tinsert(r, k)
	end
	return r
end

--- returns a list of values in the table t
lib.values = function(t)
	local r = {}
	for _, v in pairs(t) do
		tinsert(r, v)
	end
	return r
end

--- returns a list of { key, value } pairs in the table t
lib.pairs = function(t)
	local r = {}
	for k, v in pairs(t) do
		tinsert(r, { k , v })
	end
	return r
end

-- list functions

--- returns a shallow copy of the list l
lib.clone = function(l)
	local r = {}
	for i = 1, #l do
		r[i] = l[i]
	end
	return r
end

--- calls function fn on each value
lib.each = function(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		fn(v)
	end
	return l
end
lib.for_each = lib.each

--- returns a new list with the results of fn applied to all items in a list
lib.map = function(l, fn)
	local r = {}
	local len = #l
	for i = 1, len do
		r[i] = fn(l[i])
	end
	return r
end

--- return a list of values in the list l that pass a truth test fn
lib.filter = function(l, fn)
	local r = {}
	local len = #l
	for i = 1, len do
		if fn(l[i]) then
			tinsert(r, l[i])
		end
	end
	return r
end

--- reverse
lib.reverse = function(l)
	local r = {}
	local len = #l
	for i = 1, len do
		r[i] = l[len - i + 1]
	end
	return r
end

--- returns the first value in list l that passes the truth test fn
lib.find = function(l, fn)
	local r = {}
	local len = #l
	for i = 1, len do
		local v = l[i]
		if fn(v) then
			return v
		end
	end
end

--- returns true if the value v is present in the list l, false otherwise
lib.contains = function(l, v)
	local r = {}
	local len = #l
	for i = 1, len do
		if l[i] == v then
			return true
		end
	end
	return false
end

--- performs a binary search on list l for value v
lib.sorted_index = function(l, v)
	local lo = 1
	local hi = #l
	while lo < hi do
		local mid = math_floor((lo + hi) / 2)
		local mid_v = l[mid]
		if mid_v == v then
			return mid
		elseif mid_v < v then
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	return lo
end

lib.binary_search = function(l, v)
	local i = lib.sorted_index(l, v)
	return l[i] == v and v or nil
end

lib.sorted_insert = function(l, v)
	local i = lib.sorted_index(l, v)
	tinsert(l, i, v)
end

--- returns a reduction of the list based on the left associative application of the function fn to all the value of the list l
lib.reduce = function(l, fn, initial)
	local s = initial and 1 or 2
	local r = initial and initial or l[1]
	local len = #l
	for i = s, len do
		r = fn(r, l[i])
	end
	return r
end
lib.foldl = lib.reduce

--- returns a sum of all the values in the list l
lib.sum = function(l)
	return lib.reduce(l, function(a, b) return a + b end)
end

--- returns the minimum value in the list l
lib.min = function(l)
	return lib.reduce(l, math_min)
end

--- returns the maximum value in the list l
lib.max = function(l)
	return lib.reduce(l, math_max)
end

--- performs an in-place sort of the list l
lib.sort = function(l, fn)
	tsort(l, fn)
	return l
end

--- returns a sorted copy of the list l
lib.sorted = function(l, fn)
	local r = lib.clone(l)
	tsort(r, fn)
	return r
end

--- all
lib.all = function(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		if not fn(v) then
			return false
		end
	end
	return true
end
lib.every = lib.all

--- any
lib.any = function(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		if fn(v) then
			return true
		end
	end
	return false
end
lib.some = lib.any

--- union
lib.union = function(...)
	local r = {}
	local n = select("#", ...)
	for a = 1, n do
		local l = select(a, ...)
		local len = #l
		for i = 1, len do
			tinsert(r, l[i])
		end
	end

	return r
end

--- uniq
lib.uniq = function(l, is_sorted, fn)

end

-- allows it to work as a lua module outside of wow
-- shouldn't have any side effects inside wow
return lib
