lib = require("functional");

(function()
	local function dump(t)
		return "{ " .. table.concat(t, ", ") .. " }"
	end

	local function teq(t1, t2)
		if #t1 ~= #t2 then return false end
		for k, v in pairs(t1) do
			if type(v) == "table" then
				if not teq(v, t2[k]) then return false end
			elseif t2[k] ~= v then return false end
		end
		return true
	end

	local function test(t1, t2)
		if not teq(t1, t2) then
			print("test failed:")
			print("\texpected: " .. dump(t1))
			print("\tgot: " .. dump(t2))
			return false
		end
		return true
	end

	local fn = lib

	local lst = { 1, 3, 2, 5, 4 }
	local tbl = { ["a"] = 1, ["b"] = 2, ["c"] = 3, ["d"] = 4, ["e"] = 5 }

	-- self sanity check
	assert(false == teq({1, 2, 3}, {1, 5, 7}))
	assert(true == teq({1, 2, 3}, {1, 2, 3}))

	-- all
	assert(true == fn.all(lst, function(v) return v > 0 end))
	assert(false == fn.all(lst, function(v) return v > 1 end))

	-- any
	assert(true == fn.any(lst, function(v) return v > 3 end))
	assert(false == fn.any(lst, function(v) return v > 10 end))

	-- binary_search
	assert(1 == fn.binary_search(fn.sorted(lst), 1))
	assert(2 == fn.binary_search(fn.sorted(lst), 2))
	assert(3 == fn.binary_search(fn.sorted(lst), 3))
	assert(4 == fn.binary_search(fn.sorted(lst), 4))
	assert(5 == fn.binary_search(fn.sorted(lst), 5))
	assert(nil == fn.binary_search(fn.sorted(lst), 6))

	-- clone
	assert(test(lst, fn.clone(lst)))

	-- concat
	assert(test({}, fn.concat()))
	assert(test({}, fn.concat({}, {})))
	assert(test({ 1, 2, 3, 4, 5 }, fn.concat({ 1, 2, 3, 4, 5 })))
	assert(test({ 1, 2, 3, 4, 5 }, fn.concat({ 1, 2 }, { 3, 4, 5 })))
	assert(test({ 1, 2, 3, 4, 5 }, fn.concat({ 1, 2 }, { 3, 4 } , { 5 })))

	-- contains
	assert(true == fn.contains(lst, 5))
	assert(false == fn.contains(lst, 6))

	-- each
	local n = 0
	fn.each(lst, function(v) n = n + v end)
	assert(n == fn.sum(lst))

	-- filter
	assert(test({ 3, 2, 5, 4 }, fn.filter(lst, function(v) return v > 1 end)))

	-- find
	assert(5 == fn.find(lst, function(v) return v == 5 end))
	assert(nil == fn.find(lst, function(v) return v == 6 end))

	-- keys
	assert(test({ "a", "b", "c", "d", "e" }, fn.sorted(fn.keys(tbl))))

	-- map
	assert(test({ 2, 6, 4, 10, 8 }, fn.map(lst, function(v) return v * 2 end)))

	-- max
	assert(5 == fn.max(lst))

	-- min
	assert(1 == fn.min(lst))

	-- pairs
	assert(test({ { "a", 1 }, { "b", 2 } }, fn.pairs({ ["a"] = 1, ["b"] = 2 })))

	-- reduce
	assert(nil == fn.reduce({}, function(r, v) return r + v end))
	assert(5 == fn.reduce({ 5 }, function(r, v) return r + v end))
	assert(15 == fn.reduce(lst, function(r, v) return r + v end))
	assert(16 == fn.reduce(lst, function(r, v) return r + v end, 1))
	assert(15 == fn.reduce({ 5 }, function(r, v) return r + v end, 10))

	-- reverse
	assert(test({ 4, 5, 2, 3, 1 }, fn.reverse(lst)))

	-- sort
	assert(test({ 1, 2, 3, 4, 5 }, fn.sort(fn.clone(lst))))

	-- sorted
	assert(test({ 1, 2, 3, 4, 5 }, fn.sorted(lst)))
	assert(test({ 1, 3, 2, 5, 4 }, lst))

	-- sorted_index
	assert(4 == fn.sorted_index({ 1, 2, 3, 4, 5, 6 }, 4))

	-- sorted_insert
	assert(test({ 1, 2, 3, 4, 5}, fn.sorted_insert({ 1, 2, 3, 5 }, 4)))

	-- sum
	assert(15 == fn.sum(lst))

	-- union
	assert(test({}, fn.union()))
	assert(test({}, fn.union({}, {})))
	assert(test({ 1, 2, 3, 4, 5 }, fn.union({ 1, 2, 3, 3, 4, 5 })))
	assert(test({ 1, 2, 3, 4, 5 }, fn.union({ 1, 2 }, { 1, 3, 4, 5 })))
	assert(test({ 1, 2, 3, 4, 5 }, fn.union({ 1, 2 }, { 1, 2, 3, 4 } , { 3, 5 })))

	-- uniq
	assert(test({ 2, 3, 1 }, fn.uniq({ 2, 3, 2, 1, 1 })))
	assert(test({ 1, 2, 3 }, fn.uniq({ 1, 1, 2, 2, 3 }, true)))
	assert(test({ 1, 2 }, fn.uniq({ 1, 1, 2, 2, 3 }, true, function(v) return math.floor(v/2) end)))
	
	-- values
	assert(test({ 1, 2, 3, 4, 5 }, fn.sorted(fn.values(tbl))))

	print("LibFunctional-1.0: tests passed")
end)()
