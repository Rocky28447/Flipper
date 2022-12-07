local TweenService = game:GetService("TweenService")

local TWEEN_DEFAULT = TweenInfo.new()
local TWEEN_BEGIN = Enum.PlaybackState.Begin
local TWEEN_PAUSED = Enum.PlaybackState.Paused
local TWEEN_COMPLETED = Enum.PlaybackState.Completed

local Tween = {}
Tween.ClassName = "Tween"
Tween.__index = Tween

export type TweenProperties = {
	_tweenObject: NumberValue?,
	_tween: Tween?,

	_targetValue: number,
	_initialValue: number | boolean,
}

function Tween.new(targetValue: number, tweenInfo: TweenInfo?)
	assert(targetValue, "Missing argument #1: targetValue")

	local tweenObject = Instance.new("NumberValue")

	local tweenProperties: TweenProperties = {
		_tweenObject = tweenObject,
		_tween = TweenService:Create(tweenObject, tweenInfo or TWEEN_DEFAULT, { Value = targetValue }),

		_targetValue = targetValue,
		_initialValue = false,
	}

	return setmetatable(tweenProperties, Tween)
end

function Tween:Step(state, _delta)
	local tween = self._tween
	local tweenObject = self._tweenObject
	local playbackState = tween.PlaybackState

	if not self._initialValue then
		self._initialValue = state.value
		tweenObject.Value = self._initialValue
	end

	if playbackState == TWEEN_BEGIN or playbackState == TWEEN_PAUSED then
		tweenObject.Value = state.value
		tween:Play()
	elseif playbackState == TWEEN_COMPLETED then
		tweenObject:Destroy()
		tween:Destroy()

		self._tweenObject:Destroy()
		self._tween:Destroy()

		self._tweenObject = nil
		self._tween = nil
		self._targetValue = nil
		self._initialValue = nil
	end

	while self._initialValue and tweenObject.Value == state.value do
		task.wait()
	end

	tween:Pause()

	return {
		complete = playbackState == TWEEN_COMPLETED,
		value = tweenObject.Value,
	}
end

return Tween
