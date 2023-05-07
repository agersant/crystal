local pow = math.pow;

math.tau = 2 * math.pi;

math.index_to_xy = function(index, width)
	return index % width, math.floor(index / width);
end

math.round = function(n)
	return math.floor(n + 0.5);
end

math.clamp = function(value, low, high)
	assert(low <= high);
	return math.min(high, math.max(low, value));
end

math.dot_product = function(x1, y1, x2, y2)
	return x1 * x2 + y1 * y2;
end

math.cross_product = function(x1, y1, x2, y2)
	return x1 * y2 - y1 * x2;
end

math.length_squared = function(x, y)
	return x * x + y * y;
end

math.length = function(x, y)
	return math.sqrt(x * x + y * y);
end

math.normalize = function(x, y, n)
	n = n or 1;
	local length = math.length(x, y);
	assert(length > 0);
	return n * x / length, n * y / length;
end

math.distance_squared = function(x1, y1, x2, y2)
	local dx = x2 - x1;
	local dy = y2 - y1;
	return math.length_squared(dx, dy);
end

math.distance = function(x1, y1, x2, y2)
	local dx = x2 - x1;
	local dy = y2 - y1;
	return math.length(dx, dy);
end

math.angle_between = function(x1, y1, x2, y2)
	local cp = math.cross_product(x1, y1, x2, y2);
	local dp = math.dot_product(x1, y1, x2, y2);
	return math.atan2(cp, dp);
end

math.angle_delta = function(angle1, angle2)
	local delta = angle2 - angle1;
	return (delta + math.pi) % math.tau - math.pi;
end

math.angle_to_cardinal = function(angle)
	angle = angle % math.tau;
	local snapped = math.round(angle / math.tau * 8) % 8;
	if snapped == 0 then
		return 1, 0;
	elseif snapped == 1 then
		return 1, 1;
	elseif snapped == 2 then
		return 0, 1;
	elseif snapped == 3 then
		return -1, 1;
	elseif snapped == 4 then
		return -1, 0;
	elseif snapped == 5 then
		return -1, -1;
	elseif snapped == 6 then
		return 0, -1;
	elseif snapped == 7 then
		return 1, -1;
	end
end

math.lerp = function(a, b, t)
	return a + t * (b - a);
end

math.damp = function(from, to, smoothing, dt)
	assert(smoothing >= 0);
	assert(smoothing <= 1);
	assert(dt >= 0);
	return math.lerp(from, to, 1 - math.pow(smoothing, dt));
end

math.ease_linear = function(t)
	assert(t >= 0 and t <= 1);
	return t;
end

math.ease_in_quadratic = function(t)
	assert(t >= 0 and t <= 1);
	return pow(t, 2);
end

math.ease_out_quadratic = function(t)
	assert(t >= 0 and t <= 1);
	return -t * (t - 2);
end

math.ease_in_out_quadratic = function(t)
	assert(t >= 0 and t <= 1);
	if t < 0.5 then
		return 2 * t * t;
	else
		return 1 - pow(-2 * t + 2, 2) / 2;
	end
end

math.ease_in_cubic = function(t)
	assert(t >= 0 and t <= 1);
	return pow(t, 3);
end

math.ease_out_cubic = function(t)
	assert(t >= 0 and t <= 1);
	t = t - 1;
	return 1 + pow(t, 3);
end

math.ease_in_out_cubic = function(t)
	assert(t >= 0 and t <= 1);
	if t < 0.5 then
		return 4 * t * t * t;
	else
		return 1 - pow(-2 * t + 2, 3) / 2;
	end
end

math.ease_in_quartic = function(t)
	assert(t >= 0 and t <= 1);
	return pow(t, 4);
end

math.ease_out_quartic = function(t)
	assert(t >= 0 and t <= 1);
	t = t - 1;
	return 1 - pow(t, 4);
end

math.ease_in_out_quartic = function(t)
	assert(t >= 0 and t <= 1);
	if t < 0.5 then
		return 8 * t * t * t * t;
	else
		return 1 - pow(-2 * t + 2, 4) / 2;
	end
