AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= config.resourceName ) then
        print("\n\n\n^8TIMEBOMB SCRIPT ERROR ^3\n\nPLEASE ENSURE THE NAME OF THE RESOURCE MATCHES THE NAME IN THE CONFIG.LUA^7\n\n\n")
    end
end)

RegisterNetEvent("TimeBomb:countDown")
AddEventHandler("TimeBomb:countDown", function(timeToActivate, bomb)
    Citizen.CreateThread(function()
        local time = timeToActivate
        while (time ~= 0) do
            Wait(1000)
            time = time - 1
        end

        TriggerClientEvent("blowUpBomb", -1, bomb)
    end)
end)


RegisterNetEvent("TimeBomb:placeBomb")
AddEventHandler("TimeBomb:placeBomb", function(coords, timeToActivate, ped)
    TriggerClientEvent("placeBombClient", -1, coords, timeToActivate, ped)
end)