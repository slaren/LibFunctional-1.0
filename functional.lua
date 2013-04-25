local version = 1
local lib

-- allow it to work outside of wow for testing purposes
if LibStub then
	lib = LibStub:NewLibrary("LibFunctional-1.0", version)
else
	lib = {}
end

if not lib then return end

-- globals
local tinsert, tsort, tconcat = table.insert, table.sort, table.concat
local pairs, select, type, unpack, loadstring = pairs, select, type, unpack, loadstring
local math_min, math_max, math_floor, math_random = math.min, math.max, math.floor, math.random

--- Returns a list of keys in the table //t//.
-- @param t the input table.
local function keys(t)
	local r = {}
	for k, _ in pairs(t) do
		tinsert(r, k)
	end
	return r
end

--- Returns a list of values in the table //t//.
-- @param t the input table.
local function values(t)
	local r = {}
	for _, v in pairs(t) do
		tinsert(r, v)
	end
	return r
end

--- Returns a list of ##{ key, value }## pairs in the table //t//.
-- @name pairs
-- @param t the input table.
local function table_pairs(t)
	local r = {}
	for k, v in pairs(t) do
		tinsert(r, { k , v })
	end
	return r
end

--- Returns true if the table //t1// has the same keys and values than the table //t2//.
-- @paramsig t1, t2[, shallow]
-- @param t1 first table.
-- @param t2 second table.
-- @param shallow if false or omitted, tables values inside the tables are compared recursively, otherwise they are compared by their reference.
local function equal(t1, t2, shallow)
	if #t1 ~= #t2 then return false end
	for k, v in pairs(t1) do
		if type(v) == "table" and not shallow then
			if not equal(v, t2[k]) then return false end
		elseif t2[k] ~= v then return false end
	end
	return true
end

--- Returns a copy of the table //t// with its values as keys and its keys as values.
-- @param t the input table.
local function invert(t)
	local r = {}
	for k, v in pairs(t) do
		r[v] = k
	end
	return r
end

--- Returns a shallow copy of the list //l//.
-- @param l the input list.
local function clone(l)
	local r = {}
	for i = 1, #l do
		r[i] = l[i]
	end
	return r
end

--- Returns a list containing the numbers from //start// to //stop// (including //stop//) with step //step//.
-- If omitted, //start// and //step// default to 1.
-- @paramsig [start], stop[, step]
local function range(a1, a2, a3)
	local start = a2 and a1 or 1
	local stop = a2 and a2 or a1
	local step = a3 or 1
	local r = {}
	local p = 1
	for i = start, stop, step do
		r[p] = i
		p = p + 1
	end
	return r
end

--- Returns a copy of a portion of the list //l//.
-- @paramsig l, b[, e]
-- @param l the input list.
-- @param b the first index to copy. If negative, indicates an offset from the end of the list.
-- @param e optional, the last index to copy. If omitted, the list is copied through the end. If negative, indicates an offset from the end of the list.
local function slice(l, b, e)
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
local function shuffle(l)
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
local function shuffled(l)
	return shuffle(clone(l))
end

--- Returns a copy of the list //l// with any nested lists flattened to a single level.
-- @paramsig l[, shallow]
-- @param l the input list.
-- @param shallow optional, if set to true only flattens a single level
local function flatten(l, shallow, output)
	local r = output or {}
	local len = #l
	for i = 1, len do
		local v = l[i]
		if type(v) == "table" then
			local lenj = #v
			for j = 1, lenj do
				local vj = v[j]
				if type(vj) == "table" and not shallow then
					flatten(vj, shallow, r)
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

