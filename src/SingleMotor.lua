local BaseMotor = require(script.Parent.BaseMotor)

--[=[
	Motor representing a single value.

	See also: [BaseMotor](BaseMotor)

	@class SingleMotor
]=]
local SingleMotor = setmetatable({}, BaseMotor)
SingleMotor.__index = SingleMotor

--[=[
	Creates a new SingleMotor.

	@param initialValue number
	@param useImplicitConnections boolean -- Should connections to RunService be automatically managed?
	@return SingleMotor
]=]
function SingleMotor.new(initialValue: number, useImplicitConnections: boolean)
	assert(initialValue, "Missing argument #1: initialValue")
	assert(typeof(initialValue) == "number", "initialValue must be a number!")

	local self = setmetatable(BaseMotor.new(), SingleMotor)

	if useImplicitConnections ~= nil then
		self._useImplicitConnections = useImplicitConnections
	else
		self._useImplicitConnections = true
	end

	self._goal = nil
	self._state = {
		complete = true,
		value = initialValue,
	}

	return self
end

--[=[
	Advances the motor forward by a given time.

	@param deltaTime number
	@return boolean -- Is the motor complete?
]=]
function SingleMotor:Step(deltaTime)
	if self._state.complete then
		return true
	end

	local newState = self._goal:Step(self._state, deltaTime)

	self._state = newState
	self._onStep:Fire(newState.value)

	if newState.complete then
		if self._useImplicitConnections then
			self:Stop()
		end

		self._onComplete:Fire()
	end

	return newState.complete
end

--[=[
	Returns the current value of the SingleMotor.

	@return number
]=]
function SingleMotor:GetValue()
	return self._state.value
end

--[=[
	Sets the target goal and hooks up a new connection if useImplicitConnections is enabled.

	@param goal Goal
	@return nil
]=]
function SingleMotor:SetGoal(goal)
	self._state.complete = false
	self._goal = goal

	self._onStart:Fire()

	if self._useImplicitConnections then
		self:Start()
	end
end

--[=[
	Returns the type of motor. Used for isMotor.

	@return string
]=]
function SingleMotor:__tostring()
	return "Motor(Single)"
end

return SingleMotor
