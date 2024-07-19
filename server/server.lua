ESX = exports['es_extended']:getSharedObject()

local blips = {}
local blipFile = "blips.json"

local function sendDiscordWebhook(title, message)
    if Config.DiscordWebhookURL == "" then
        return
    end

    PerformHttpRequest(Config.DiscordWebhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = "Blip Manager",
        embeds = {
            {
                color = 3447003,
                title = title,
                description = message,
                footer = {
                    text = os.date("%Y-%m-%d %H:%M:%S"),
                }
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

local function loadBlipsFromFile()
    local resourceName = GetCurrentResourceName()
    local fileContent = LoadResourceFile(resourceName, blipFile)
    if fileContent then
        blips = json.decode(fileContent)
        print("Blips loaded from file.")
    else
        print("Failed to load blips from file.")
    end
end

local function saveBlipsToFile()
    local resourceName = GetCurrentResourceName()
    SaveResourceFile(resourceName, blipFile, json.encode(blips), -1)
    print("Blips saved to file.")
end

local function sendBlipsToClient(playerId)
    TriggerClientEvent('aar-blips:client:loadBlips', playerId, blips)
end

local function sendBlipsToAllClients()
    for _, playerId in ipairs(GetPlayers()) do
        sendBlipsToClient(playerId)
    end
end

local function initializeCallbacks()
    if ESX and ESX.RegisterServerCallback then
        ESX.RegisterServerCallback('aar-blips:server:getBlips', function(source, cb)
            cb(blips)
        end)

        ESX.RegisterServerCallback('aar-blips:server:checkPermission', function(source, cb, requiredRole)
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                if xPlayer.getGroup() == requiredRole then
                    print("Permessi confermati per " .. xPlayer.getIdentifier())
                    cb(true)
                else
                    print("Permessi negati per " .. xPlayer.getIdentifier())
                    cb(false)
                end
            else
                print("xPlayer non trovato per " .. source)
                cb(false)
            end
        end)
    else
        print("Attenzione: ESX.RegisterServerCallback non è disponibile. Alcune funzionalità potrebbero non funzionare correttamente.")
    end
end

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(100)
    end
    Citizen.Wait(5000)  -- Aumentiamo il tempo di attesa per assicurarci che il Framework sia completamente caricato
    loadBlipsFromFile()
    initializeCallbacks()
    sendBlipsToAllClients()
end)

AddEventHandler('playerConnecting', function()
    local playerId = source
    Citizen.Wait(5000)
    sendBlipsToClient(playerId)
end)

RegisterNetEvent('aar-blips:server:createBlip')
AddEventHandler('aar-blips:server:createBlip', function(blipData)
    local xPlayer = ESX.GetPlayerFromId(source)
    for _, blip in ipairs(blips) do
        if blip.coords.x == blipData.coords.x and blip.coords.y == blipData.coords.y and blip.coords.z == blipData.coords.z and blip.icon == blipData.icon and blip.color == blipData.color then
            return
        end
    end
    table.insert(blips, blipData)
    saveBlipsToFile()
    sendBlipsToAllClients()
    sendDiscordWebhook("Blip Created", string.format("Player **%s** created a blip.\n**Name**: %s\n**Coordinates**: %s, %s, %s\n**Icon**: %d\n**Color**: %d", xPlayer.getIdentifier(), blipData.name, blipData.coords.x, blipData.coords.y, blipData.coords.z, blipData.icon, blipData.color))
end)

RegisterNetEvent('aar-blips:server:updateBlip')
AddEventHandler('aar-blips:server:updateBlip', function(index, blipData)
    local xPlayer = ESX.GetPlayerFromId(source)
    if blips[index] then
        local oldBlipData = blips[index]
        blips[index] = blipData
        saveBlipsToFile()
        sendBlipsToAllClients()
        sendDiscordWebhook("Blip Updated", string.format("Player **%s** updated a blip.\n**Old Name**: %s\n**New Name**: %s\n**Coordinates**: %s, %s, %s\n**Old Icon**: %d\n**New Icon**: %d\n**Old Color**: %d\n**New Color**: %d", xPlayer.getIdentifier(), oldBlipData.name, blipData.name, blipData.coords.x, blipData.coords.y, blipData.coords.z, oldBlipData.icon, blipData.icon, oldBlipData.color, blipData.color))
    end
end)

RegisterNetEvent('aar-blips:server:deleteBlip')
AddEventHandler('aar-blips:server:deleteBlip', function(index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if blips[index] then
        local blipData = blips[index]
        table.remove(blips, index)
        saveBlipsToFile()
        sendBlipsToAllClients()
        sendDiscordWebhook("Blip Deleted", string.format("Player **%s** deleted a blip.\n**Name**: %s\n**Coordinates**: %s, %s, %s\n**Icon**: %d\n**Color**: %d", xPlayer.getIdentifier(), blipData.name, blipData.coords.x, blipData.coords.y, blipData.coords.z, blipData.icon, blipData.color))
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The resource ' .. resourceName .. ' has been started.')
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(100)
    end
    Citizen.Wait(5000)  -- Aumentiamo il tempo di attesa per assicurarci che il Framework sia completamente caricato
    loadBlipsFromFile()
    initializeCallbacks()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The resource ' .. resourceName .. ' has been stopped.')
    saveBlipsToFile()
end)
