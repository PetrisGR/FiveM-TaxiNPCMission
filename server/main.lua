local MissionCooldowns = {}
local ActiveMissions = {}
local PlayerTaxis = {}

local function MathRound(num)
    return math.floor(num + 0.5)
end

local function GetVector3(c)
    return vector3(c.x, c.y, c.z)
end

local function SpawnNetworkedVehicle(model, coords, cb)
    if type(model) == 'string' then model = joaat(model) end

    CreateThread(function()
        local Entity = Citizen.InvokeNative(`CREATE_AUTOMOBILE`, model, coords.x, coords.y, coords.z, coords.w)
        while not DoesEntityExist(Entity) do Wait(50) end
        SetVehicleNumberPlateText(Entity, Config.Settings["VehiclePlate"])
        cb(NetworkGetNetworkIdFromEntity(Entity))
    end)
end

local function SpawnNetworkedPed(model, coords, cb)
	if type(model) == 'string' then model = joaat(model) end

	CreateThread(function()
		local entity = CreatePed(0, model, coords.x, coords.y, coords.z + 1.0, coords.w, true, true)
		while not DoesEntityExist(entity) do Wait(50) end
        FreezeEntityPosition(entity, true)
		cb(NetworkGetNetworkIdFromEntity(entity))
	end)
end

local function DeleteCustomerPed(playerId)
    if ActiveMissions[playerId] then
        local entity = NetworkGetEntityFromNetworkId(ActiveMissions[playerId].ped)

        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
end

local function DeleteTaxiVehicle(playerId)
    if PlayerTaxis[playerId] then 
        local myTaxi = NetworkGetEntityFromNetworkId(PlayerTaxis[playerId])

        if DoesEntityExist(myTaxi) then
            DeleteEntity(myTaxi)
            PlayerTaxis[playerId] = nil
        end
    end
end

