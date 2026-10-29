local RunService = cloneref(game:GetService("RunService"))

local ActiveTweens = {}
local CustomLinearTween = {}

CustomLinearTween.__index = CustomLinearTween

function CustomLinearTween.Create(Instance, TargetValue, Speed)
    if not Instance then
        return
    end

    if Speed <= 0 then
        if ActiveTweens[Instance] then
            if ActiveTweens[Instance].Connection then
                ActiveTweens[Instance].Connection:Disconnect()
            end

            ActiveTweens[Instance] = nil
        end

        if typeof(TargetValue) == "CFrame" and Instance:IsA("BasePart") then
            Instance.CFrame = TargetValue
        elseif typeof(TargetValue) == "Vector3" and Instance:IsA("BasePart") then
            Instance.Position = TargetValue
        end

        return
    end

    if ActiveTweens[Instance] then
        if ActiveTweens[Instance].Target == TargetValue then
            return
        else
            ActiveTweens[Instance].Connection:Disconnect()
        end
    end

    local TweenState = { Target = TargetValue, Connection = nil }
    ActiveTweens[Instance] = TweenState

    TweenState.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        if not Instance.Parent or ActiveTweens[Instance] ~= TweenState then
            TweenState.Connection:Disconnect()
            return
        end

        if Instance:IsA("BasePart") then
            local CurrentPos = Instance.Position
            local TargetPos = (typeof(TargetValue) == "CFrame") and TargetValue.Position or TargetValue
            local Distance = (TargetPos - CurrentPos).Magnitude
            local MaxFrameDistance = Speed * DeltaTime

            if Distance <= MaxFrameDistance then
                TweenState.Connection:Disconnect()
                ActiveTweens[Instance] = nil

                if typeof(TargetValue) == "CFrame" then
                    Instance.CFrame = TargetValue
                else
                    Instance.Position = TargetValue
                end

                return
            end

            local Direction = (TargetPos - CurrentPos).Unit
            local NewPosition = CurrentPos + (Direction * MaxFrameDistance)

            if typeof(TargetValue) == "CFrame" then
                Instance.CFrame = CFrame.new(NewPosition) * TargetValue.Rotation
            else
                Instance.Position = NewPosition
            end
        end
    end)
end

function CustomLinearTween.Clear()
    for Instance, TweenState in ActiveTweens do
        if TweenState.Connection then
            TweenState.Connection:Disconnect()
        end
    end

    table.clear(ActiveTweens)
end

return CustomLinearTween
