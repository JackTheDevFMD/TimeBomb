local display = false
local bombCoords = nil
local ped = nil
local bomb = nil
local defusalTime = 0


RegisterCommand("timebomb", function(source)

    -- Command to start the bomb placement.

    ped = PlayerPedId()
    bombCoords = GetEntityCoords(ped)

    SetDisplay(true)

end, false)


function clientBombFirst(time)

    -- Completes the animation for placing the bomb.
    -- This is only run for the person that ran the command.
    local dict = config.animationDictionary

    loadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, config.animationName, 8.0, 1.0, -1, 0, 1)

    TriggerServerEvent("TimeBomb:placeBomb", bombCoords, time, ped)  
end

RegisterNetEvent("placeBombClient")
AddEventHandler("placeBombClient", function(coords, timeToActivate, ped)

    -- Places the bomb for the clients

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

end)


RegisterNetEvent("blowUpBomb")
AddEventHandler("blowUpBomb", function()

    -- Blows up the bomb

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


RegisterNetEvent("bombTick")
AddEventHandler("bombTick", function(playerId)

    -- Checks the location of the player and the bomb
    -- If they are close to each other the sound will start. Otherwise it wont.

    local bombCoords = GetEntityCoords(bomb)
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

    if Vdist2(playerCoords, bombCoords) < 2*config.soundDistance then 
        PlaySoundFromEntity(-1, "5_SEC_WARNING", ped, "HUD_MINI_GAME_SOUNDSET", true, 0)
    end
end)



-- Defusale 

-- Hovering numbers countdown

RegisterNetEvent("displayTimeLeftNumber")
AddEventHandler("displayTimeLeftNumber", function(time)
    defusalTime = time
end)

RegisterNetEvent("displayTimeLeft")
AddEventHandler("displayTimeLeft", function(startNumber)

    -- Doesn't display to the other people :(
        
    defusalTime = 0

    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(0)
            if bomb ~= nil then 
                local bombCoords = GetEntityCoords(bomb)
                local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

                if Vdist2(playerCoords, bombCoords) < config.defuseDistance then 
                    Draw3DText(bombCoords.x, bombCoords.y, bombCoords.z+0.5, 0.5, tostring(defusalTime))
                end
            end
        end
    end)
end)




-- ## NUI ## -- 

RegisterNUICallback("buttonPress", function(data)

    -- Registeres the button press of the NUI and plays a sound.

    PlaySoundFromEntity(-1, "5_SEC_WARNING", ped, "HUD_MINI_GAME_SOUNDSET", true, 0)
end)

RegisterNUICallback("exit", function(data)

    -- Exits the NUI and deturmins whether a bomb has been planted or not.

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


-- A thread that contains whether the NUI is displayed, if so the user can not 
-- do those controls.
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