local MathUtils = require("utils/MathUtils");

local tests = {};

tests[#tests + 1] = { name = "Round" };
tests[#tests].body = function()
	assert(MathUtils.round(2) == 2);
	assert(MathUtils.round(2.2) == 2);
	assert(MathUtils.round(2.8) == 3);
	assert(MathUtils.round(-2) == -2);
	assert(MathUtils.round(-2.2) == -2);
	assert(MathUtils.round(-2.8) == -3);
end

tests[#tests + 1] = { name = "Clamp" };
tests[#tests].body = function()
	assert(2 == MathUtils.clamp(0, 2, 5));
	assert(0 == MathUtils.clamp(0, -2, 5));
	assert(5 == MathUtils.clamp(0, 12, 5));
end

tests[#tests + 1] = { name = "Angle between vectors" };
tests[#tests].body = function()
	assert(0 == math.deg(MathUtils.angleBetweenVectors(0, 1, 0, 2)));
	assert(90 == math.deg(MathUtils.angleBetweenVectors(0, 1, 2, 0)));
	assert(180 == math.deg(MathUtils.angleBetweenVectors(0, 1, 0, -3)));
end

tests[#tests + 1] = { name = "Difference between angles" };
tests[#tests].body = function()
	local epsilon = 0.0001;
	assert(0 == MathUtils.angleDifference(0, math.rad(0)));
	assert(math.abs(math.rad(40) - MathUtils.angleDifference(math.rad(40), math.rad(0))) < epsilon);
	assert(math.abs(math.rad(180) - MathUtils.angleDifference(math.rad(0), math.rad(180))) < epsilon);
	assert(math.abs(math.rad(180) - MathUtils.angleDifference(math.rad(-20), math.rad(160))) < epsilon);
end

tests[#tests + 1] = { name = "Index to XY" };
tests[#tests].body = function()
	local x, y = MathUtils.indexToXY(8, 5);
	assert(x == 3);
	assert(y == 1);
end

tests[#tests + 1] = { name = "Snap angle" };
tests[#tests].body = function()
	assert(0 == MathUtils.snapAngle(math.rad(0), 4));
	assert(1 == MathUtils.snapAngle(math.rad(90), 4));
	assert(2 == MathUtils.snapAngle(math.rad(180), 4));
	assert(3 == MathUtils.snapAngle(math.rad(270), 4));
	assert(0 == MathUtils.snapAngle(math.rad(360), 4));
	assert(0 == MathUtils.snapAngle(math.rad(20), 4));
	assert(1 == MathUtils.snapAngle(math.rad(80), 4));
	assert(0 == MathUtils.snapAngle(math.rad(330), 4));
end

tests[#tests + 1] = { name = "Angle to dir 8" };
tests[#tests].body = function()
	assert(1, 0 == MathUtils.angleToDir8(math.rad(0)));
	assert(1, 0 == MathUtils.angleToDir8(math.rad(20)));
	assert(1, 1 == MathUtils.angleToDir8(math.rad(30)));
	assert(0, 1 == MathUtils.angleToDir8(math.rad(80)));
	assert(1, 0 == MathUtils.angleToDir8(math.rad(350)));
end

tests[#tests + 1] = { name = "Damping" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Linear easing" };
tests[#tests].body = function()
	assert(0, 0 == MathUtils.ease(0, "linear"));
	assert(0.25, 0 == MathUtils.ease(0.25, "linear"));
	assert(0.5, 0 == MathUtils.ease(0.5, "linear"));
	assert(0.75, 0 == MathUtils.ease(0.75, "linear"));
	assert(1, 0 == MathUtils.ease(1, "linear"));
end

tests[#tests + 1] = { name = "Quadratic easing" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Cubic easing" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Quartic easing" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Quintic easing" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Bounce easing" };
tests[#tests].body = function()
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
end

return tests;
