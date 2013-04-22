local version = 1
local lib = LibStub and LibStub:NewLibrary("LibFunctional-1.0", version) or {}

if not lib then return end

-- globals
local tinsert, tsort = table.insert, table.sort
local pairs, select, type, unpack = pairs, select, type, unpack
local math_min, math_max, math_floor, math_random = math.min, math.max, math.floor, math.random


--[[
TODO:
	range([start], stop[, step])
	bind(fn, arg1[, arg2...])
]]

-- table functions

--- Returns a list of keys in the table //t//.
-- @param t the input table.
lib.keys = function(t)
	local r = {}
	for k, _ in pairs(t) do
		tinsert(r, k)
	end
	return r
end

--- Returns a list of values in the table //t//.
-- @param t the input table.
lib.values = function(t)
	local r = {}
	for _, v in pairs(t) do
		tinsert(r, v)
	end
	return r
end

--- Returns a list of ##{ key, value }## pairs in the table //t//.
-- @param t the input table.
lib.pairs = function(t)
	local r = {}
	for k, v in pairs(t) do
		tinsert(r, { k , v })
	end
	return r
end

--- Returns true if //t1// has the same keys and values than //t2//.
-- @paramsig t1, t2[, shallow]
-- @param t1 first table.
-- @param t2 second table.
-- @param shallow if false or omitted, tables values inside the tables are compared recursively, otherwise they are compared by their reference.
lib.equal = function(t1, t2, shallow)
	if #t1 ~= #t2 then return false end
	for k, v in pairs(t1) do
		if type(v) == "table" and not shallow then
			if not lib.equal(v, t2[k]) then return false end
		elseif t2[k] ~= v then return false end
	end
	return true
end

-- Returns a copy of the table //t// with is values as keys and its keys as values
-- @param t the input table.
lib.invert = function(t)
	local r = {}
	for k, v in pairs(t) do
		r[v] = k
	end
	return r
end

-- list functions

--- Returns a copy of a portion of the list //l//.
-- @paramsig l, b[, e]
-- @param l the input list.
-- @param b the first index to copy. If negative, indicates an offset from the end of the list.
-- @param e optional, the last index to copy. If omitted, the list is copied through the end. If negative, indicates an offset from the end of the list.
lib.slice = function(l, b, e)
	local r = {}
	local len = #l
	b = b or 1
	e = e or len
	b = b < 0 and (len + b + 1) or b
	e = e < 0 and (len + e) or e
	for i = b, e do
		r[i - b + 1] = l[i]
	end
	return r
end

--- Shuffles the list //l// in-place using the Fisher–Yates algorithm and returns it.
-- @param l the input list.
lib.shuffle = function(l)
	local j = #l
	while (j > 0) do
		local i = math_random(j)
		local tmp = l[i]
		l[i] = l[j]
		l[j] = tmp
		j = j - 1
	end
	return l
end

--- Returns a copy of the list //l// shuffled using the Fisher–Yates algorithm.
-- @param l the input list.
lib.shuffled = function(l)
	return lib.shuffle(lib.clone(l))
end

--- Returns a copy of the list //l// with any nested lists flattened to a single level.
-- @paramsig l[, shallow]
-- @param l the input list.
-- @param shallow optional, if set to true only flattens a single level
lib.flatten = function(l, shallow, output)
	local r = output or {}
	local len = #l
	for i = 1, len do
		local v = l[i]
		if type(v) == "table" then
			local lenj = #v
			for j = 1, lenj do
				local vj = v[j]
				if type(vj) == "table" and not shallow then
					lib.flatten(vj, shallow, r)
				else
					tinsert(r, vj)
				end
			end
		else
			tinsert(r, v)
		end
	end
	return r
end


