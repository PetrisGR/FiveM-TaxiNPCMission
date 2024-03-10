local API_ProgressBar = exports[GetCurrentResourceName()]:GetAPI()

local ScriptData = {
    ["State"] = "idle",
    ["StoppedMission"] = false,
    ["TextDisplayed"] = false,
    ["PickUpLocation"] = nil,
    ["DriveCustomerMessage"] = "",
    ["CurrentFareTxt"] = "",
    ["NetworkIds"] = {["taxi"] = nil, ["customer"] = nil},
    ["CustomerBlip"] = nil,
    ["DestinationBlip"] = nil,
    ["Destination"] = nil,
    ["TaxiBlip"] = nil,
    ["FareBar"] = nil,
    ["MyCustomer"] = nil,
    ["MyTaxi"] = nil,
    ["NotInTaxi"] = false,
}

local function DrawSubtitle(msg)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint((60 * 60000), 1)
end

local function ShowHelpNotification(msg)
    AddTextEntry('TaxiNPCMission_HelpNotification', msg)
    DisplayHelpTextThisFrame('TaxiNPCMission_HelpNotification', false)
end

local function ShowCabNotification(msg) 
    AddTextEntry('TaxiNPCMission_notification', msg)
    BeginTextCommandThefeedPost('TaxiNPCMission_notification')
    ThefeedSetNextPostBackgroundColor(184)
	EndTextCommandThefeedPostMessagetext("CHAR_TAXI", "CHAR_TAXI", true, 1, "Downtown Cab Co.", "New Customer")
	EndTextCommandThefeedPostTicker(true, false)
end

local function GetVector3(c)
    return vector3(c.x, c.y, c.z)
end

local function DestroyCustomerBlip()
    if ScriptData["CustomerBlip"] then RemoveBlip(ScriptData["CustomerBlip"]) ScriptData["CustomerBlip"] = nil end
end

local function DestroyTaxiBlip()
    if ScriptData["TaxiBlip"] then RemoveBlip(ScriptData["TaxiBlip"]) ScriptData["TaxiBlip"] = nil end
end

local function DestroyDestinationBlip()
    if ScriptData["DestinationBlip"] then RemoveBlip(ScriptData["DestinationBlip"]) ScriptData["DestinationBlip"] = nil end
end

local function DestroyBar()
    if ScriptData["FareBar"] then API_ProgressBar.remove(ScriptData["FareBar"]._id) ScriptData["FareBar"] = nil end
end

local function DrawFareBar()
    ScriptData["FareBar"] = API_ProgressBar.add("TextTimerBar", "FARE", ScriptData["CurrentFareTxt"])
    ScriptData["FareBar"].Func.setTitleColor({0, 255, 0, 255})
    ScriptData["FareBar"].Func.setHighlightColor({0, 255, 0, 25})
end

local function ResetData()
    ScriptData["State"] = "idle"
    ScriptData["PickUpLocation"] = nil
    ScriptData["TextDisplayed"] = false
    ScriptData["NetworkIds"]["taxi"] = nil 
    ScriptData["NetworkIds"]["customer"] = nil
    ScriptData["NotInTaxi"] = false
    ScriptData["CurrentFareTxt"] = ""
    ScriptData["DriveCustomerMessage"] = ""
    ScriptData["Destination"] = nil

    ClearPrints()
    DestroyBar()
    DestroyCustomerBlip()
    DestroyTaxiBlip()
    DestroyDestinationBlip()

    Citizen.CreateThread(function()
        Wait(10000)
        ScriptData["StoppedMission"] = false
    end)
end

local function MissionStopped(reason)
    ScriptData["StoppedMission"] = true

    TriggerServerEvent('TaxiNPCMission:Server:Stopped', reason)

    local previousState = ScriptData["State"]

    ResetData()

    if previousState == "pickedup" and reason ~= "manual_cancel" then
        TaskLeaveVehicle(ScriptData["MyCustomer"], ScriptData["MyTaxi"], 256)
    end

    if reason ~= "customer_died" and reason ~= "manual_cancel" then
        ClearPedTasks(ScriptData["MyCustomer"])
        TaskSmartFleePed(ScriptData["MyCustomer"], PlayerPedId(), 50.0, -1)
    end

    if reason == "manual_cancel" then return end

    ClearPedTasks(ScriptData["MyCustomer"])

    while IsEntityOnScreen(ScriptData["MyCustomer"]) do
        Citizen.Wait(500)
    end

    TriggerServerEvent('TaxiNPCMission:Server:DeleteCustomer', NetworkGetNetworkIdFromEntity(ScriptData["MyCustomer"]))
    ScriptData["MyCustomer"] = nil