end

math.ease_in_quintic = function(t)
	assert(t >= 0 and t <= 1);
	return pow(t, 5);
end

math.ease_out_quintic = function(t)
	assert(t >= 0 and t <= 1);
	t = t - 1;
	return 1 + pow(t, 5);
end

math.ease_in_out_quintic = function(t)
	assert(t >= 0 and t <= 1);
	if t < 0.5 then
		return 16 * t * t * t * t * t;
	else
		return 1 - pow(-2 * t + 2, 5) / 2;
	end
end

math.ease_in_bounce = function(t)
	assert(t >= 0 and t <= 1);
	if t <= 0.04 then
		return math.lerp(0, 0.0154, t / 0.04);
	elseif t <= 0.08 then
		return math.lerp(0.0154, 0.0066, (t - 0.04) / (0.08 - 0.04));
	elseif t <= 0.18 then
		return math.lerp(0.0066, 0.0625, (t - 0.08) / (0.18 - 0.08));
	elseif t <= 0.26 then
		return math.lerp(0.0625, 0.0163, (t - 0.18) / (0.26 - 0.18));
	elseif t <= 0.46 then
		return math.lerp(0.0163, 0.2498, (t - 0.26) / (0.46 - 0.26));
	elseif t <= 0.64 then
		return math.lerp(0.2498, 0.0199, (t - 0.46) / (0.64 - 0.46));
	elseif t <= 0.76 then
		return math.lerp(0.0199, 0.5644, (t - 0.64) / (0.76 - 0.64));
	elseif t <= 0.88 then
		return math.lerp(0.5644, 0.8911, (t - 0.76) / (0.88 - 0.76));
	else
		return math.lerp(0.8911, 1, (t - 0.88) / (1.0 - 0.88));
	end
end

math.ease_out_bounce = function(t)
	assert(t >= 0 and t <= 1);
	if t <= 0.12 then
		return math.lerp(0, 0.1089, t / 0.12);
	elseif t <= 0.24 then
		return math.lerp(0.1089, 0.4356, (t - 0.12) / (0.24 - 0.12));
	elseif t <= 0.36 then
		return math.lerp(0.4356, 0.9801, (t - 0.24) / (0.36 - 0.24));
	elseif t <= 0.54 then
		return math.lerp(0.9801, 0.7502, (t - 0.36) / (0.54 - 0.36));
	elseif t <= 0.74 then
		return math.lerp(0.7502, 0.9837, (t - 0.54) / (0.74 - 0.54));
	elseif t <= 0.82 then
		return math.lerp(0.9837, 0.9375, (t - 0.74) / (0.82 - 0.74));
	elseif t <= 0.92 then
		return math.lerp(0.9375, 0.9934, (t - 0.82) / (0.92 - 0.82));
	elseif t <= 0.96 then
		return math.lerp(0.9934, 0.9846, (t - 0.92) / (0.96 - 0.92));
	else
		return math.lerp(0.9846, 1, (t - 0.96) / (1.0 - 0.96));
	end
end

math.ease_in_out_bounce = function(t)
	assert(t >= 0 and t <= 1);
	if t < 0.5 then
		return (1 - math.ease_out_bounce(1 - 2 * t)) / 2;
	else
		return (1 + math.ease_out_bounce(2 * t - 1)) / 2;
	end
end

