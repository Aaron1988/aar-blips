Framework = {}

local function detectFramework()
    if GetResourceState('es_extended') == 'started' then
        return 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        return 'QBCore'
    else
        return 'Unknown'
    end
end

local function initESX()
    local ESX = exports['es_extended']:getSharedObject()
    Framework.Core = ESX
    Framework.PlayerLoaded = 'esx:playerLoaded'
    Framework.PlayerLogout = 'esx:playerLogout'
    Framework.CreateCallback = ESX.RegisterServerCallback
    Framework.TriggerCallback = ESX.TriggerServerCallback
    Framework.ShowNotification = ESX.ShowNotification
    
    if ESX.UI then
        Framework.OpenMenu = ESX.UI.Menu.Open
        Framework.CloseMenu = ESX.UI.Menu.CloseAll
    else
        print("Attenzione: ESX.UI non è disponibile. Utilizzando funzioni di menu alternative.")
        Framework.OpenMenu = function(type, namespace, name, data, submit, cancel, change)
            print("Apertura menu", name)
            -- Implementa qui una logica alternativa per l'apertura del menu
        end
        Framework.CloseMenu = function()
            print("Chiusura menu")
            -- Implementa qui una logica alternativa per la chiusura del menu
        end
    end

    Framework.GetPlayerData = ESX.GetPlayerData
    Framework.IsPlayerLoaded = function()
        return ESX.IsPlayerLoaded()
    end
end

local function initQBCore()
    local QBCore = exports['qb-core']:GetCoreObject()
    Framework.Core = QBCore
    Framework.PlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    Framework.PlayerLogout = 'QBCore:Client:OnPlayerUnload'
    Framework.CreateCallback = QBCore.Functions.CreateCallback
    Framework.TriggerCallback = QBCore.Functions.TriggerCallback
    Framework.ShowNotification = QBCore.Functions.Notify
    Framework.OpenMenu = function(data) exports['qb-menu']:openMenu(data) end
    Framework.CloseMenu = function() exports['qb-menu']:closeMenu() end
    Framework.GetPlayerData = QBCore.Functions.GetPlayerData
    Framework.IsPlayerLoaded = function()
        return QBCore.Functions.GetPlayerData().citizenid ~= nil
    end
end

CreateThread(function()
    local frameworkName = detectFramework()
    if frameworkName == 'ESX' then
        initESX()
    elseif frameworkName == 'QBCore' then
        initQBCore()
    else
        print('Framework non supportato rilevato. Assicurati di avere ESX o QBCore installato e avviato.')
    end
    
    Framework.Name = frameworkName
    print('Framework rilevato: ' .. frameworkName)
end)

-- Funzioni wrapper universali
Framework.ShowNotification = Framework.ShowNotification or function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

Framework.GetCoords = function(entity)
    local coords = GetEntityCoords(entity)
    return vector3(coords.x, coords.y, coords.z)
end

Framework.SpawnVehicle = function(model, coords, heading, cb)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(model)
    if cb then
        cb(vehicle)
    end
end

Framework.DeleteVehicle = function(vehicle)
    SetEntityAsMissionEntity(vehicle, false, true)
    DeleteVehicle(vehicle)
end

Framework.GetPlayers = function()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        table.insert(players, player)
    end
    return players
end

Framework.GetClosestPlayer = function(coords)
    local players = Framework.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    for i = 1, #players do
        local target = players[i]
        local targetCoords = Framework.GetCoords(GetPlayerPed(target))
        local distance = #(coords - targetCoords)
        if closestDistance == -1 or closestDistance > distance then
            closestPlayer = target
            closestDistance = distance
        end
    end
    return closestPlayer, closestDistance
end

return Framework