end

local function DrawTaxiBlip()
    if not ScriptData["TaxiBlip"] then
        ScriptData["TaxiBlip"] = AddBlipForCoord(GetEntityCoords(ScriptData["MyTaxi"]))
        SetBlipSprite(ScriptData["TaxiBlip"], 198)
        SetBlipColour(ScriptData["TaxiBlip"], 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("My Taxi")
        EndTextCommandSetBlipName(ScriptData["TaxiBlip"])
    end
end

local function DrawCustomerBlip()
    if not ScriptData["CustomerBlip"] then
        ScriptData["CustomerBlip"] = AddBlipForCoord(ScriptData["PickUpLocation"])
        SetBlipRoute(ScriptData["CustomerBlip"], true)
        SetBlipSprite(ScriptData["CustomerBlip"], 280)
        SetBlipColour(ScriptData["CustomerBlip"], 3)
        SetBlipRouteColour(ScriptData["CustomerBlip"], 3)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Taxi Customer")
        EndTextCommandSetBlipName(ScriptData["CustomerBlip"])
    end
end

local function DrawDestinationBlip()
    if not ScriptData["DestinationBlip"] then
        ScriptData["DestinationBlip"] = AddBlipForCoord(ScriptData["Destination"])
        SetBlipRoute(ScriptData["DestinationBlip"], true)
        SetBlipColour(ScriptData["DestinationBlip"], 5)
        SetBlipRouteColour(ScriptData["DestinationBlip"], 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Customer's Destination")
        EndTextCommandSetBlipName(ScriptData["DestinationBlip"])
    end
end

local function PickUpCustomer()
    FreezeEntityPosition(ScriptData["MyCustomer"], false)
    ClearPedTasks(ScriptData["MyCustomer"])
    DestroyCustomerBlip()
    DrawFareBar()
    local timeout = 0

    while true do
        Citizen.Wait(0)
        if ((GetEntitySpeed(ScriptData["MyTaxi"]) * 2.236936) > 2) then
            DisableAllControlActions(0)

            if timeout == 0 then
                TaskVehicleTempAction(ScriptData["MyTaxi"], 1, 1200)
            end

            timeout = timeout + 1
            if timeout == 1000 then timeout = 0 end
        else
            break
        end
    end

    TaskEnterVehicle(ScriptData["MyCustomer"], ScriptData["MyTaxi"], -1, 2, 1.0, 1, 0)

    while true do
        Citizen.Wait(0)
        if not IsPedInVehicle(ScriptData["MyCustomer"], ScriptData["MyTaxi"], false) then
            FreezeEntityPosition(ScriptData["MyTaxi"], true)
        else
            FreezeEntityPosition(ScriptData["MyTaxi"], false)
            break
        end
    end
    
    ScriptData["State"] = "pickedup"
    TriggerServerEvent('TaxiNPCMission:Server:PickedUp')
    DrawSubtitle(ScriptData["DriveCustomerMessage"])
    ScriptData["TextDisplayed"] = false
    DrawDestinationBlip()
end

local function DropOffCustomer()
    local timeout = 0
    while true do
        Citizen.Wait(0)
        if ((GetEntitySpeed(ScriptData["MyTaxi"]) * 2.236936) > 2) then
            DisableAllControlActions(0)
            if timeout == 0 then
                TaskVehicleTempAction(ScriptData["MyTaxi"], 1, 1000)
            end
            timeout = timeout + 1
            if timeout == 1000 then timeout = 0 end
        else
            break
        end
    end

    TaskLeaveVehicle(ScriptData["MyCustomer"], ScriptData["MyTaxi"], 256)
    
    while true do
        Citizen.Wait(0)
        if IsPedInVehicle(ScriptData["MyCustomer"], ScriptData["MyTaxi"], true) then
            FreezeEntityPosition(ScriptData["MyTaxi"], true)
        else
            FreezeEntityPosition(ScriptData["MyTaxi"], false)
            break
        end
    end

    TaskWanderStandard(ScriptData["MyCustomer"], 10.0, 10)
    TriggerServerEvent('TaxiNPCMission:Server:JobDone')
    PlaySoundFrontend(-1, "package_delivered_success", "DLC_GR_Generic_Mission_Sounds")
    ResetData()
    ScriptData["StoppedMission"] = true

    while IsEntityOnScreen(ScriptData["MyCustomer"]) do
        Citizen.Wait(500)
    end

    TriggerServerEvent('TaxiNPCMission:Server:DeleteCustomer', NetworkGetNetworkIdFromEntity(ScriptData["MyCustomer"]))
    ScriptData["MyCustomer"] = nil
end

local ForcingJobEntityToLoad = {["taxi"] = false, ["customer"] = false}

local function ForceJobEntityToLoad(entity)
    local forcedStop = false
    ForcingJobEntityToLoad[entity] = true

    if entity == "taxi" then
        local taxi = NetworkGetEntityFromNetworkId(ScriptData["NetworkIds"]["taxi"])

        while not DoesEntityExist(taxi) and not NetworkHasControlOfEntity(taxi) do
            Wait(0)
            taxi = NetworkGetEntityFromNetworkId(ScriptData["NetworkIds"]["taxi"])
            NetworkRequestControlOfEntity(taxi)
            if ScriptData["StoppedMission"] then forcedStop = true break end
        end

        if forcedStop then ForcingJobEntityToLoad[entity] = false return end
        ScriptData["MyTaxi"] = taxi
    elseif entity == "customer" then
        while true do
            Wait(500)
            if ScriptData["StoppedMission"] then forcedStop = true break end
            if (#(GetEntityCoords(PlayerPedId()) - ScriptData["PickUpLocation"]) < 424) then break end
        end

        if forcedStop then ForcingJobEntityToLoad[entity] = false return end
        local customer = NetworkGetEntityFromNetworkId(ScriptData["NetworkIds"]["customer"])

        while not DoesEntityExist(customer) and not NetworkHasControlOfEntity(customer) do
            Wait(0)
            customer = NetworkGetEntityFromNetworkId(ScriptData["NetworkIds"]["customer"])
            NetworkRequestControlOfEntity(customer)
            if ScriptData["StoppedMission"] then forcedStop = true break end
        end

        if forcedStop then ForcingJobEntityToLoad[entity] = false return end
        ScriptData["MyCustomer"] = customer
        SetBlockingOfNonTemporaryEvents(ScriptData["MyCustomer"], true)

        Citizen.CreateThread(function()
            RequestAnimDict("taxi_hail")
            while not HasAnimDictLoaded("taxi_hail") do
                Citizen.Wait(0)
            end
            TaskPlayAnim(ScriptData["MyCustomer"], "taxi_hail", "hail_taxi", 1.0, 1.0, -1, 49, 0, false, false, false)
        end)
    end
    ForcingJobEntityToLoad[entity] = false
    return true
end

RegisterNetEvent('TaxiNPCMission:Client:CustomerDamaged')
AddEventHandler('TaxiNPCMission:Client:CustomerDamaged', function()
    MissionStopped('customer_damaged')
end)

RegisterNetEvent('TaxiNPCMission:Client:ManualCancelled')
AddEventHandler('TaxiNPCMission:Client:ManualCancelled', function()
    MissionStopped('manual_cancel')
end)

RegisterNetEvent('TaxiNPCMission:Client:Started')
AddEventHandler('TaxiNPCMission:Client:Started', function(destination, ped, fare, vehicle, pickup, messages)
    local forcedStop = false
    ScriptData["NetworkIds"]["taxi"] = vehicle 
    ScriptData["NetworkIds"]["customer"] = ped
    local taxi = NetworkGetEntityFromNetworkId(vehicle)
    local customer = NetworkGetEntityFromNetworkId(ped)

    while not DoesEntityExist(taxi) and not NetworkHasControlOfEntity(taxi) do
        taxi = NetworkGetEntityFromNetworkId(vehicle)
        NetworkRequestControlOfEntity(taxi)
        if ScriptData["StoppedMission"] then forcedStop = true break end
        Wait(0)
    end

    ScriptData["MyTaxi"] = taxi
    if forcedStop then return end

    Citizen.CreateThread(function()
        while not (#(GetEntityCoords(PlayerPedId()) - pickup) < 424) do
            Wait(500)
            if ScriptData["StoppedMission"] then forcedStop = true break end
        end

        if forcedStop then return end

        while not DoesEntityExist(customer) and not NetworkHasControlOfEntity(customer) do
            customer = NetworkGetEntityFromNetworkId(ped)
            NetworkRequestControlOfEntity(customer)
            if ScriptData["StoppedMission"] then forcedStop = true break end
            Wait(0)
        end

        if forcedStop then return end

        ScriptData["MyCustomer"] = customer
        SetBlockingOfNonTemporaryEvents(ScriptData["MyCustomer"], true)

        Citizen.CreateThread(function()
            RequestAnimDict("taxi_hail")
            while not HasAnimDictLoaded("taxi_hail") do
                Citizen.Wait(0)
            end
            TaskPlayAnim(ScriptData["MyCustomer"], "taxi_hail", "hail_taxi", 1.0, 1.0, -1, 49, 0, false, false, false)
        end)
    end)

    if forcedStop then return end

    ScriptData["PickUpLocation"] = pickup
    ScriptData["DriveCustomerMessage"] = messages["drive_customer"] 
    ScriptData["CurrentFareTxt"] = ""..fare..""..messages['currency']..""
    ScriptData["Destination"] = destination
    ScriptData["State"] = "started"
    
    DrawCustomerBlip()
    ShowCabNotification(messages['message'])

    while true do
        Citizen.Wait(1000)
        if forcedStop or ScriptData["StoppedMission"] then break end
        
        if DoesEntityExist(ScriptData["MyTaxi"]) and NetworkHasControlOfEntity(ScriptData["MyTaxi"]) then
            if IsVehicleDriveable(ScriptData["MyTaxi"], true) then
                if not IsEntityUpsidedown(ScriptData["MyTaxi"]) then
                    if GetVehiclePedIsIn(PlayerPedId()) ~= ScriptData["MyTaxi"] then
                        if not ScriptData["NotInTaxi"] then
                            ScriptData["NotInTaxi"] = true
                            DrawTaxiBlip()
                            DrawSubtitle(messages['get_into_car'])
                            ScriptData["TextDisplayed"] = false
                        else
                            Citizen.Wait(500)
                        end
                    else
                        if not ScriptData["TextDisplayed"] and ScriptData["State"] == "started" then
                            DrawSubtitle(messages['pickup_customer'])
                            ScriptData["TextDisplayed"] = true
                        end
                        if ScriptData["NotInTaxi"] then
                            ScriptData["NotInTaxi"] = false
                            DestroyTaxiBlip()
                            if ScriptData["State"] == "pickedup" then
                                DrawSubtitle(messages["drive_customer"])
                            end
                        else
                            Citizen.Wait(500)
                        end
                    end
                else
                    MissionStopped('vehicle_flipped')
                    break
                end
            else
                MissionStopped('vehicle_undriveable')
                break
            end
        else
            if not ForcingJobEntityToLoad["taxi"] then ForceJobEntityToLoad("taxi") end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if ScriptData["State"] ~= "idle" then
            if ScriptData["State"] == "started" then
                if not ScriptData["NotInTaxi"] then
                    local pickupDistance = #(GetEntityCoords(PlayerPedId()) - ScriptData["PickUpLocation"])
                    
                    if pickupDistance < 15.0 then
                        local pedCoords = GetEntityCoords(ScriptData["MyCustomer"])
                        DrawMarker(2, pedCoords.x, pedCoords.y, pedCoords.z + 1.25, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, 0, 200, 0, 150, true, true, 2, false)

                        if pickupDistance < 2.75 then
                            ShowHelpNotification('Press ~INPUT_CONTEXT~ to ~y~horn ~w~and ~b~pick-up customer.')

                            if IsHornActive(ScriptData["MyTaxi"]) then
                                PickUpCustomer()
                                Citizen.Wait(500)
                            end
                        end
                    else
                        Citizen.Wait(750)
                    end
                else
                    Citizen.Wait(1500)
                end
            elseif ScriptData["State"] == "pickedup" then
                if not ScriptData["NotInTaxi"] then 
                    local destinationDistance = #(GetEntityCoords(PlayerPedId()) - ScriptData["Destination"])

                    if destinationDistance < 20.0 then
                        DrawMarker(4, ScriptData["Destination"].x, ScriptData["Destination"].y, ScriptData["Destination"].z + 1.25, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 200, 0, 150, true, true, 2, false)

                        if destinationDistance < 3.5 then
                            DropOffCustomer()
                        end
                    else
                        Citizen.Wait(750)
                    end
                else
                    Citizen.Wait(1500)
                end
            end
        else
            Citizen.Wait(2500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if ScriptData["State"] ~= "idle" then
            if IsEntityDead(PlayerPedId()) then MissionStopped('self_died') end

            if ScriptData["MyCustomer"] and DoesEntityExist(ScriptData["MyCustomer"]) and NetworkHasControlOfEntity(ScriptData["MyCustomer"]) then
                if IsEntityDead(ScriptData["MyCustomer"]) then MissionStopped('customer_died') end
            else
                if not ForcingJobEntityToLoad["customer"] then ForceJobEntityToLoad("customer") end
            end
        else Citizen.Wait(3000) end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    ClearPrints()
end)
