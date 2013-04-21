--LibStub = {}
lib = require("functional");

(function()
	local function dump(v)
	end

	local function teq(t1, t2)
		if #t1 ~= #t2 then return false end
		for k, v in pairs(t1) do
			if t2[k] ~= v then return false end
		end
		return true
	end

	local function test(t1, t2)
		if not teq(t1, t2) then
			print("test failed:")
			print("\texpected: { " .. table.concat(t1, ", ") .. " }")
			print("\tgot: { " .. table.concat(t2, ", ") .. " }")
			return false
		end
		return true
	end

	local fn = lib

	local lst = { 1, 3, 2, 5, 4 }
	local tbl = { ["a"] = 1, ["b"] = 2, ["c"] = 3, ["d"] = 4, ["e"] = 5 }

	-- teq
	assert(false == teq({1, 2, 3}, {1, 5, 7}))
	assert(true == teq({1, 2, 3}, {1, 2, 3}))

	-- clone
	assert(test(lst, fn.clone(lst)))

	-- map
	assert(test({ 2, 6, 4, 10, 8 }, fn.map(lst, function(v) return v * 2 end)))

	-- filter
	assert(test({ 3, 2, 5, 4 }, fn.filter(lst, function(v) return v > 1 end)))

	-- find
	assert(5 == fn.find(lst, function(v) return v == 5 end))
	assert(nil == fn.find(lst, function(v) return v == 6 end))

	-- contains
	assert(true == fn.contains(lst, 5))
	assert(false == fn.contains(lst, 6))

	-- reverse
	assert(test({ 4, 5, 2, 3, 1 }, fn.reverse(lst)))

	-- binary_search
	assert(1 == fn.binary_search(fn.sorted(lst), 1))
	assert(2 == fn.binary_search(fn.sorted(lst), 2))
	assert(3 == fn.binary_search(fn.sorted(lst), 3))
	assert(4 == fn.binary_search(fn.sorted(lst), 4))
	assert(5 == fn.binary_search(fn.sorted(lst), 5))
	assert(nil == fn.binary_search(fn.sorted(lst), 6))

	-- reduce without initial value
	assert(15 == fn.reduce(lst, function(r, v) return r + v end))

	-- reduce with initial value
	assert(16 == fn.reduce(lst, function(r, v) return r + v end, 1))

	-- sum
	assert(15 == fn.sum(lst))

	-- min
	assert(1 == fn.min(lst))

	-- max
	assert(5 == fn.max(lst))

	-- all
	assert(true == fn.all(lst, function(v) return v > 0 end))
	assert(false == fn.all(lst, function(v) return v > 1 end))

	-- any
	assert(true == fn.any(lst, function(v) return v > 3 end))
	assert(false == fn.any(lst, function(v) return v > 10 end))

	-- union
	assert(test({ 1, 2, 3, 4, 5 }, fn.union({ 1, 2, 3, 4, 5 })))
	assert(test({ 1, 2, 3, 4, 5 }, fn.union({ 1, 2 }, { 3, 4, 5 })))
	assert(test({ 1, 2, 3, 4, 5 }, fn.union({ 1, 2 }, { 3, 4 } , { 5 })))

	-- uniq
	assert(test({ 2, 3, 1 }, fn.uniq({ 2, 3, 2, 1, 1 })))
	assert(test({ 1, 2, 3 }, fn.uniq({ 1, 1, 2, 2, 3 }, true)))
	assert(test({ 1, 2 }, fn.uniq({ 1, 1, 2, 2, 3 }, true, function(v) return math.floor(v/2) end)))

	-- keys
	assert(test({ "a", "b", "c", "d", "e" }, fn.sorted(fn.keys(tbl))))

	-- values
	assert(test({ 1, 2, 3, 4, 5 }, fn.sorted(fn.values(tbl))))

	-- sorted
	assert(test({ 1, 2, 3, 4, 5 }, fn.sorted(lst)))
	assert(test({ 1, 3, 2, 5, 4 }, lst))

	-- sort
	assert(test({ 1, 2, 3, 4, 5 }, fn.sort(lst)))
	
	print("LibFunctional-1.0: tests passed")
end)()
