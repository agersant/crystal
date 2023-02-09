local TableUtils = {};

TableUtils.countKeys = function(t)
	local count = 0;
	for _, _ in pairs(t) do
		count = count + 1;
	end
	return count;
end

TableUtils.shallowCopy = function(t)
	local out = {};
	for k, v in pairs(t) do
		out[k] = v;
	end
	return out;
end

TableUtils.serialize = function(t)
	local refCounts = {};
	local verifyRefs;
	verifyRefs = function(t)
		assert(not refCounts[t]);
		refCounts[t] = true;
		for _, v in pairs(t) do
			if type(v) == "table" then
				verifyRefs(v);
			end
		end
		return true;
	end
	assert(verifyRefs(t));

	local writeValue;
	writeValue = function(v)
		if type(v) == "number" then
			return tostring(v);
		elseif type(v) == "string" then
			return "\"" .. tostring(v) .. "\"";
		elseif type(v) == "table" then
			local out = "{\n";
			for key, value in pairs(v) do
				if type(key) == "number" then
					out = out .. "[" .. key .. "]";
				elseif type(key) == "string" then
					out = out .. key;
				else
					error("Unsupported table key type: " .. type(key));
				end
				out = out .. " = " .. writeValue(value) .. ",\n";
			end
			out = out .. "}";
			return out;
		else
			error("Unsupported table value type: " .. type(v));
		end
	end

	local serialized = "return " .. writeValue(t);
	return serialized;
end

TableUtils.unserialize = function(source)
	local luaChunk = loadstring(source);
	assert(luaChunk);
	local outTable = luaChunk();
	assert(outTable);
	return outTable;
end

TableUtils.contains = function(t, value)
	for k, v in pairs(t) do
		if v == value then
			return true;
		end
	end
	return false;
end

TableUtils.equals = function(t, u)
	assert(type(t) == "table");
	assert(type(u) == "table");
	for k, v in pairs(t) do
		if t[k] ~= u[k] then
			return false;
		end
	end
	for k, v in pairs(u) do
		if t[k] ~= u[k] then
			return false;
		end
	end
	return true;
end

TableUtils.merge = function(recipient, otherTable)
	for k, v in pairs(otherTable) do
		recipient[k] = v;
	end
end

--#region Tests


crystal.test.add("Count keys", function()
	assert(TableUtils.countKeys({}) == 0);
	assert(TableUtils.countKeys({ a = 0, b = 2 }) == 2);
	assert(TableUtils.countKeys({ 1, 2, 3 }) == 3);
end);

crystal.test.add("Contains", function()
	assert(TableUtils.contains({ 2 }, 2));
	assert(TableUtils.contains({ a = 2 }, 2));
	assert(not TableUtils.contains({ 2 }, 3));
	assert(not TableUtils.contains({ [3] = 2 }, 3));
end);

crystal.test.add("Shallow copy", function()
	local original = { a = { 1, 2, 3 } };
	local copy = TableUtils.shallowCopy(original);
	assert(copy ~= original);
	assert(copy.a == original.a);
end);

crystal.test.add("Serialize empty table", function()
	local original = {};
	local copy = TableUtils.unserialize(TableUtils.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(TableUtils.countKeys(copy) == 0);
end);

crystal.test.add("Serialize trivial table", function()
	local original = { a = 0, b = "oink" };
	local copy = TableUtils.unserialize(TableUtils.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(copy.a == 0);
	assert(copy.b == "oink");
end);

crystal.test.add("Serialize simple table", function()
	local original = { a = 0, b = "oink", c = { 1, 2, 3 }, d = { b = "gruik" } };
	local copy = TableUtils.unserialize(TableUtils.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(copy.a == 0);
	assert(copy.b == "oink");
	assert(copy.c[1] == 1);
	assert(copy.c[2] == 2);
	assert(copy.c[3] == 3);
	assert(copy.d.b == "gruik");
end);

crystal.test.add("Equality", function()
	assert(TableUtils.equals({}, {}));
	assert(TableUtils.equals({ 1, 2, 3 }, { 1, 2, 3 }));
	assert(not TableUtils.equals({ 1, 2 }, { 1, 2, 3 }));
	assert(not TableUtils.equals({ 1, 3, 2 }, { 1, 2, 3 }));
	assert(TableUtils.equals({ a = 0, b = 1 }, { a = 0, b = 1 }));
	assert(not TableUtils.equals({ a = 0, b = 1 }, { a = 1, b = 0 }));
	assert(not TableUtils.equals({ a = 0 }, { a = 1 }));
end);

--#endregion

return TableUtils;
