table.is_empty = function(t)
	return next(t) == nil;
end

table.clear = function(t)
	for k in pairs(t) do
		t[k] = nil;
	end
end

table.count = function(t)
	local count = 0;
	for _, _ in pairs(t) do
		count = count + 1;
	end
	return count;
end

table.index_of = function(t, v)
	for i, tv in ipairs(t) do
		if tv == v then
			return i;
		end
	end
	return nil;
end

table.push = function(t, v)
	table.insert(t, v);
end

table.pop = function(t)
	return table.remove(t);
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

table.merge = function(table_a, table_b)
	local out = {};
	for k, v in pairs(table_a) do
		out[k] = v;
	end
	for k, v in pairs(table_b) do
		out[k] = v;
	end
	return out;
end

table.serialize = function(t)
	local ref_counts = {};
	local check_refs;
	check_refs = function(t)
		assert(not ref_counts[t]);
		ref_counts[t] = true;
		for _, v in pairs(t) do
			if type(v) == "table" then
				check_refs(v);
			end
		end
		return true;
	end
	assert(check_refs(t));

	local write_value;
	write_value = function(v)
		if type(v) == "number" then
			return tostring(v);
		elseif type(v) == "boolean" then
			return tostring(v);
		elseif type(v) == "string" then
			return "\"" .. tostring(v) .. "\"";
		elseif type(v) == "table" then
			local out = "{\n";
			for key, value in pairs(v) do
				if type(key) == "number" then
					out = out .. "[" .. key .. "]";
				elseif type(key) == "boolean" then
					out = out .. "[" .. key .. "]";
				elseif type(key) == "string" then
					out = out .. key;
				else
					error("Unsupported table key type: " .. type(key));
				end
				out = out .. " = " .. write_value(value) .. ",\n";
			end
			out = out .. "}";
			return out;
		else
			error("Unsupported table value type: " .. type(v));
		end
	end

	local serialized = "return " .. write_value(t);
	return serialized;
end

table.deserialize = function(source)
	local lua_chunk = loadstring(source);
	assert(lua_chunk);
	local deserialized = lua_chunk();
	assert(deserialized);
	return deserialized;
end

return {
	init = function()
		--#region Tests

		crystal.test.add("Can check if table is empty", function()
			assert(table.is_empty({}));
			assert(not table.is_empty({ a = false }));
		end);

		crystal.test.add("Can clear a table", function()
			local t = { 1, 2, "oink" };
			assert(not table.is_empty(t));
			table.clear(t);
			assert(table.is_empty(t));
		end);

		crystal.test.add("Can count table keys", function()
			assert(table.count({}) == 0);
			assert(table.count({ a = 0, b = 2 }) == 2);
			assert(table.count({ 1, 2, 3 }) == 3);
		end);

		crystal.test.add("Can find index of a value", function()
			assert(table.index_of({ "a", "b", "c" }, "a") == 1);
			assert(table.index_of({ "a", "b", "c" }, "b") == 2);
			assert(table.index_of({ "a", "b", "c" }, "d") == nil);
			assert(table.index_of({ a = "b" }, "b") == nil);
		end);

		crystal.test.add("Can push/pop table values", function()
			local t = { 1 };
			table.push(t, 2);
			assert(t[2] == 2);
			assert(table.pop(t) == 2);
			assert(t[2] == nil);
		end);

		crystal.test.add("Can map table values", function()
			local t = { a = 1, b = 4 };
			local m = table.map(t, function(n) return n * n; end);
			assert(t.a == 1);
			assert(t.b == 4);
			assert(m.a == 1);
			assert(m.b == 16);
		end);

		crystal.test.add("Can merge tables", function()
			local m = table.merge({ a = 1 }, { b = 2 });
			assert(m.a == 1);
			assert(m.b == 2);
		end);

		crystal.test.add("Can test if table contains value", function()
			assert(table.contains({ 2 }, 2));
			assert(table.contains({ a = 2 }, 2));
			assert(not table.contains({ 2 }, 3));
			assert(not table.contains({ [3] = 2 }, 3));
		end);

		crystal.test.add("Can copy table", function()
			local original = { a = { 1, 2, 3 } };
			local copy = table.copy(original);
			assert(copy ~= original);
			assert(copy.a == original.a);
		end);

		crystal.test.add("Can serialize empty table", function()
			local original = {};
			local copy = table.deserialize(table.serialize(original));
			assert(type(copy) == "table");
			assert(copy ~= original);
			assert(table.is_empty(copy));
		end);

		crystal.test.add("Can serialize table", function()
			local original = { a = 0, b = "oink", c = { 1, 2, 3 }, d = { b = "gruik" }, e = false, };
			local copy = table.deserialize(table.serialize(original));
			assert(type(copy) == "table");
			assert(copy ~= original);
			assert(copy.a == 0);
			assert(copy.b == "oink");
			assert(copy.c[1] == 1);
			assert(copy.c[2] == 2);
			assert(copy.c[3] == 3);
			assert(copy.d.b == "gruik");
			assert(copy.e == false);
		end);

		crystal.test.add("Can test table equality", function()
			assert(table.equals({}, {}));
			assert(table.equals({ 1, 2, 3 }, { 1, 2, 3 }));
			assert(not table.equals({ 1, 2 }, { 1, 2, 3 }));
			assert(not table.equals({ 1, 3, 2 }, { 1, 2, 3 }));
			assert(table.equals({ a = 0, b = 1 }, { a = 0, b = 1 }));
			assert(not table.equals({ a = 0, b = 1 }, { a = 1, b = 0 }));
			assert(not table.equals({ a = 0 }, { a = 1 }));
		end);

		--#endregion
	end,
};
