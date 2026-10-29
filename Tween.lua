local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))

local LocalPlayer = Players.LocalPlayer

local CustomTween, ActiveTweens = {}, {}
local NoClipConnection = nil

CustomTween.__index = CustomTween

function CustomTween.Body(NoClip, BodyVelocity, PlatformStand)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

    if Humanoid then
        Humanoid.PlatformStand = PlatformStand
    end

    if NoClip then
        if not NoClipConnection then
            NoClipConnection = RunService.Heartbeat:Connect(function()
                local NewCharacter = LocalPlayer.Character

                if NewCharacter then
                    for _, Part in NewCharacter:GetChildren() do
                        if Part:IsA("BasePart") then
                            Part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
    end

    if BodyVelocity and HumanoidRootPart then
        local Ssamachi = HumanoidRootPart:FindFirstChild("Ssamachi")

        if not Ssamachi then
            local NewBodyVelocity = Instance.new("BodyVelocity", HumanoidRootPart)
            NewBodyVelocity.Name = "Ssamachi"
            NewBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            NewBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
    else
        if HumanoidRootPart then
            local Ssamachi = HumanoidRootPart:FindFirstChild("Ssamachi")

            if Ssamachi then
                Ssamachi:Destroy()
            end
        end
    end
end

function CustomTween.Create(TargetInstance, TargetValue, Speed)
    if not TargetInstance then
        return
    end

    local HumanoidRootPart = TargetInstance:IsA("Model") and TargetInstance:FindFirstChild("HumanoidRootPart") or TargetInstance

    if not HumanoidRootPart or not HumanoidRootPart:IsA("BasePart") then
        return
    end

    if Speed <= 0 then
        if ActiveTweens[HumanoidRootPart] then
            if ActiveTweens[HumanoidRootPart].Connection then
                ActiveTweens[HumanoidRootPart].Connection:Disconnect()
            end

            ActiveTweens[HumanoidRootPart] = nil
        end

        if typeof(TargetValue) == "CFrame" then
            HumanoidRootPart.CFrame = TargetValue
        elseif typeof(TargetValue) == "Vector3" then
            HumanoidRootPart.Position = TargetValue
        end

        return
    end

    if ActiveTweens[HumanoidRootPart] then
        if ActiveTweens[HumanoidRootPart].Target == TargetValue then
            return
        else
            ActiveTweens[HumanoidRootPart].Connection:Disconnect()
        end
    end

    local TweenState = { Target = TargetValue, Connection = nil }
    ActiveTweens[HumanoidRootPart] = TweenState

    TweenState.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        if not HumanoidRootPart.Parent or ActiveTweens[HumanoidRootPart] ~= TweenState then
            TweenState.Connection:Disconnect()
            return
        end

        local CurrentPos = HumanoidRootPart.Position
        local TargetPos = (typeof(TargetValue) == "CFrame") and TargetValue.Position or TargetValue
        local Distance = (TargetPos - CurrentPos).Magnitude
        local MaxFrameDistance = Speed * DeltaTime

        if Distance <= MaxFrameDistance then
            TweenState.Connection:Disconnect()
            ActiveTweens[HumanoidRootPart] = nil
            
            if typeof(TargetValue) == "CFrame" then
                HumanoidRootPart.CFrame = TargetValue
            else
                HumanoidRootPart.Position = TargetValue
            end

            return
        end

        local Direction = (TargetPos - CurrentPos).Unit
        local NewPosition = CurrentPos + (Direction * MaxFrameDistance)

        if typeof(TargetValue) == "CFrame" then
            HumanoidRootPart.CFrame = CFrame.new(NewPosition) * TargetValue.Rotation
        else
            HumanoidRootPart.Position = NewPosition
        end
    end)
end

function CustomTween.Clear()
    for Instance, TweenState in ActiveTweens do
        if TweenState.Connection then
            TweenState.Connection:Disconnect()
        end
    end

    table.clear(ActiveTweens)
end

return CustomTween