--- Calls function //fn// on each value.
-- **aliases**: //for_each//
-- @param l the input list.
-- @param fn the function called with each value.
local function each(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		fn(v)
	end
	return l
end

--- Returns a new list with the results of //fn// applied to all items in the list //l//.
-- @param l the input list.
-- @param fn the function called with each value.
local function map(l, fn)
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
local function filter(l, fn)
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
local function reverse(l)
	local r = {}
	local len = #l
	for i = 1, len do
		r[i] = l[len - i + 1]
	end
	return r
end

--- Returns true if the value //v// is present in the list //l//, false otherwise.
-- **aliases**: //elem//
-- @param l the input list.
-- @param v the value.
local function contains(l, v)
	local r = {}
	local len = #l
	for i = 1, len do
		if l[i] == v then
			return true
		end
	end
	return false
end

--- Returns the first value and its index in list //l// that is equal to any of the values passed.
-- @param l the input list.
-- @param ... one or more values to search for.
local function find_first_of(l, ...)
	local vs = { ... }
	local r = {}
	local len = #l
	for i = 1, len do
		local lv = l[i]
		if contains(vs, lv) then
			return lv, i
		end
	end
end

--- Returns the last value and its index in list //l// that is equal to any of the values passed.
-- @param l the input list.
-- @param ... one or more values to search for.
local function find_last_of(l, ...)
	local vs = { ... }
	local r = {}
	local len = #l
	for i = len, 1, -1 do
		local lv = l[i]
		if contains(vs, lv) then
			return lv, i
		end
	end
end

--- Returns the first value and its index in list //l// that passes the truth test //fn//.
-- @param l the input list.
-- @param fn the truth test function.
local function find_if(l, fn)
	local r = {}
	local len = #l
	for i = 1, len do
		local v = l[i]
		if fn(v) then
			return v, i
		end
	end
end

--- Performs a binary search on sorted list //l// for value //v// and returns the index at which value should be inserted.
-- @param l the input sorted list.
-- @param v the value to search for.
local function sorted_index(l, v)
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
local function binary_search(l, v)
	local i = sorted_index(l, v)
	if l[i] == v then
		return i
	end
end

--- Inserts a value //v// in a sorted list //l// and returns it.
-- @param l the input sorted list.
-- @param v the value to insert.
local function sorted_insert(l, v)
	local i = sorted_index(l, v)
	tinsert(l, i, v)
	return l
end

--- Returns a reduction of the list //l// based on the left associative application of the function //fn//.
-- **aliases**: //foldl//
-- @paramsig l, fn[, initial]
-- @param l the input list.
-- @param fn a function receiving two values representing the result of the previous application of this function and the next value in the list //l//.
-- @param initial an optional initial value to be passed together with the first value of the list //l// to the function //fn//. If omitted, the first call is passed the two first values in the list //l// instead.
local function reduce(l, fn, initial)
	local s = initial and 1 or 2
	local r = initial and initial or l[1]
	local len = #l
	for i = s, len do
		r = fn(r, l[i])
	end
	return r
end

--- Returns a reduction of the list //l// based on the right associative application of the function //fn//.
-- **aliases**: //foldr//
-- @paramsig l, fn[, initial]
-- @param l the input list.
-- @param fn a function receiving two values representing the result of the previous application of this function and the previous value in the list //l//.
-- @param initial an optional initial value to be passed together with the last value of the list //l// to the function //fn//. If omitted, the first call is passed the two last values in the list //l// instead.
local function reduce_right(l, fn, initial)
	local s = initial and #l or #l - 1
	local r = initial and initial or l[#l]
	for i = s, 1, -1 do
		r = fn(r, l[i])
	end
	return r
end

--- Returns a sum of all the values in the list //l//.
-- @param l the input list.
local function sum(l)
	return reduce(l, function(a, b) return a + b end)
end

--- Returns the minimum value in the list //l//.
-- @param l the input list.
local function min(l)
	return reduce(l, math_min)
end

--- Returns the maximum value in the list //l//.
-- @param l the input list.
local function max(l)
	return reduce(l, math_max)
end

--- Performs an in-place sort of the list //l//.
-- @paramsig l[, comp]
-- @param l the input list
-- @param comp an optional comparison function that receives two values and returns true when the first is less than the second.
local function sort(l, comp)
	tsort(l, comp)
	return l
end

--- Returns a sorted copy of the list //l//.
-- @paramsig l[, comp]
-- @param l the input list.
-- @param comp an optional comparison function that receives two values and returns true when the first is less than the second.
local function sorted(l, comp)
	local r = clone(l)
	tsort(r, comp)
	return r
end

--- Returns true if all the values in the list //l// satisfy the truth test //fn//, false otherwise.
-- **aliases**: //every//
-- @param l the input list.
-- @param fn the truth test function.
local function all(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		if not fn(v) then
			return false
		end
	end
	return true
end

--- Returns true if any value in the list //l// satisfies the truth test //fn//, false otherwise.
-- **aliases**: //some//
-- @param l the input list.
-- @param fn the truth test function.
local function any(l, fn)
	local len = #l
	for i = 1, len do
		local v = l[i]
		if fn(v) then
			return true
		end
	end
	return false
end

--- Returns a list containing the concatenation of all the input lists.
-- @param ... any number of input lists.
local function concat(...)
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

--- Returns a copy of the list //l// with any duplicate values removed.
-- @paramsig l[, is_sorted[, fn]]
-- @param l the input list.
-- @param is_sorted an optional argument specifying if the list is sorted, allowing to use a more efficient algorithm.
-- @param fn an optional function that is applied to each value in the list before performing the comparison.
local function uniq(l, is_sorted, fn)
	local lm = fn and map(l, fn) or l
	local r = {}
	local seen = {}
	local len = #l
	for i = 1, len do
		local v = lm[i]
		local newv = is_sorted and (i == 1 or lm[i - 1] ~= v) or not contains(seen, v)
		if newv then
			tinsert(seen, v)
			tinsert(r, l[i])
		end
	end
	return r
end

--- Returns a list containing all the different values present in the input lists.
-- @param ... any number of input lists.
local function union(...)
	return uniq(concat(...))
end

--- Returns a list constructed from the result of an iterator function.
-- @paramsig [tr, ]f, s, var
-- @param tr an optional function that is applied to the values returned by the iterator before adding them to the list.
-- If omitted, the default function packs all the values returned by the iterator into a list.
-- @param f the values returned by an iterator function.
-- @param s the values returned by an iterator function.
-- @param var the values returned by an iterator function.
local function from_iterator(...)
	local tr
	local f, s, var

	if select("#", ...) == 4 then
		tr = select(1, ...)
		f = select(2, ...)
		s = select(3, ...)
		var = select(4, ...)
	else
		tr = function(...) return { ... } end
		f = select(1, ...)
		s = select(2, ...)
		var = select(3, ...)
	end

	local function mtr(...)
		var = select(1, ...)
		if var  == nil then
			return nil
		else
			return tr(...)
		end
	end

	local r = {}
	local n = 1
	while true do
		local v = mtr(f(s, var))
		if var == nil then break end
		r[n] = v
		n = n + 1
	end

	return r
end

--- Takes any number of lists and returns a new list where each element is a list of the values in all the passed lists at that position.
-- If one list is shorter than the others, excess elements of the longer lists are discarded.
-- @param ... any number of input lists.
-- @see unzip
local function zip(...)
	local ls = { ... }
	local n = #ls
	if n == 0 then return {} end
	local len = reduce(ls, function(r, v) return math_min(r, #v) end, #ls[1])
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
-- @see zip
local function unzip(l)
	return unpack(zip(unpack(l)))
end

--- Returns a function //f// such as calling //f(p1, p2, ..pn)// is equivalent to calling //fn(arg1, arg2, .. argn, p1, p2, ..pn)//.
-- @paramsig fn, arg1[, arg2...]
-- @param fn the input function.
-- @param "arg1[, arg2...]" one or more arguments to be bound.
local function bind(fn, ...)
	local anames = tconcat(map(range(select("#", ...)), function(x) return "a"..x end), ",")
	return loadstring(
		[[return function(fn, ]] .. anames .. [[)
			return function(...)
				return fn(]] .. anames .. [[, ...)
			end
		end]])()(fn, ...)
end

--- Returns a function //f// such as calling //f(p1, p2, ..pn)// is equivalent to calling //fn(p1, p2, .. pnth, arg1, arg2, .. argn, pnth+1, pnth+2, ..pnth+n)//.
-- @paramsig fn, nth, arg1[, arg2...]
-- @param fn the input function.
-- @param nth the position of the first argument to be bound.
-- @param "arg1[, arg2...]" one or more arguments to be bound.
local function bind_nth(fn, nth, ...)
	local pnames = tconcat(map(range(nth - 1), function(x) return "p"..x end), ",")
	local anames = tconcat(map(range(select("#", ...)), function(x) return "a"..x end), ",")
	if nth > 1 then	pnames = pnames .. "," end
	return loadstring(
		[[return function(fn, ]] .. anames .. [[)
			return function(]] .. pnames .. [[ ...)
				return fn(]] .. pnames .. anames .. [[, ...)
			end
		end]])()(fn, ...)
end

-- setup library table

lib.all = all
lib.any = any
lib.binary_search = binary_search
lib.bind = bind
lib.bind_nth = bind_nth
lib.clone = clone
lib.concat = concat
lib.contains = contains
lib.each = each
lib.elem = contains
lib.equal = equal
lib.every = all
lib.filter = filter
lib.find_first_of = find_first_of
lib.find_if = find_if
lib.find_last_of = find_last_of
lib.flatten = flatten
lib.foldl = reduce
lib.foldr = reduce_right
lib.for_each = each
lib.from_iterator = from_iterator
lib.invert = invert
lib.keys = keys
lib.map = map
lib.max = max
lib.min = min
lib.pairs = table_pairs
lib.range = range
lib.reduce = reduce
lib.reduce_right = reduce_right
lib.reverse = reverse
lib.shuffle = shuffle
lib.shuffled = shuffled
lib.slice = slice
lib.some = any
lib.sort = sort
lib.sorted = sorted
lib.sorted_index = sorted_index
lib.sorted_insert = sorted_insert
lib.sum = sum
lib.union = union
lib.uniq = uniq
lib.unzip = unzip
lib.values = values
lib.zip = zip

-- allows it to work as a lua module outside of wow
-- shouldn't have any side effects inside wow
return lib
