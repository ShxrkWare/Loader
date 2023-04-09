Here it is, I didn't test, if there is some problem let me know! 
**Script to send all account information to a discord webhook!**

```lua
local WEBHOOK_URL = "" -- Set your webhook url
local MINUTES = 30 -- How often will send a discord webhook
local MAIN_ACCOUNT_NAME = "MyBeautifulUsername"
local MAIN_ACCOUNT_ID = "1234567896969"

-- First you will need to get the actual diamonds/gems you have in-game
local LocalPlayer = game.Players.LocalPlayer
local Library = require(game:GetService("ReplicatedStorage").Library) -- PSX Library

-- Lets save this to a folder with all our accounts
-- We can also set this to a loop
task.spawn(function() 
  while true do
    local Diamonds = Library.Save.Get().Diamonds -- Get save, and then Diamonds
    if not isfolder("accounts") then makefolder("accounts") end
    writefile("accounts/" .. LocalPlayer.Name .. ".txt", tostring(Diamonds))
    task.wait(1)
  end
end)

function SendDiscordWebhook()
    -- Check for webhook_url
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    local totalGems = 0
    if not isfolder("accounts") then return end
    for i, v in pairs(listfiles("accounts")) do
      local currentAccountDiamonds = readfile(v)
      if currentAccountDiamonds and tonumber(currentAccountDiamonds) then
        totalGems = totalGems + tonumber(currentAccountDiamonds)
      end
    end

    local embed = {
            ["title"] = "Total Gems",
            ["description"] = "💎 Total Gems/Diamonds: " .. tostring(totalGems)
        }
      
    -- Compatibility with Synapse and UNC executors (script-ware, krnl, WeAreDevs, Fluxus, Oxygen, Comet, etc...)  
    (syn and syn.request or http_request or http.request) {
        Url = WEBHOOK_URL,
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = HttpService:JSONEncode({
            embeds = {embed} 
        })
    }
end
  
-- Just one of the accounts need to handle the discord webhook, 
if game.Players.LocalPlayer.Name == MAIN_ACCOUNT_NAME then
-- Or you can use the UserId check:
-- if game.Players.LocalPlayer.UserId == MAIN_ACCOUNT_ID then
  task.spawn(function()
    while task.wait(MINUTES * 60) do 
      SendDiscordWebhook()
    end
  end)
end
```
