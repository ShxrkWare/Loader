getgenv().enabled = true


local plr = game.Players.LocalPlayer

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

function getShark()
    return game:GetService("Workspace").Sharks:GetChildren()[1]
end

local gunRemote
for i,v in pairs(getgc()) do
    if type(v) == 'function' and islclosure(v) and not(is_synapse_function(v)) then
        if getinfo(v).name == 'reportHit' and getinfo(v).source:match("Turret") == nil then
            gunRemote = getupvalue(v, 2)
            break
        end
    end
end

local shark = getShark()
local tool = plr.Backpack:FindFirstChildWhichIsA("Tool") or plr.Character:FindFirstChildWhichIsA("Tool")

local debug = false

task.spawn(function()
    while debug and enabled do
        task.wait(5)
        print(debug)
    end
end)

local old
old = hookmetamethod(game, '__namecall', function(self, ...)
    if self.Name == 'ToggleSpectator' then
        return
    end
    return old(self, ...)
end)

function killPlayers()
    local shark = getShark()
    if tostring(plr.Team) == 'Shark' and shark then
        if isnetworkowner(shark.SharkMain.Engine) then
            print(shark)
            for i,v in pairs(game.Players:GetChildren()) do
                shark.SharkMain.Engine.CFrame = v.Character.HumanoidRootPart.CFrame
                
                task.wait(0.2)

                local player = v.Character
                local sharkInstance = shark
                game:GetService("ReplicatedStorage").EventsFolder.Shark.Kill:InvokeServer(player, sharkInstance)
                
                task.wait(0.2)
                
            end
        end
    end
end

while task.wait() and enabled do
    while plr.Character == nil or plr.Character:FindFirstChild("Humanoid") == nil or plr.Character:FindFirstChild("HumanoidRootPart") == nil do
        task.wait()
    end
    
    if shark and tool then
        
        if tool.Parent ~= plr.Character and tool.Parent ~= nil then
            tool.Parent = plr.Character
            debug = 'setting tool parent to char'
        end
        
        plr.Character.Humanoid.Sit = false
        debug = 'unsat humaonid'
        
        if shark:FindFirstChild("SharkMain") then
            debug = 'killing shark'
            plr.Character.HumanoidRootPart.CFrame = shark.SharkMain.Engine.CFrame * CFrame.new(0, 20, 20)
            
            local belowPlayer = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0)
            
            game:GetService("ReplicatedStorage").Projectiles.Events.Weapons.HitScanFire:FireServer(belowPlayer.p)
            gunRemote:FireServer(shark)
            game:GetService("ReplicatedStorage").Projectiles.Events.Weapons.HitScanEnded:FireServer()
        else
           shark = nil 
        end
    else
        repeat 
            task.wait()
            shark = getShark()
            tool = plr.Backpack:FindFirstChildWhichIsA("Tool")
            
            -- if tostring(plr.Team) == 'Shark' then
            --     debug = 'killing players'
            --     killPlayers()
            -- end
            
            debug  = 'waiting for shark and tool'
            
        until shark ~= nil and tool ~= nil
    end
end
