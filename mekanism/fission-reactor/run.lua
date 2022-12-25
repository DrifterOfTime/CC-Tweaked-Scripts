local reactor = require("Reactor")

reactor:initialize()

while true do
	reactorStatus = reactor:check()
	if not reactorStatus then
		error("Not Active")
	end
	reactor:adjust(-0.1)
end