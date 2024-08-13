-- Config
local openDistance = 3.0 -- Die maximale Entfernung, um die Tür zu öffnen

-- Hauptfunktion, die die Tür öffnet
RegisterCommand('opendoor', function()
    local playerPed = PlayerPedId()
    local vehicle = GetClosestVehicleInDirection(playerPed)

    if vehicle then
        local doorIndex = GetClosestVehicleDoor(vehicle, playerPed)

        if doorIndex ~= -1 then
            -- Animation starten
            TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

            -- Warten, bis die Animation abgespielt ist
            Citizen.Wait(1500)
print(vehicle)
            -- Tür öffnen
            SetVehicleDoorOpen(vehicle, doorIndex, false, false)

            -- Animation stoppen
            ClearPedTasksImmediately(playerPed)
        else
            TriggerEvent('chat:addMessage', {
                args = {'^1Es gibt keine Tür in der Nähe, die geöffnet werden kann.'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            args = {'^1Kein Fahrzeug in der Nähe gefunden.'}
        })
    end
end, false)

-- Funktion, um das nächste Fahrzeug zu finden
function GetClosestVehicleInDirection(playerPed)
    local pos = GetEntityCoords(playerPed)
    local frontPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, openDistance, 0.0)
    local rayHandle = StartShapeTestRay(pos.x, pos.y, pos.z, frontPos.x, frontPos.y, frontPos.z, 10, playerPed, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- Funktion, um die nächste Tür zu finden
function GetClosestVehicleDoor(vehicle, playerPed)
    local minDistance = 9999
    local doorIndex = -1
    local playerPos = GetEntityCoords(playerPed)

    for i = 0, GetNumberOfVehicleDoors(vehicle) - 1 do
        local doorPos = GetEntryPositionOfDoor(vehicle, i)
        local distance = #(doorPos - playerPos)

        if distance < minDistance then
            minDistance = distance
            doorIndex = i
        end
    end

    if minDistance <= openDistance then
        return doorIndex
    else
        return -1
    end
end

-- Funktion, um die Türposition zu bekommen
function GetEntryPositionOfDoor(vehicle, doorIndex)
    local boneName = GetEntityBoneIndexByName(vehicle, 'door_dside_f')
    if doorIndex == 1 then
        boneName = GetEntityBoneIndexByName(vehicle, 'door_pside_f')
    elseif doorIndex == 2 then
        boneName = GetEntityBoneIndexByName(vehicle, 'door_dside_r')
    elseif doorIndex == 3 then
        boneName = GetEntityBoneIndexByName(vehicle, 'door_pside_r')
    end

    return GetWorldPositionOfEntityBone(vehicle, boneName)
end
