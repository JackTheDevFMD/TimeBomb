AddEventHandler('onResourceStart', function(resourceName)

    -- Ensures the resource name is correct so the NUI can work properly.

    if (GetCurrentResourceName() ~= config.resourceName ) then
        print("\n\n\n^8TIMEBOMB SCRIPT ERROR ^3\n\nPLEASE ENSURE THE NAME OF THE RESOURCE MATCHES THE NAME IN THE CONFIG.LUA^7\n\n\n")
    end
end)

RegisterNetEvent("TimeBomb:countDown")
AddEventHandler("TimeBomb:countDown", function(timeToActivate)

    -- Sets a countdown timer for the bomb to go off.

    TriggerClientEvent("displayTimeLeft", -1, timeToActivate)

    Citizen.CreateThread(function()
        local time = timeToActivate
        while (time ~= 0) do
            TriggerClientEvent("displayTimeLeftNumber", -1, time)
            Wait(1000)
            time = time - 1
        end

        TriggerClientEvent("blowUpBomb", -1)
    end)
end)

RegisterNetEvent("TimeBomb:countdownDisplay")
AddEventHandler("TimeBomb:countdownDisplay", function(time)
end)

RegisterNetEvent("TimeBomb:placeBomb")
AddEventHandler("TimeBomb:placeBomb", function(coords, timeToActivate, ped)

    -- Loops through all players within the server and send the player id to
    -- the clients, if the player is close enough to the bomb it will play a 
    -- sound. Otherwise it wont. It also places the bomb prop for all players.
    
    TriggerClientEvent("placeBombClient", -1, coords, timeToActivate, ped)

    Citizen.CreateThread(function()
        local time = timeToActivate

        while (time ~= 0) do
            for _, playerId in ipairs(GetPlayers()) do
                TriggerClientEvent("bombTick", playerId)
            end

            Wait(1000)
            time = time - 1
        end
    end)
end)
