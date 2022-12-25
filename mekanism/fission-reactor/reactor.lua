Reactor = {}

Reactor.logging = "v"

----------------------------------------------------
-- Logging
----------------------------------------------------

function Reactor:log(message, messageType)
	messageType = messageType or "n"
	if self.logging == "q" then return true end
	local doLog = false
	messageHandler = io.stdout
	if messageType == "e" then
		messageHandler = io.stderr
		doLog = true
	elseif messageType == "n" then
		if self.logging == "n" or "v" then
			doLog = true
		end
	elseif messageType == "v" then
		if self.logging == "v" then
			doLog = true
		end
	end
	if doLog then
		messageHandler:write(message .. "\n")
		return true
	end
	return false
end -- Reactor:log()

----------------------------------------------------
-- Getters
----------------------------------------------------

function Reactor:getBurnRate()
	local burnRate = {}
	burnRate["amount"] = self.adapter.getBurnRate()
	burnRate["actual"] = self.adapter.getActualBurnRate()
	burnRate["max"] = self.adapter.getMaxBurnRate()
	return burnRate
end -- Reactor:getBurnRate()

function Reactor:getCoolant()
	local coolant = self.adapter.getCoolant()
	coolant["max"] = self.adapter.getCoolantCapacity()
	return coolant
end -- Reactor:getCoolant()

function Reactor:getDamagePercent()
	return self.adapter.getDamagePercent()
end -- Reactor:getDamagePercent()

function Reactor:getFuel()
	local fuel = self.adapter.getFuel()
	fuel["max"] = self.adapter.getFuelCapacity()
	return fuel
end -- Reactor:getFuel()

function Reactor:getTemperature()
	temperature["amount"] = self.adapter.getTemperature()
	temperature["max"] = self.adapter.getHeatCapacity()
	return 
end -- Reactor:getTemperature()

function Reactor:getHeatedCoolant()
	local heatedCoolant = self.adapter.getHeatedCoolant()
	heatedCoolant["max"] = self.adapter.getHeatedCoolantCapacity()
	return heatedCoolant
end -- Reactor:getHeatedCoolant()

function Reactor:getHeatingRate()
	return self.adapter.getHeatingRate()
end -- Reactor:getHeatingRate()

function Reactor:getWaste()
	local waste = self.adapter.getWaste()
	waste["max"] = self.adapter.getWasteCapacity()
	return waste
end -- Reactor:getWaste()

function Reactor:isActive()
	return self.adapter.getStatus()
end -- Reactor:isActive()

function Reactor:isFormed()
	return self.adapter.isFormed()
end -- Reactor:isFormed()

----------------------------------------------------
-- Setters
----------------------------------------------------

function Reactor:setBurnRate(rate)
	return self.adapter.setBurnRate(rate)
end -- Reactor:setBurnRate()

----------------------------------------------------
-- Misc Simple Functions
----------------------------------------------------

function Reactor:scram()
	return self.adapter.scram()
end -- Reactor:scram()

----------------------------------------------------
-- Main Functions
----------------------------------------------------

function Reactor:initialize()
	self.adapter = peripheral.find("fissionReactorLogicAdapter")
	if self.adapter == nil then
		self:log("Reactor not found","e")
		return false
	end
	if not self:isFormed() then
		self:log("Reactor not formed","e")
		return false
	end
	self:log("Reactor successfully initialized")
	return true
end -- Reactor:initialize()

function Reactor:activate()
	local check = self:check()
	if check < 0 then
		self:log(safetyMessage,"e")
		return false
	else
		local status, err = pcall(self.adapter.activate)
		if status then
			self:log("Reactor activated","v")
			return true
		else
			self:log("Activation failed: " .. err,"e")
			return false
		end
	end
end -- Reactor:activate()

function Reactor:check()
	local formed = self:isFormed()
	local active = self:isActive()
	if not formed then
		self:log("Reactor not formed", "e")
		return false
	end
	if not active then
		self:log("Reactor not active", "e")
		return false
	end
	return true
end -- Reactor:check()

function Reactor:adjust(burnRateDelta)
	local burnRate = self:getBurnRate()
	local fuel = self:getFuel()
	if not previousFuelAmount then
		fuelDrainRateFirstDifference = fuel["amount"]
	else
		fuelDrainRateFirstDifference = fuel["amount"] - previousFuelAmount
	end
	previousFuelAmount = fuel["amount"] 
	if burnRate < 0.1 then
		self:log("Stopping Reactor")
		self:scram()
	end
	self:setBurnRate(burnRate + burnRateDelta)
end

return Reactor