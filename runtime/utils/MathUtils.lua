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

--#region Tests

crystal.test.add("Round", function()
	assert(MathUtils.round(2) == 2);
	assert(MathUtils.round(2.2) == 2);
	assert(MathUtils.round(2.8) == 3);
	assert(MathUtils.round( -2) == -2);
	assert(MathUtils.round( -2.2) == -2);
	assert(MathUtils.round( -2.8) == -3);
end);

crystal.test.add("Clamp", function()
	assert(2 == MathUtils.clamp(0, 2, 5));
	assert(0 == MathUtils.clamp(0, -2, 5));
	assert(5 == MathUtils.clamp(0, 12, 5));
end);

crystal.test.add("Angle between vectors", function()
	assert(0 == math.deg(MathUtils.angleBetweenVectors(0, 1, 0, 2)));
	assert(90 == math.deg(MathUtils.angleBetweenVectors(0, 1, 2, 0)));
	assert(180 == math.deg(MathUtils.angleBetweenVectors(0, 1, 0, -3)));
end);

crystal.test.add("Difference between angles", function()
	local epsilon = 0.0001;
	assert(0 == MathUtils.angleDifference(0, math.rad(0)));
	assert(math.abs(math.rad(40) - MathUtils.angleDifference(math.rad(40), math.rad(0))) < epsilon);
	assert(math.abs(math.rad(180) - MathUtils.angleDifference(math.rad(0), math.rad(180))) < epsilon);
	assert(math.abs(math.rad(180) - MathUtils.angleDifference(math.rad( -20), math.rad(160))) < epsilon);
end);

crystal.test.add("Index to XY", function()
	local x, y = MathUtils.indexToXY(8, 5);
	assert(x == 3);
	assert(y == 1);
end);

crystal.test.add("Snap angle", function()
	assert(0 == MathUtils.snapAngle(math.rad(0), 4));
	assert(1 == MathUtils.snapAngle(math.rad(90), 4));
	assert(2 == MathUtils.snapAngle(math.rad(180), 4));
	assert(3 == MathUtils.snapAngle(math.rad(270), 4));
	assert(0 == MathUtils.snapAngle(math.rad(360), 4));
	assert(0 == MathUtils.snapAngle(math.rad(20), 4));
	assert(1 == MathUtils.snapAngle(math.rad(80), 4));
	assert(0 == MathUtils.snapAngle(math.rad(330), 4));
end);

crystal.test.add("Angle to dir 8", function()
	assert(1, 0 == MathUtils.angleToDir8(math.rad(0)));
	assert(1, 0 == MathUtils.angleToDir8(math.rad(20)));
	assert(1, 1 == MathUtils.angleToDir8(math.rad(30)));
	assert(0, 1 == MathUtils.angleToDir8(math.rad(80)));
	assert(1, 0 == MathUtils.angleToDir8(math.rad(350)));
end);

crystal.test.add("Damping", function()
	assert(10 == MathUtils.damp(10, 20, 0, 0));
	assert(20 == MathUtils.damp(10, 20, 0, 0.5));
	assert(20 == MathUtils.damp(10, 20, 0, 1));

	assert(10 == MathUtils.damp(10, 20, 1, 0));
	assert(10 == MathUtils.damp(10, 20, 1, 0.5));
	assert(10 == MathUtils.damp(10, 20, 1, 1));

	assert(10 == MathUtils.damp(10, 20, 0.5, 0));
	assert(15 == MathUtils.damp(10, 20, 0.5, 1));
	assert(17.5 == MathUtils.damp(10, 20, 0.5, 2));

	assert(10 == MathUtils.damp(10, 20, 0.75, 0));
	assert(12.5 == MathUtils.damp(10, 20, 0.75, 1));
end);

crystal.test.add("Linear easing", function()
	assert(0, 0 == MathUtils.ease(0, "linear"));
	assert(0.25, 0 == MathUtils.ease(0.25, "linear"));
	assert(0.5, 0 == MathUtils.ease(0.5, "linear"));
	assert(0.75, 0 == MathUtils.ease(0.75, "linear"));
	assert(1, 0 == MathUtils.ease(1, "linear"));
end);

