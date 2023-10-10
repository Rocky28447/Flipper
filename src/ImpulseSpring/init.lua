local Spring = require(script.Spring)

local VELOCITY_THRESHOLD = 0.001
local POSITION_THRESHOLD = 0.001

local ImpulseSpring = {}
ImpulseSpring.ClassName = "ImpulseSpring"
ImpulseSpring.__index = ImpulseSpring

export type Options = {
	Damper: number,
	Position: number,
	Speed: number,
	Velocity: number,
}

function ImpulseSpring.new(TargetValue, PossibleOptions: Options?)
	assert(TargetValue, "Missing argument #1: targetValue")
	local Options = PossibleOptions or {}
	local Spring = Spring.new(Options.Position or 0)
	Spring.Damper = Options.Damper or 1
	Spring.Speed = Options.Speed or 1
	Spring.Velocity = Options.Velocity or 1
	Spring.Target = TargetValue

	return setmetatable({
		_Spring = Spring,
		_TargetValue = TargetValue,
	}, ImpulseSpring)
end

function ImpulseSpring:Step(State, DeltaTime)
	self._Spring.Target = self._TargetValue
	local Goal, Velocity1, Position1 = self._Spring.Target, self._Spring.Velocity, self._Spring.Position

	local Complete = math.abs(Velocity1) < VELOCITY_THRESHOLD and math.abs(Position1 - Goal) < POSITION_THRESHOLD

	return {
		complete = Complete,
		value = Complete and Goal or Position1,
		velocity = Velocity1,
	}
end

return ImpulseSpring
