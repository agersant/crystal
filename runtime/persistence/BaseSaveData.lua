local BaseSaveData = Class("BaseSaveData");

BaseSaveData.init = function(self)
end

BaseSaveData.toPOD = function(self)
	return {};
end

BaseSaveData.fromPOD = function(self, pod)
	return BaseSaveData:new();
end

BaseSaveData.save = function(self)
end

BaseSaveData.load = function(self)
end

return BaseSaveData;
