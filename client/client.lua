--[[
## Beta ## 

Command to activate bomb

/timebomb time_to_activate size

## Release ##

NUI to set time and size

]]

local display = false


RegisterCommand("timebomb", function(source, args)
    local timeToActivate = args[1]
    local size = args[2]
    local ped = GetPlayerPed(source)

    local bombCoords = GetEntityCoords(ped)

    -- Animation 
    local dict = "weapons@projectile@sticky_bomb"
    loadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, "plant_floor", 8.0, 1.0, -1, 0, 1)

    SetDisplay(true)

    TriggerServerEvent("placeBomb", bombCoords, timeToActivate, size, ped)

end, false)


RegisterNetEvent("placeBombClient")
AddEventHandler("placeBombClient", function(coords, timeToActivate, size, ped)
    local bombProp = config.bombModel
    local bombCoords = coords

    if not HasModelLoaded(bombProp) then
        -- If the model isnt loaded we request the loading of the model and wait that the model is loaded
        RequestModel(bombProp)
    
        while not HasModelLoaded(bombProp) do
            Citizen.Wait(1)
        end
    end

    Citizen.Wait(700) -- Wait till the client puts the bomb down

    local bonePos = GetPedBoneCoords(ped, 6286)

    bomb = CreateObject(bombProp, bonePos.x, bonePos.y, bonePos.z, true, false, false)
    PlaceObjectOnGroundProperly(bomb)

    TriggerServerEvent("countDown", timeToActivate, size, bomb)

    Citizen.CreateThread(function()
        local time = timeToActivate

        while (time ~= 0) do 
            
            PlaySoundFromEntity(-1, "5_SEC_WARNING", bomb, "HUD_MINI_GAME_SOUNDSET", true, 0)
            Wait(1000)
            time = time - 1

        end
    end)

end)

-- AUDIO_ITEM_STICKYBOMB

RegisterNetEvent("blowUpBomb")
AddEventHandler("blowUpBomb", function(bomb, size)
    local bombCoords = GetEntityCoords(bomb)

    AddExplosion(
        bombCoords.x, 
        bombCoords.y+0.5, 
        bombCoords.z,
        32,
        150000.0,
        true,
        false,
        size
    )

    DeleteEntity(bomb)
end)

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end


Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)

        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)