--- Takes any number of lists and returns a new list where each element is a list of the values in all the passed lists at that position.
-- If one list is shorter than the others, excess elements of the longer lists are discarded
-- @param ... any number of input lists.
lib.zip = function(...)
	local ls = { ... }
	local n = #ls
	if n == 0 then return {} end
	local len = lib.reduce(ls, function(r, v) return math_min(r, #v) end, #ls[1])
	local r = {}
	for i = 1, len do
		local v = {}
		for j = 1, n do
			v[j] = ls[j][i]
		end
		r[i] = v
	end
	return r
end

--- Undoes a zip operation.
-- @param l a list of lists.
lib.unzip = function(l)
	return unpack(lib.zip(unpack(l)))
end

-- index_of(l, v)
-- last_index_of(l, v)
-- range([start], stop[, step])

--- Returns a shallow copy of the list //l//.
-- @param l the input list.
lib.clone = function(l)
	local r = {}
	for i = 1, #l do
		r[i] = l[i]
	end
	return r
end

--- Calls function //fn// on each value.
-- **aliases**: //for_each//
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

--- Returns a new list with the results of //fn// applied to all items in the list //l//.
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

--- Returns a list of values in the list //l// that pass a truth test //fn//.
-- @param l the input list.
-- @param fn the truth test function.
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

--- Returns a reversed copy of the list //l//.
-- @param l the input list.
lib.reverse = function(l)
	local r = {}
	local len = #l
	for i = 1, len do
		r[i] = l[len - i + 1]
	end
	return r
end

--- Returns the first value and its index in list //l// that is equal to any of the values passed.
-- @param l the input list.
-- @param ... one or more values to search for.
lib.find_first_of = function(l, ...)
	local vs = { ... }
	local r = {}
	local len = #l
	for i = 1, len do
		local lv = l[i]
		if lib.contains(vs, lv) then
			return lv, i
		end
	end
end

--- Returns the last value and its index in list //l// that is equal to any of the values passed.
-- @param l the input list.
-- @param ... one or more values to search for.
lib.find_last_of = function(l, ...)
	local vs = { ... }
	local r = {}
	local len = #l
	for i = len, 1, -1 do
		local lv = l[i]
		if lib.contains(vs, lv) then
			return lv, i
		end
	end
end

--- Returns the first value and its index in list //l// that passes the truth test //fn//.
-- @param l the input list.
-- @param fn the truth test function.
lib.find_if = function(l, fn)
	local r = {}
	local len = #l
	for i = 1, len do
		local v = l[i]
		if fn(v) then
			return v, i
		end
	end
end

--- Returns true if the value //v// is present in the list //l//, false otherwise.
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

--- Performs a binary search on sorted list //l// for value //v// and returns the index at which value should be inserted.
-- @param l the input sorted list.
-- @param v the value to search for.
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

--- Performs a binary search on sorted list //l// for value //v// and returns its index if found
-- @param l the input sorted list.
-- @param v the value to search for.
lib.binary_search = function(l, v)
	local i = lib.sorted_index(l, v)
	if l[i] == v then
		return i
	end
end

--- Inserts a value //v// in a sorted list //l// and returns it.
-- @param l the input sorted list.
-- @param v the value to insert.
lib.sorted_insert = function(l, v)
	local i = lib.sorted_index(l, v)
	tinsert(l, i, v)
	return l
end

--- Returns a reduction of the list //l// based on the left associative application of the function //fn//.
-- **aliases**: //foldl//
-- @paramsig l, fn[, initial]
-- @param l the input list.
-- @param fn a function receiving two values representing the result of the previous application of this function and the next value in the list //l//.
-- @param initial an optional initial value to be passed together with the first value of the list //l// to the function //fn//. If omitted, the first call is passed the two first values in the list //l// instead.
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

--- Returns a reduction of the list //l// based on the right associative application of the function //fn//.
-- **aliases**: //foldr//
-- @paramsig l, fn[, initial]
-- @param l the input list.
-- @param fn a function receiving two values representing the result of the previous application of this function and the previous value in the list //l//.
-- @param initial an optional initial value to be passed together with the last value of the list //l// to the function //fn//. If omitted, the first call is passed the two last values in the list //l// instead.
lib.reduce_right = function(l, fn, initial)
	local s = initial and #l or #l - 1
	local r = initial and initial or l[#l]
	for i = s, 1, -1 do
		r = fn(r, l[i])
	end
	return r
end
lib.foldr = lib.reduce_right

--- Returns a sum of all the values in the list //l//.
-- @param l the input list.
lib.sum = function(l)
	return lib.reduce(l, function(a, b) return a + b end)
end

--- Returns the minimum value in the list //l//.
-- @param l the input list.
lib.min = function(l)
	return lib.reduce(l, math_min)
end

--- Returns the maximum value in the list //l//.
-- @param l the input list.
lib.max = function(l)
	return lib.reduce(l, math_max)
end

--- Performs an in-place sort of the list //l//.
-- @paramsig l[, comp]
-- @param l the input list
-- @param comp an optional comparison function that receives two values and returns true when the first is less than the second.
lib.sort = function(l, comp)
	tsort(l, comp)
	return l
end

--- Returns a sorted copy of the list //l//.
-- @paramsig l[, comp]
-- @param l the input list.
-- @param comp an optional comparison function that receives two values and returns true when the first is less than the second.
lib.sorted = function(l, comp)
	local r = lib.clone(l)
	tsort(r, comp)
	return r
end

--- Returns true if all the values in the list //l// satisfy the truth test //fn//, false otherwise.
-- **aliases**: //every//
-- @param l the input list.
-- @param fn the truth test function.
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

--- Returns true if any value in the list //l// satisfies the truth test //fn//, false otherwise.
-- **aliases**: //some//
-- @param l the input list.
-- @param fn the truth test function.
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

--- Returns a copy of the list //l// with any duplicate values removed.
-- @paramsig l[, is_sorted[, fn]]
-- @param l the input list.
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
