local InputContext = Class("InputContext");

InputContext.init = function(self, context, commands)
	assert(context);
	self._context = context;
	if commands then
		self._commands = {};
		for i, command in ipairs(commands) do
			self._commands[command] = true;
		end
	end
end

InputContext.getContext = function(self)
	return self._context;
end

InputContext.isCommandRelevant = function(self, command)
	if not self._commands then
		return true;
	end
	return self._commands[command];
end

return InputContext;