return {
	start = function()
		--#region Tests

		crystal.test.add("Can round numbers", function()
			assert(math.round(2) == 2);
			assert(math.round(2.2) == 2);
			assert(math.round(2.8) == 3);
			assert(math.round(-2) == -2);
			assert(math.round(-2.2) == -2);
			assert(math.round(-2.8) == -3);
		end);

		crystal.test.add("Can clamp numbers", function()
			assert(math.clamp(2, 0, 5) == 2);
			assert(math.clamp(-2, 0, 5) == 0);
			assert(math.clamp(12, 0, 5) == 5);
		end);

		crystal.test.add("Can compute angle between vectors", function()
			assert(math.deg(math.angle_between(0, 1, 0, 2)) == 0);
			assert(math.deg(math.angle_between(0, 1, 2, 0)) == -90);
			assert(math.deg(math.angle_between(2, 0, 0, 1)) == 90);
			assert(math.deg(math.angle_between(0, 2, -3, 0)) == 90);
			assert(math.deg(math.angle_between(0, 1, 0, -3)) == -180);
		end);

		crystal.test.add("Can compute delta between angles", function()
			local epsilon = 0.0001;
			assert(math.angle_delta(0, math.rad(0)) == 0);
			assert(math.abs(math.rad(-40) - math.angle_delta(math.rad(40), math.rad(0))) < epsilon);
			assert(math.abs(math.rad(20) - math.angle_delta(math.rad(-40), math.rad(-20))) < epsilon);
			assert(math.abs(math.rad(-180) - math.angle_delta(math.rad(0), math.rad(180))) < epsilon);
			assert(math.abs(math.rad(-180) - math.angle_delta(math.rad(-20), math.rad(160))) < epsilon);
		end);

		crystal.test.add("Can convert index to XY", function()
			local x, y = math.index_to_xy(8, 5);
			assert(x == 3);
			assert(y == 1);
		end);

		crystal.test.add("Can convert angle to cardinal direction", function()
			assert(1, 0 == math.angle_to_cardinal(math.rad(0)));
			assert(1, 0 == math.angle_to_cardinal(math.rad(20)));
			assert(1, 1 == math.angle_to_cardinal(math.rad(30)));
			assert(0, 1 == math.angle_to_cardinal(math.rad(80)));
			assert(1, 0 == math.angle_to_cardinal(math.rad(350)));
		end);

		crystal.test.add("Can damp value", function()
			assert(math.damp(10, 20, 0, 0) == 10);
			assert(math.damp(10, 20, 0, 0.5) == 20);
			assert(math.damp(10, 20, 0, 1) == 20);

			assert(math.damp(10, 20, 1, 0) == 10);
			assert(math.damp(10, 20, 1, 0.5) == 10);
			assert(math.damp(10, 20, 1, 1) == 10);

			assert(math.damp(10, 20, 0.5, 0) == 10);
			assert(math.damp(10, 20, 0.5, 1) == 15);
			assert(math.damp(10, 20, 0.5, 2) == 17.5);

			assert(math.damp(10, 20, 0.75, 0) == 10);
			assert(math.damp(10, 20, 0.75, 1) == 12.5);
		end);

		crystal.test.add("Can ease value (linear)", function()
			assert(math.ease_linear(0) == 0);
			assert(math.ease_linear(0.25) == 0.25);
			assert(math.ease_linear(0.5) == 0.5);
			assert(math.ease_linear(0.75) == 0.75);
			assert(math.ease_linear(1) == 1);
		end);

		crystal.test.add("Can ease value (power functions)", function()
			local functions = {
				math.ease_in_quadratic,
				math.ease_out_quadratic,
				math.ease_in_out_quadratic,
				math.ease_in_cubic,
				math.ease_out_cubic,
				math.ease_in_out_cubic,
				math.ease_in_quartic,
				math.ease_out_quartic,
				math.ease_in_out_quartic,
				math.ease_in_quintic,
				math.ease_out_quintic,
				math.ease_in_out_quintic,
			};
			for _, f in pairs(functions) do
				assert(f(0) == 0);
				assert(f(1) == 1);
				for i = 0, 100 do
					assert(f(i / 100) >= 0);
					if i > 0 then
						assert(f(i / 100) > f((i - 1) / 100));
					end
				end
			end
		end);

		crystal.test.add("Can ease value (bounce)", function()
			local functions = {
				math.ease_in_bounce,
				math.ease_out_bounce,
				math.ease_in_out_bounce,
			};
			for _, f in pairs(functions) do
				assert(f(0) == 0);
				for i = 0, 100 do
					assert(f(i / 100) >= 0);
					assert(f(i / 100) <= 1);
				end
				assert(f(1) == 1);
			end
		end);

		--#endregion
	end
};
