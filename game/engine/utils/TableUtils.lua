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

return TableUtils;
