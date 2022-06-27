local MathUtils = {};

MathUtils.indexToXY = function(index, width)
	return index % width, math.floor(index / width);
end

MathUtils.round = function(n)
	return math.floor(n + 0.5);
end

MathUtils.clamp = function(low, value, high)
	assert(low <= high);
	return math.min(high, math.max(low, value));
end

MathUtils.dotProduct = function(x1, y1, x2, y2)
	return x1 * x2 + y1 * y2;
end

MathUtils.vectorLength2 = function(x, y)
	return x * x + y * y;
end

MathUtils.vectorLength = function(x, y)
	return math.sqrt(x * x + y * y);
end

MathUtils.normalize = function(x, y, n)
	n = n or 1;
	local length = MathUtils.vectorLength(x, y);
	assert(length > 0);
	return n * x / length, n * y / length;
end

MathUtils.distance2 = function(x1, y1, x2, y2)
	local dx = x2 - x1;
	local dy = y2 - y1;
	return MathUtils.vectorLength2(dx, dy);
end

MathUtils.distance = function(x1, y1, x2, y2)
	local dx = x2 - x1;
	local dy = y2 - y1;
	return MathUtils.vectorLength(dx, dy);
end

MathUtils.angleBetweenVectors = function(x1, y1, x2, y2)
	local n1 = MathUtils.vectorLength(x1, y1);
	local n2 = MathUtils.vectorLength(x2, y2);
	assert(n1 > 0);
	assert(n2 > 0);
	local dp = MathUtils.dotProduct(x1, y1, x2, y2);
	return math.acos(dp / (n1 * n2));
end

MathUtils.angleDifference = function(angle1, angle2)
	local angle1 = angle1 % (2 * math.pi);
	local angle2 = angle2 % (2 * math.pi);
	local delta = math.abs(angle1 - angle2);
	return math.min(delta, 2 * math.pi - delta);
end

MathUtils.snapAngle = function(angle, numDirections)
	local rad360 = 2 * math.pi;
	angle = angle % rad360;
	assert(numDirections > 0);
	return math.floor(.5 + angle / rad360 * numDirections) % numDirections;
end

MathUtils.angleToDir8 = function(angle)
	local snappedAngle = MathUtils.snapAngle(angle, 8);
	if snappedAngle == 0 then
		return 1, 0;
	elseif snappedAngle == 1 then
		return 1, 1;
	elseif snappedAngle == 2 then
		return 0, 1;
	elseif snappedAngle == 3 then
		return -1, 1;
	elseif snappedAngle == 4 then
		return -1, 0;
	elseif snappedAngle == 5 then
		return -1, -1;
	elseif snappedAngle == 6 then
		return 0, -1;
	elseif snappedAngle == 7 then
		return 1, -1;
	end
	error("Unexpected angle: " .. tostring(snappedAngle));
end

MathUtils.lerp = function(t, a, b)
	return a + t * (b - a);
end

MathUtils.damp = function(from, to, smoothing, dt)
	assert(smoothing >= 0);
	assert(smoothing <= 1);
	assert(dt >= 0);
	return MathUtils.lerp(1 - math.pow(smoothing, dt), from, to);
end

MathUtils.ease = function(t, easing)
	local pow = math.pow;
	assert(t >= 0);
	assert(t <= 1);
	if easing == "linear" then
		return t;
	elseif easing == "inQuadratic" then
		return pow(t, 2);
	elseif easing == "outQuadratic" then
		return -t * (t - 2);
	elseif easing == "inCubic" then
		return pow(t, 3);
	elseif easing == "outCubic" then
		t = t - 1;
		return 1 + pow(t, 3);
	elseif easing == "inQuartic" then
		return pow(t, 4);
	elseif easing == "outQuartic" then
		t = t - 1;
		return 1 - pow(t, 4);
	elseif easing == "inQuintic" then
		return pow(t, 5);
	elseif easing == "outQuintic" then
		t = t - 1;
		return 1 + pow(t, 5);
	elseif easing == "inBounce" then
		if t <= 0.04 then
			return MathUtils.lerp(t / 0.04, 0, 0.0154);
		elseif t <= 0.08 then
			return MathUtils.lerp((t - 0.04) / (0.08 - 0.04), 0.0154, 0.0066);
		elseif t <= 0.18 then
			return MathUtils.lerp((t - 0.08) / (0.18 - 0.08), 0.0066, 0.0625);
		elseif t <= 0.26 then
			return MathUtils.lerp((t - 0.18) / (0.26 - 0.18), 0.0625, 0.0163);
		elseif t <= 0.46 then
			return MathUtils.lerp((t - 0.26) / (0.46 - 0.26), 0.0163, 0.2498);
		elseif t <= 0.64 then
			return MathUtils.lerp((t - 0.46) / (0.64 - 0.46), 0.2498, 0.0199);
		elseif t <= 0.76 then
			return MathUtils.lerp((t - 0.64) / (0.76 - 0.64), 0.0199, 0.5644);
		elseif t <= 0.88 then
			return MathUtils.lerp((t - 0.76) / (0.88 - 0.76), 0.5644, 0.8911);
		else
			return MathUtils.lerp((t - 0.88) / (1.0 - 0.88), 0.8911, 1);
		end
	elseif easing == "outBounce" then
		if t <= 0.12 then
			return MathUtils.lerp(t / 0.12, 0, 0.1089);
		elseif t <= 0.24 then
			return MathUtils.lerp((t - 0.12) / (0.24 - 0.12), 0.1089, 0.4356);
		elseif t <= 0.36 then
			return MathUtils.lerp((t - 0.24) / (0.36 - 0.24), 0.4356, 0.9801);
		elseif t <= 0.54 then
			return MathUtils.lerp((t - 0.36) / (0.54 - 0.36), 0.9801, 0.7502);
		elseif t <= 0.74 then
			return MathUtils.lerp((t - 0.54) / (0.74 - 0.54), 0.7502, 0.9837);
		elseif t <= 0.82 then
			return MathUtils.lerp((t - 0.74) / (0.82 - 0.74), 0.9837, 0.9375);
		elseif t <= 0.92 then
			return MathUtils.lerp((t - 0.82) / (0.92 - 0.82), 0.9375, 0.9934);
		elseif t <= 0.96 then
			return MathUtils.lerp((t - 0.92) / (0.96 - 0.92), 0.9934, 0.9846);
		else
			return MathUtils.lerp((t - 0.96) / (1.0 - 0.96), 0.9846, 1);
		end
	end
end

return MathUtils;
