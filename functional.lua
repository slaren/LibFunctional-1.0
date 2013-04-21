local version = 1
local lib = LibStub and LibStub:NewLibrary("LibFunctional-1.0", version) or {}

if not lib then return end

-- globals
local tinsert = table.insert
local tsort = table.sort
local pairs, select = pairs, select
local math_min, math_max, math_floor = math.min, math.max, math.floor


-- table functions

--- Returns a list of keys in the table t.
-- @param t the input table.
lib.keys = function(t)
	local r = {}
	for k, _ in pairs(t) do
		tinsert(r, k)
	end
	return r
end

--- Returns a list of values in the table t.
-- @param t the input table.
lib.values = function(t)
	local r = {}
	for _, v in pairs(t) do
		tinsert(r, v)
	end
	return r
end

--- Returns a list of { key, value } pairs in the table t.
-- @param t the input table.
lib.pairs = function(t)
	local r = {}
	for k, v in pairs(t) do
		tinsert(r, { k , v })
	end
	return r
end

-- list functions

--- Returns a shallow copy of the list l.
-- @param l the input list.
lib.clone = function(l)
	local r = {}
	for i = 1, #l do
		r[i] = l[i]
	end
	return r
end

--- Calls function fn on each value.
-- aliases: for_each
-- @param l the input list.
-- @param fn the function called with each value.
lib.each = function(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		fn(v)
	end
	return l
end
lib.for_each = lib.each

--- Returns a new list with the results of fn applied to all items in a list.
-- @param l the input list.
-- @param fn the function called with each value.
lib.map = function(l, fn)
	local r = {}
	local len = #l
	for i = 1, len do
		r[i] = fn(l[i])
	end
	return r
end

--- Returns a list of values in the list l that pass a truth test fn.
-- @param l the input list.
-- @param fn the function called with each value.
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

--- Returns a reversed copy of the list l.
-- @param l the input list
lib.reverse = function(l)
	local r = {}
	local len = #l
	for i = 1, len do
		r[i] = l[len - i + 1]
	end
	return r
end

--- Returns the first value in list l that passes the truth test fn.
-- @param l the input list
-- @param fn the truth test function
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

--- Returns true if the value v is present in the list l, false otherwise.
-- @param l the input list.
-- @param v the value.
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

--- Performs a binary search on list l for value v and returns it if found.
-- @param l the input list.
-- @param v the value to search for.
lib.binary_search = function(l, v)
	local i = lib.sorted_index(l, v)
	return l[i] == v and v or nil
end

--- Inserts a value v in a sorted list l.
-- @param l the input list.
-- @param v the value to insert.
lib.sorted_insert = function(l, v)
	local i = lib.sorted_index(l, v)
	tinsert(l, i, v)
end

--- Returns a reduction of the list based on the left associative application of the function fn to all the value of the list l.
-- aliases: foldl
-- @param l the input list.
-- @param fn a function receiving two values representing the result of the previous application of this function and the next value in the list l.
-- @param initial an optional initial value to be passed together with the first value of the list l to the function fn. If omitted, the first call is passed the two first values in the list l instead.
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

--- Returns a sum of all the values in the list l.
-- @param l the input list.
lib.sum = function(l)
	return lib.reduce(l, function(a, b) return a + b end)
end

--- Returns the minimum value in the list l.
-- @param l the input list.
lib.min = function(l)
	return lib.reduce(l, math_min)
end

--- Returns the maximum value in the list l.
-- @param l the input list.
lib.max = function(l)
	return lib.reduce(l, math_max)
end

--- Performs an in-place sort of the list l.
-- @param l the input list
-- @param comp an optional comparison function that receives two values and returns true when the first is less than the second
lib.sort = function(l, comp)
	tsort(l, comp)
	return l
end

--- Returns a sorted copy of the list l.
-- @param l the input list.
-- @param comp an optional comparison function that receives two values and returns true when the first is less than the second.
lib.sorted = function(l, comp)
	local r = lib.clone(l)
	tsort(r, comp)
	return r
end

--- Returns true if all the values in l satisfy the truth function fn, false otherwise.
-- aliases: every
-- @param l the input list.
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

--- Returns true if any value in l satisfies the truth function fn, false otherwise.
-- aliases: some
-- @param l the input list.
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

--- Returns a list containing the concatenation of all the input lists.
-- @param ... any number of input lists.
lib.concat = function(...)
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

--- Returns a list containing all the different values present in the input lists.
-- @param ... any number of input lists.
lib.union = function(...)
	return lib.uniq(lib.concat(...))
end

--- Returns a copy of the list l with any the duplicate values removed.
-- @param l the input list
-- @param is_sorted an optional argument specifying if the list is sorted, allowing to use a more efficient algorithm.
-- @param fn an optional function that is applied to each value in the list before performing the comparison.
lib.uniq = function(l, is_sorted, fn)
	local lm = fn and lib.map(l, fn) or l
	local r = {}
	local seen = {}
	local len = #l
	for i = 1, len do
		local v = lm[i]
		local newv = is_sorted and (i == 1 or lm[i - 1] ~= v) or not lib.contains(seen, v)
		if newv then
			tinsert(seen, v)
			tinsert(r, l[i])
		end
	end

	return r
end

-- allows it to work as a lua module outside of wow
-- shouldn't have any side effects inside wow
return lib
