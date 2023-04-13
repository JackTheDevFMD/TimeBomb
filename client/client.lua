local display = false
local bombCoords = nil
local ped = nil


RegisterCommand("timebomb", function(source)
    ped = GetPlayerPed(source)
    bombCoords = GetEntityCoords(ped)

    SetDisplay(true)

end, false)


function clientBombFirst(time)
    local dict = "weapons@projectile@sticky_bomb"
    loadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, "plant_floor", 8.0, 1.0, -1, 0, 1)

    TriggerServerEvent("TimeBomb:placeBomb", bombCoords, time, ped)  
end

RegisterNetEvent("placeBombClient")
AddEventHandler("placeBombClient", function(coords, timeToActivate, ped)
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

    TriggerServerEvent("TimeBomb:countDown", timeToActivate, bomb)

    Citizen.CreateThread(function()
        local time = timeToActivate

        while (time ~= 0) do 
            
            PlaySoundFromEntity(-1, "5_SEC_WARNING", bomb, "HUD_MINI_GAME_SOUNDSET", false, 0)
            Wait(1000)
            time = time - 1

        end
    end)

end)


RegisterNetEvent("blowUpBomb")
AddEventHandler("blowUpBomb", function(bomb)
    local bombCoords = GetEntityCoords(bomb)

    AddExplosion(
        bombCoords.x, 
        bombCoords.y+0.5, 
        bombCoords.z,
        32,
        150000.0,
        true,
        false,
        0.4
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

RegisterNUICallback("buttonPress", function(data)
    PlaySoundFromEntity(-1, "5_SEC_WARNING", ped, "HUD_MINI_GAME_SOUNDSET", true, 0)
end)

RegisterNUICallback("exit", function(data)
    local time = nil

    SetDisplay(false)
    if data.text ~= "none" and data.text ~= "escape" then 
        time2 = string.gsub(data.text, ":", "")
        TriggerEvent("chat:addMessage", {
            args = {"^2[Time Bomb]^1 Bomb placed. It will detonate in "..tonumber(time2).." seconds."}
        })
        clientBombFirst(time2) 
    end
end)

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