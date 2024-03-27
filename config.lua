Config = {
    Settings = {
        ["Vehicle"] = "taxi",
        ["VehicleSpawnPoint"] = vector4(916.37, -170.61, 73.06, 100.50773620605),
        ["VehiclePlate"] = "TAXI",
        ["FarePerKilometer"] = 400, -- INFO: The fare will be proportional to the distance between pick up location and destination.
        ["Cooldown"] = 5, -- INFO: In minutes
    },

    PedModels = {
        "a_f_m_bevhills_01",
        "a_f_y_bevhills_03",
        "a_m_y_beachvesp_01",
        "a_m_y_hipster_01",
    },

    Routes = { -- INFO: It will pick a random route every time the export function is triggered. 
        {   
            ["PickUp"] = vector4(-1378.91, -74.53, 51.29, 12.091267585754),
            ["Destination"] = vector3(1004.13, -700.54, 55.87), 
        },
        {   
            ["PickUp"] = vector4(-352.58, -1445.13, 28.43, 5.0990152359009),
            ["Destination"] = vector3(1110.72, -1444.34, 34.58), 
        },
        {   
            ["PickUp"] = vector4(374.12, -415.62, 44.97, 36.246059417725),
            ["Destination"] = vector3(-98.43, 6295.35, 29.9), 
        },
        {   
            ["PickUp"] = vector4(-2113.15, -350.84, 12.05, 158.67686462402),
            ["Destination"] = vector3(299.05, -234.87, 52.46), 
        },
        {   
            ["PickUp"] = vector4(-1412.03, -567.61, 29.37, 216.83416748047),
            ["Destination"] = vector3(-408.76, 1199.92, 324.65), 
        },
        {   
            ["PickUp"] = vector4(285.46, 1092.02, 215.63, 304.25314331055),
            ["Destination"] = vector3(236.27, 3102.8, 41.42), 
        },
    },

    Translation = {
        ['currency'] = '$',
        ['youve_been_paid'] = 'Congratulations! You\'ve received ~g~',
        ['pickup_customer'] = 'Pick up the ~b~customer.',
        ['drive_customer'] = 'Drive the customer to their ~y~destination.',
        ['already_started'] = "Mission is already in progress!",
        ['get_into_car'] = "Get into your ~y~taxi vehicle.",
        ['mission_cooldown'] = "You can't start a mission right now! Please try again later.",
        ['must_be_closer'] = "You must be closer to the taxi office.",
        ['must_be_closer_to_your_taxi'] = "You must be closer to your taxi vehicle.",
        ['message'] = "We've found a ~g~customer ~w~for you!~n~His/her ~b~pick-up location ~w~has been marked into your ~p~GPS.",
        ['mission_cancelled'] = "The mission has been cancelled due to",
        Reasons = {
            ["manual_cancel"] = "manual cancel.",
            ["customer_damaged"] = "customer being damaged.",
            ["customer_died"] = "customer's death.",
            ["vehicle_undriveable"] = "your vehicle being undriveable.",
            ["vehicle_flipped"] = "your vehicle being upside down.",
            ["self_died"] = "your death."
        }
    },

    Framework = (GetResourceState("es_extended") == "started" and exports['es_extended']:getSharedObject()) or (GetResourceState("qb-core") == "started" and  exports['qb-core']:GetCoreObject()) or nil,

    Functions = {
        CanStart = function(playerId)
            -- You can add any terms here.
            return true
        end,
        
        GetIdentifier = function(playerId)
            if GetResourceState("es_extended") == "started" then
                local xPlayer = Config.Framework.GetPlayerFromId(playerId)

                return xPlayer.identifier
            elseif GetResourceState("qb-core") == "started" then
                local Player = Config.Framework.Functions.GetPlayer(playerId)

                return Player.PlayerData.citizenid
            end
        end,

        SendNotification = function(playerId, text)
            if GetResourceState("es_extended") == "started" then
                TriggerClientEvent('esx:showNotification', playerId, text)
            elseif GetResourceState("qb-core") == "started" then
                TriggerClientEvent('QBCore:Notify', playerId, text)
            end
        end,

        PayDriver = function(driverId, reward)
            if GetResourceState("es_extended") == "started" then
                local xPlayer = Config.Framework.GetPlayerFromId(driverId)
                
                xPlayer.addAccountMoney('money', reward, 'Taxi Mission')
            elseif GetResourceState("qb-core") == "started" then
                local Player = Config.Framework.Functions.GetPlayer(driverId)

                Player.Functions.AddMoney('cash', reward, "taxi-mission", false)
            end
        end
    }
}
