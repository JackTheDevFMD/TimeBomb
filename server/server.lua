RegisterNetEvent("countDown")
AddEventHandler("countDown", function(timeToActivate, bomb)
    Citizen.CreateThread(function()
        local time = timeToActivate -- 10 seconds
        while (time ~= 0) do -- Whist we have time to wait
            Wait( 1000 ) -- Wait a second
            time = time - 1
            -- 1 Second should have past by now
            print(time)
        end

        TriggerClientEvent("blowUpBomb", -1, bomb)
    end)
end)


RegisterNetEvent("placeBomb")
AddEventHandler("placeBomb", function(coords, timeToActivate, ped)
    TriggerClientEvent("placeBombClient", -1, coords, timeToActivate, ped)
end)