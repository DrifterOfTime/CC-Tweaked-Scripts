Reactor = {}

Reactor.logging = "v"

function Reactor.initialize()
	Reactor.adapter = peripheral.find("fissionReactorLogicAdapter")
	if Reactor.adapter == nil then
		Reactor.log("Reactor not found","e")
		return false
	end
	if not self.adapter.isFormed() then
		Reactor.log("Reactor not formed","e")
		return false
	end
	Reactor.log("Reactor successfully initialized")
	return true
end

function Reactor.activate()
	local isSafe, safetyMessage = self.checkSafety()
	if not isSafe then
		Reactor.log(safetyMessage,"e")
		return false, "Unsafe"
	else
		local status, err = pcall(self.adapter.activate)
		if status then
			Reactor.log("Reactor activated")
			return true
		else
			Reactor.log("Activation failed: " .. err,"e")
			return false, "Activation failed"
		end
	end
end

function Reactor.scram()
  Reactor.adapter.scram()
  Reactor.log("SCRAM")
end

function Reactor.checkSafety()
  return true
end

function Reactor.log(message, messageType)
	messageType = messageType or "n"
	if Reactor.logging == "q" then return true end
	local doLog = false
	messageHandler = io.stdout
	if messageType == "e" then
		messageHandler = io.stderr
		doLog = true
	elseif messageType == "n" then
		if Reactor.logging = "n" or self.logging = "v" then
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
end

-- returns bool, float or string
-- if true, float is recommended fuel rate change
-- if false, string is reason check failed
function Reactor.check()
	local formed = Reactor.adapter.isFormed()
	local active = Reactor.adapter.getStatus()
	if not formed then
		Reactor.log("Reactor not formed","e")
		return false, "Reactor not formed"
	end
	if not active then
		return false, "Reactor not active"
	end
	return true
end -- Reactor.check()

return Reactor