function StartTaxiMission(playerId)
    if not playerId then return end

    if not ActiveMissions[playerId] then
        if Config.Functions.CanStart(playerId) then
            if not MissionCooldowns[Config.Functions.GetIdentifier(playerId)] then
                if not PlayerTaxis[playerId] then
                    local dist = #(GetEntityCoords(GetPlayerPed(playerId)) - GetVector3(Config.Settings["VehicleSpawnPoint"]))

                    if dist < 424.0 then
                        SpawnNetworkedVehicle(Config.Settings["Vehicle"], Config.Settings["VehicleSpawnPoint"], function(networkId)
                            PlayerTaxis[playerId] = networkId
                            local routeId = math.random(1, #Config.Routes)
                            local ped = Config.PedModels[math.random(1, #Config.PedModels)]
                            local pickup = Config.Routes[routeId]["PickUp"]
                            local destination = Config.Routes[routeId]["Destination"]

                            SpawnNetworkedPed(ped, pickup, function(netId)
                                MissionCooldowns[Config.Functions.GetIdentifier(playerId)] = Config.Settings["Cooldown"]
                                local fareDistance = #(GetVector3(pickup) - destination)
                                local fare = MathRound(fareDistance * (Config.Settings['FarePerKilometer'] / 1000))
                                ActiveMissions[playerId] = {state = "started", route = routeId, destination = destination, ped = netId, fare = fare}
                                TriggerClientEvent('TaxiNPCMission:Client:Started', playerId, ActiveMissions[playerId].destination, ActiveMissions[playerId].ped, ActiveMissions[playerId].fare, PlayerTaxis[playerId], GetVector3(pickup), Config.Translation)
                            end)
                        end)
                    else
                        Config.Functions.SendNotification(playerId, Config.Translation['must_be_closer'])
                    end
                else
                    local myExistingTaxi = NetworkGetEntityFromNetworkId(PlayerTaxis[playerId])
                    if DoesEntityExist(myExistingTaxi) then
                        local dist = #(GetEntityCoords(GetPlayerPed(playerId)) - GetEntityCoords(myExistingTaxi))

                        if dist < 424.0 then
                            local routeId = math.random(1, #Config.Routes)
                            local ped = Config.PedModels[math.random(1, #Config.PedModels)]
                            local pickup = Config.Routes[routeId]["PickUp"]
                            local destination = Config.Routes[routeId]["Destination"]

                            SpawnNetworkedPed(ped, pickup, function(netId)
                                MissionCooldowns[Config.Functions.GetIdentifier(playerId)] = Config.Settings["Cooldown"]
                                local fareDistance = #(GetVector3(pickup) - destination)
                                local fare = MathRound(fareDistance * (Config.Settings['FarePerKilometer'] / 1000))
                                ActiveMissions[playerId] = {state = "started", route = routeId, destination = destination, ped = netId, fare = fare}
                                TriggerClientEvent('TaxiNPCMission:Client:Started', playerId, ActiveMissions[playerId].destination, ActiveMissions[playerId].ped, ActiveMissions[playerId].fare, PlayerTaxis[playerId], GetVector3(pickup), Config.Translation)
                            end)
                        else
                            Config.Functions.SendNotification(playerId, Config.Translation['must_be_closer_to_your_taxi'])
                        end
                    else
                        DeleteTaxiVehicle(playerId)
                        local dist = #(GetEntityCoords(GetPlayerPed(playerId)) - GetVector3(Config.Settings["VehicleSpawnPoint"]))
                        
                        if dist < 424.0 then
                            SpawnNetworkedVehicle(Config.Settings["Vehicle"], Config.Settings["VehicleSpawnPoint"], function(networkId)
                                PlayerTaxis[playerId] = networkId
                                local routeId = math.random(1, #Config.Routes)
                                local ped = Config.PedModels[math.random(1, #Config.PedModels)]
                                local pickup = Config.Routes[routeId]["PickUp"]
                                local destination = Config.Routes[routeId]["Destination"]

                                SpawnNetworkedPed(ped, pickup, function(netId)
                                    MissionCooldowns[Config.Functions.GetIdentifier(playerId)] = Config.Settings["Cooldown"]
                                    local fareDistance = #(GetVector3(pickup) - destination)
                                    local fare = MathRound(fareDistance * (Config.Settings['FarePerKilometer'] / 1000))
                                    ActiveMissions[playerId] = {state = "started", route = routeId, destination = destination, ped = netId, fare = fare}
                                    TriggerClientEvent('TaxiNPCMission:Client:Started', playerId, ActiveMissions[playerId].destination, ActiveMissions[playerId].ped, ActiveMissions[playerId].fare, PlayerTaxis[playerId], GetVector3(pickup), Config.Translation)
                                end)
                            end)
                        else
                            Config.Functions.SendNotification(playerId, Config.Translation['must_be_closer'])
                        end
                    end
                end
            else
                Config.Functions.SendNotification(playerId, Config.Translation['mission_cooldown'])
            end
        end
    else
        Config.Functions.SendNotification(playerId, Config.Translation['already_started'])
    end
end

function StopTaxiMission(playerId)
    if not playerId then return end

    if ActiveMissions[playerId] then
        DeleteCustomerPed(playerId)
        TriggerClientEvent('TaxiNPCMission:Client:ManualCancelled', playerId)
    end
end

RegisterServerEvent('TaxiNPCMission:Server:DeleteCustomer')
AddEventHandler('TaxiNPCMission:Server:DeleteCustomer', function(netId)
    local playerId = source
    local entity = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(entity) then DeleteEntity(entity) end
end)

RegisterServerEvent('TaxiNPCMission:Server:PickedUp')
AddEventHandler('TaxiNPCMission:Server:PickedUp', function()
    local playerId = source
    local currentMission = ActiveMissions[playerId]

    if not currentMission then return end

    ActiveMissions[playerId].state = "pickedup"
end)

RegisterServerEvent('TaxiNPCMission:Server:JobDone')
AddEventHandler('TaxiNPCMission:Server:JobDone', function()
    local playerId = source
    local currentMission = ActiveMissions[playerId]

    if not currentMission then return end
    if not currentMission.state == "dropoff" then return end 

    Config.Functions.PayDriver(playerId, currentMission.fare)
    Config.Functions.SendNotification(playerId, ""..Config.Translation['youve_been_paid']..""..currentMission.fare..""..Config.Translation['currency'].."")
    ActiveMissions[playerId] = nil
end)

RegisterServerEvent('TaxiNPCMission:Server:Stopped')
AddEventHandler('TaxiNPCMission:Server:Stopped', function(reason)
    local playerId = source
    local currentMission = ActiveMissions[playerId]
    ActiveMissions[playerId] = nil

    if reason == "vehicle_undriveable" or reason == "manual_cancel" then
        DeleteTaxiVehicle(playerId)
    end

    Config.Functions.SendNotification(playerId, Config.Translation['mission_cancelled'].." "..Config.Translation.Reasons[reason].."")
end)

CreateThread(function()
    while true do
        Wait(1500)
        local activeMissionFound = false
        local activeMissionPickedUp = false

        for k,v in pairs(ActiveMissions) do
            activeMissionFound = true

            if v.state == "pickedup" then
                activeMissionPickedUp = true

                if #(GetEntityCoords(GetPlayerPed(k)) - v.destination) < 5.0 then
                    ActiveMissions[k].state = "dropoff"
                end
            end
        end

        if not activeMissionPickedUp then Wait(3000) end
        if not activeMissionFound then Wait(7000) end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2500)
        for k,v in pairs(ActiveMissions) do
            local ped = NetworkGetEntityFromNetworkId(v.ped)

            if GetPedSourceOfDamage(ped) ~= 0 then
                TriggerClientEvent('TaxiNPCMission:Client:CustomerDamaged', k)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        for k,v in pairs(MissionCooldowns) do
            if v >= 1 then
                MissionCooldowns[k] = v - 1
            end

            if v == 0 then MissionCooldowns[k] = nil end
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    DeleteTaxiVehicle(playerId)
    DeleteCustomerPed(playerId)

    if ActiveMissions[playerId] then 
        ActiveMissions[playerId] = nil 
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    for k,v in pairs(PlayerTaxis) do
        local taxi = NetworkGetEntityFromNetworkId(v)

		if DoesEntityExist(taxi) then DeleteEntity(taxi) end
    end

    for k,v in pairs(ActiveMissions) do
        local ped = NetworkGetEntityFromNetworkId(v.ped)

        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)
