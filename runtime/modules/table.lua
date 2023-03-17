table.is_empty = function(t)
	return next(t) == nil;
end

table.count = function(t)
	local count = 0;
	for _, _ in pairs(t) do
		count = count + 1;
	end
	return count;
end

table.map = function(t, f)
	local out = {};
	for k, v in pairs(t) do
		out[k] = f(v);
	end
	return out;
end

table.copy = function(t)
	local out = {};
	for k, v in pairs(t) do
		out[k] = v;
	end
	return out;
end

table.serialize = function(t)
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

table.deserialize = function(source)
	local luaChunk = loadstring(source);
	assert(luaChunk);
	local outTable = luaChunk();
	assert(outTable);
	return outTable;
end

table.contains = function(t, value)
	for k, v in pairs(t) do
		if v == value then
			return true;
		end
	end
	return false;
end

table.equals = function(t, u)
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

table.merge = function(recipient, otherTable)
	for k, v in pairs(otherTable) do
		recipient[k] = v;
	end
end

--#region Tests

crystal.test.add("Count keys", function()
	assert(table.count(({})) == 0);
	assert(table.count(({ a = 0, b = 2 })) == 2);
	assert(table.count(({ 1, 2, 3 })) == 3);
end);

crystal.test.add("Contains", function()
	assert(table.contains({ 2 }, 2));
	assert(table.contains({ a = 2 }, 2));
	assert(not table.contains({ 2 }, 3));
	assert(not table.contains({ [3] = 2 }, 3));
end);

crystal.test.add("Shallow copy", function()
	local original = { a = { 1, 2, 3 } };
	local copy = table.copy(original);
	assert(copy ~= original);
	assert(copy.a == original.a);
end);

crystal.test.add("Serialize empty table", function()
	local original = {};
	local copy = table.deserialize(table.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(table.is_empty(copy));
end);

crystal.test.add("Serialize trivial table", function()
	local original = { a = 0, b = "oink" };
	local copy = table.deserialize(table.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(copy.a == 0);
	assert(copy.b == "oink");
end);

crystal.test.add("Serialize simple table", function()
	local original = { a = 0, b = "oink", c = { 1, 2, 3 }, d = { b = "gruik" } };
	local copy = table.deserialize(table.serialize(original));
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
	assert(table.equals({}, {}));
	assert(table.equals({ 1, 2, 3 }, { 1, 2, 3 }));
	assert(not table.equals({ 1, 2 }, { 1, 2, 3 }));
	assert(not table.equals({ 1, 3, 2 }, { 1, 2, 3 }));
	assert(table.equals({ a = 0, b = 1 }, { a = 0, b = 1 }));
	assert(not table.equals({ a = 0, b = 1 }, { a = 1, b = 0 }));
	assert(not table.equals({ a = 0 }, { a = 1 }));
end);

--#endregion

return {};
