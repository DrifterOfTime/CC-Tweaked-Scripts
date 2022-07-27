Reactor = {}

Reactor.logging = "v"

----------------------------------------------------
-- Logging
----------------------------------------------------

function Reactor.log(message, messageType)
	messageType = messageType or "n"
	if Reactor.logging == "q" then return true end
	local doLog = false
	messageHandler = io.stdout
	if messageType == "e" then
		messageHandler = io.stderr
		doLog = true
	elseif messageType == "n" then
		if Reactor.logging = "n" or Reactor.logging = "v" then
			doLog = true
		end
	elseif messageType == "v" then
		if Reactor.logging == "v" then
			doLog = true
		end
	end
	if doLog then
		messageHandler:write(message .. "\n")
		return true
	end
	return false
end -- Reactor.log()

----------------------------------------------------
-- Getters
----------------------------------------------------

function Reactor.getBurnRate()
	return Reactor.adapter.getBurnRate()
end -- Reactor.getBurnRate()

function Reactor.getBurnRateMax()
	return Reactor.adapter.getMaxBurnRate()
end -- Reactor.getBurnRateMax()

function Reactor.getCoolant()
	return Reactor.adapter.getCoolant()
end -- Reactor.getCoolant()

function Reactor.getCoolantMax()
	return Reactor.adapter.getCoolantCapacity()
end -- Reactor.getCoolantMax()

function Reactor.getDamagePercent()
	return Reactor.adapter.getDamagePercent()
end -- Reactor.getDamagePercent()

function Reactor.getFuel()
	return Reactor.adapter.getFuel()
end -- Reactor.getFuel()

function Reactor.getFuelMax()
	return Reactor.adapter.getFuelCapacity()
end -- Reactor.getFuelMax()

function Reactor.getTemperature()
	return Reactor.adapter.getTemperature()
end -- Reactor.getTemperature()

function Reactor.getTemperatureMax()
	return Reactor.adapter.getHeatCapacity()
end -- Reactor.getTemperatureMax()

function Reactor.getHeatedCoolant()
	return Reactor.adapter.getHeatedCoolant()
end -- Reactor.getHeatedCoolant()

function Reactor.getHeatedCoolantMax()
	return Reactor.adapter.getHeatedCoolantCapacity()
end -- Reactor.getHeatedCoolantMax()

function Reactor.getHeatingRate()
	return Reactor.adapter.getHeatingRate()
end -- Reactor.getHeatingRate()

function Reactor.getWaste()
	return Reactor.adapter.getWaste()
end -- Reactor.getWaste()

function Reactor.getWasteMax()
	return Reactor.adapter.getWasteCapacity()
end -- Reactor.getWasteMax()

function Reactor.isActive()
	return Reactor.adapter.getStatus()
end -- Reactor.isActive()

function Reactor.isFormed()
	return Reactor.adapter.isFormed()
end -- Reactor.isFormed()

----------------------------------------------------
-- Setters
----------------------------------------------------

function Reactor.setBurnRate(rate)
	return Reactor.adapter.setBurnRate(rate)
end -- Reactor.setBurnRate()

----------------------------------------------------
-- Misc Simple Functions
----------------------------------------------------

function Reactor.scram()
	return Reactor.adapter.scram()
end -- Reactor.scram()

----------------------------------------------------
-- Main Functions
----------------------------------------------------

function Reactor.initialize()
	Reactor.adapter = peripheral.find("fissionReactorLogicAdapter")
	if Reactor.adapter == nil then
		Reactor.log("Reactor not found","e")
		return false
	end
	if not Reactor.isFormed() then
		Reactor.log("Reactor not formed","e")
		return false
	end
	Reactor.log("Reactor successfully initialized")
	return true
end -- Reactor.initialize()

function Reactor.activate()
	local check = Reactor.check()
	if check < 0 then
		Reactor.log(safetyMessage,"e")
		return false
	else
		local status, err = pcall(Reactor.adapter.activate)
		if status then
			Reactor.log("Reactor activated","v")
			return true
		else
			Reactor.log("Activation failed: " .. err,"e")
			return false
		end
	end
end -- Reactor.activate()

function Reactor.check()
	local formed = Reactor.isFormed()
	local active = Reactor.isActive()
	if not formed then
		Reactor.log("Reactor not formed", "e")
		return false
	end
	if not active then
		Reactor.log("Reactor not active", "e")
		return false
	end
	return true
end -- Reactor.check()

function Reactor.adjust(burnRateDelta)
	burnRate = Reactor.adapter.getBurnRate()
	if burnRate < 0.1 then
		Reactor.log("Stopping Reactor")
		Reactor.scram()
	end
	Reactor.setBurnRate(burnRate + burnRateDelta)
end

return Reactor