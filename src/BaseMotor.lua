local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Parent.Signal)

local noop = function() end

--[=[
	@interface MotorState
	@within BaseMotor
	@field value number
	@field velocity number
	@field complete boolean
]=]

--[=[
	@class BaseMotor

	Base class for SingleMotor and GroupMotor, manages connections to RunService.
]=]
local BaseMotor = {}
BaseMotor.__index = BaseMotor

function BaseMotor.new()
	return setmetatable({
		_onStep = Signal.new(),
		_onStart = Signal.new(),
		_onComplete = Signal.new(),
	}, BaseMotor)
end

--[=[
	Fired when the motor's state updates.

	@param handler (state: unknown) -> nil
	@return Connection
]=]
function BaseMotor:OnStep(handler)
	return self._onStep:Connect(handler)
end

--[=[
	Fired whenever BaseMotor:start() is called.

	If `useImplicitConnections` is set to true, this will be called whenever setGoal is called.

	@param handler () -> nil
	@return Connection
]=]
function BaseMotor:OnStart(handler)
	return self._onStart:Connect(handler)
end

--[=[
	Fired whenever a motor finishes.

	It's recommended to use onStep and check for a certain threshold (i.e. 99% of the way there) instead of using this, as it can often take a while to fire.

	@param handler () -> nil
	@return Connection
]=]
function BaseMotor:OnComplete(handler)
	return self._onComplete:Connect(handler)
end

--[=[
	Creates a connection to RunService if there isn't one already.

	@return nil
]=]
function BaseMotor:Start()
	if not self._connection then
		self._connection = RunService.RenderStepped:Connect(function(deltaTime)
			self:Step(deltaTime)
		end)
	end
end

--[=[
	Removes the connection to RunService if it exists.

	@return nil
]=]
function BaseMotor:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

BaseMotor.Destroy = BaseMotor.Stop

BaseMotor.Step = noop
BaseMotor.GetValue = noop
BaseMotor.SetGoal = noop

--[=[
	Returns the type of motor. Used for isMotor.

	@return string
]=]
function BaseMotor:__tostring()
	return "Motor"
end

return BaseMotor
