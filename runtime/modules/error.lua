local features = require(CRYSTAL_RUNTIME .. "features");

local current_error;
local traceback;
local script_traceback;

local draw_call_stack = function(x, y, stack_string, stack_top)
	local stack_font = crystal.ui.font("crystal_regular_sm");
	local location_column_width = 0;
	local function_name_column_width = 0;
	local stack_frames = {};

	for line in stack_string:gmatch("[^\r\n]+") do
		local location, function_name = line:match("(.+): in function (.+)");
		if location and function_name then
			function_name = function_name:gsub("'", ""):trim();
			location = location:trim();
			location_column_width = math.max(location_column_width, stack_font:getWidth(location));
			function_name_column_width = math.max(function_name_column_width, stack_font:getWidth(function_name));
			table.push(stack_frames, { location, function_name });
		end
	end

	if stack_top and #stack_frames > 0 then
		stack_frames[1][1] = stack_top;
	end

	local column_spacing = 100;
	local table_margin = 10;
	local row_height = 24;
	local table_width = location_column_width + function_name_column_width + column_spacing + 2 * table_margin;

	local stack_header_font = crystal.ui.font("crystal_bold_sm");
	love.graphics.setColor(crystal.Color.greyD);
	love.graphics.rectangle("fill", x, y, table_width, stack_header_font:getHeight());
	love.graphics.setColor(crystal.Color.grey0);
	love.graphics.printf("LOCATION", stack_header_font, x + table_margin, y, math.huge);
	love.graphics.printf("FUNCTION", stack_header_font, x + table_margin + location_column_width + column_spacing, y,
		math.huge);

	for i, frame in ipairs(stack_frames) do
		y = y + row_height;
		local game_code = not (frame[1]:starts_with("[C]") or frame[1]:starts_with("crystal/") or frame[1]:starts_with("[love"));
		if i % 2 == 1 then
			love.graphics.setColor(crystal.Color.greyB);
			love.graphics.rectangle("fill", x, y, table_width, row_height);
		end
		if game_code then
			love.graphics.setColor(crystal.Color.cyan);
			love.graphics.rectangle("fill", x, y, table_margin / 2, row_height);
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
			if type(error) == "string" then
				current_error = error;
				traceback = debug.traceback("", 2);
			elseif type(error) == "table" then
				assert(type(error.message) == "string");
				assert(type(error.traceback) == "string");
				current_error = error.message;
				traceback = error.traceback;
				script_traceback = error.script_traceback;
			end
		end);
		if current_error then
			crystal.log.error(current_error);
			crystal.log.error(traceback);
			if script_traceback then
				crystal.log.error(script_traceback);
			end
			if not features.recoverable_errors then
				error(current_error);
			end
		end
	end,
	draw = function(screenshot)
		if not features.recoverable_errors or not current_error then
			return nil;
		end

		local margin = 30;
		local x = margin;
		local y = margin;
		local window_width, window_height = love.window.getMode();
		local viewport_scale = crystal.window.viewport_scale();

		love.graphics.clear(crystal.Color.grey0);

		-- Draws screenshot
		local screenshot_width, screenshot_height = screenshot:getDimensions();
		local image_width = math.ceil(math.min(screenshot_width / viewport_scale, window_width / 3));
		local image_height = math.ceil(image_width * screenshot_height / screenshot_width);
		local screenshot_font = crystal.ui.font("crystal_regular_sm");
		love.graphics.setColor(crystal.Color.greyA);
		love.graphics.rectangle("fill", x, y, image_width, image_height);
		love.graphics.setColor(crystal.Color.greyD);
		love.graphics.printf(
			"no screenshot captured",
			screenshot_font,
			math.floor(x),
			math.floor(y + (image_height - screenshot_font:getHeight()) / 2),
			image_width,
			"center");
		love.graphics.setColor(crystal.Color.white);
		love.graphics.draw(screenshot, x, y, 0, image_width / screenshot_width, image_height / screenshot_height);

		-- Draw separator
		x = x + image_width + margin;
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
		y = y + 50;

		-- Draw script callstack
		if script_traceback then
			x, y = draw_call_stack(x, y, script_traceback, location_text);
			y = y + 50;
		end

		-- Draw regular callstack
		x, y = draw_call_stack(x, y, traceback);
	end,
};
