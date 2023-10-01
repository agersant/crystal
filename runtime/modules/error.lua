local current_error;
local traceback;

local draw_call_stack = function(x, y, stack_string)
	local stack_font = crystal.ui.font("crystal_regular_sm");
	local location_column_width = 0;
	local function_name_column_width = 0;
	local stack_frames = {};

	for line in stack_string:gmatch("[^\r\n]+") do
		local location, function_name = line:match("(.+): in function (.+)");
		if location and function_name then
			if function_name:starts_with("<") then
				function_name = "[anonymous function]";
			end
			function_name = function_name:gsub("'", ""):trim();
			location = location:trim();
			location_column_width = math.max(location_column_width, stack_font:getWidth(location));
			function_name_column_width = math.max(function_name_column_width, stack_font:getWidth(function_name));
			table.push(stack_frames, { location, function_name });
		end
	end

	local column_spacing = 100;
	local table_margin = 10;
	local table_width = location_column_width + function_name_column_width + column_spacing + 2 * table_margin;

	local stack_header_font = crystal.ui.font("crystal_bold_xs");
	love.graphics.printf("LOCATION", stack_header_font, x + table_margin, y, math.huge);
	love.graphics.printf("FUNCTION", stack_header_font, x + table_margin + location_column_width + column_spacing, y,
		math.huge);

	for i, frame in ipairs(stack_frames) do
		y = y + 24;
		if i % 2 == 1 then
			love.graphics.setColor(crystal.Color.greyB);
			love.graphics.rectangle("fill", x, y, table_width, 24);
		end
		love.graphics.setColor(crystal.Color.greyD);
		love.graphics.printf(frame[1], stack_font, x + table_margin, y + 2, math.huge);
		love.graphics.printf(frame[2], stack_font, x + table_margin + location_column_width + column_spacing, y + 2,
			math.huge);
	end

	return x, y;
end

return {
	catch_errors = function(f)
		if current_error then
			return;
		end
		xpcall(f, function(error)
			current_error = error;
			traceback = debug.traceback("", 2);
		end);
		if current_error then
			crystal.log.error(current_error);
			crystal.log.error(traceback);
		end
	end,
	current_error = function()
		return current_error;
	end,
	draw = function()
		local margin = 30;
		local x = margin;
		local y = margin;
		local window_width, window_height = love.window.getMode();

		love.graphics.clear(crystal.Color.grey0);

		-- Draws screenshot
		-- TODO Actual screenshot
		local viewport_width, viewport_height = crystal.window.viewport_size();
		local screenshot_width = math.min(viewport_width, window_width / 4);
		local screenshot_height = math.ceil(screenshot_width * viewport_height / viewport_width);
		love.graphics.rectangle("fill", x, y, screenshot_width, screenshot_height);

		-- Draw separator
		x = x + screenshot_width + margin;
		love.graphics.setColor(crystal.Color.greyC);
		love.graphics.rectangle("fill", x, y, 2, window_height - 2 * margin);
		x = x + margin;

		-- Draw header
		assert(current_error);
		assert(traceback);
		local location_end, error_start = current_error:find(": ");
		local location_text = current_error:sub(0, location_end - 1):trim();
		local error_text = current_error:sub(error_start):trim();

		love.graphics.setColor(crystal.Color.red);
		love.graphics.rectangle("fill", x, y, 300, 40);
		love.graphics.setColor(crystal.Color.white);
		love.graphics.printf("Runtime Error", crystal.ui.font("crystal_bold_xl"), x + 10, y + 7, math.huge);
		y = y + 50;
		love.graphics.printf(error_text, crystal.ui.font("crystal_bold_md"), x, y, math.huge);
		y = y + 20;
		love.graphics.setColor(crystal.Color.greyD);
		love.graphics.printf("From " .. location_text, crystal.ui.font("crystal_regular_md"), x, y, math.huge);
		y = y + 50;

		x, y = draw_call_stack(x, y, traceback);
	end,
};