crystal.test.add("Quadratic easing", function()
	assert(0 == MathUtils.ease(0, "inQuadratic"));
	assert(0.0625 == MathUtils.ease(0.25, "inQuadratic"));
	assert(0.25 == MathUtils.ease(0.5, "inQuadratic"));
	assert(0.5625 == MathUtils.ease(0.75, "inQuadratic"));
	assert(1 == MathUtils.ease(1, "inQuadratic"));
	assert(0 == MathUtils.ease(0, "outQuadratic"));
	assert(0.4375 == MathUtils.ease(0.25, "outQuadratic"));
	assert(0.75 == MathUtils.ease(0.5, "outQuadratic"));
	assert(0.9375 == MathUtils.ease(0.75, "outQuadratic"));
	assert(1 == MathUtils.ease(1, "outQuadratic"));
end);

crystal.test.add("Cubic easing", function()
	assert(0 == MathUtils.ease(0, "inCubic"));
	assert(0.015625 == MathUtils.ease(0.25, "inCubic"));
	assert(0.125 == MathUtils.ease(0.5, "inCubic"));
	assert(0.421875 == MathUtils.ease(0.75, "inCubic"));
	assert(1 == MathUtils.ease(1, "inCubic"));
	assert(0 == MathUtils.ease(0, "outCubic"));
	assert(0.578125 == MathUtils.ease(0.25, "outCubic"));
	assert(0.875 == MathUtils.ease(0.5, "outCubic"));
	assert(0.984375 == MathUtils.ease(0.75, "outCubic"));
	assert(1 == MathUtils.ease(1, "outCubic"));
end);

crystal.test.add("Quartic easing", function()
	assert(0 == MathUtils.ease(0, "inQuartic"));
	assert(0.00390625 == MathUtils.ease(0.25, "inQuartic"));
	assert(0.0625 == MathUtils.ease(0.5, "inQuartic"));
	assert(0.31640625 == MathUtils.ease(0.75, "inQuartic"));
	assert(1 == MathUtils.ease(1, "inQuartic"));
	assert(0 == MathUtils.ease(0, "outQuartic"));
	assert(0.68359375 == MathUtils.ease(0.25, "outQuartic"));
	assert(0.9375 == MathUtils.ease(0.5, "outQuartic"));
	assert(0.99609375 == MathUtils.ease(0.75, "outQuartic"));
	assert(1 == MathUtils.ease(1, "outQuartic"));
end);

crystal.test.add("Quintic easing", function()
	assert(0 == MathUtils.ease(0, "inQuintic"));
	assert(0.0009765625 == MathUtils.ease(0.25, "inQuintic"));
	assert(0.03125 == MathUtils.ease(0.5, "inQuintic"));
	assert(0.2373046875 == MathUtils.ease(0.75, "inQuintic"));
	assert(1 == MathUtils.ease(1, "inQuintic"));
	assert(0 == MathUtils.ease(0, "outQuintic"));
	assert(0.7626953125 == MathUtils.ease(0.25, "outQuintic"));
	assert(0.96875 == MathUtils.ease(0.5, "outQuintic"));
	assert(0.9990234375 == MathUtils.ease(0.75, "outQuintic"));
	assert(1 == MathUtils.ease(1, "outQuintic"));
end);

crystal.test.add("Bounce easing", function()
	assert(0 == MathUtils.ease(0, "inBounce"));
	for i = 0, 100 do
		assert(0 <= MathUtils.ease(i / 100, "inBounce"));
		assert(1 >= MathUtils.ease(i / 100, "inBounce"));
	end
	assert(1 == MathUtils.ease(1, "inBounce"));

	assert(0 == MathUtils.ease(0, "outBounce"));
	for i = 0, 100 do
		assert(0 <= MathUtils.ease(i / 100, "outBounce"));
		assert(1 >= MathUtils.ease(i / 100, "outBounce"));
	end
	assert(1 == MathUtils.ease(1, "outBounce"));
end);

--#endregion

return MathUtils;
