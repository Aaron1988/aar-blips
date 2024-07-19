local ESX = exports["es_extended"]:getSharedObject()

if not ESX then
    print("ESX non è stato trovato. Assicurati che es_extended sia caricato prima di questo script.")
    return
end

local blips = {}
local Blips = {}
local previewBlip = nil

local function loadBlipsData()
    local resourceName = GetCurrentResourceName()
    local chunk = LoadResourceFile(resourceName, 'blips.lua')
    if chunk then
        local fn, err = load(chunk, 'blips.lua', 't')
        if fn then
            Blips = fn()
        else
            print("Error loading blips.lua: " .. tostring(err))
        end
    else
        print("Could not load blips.lua")
    end
end

local function createPreviewBlip(coords, icon, color)
    if previewBlip then
        RemoveBlip(previewBlip)
    end
    previewBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(previewBlip, icon)
    SetBlipColour(previewBlip, color)
    SetBlipDisplay(previewBlip, 4)
    SetBlipScale(previewBlip, Config.DefaultBlipScale)
    SetBlipAsShortRange(previewBlip, true)
    SetBlipAlpha(previewBlip, Config.DefaultBlipAlpha)
end

local function blipExists(coords, icon, color)
    for _, blipData in ipairs(blips) do
        if blipData.coords.x == coords.x and blipData.coords.y == coords.y and blipData.coords.z == coords.z and blipData.icon == icon and blipData.color == color then
            return true
        end
    end
    return false
end

local function updateBlipIcon(index, icon, name, coords)
    if not blips[index] then
        ESX.ShowNotification(Config.Text.BlipNotFound)
        return
    end
    local blip = blips[index].blip
    SetBlipSprite(blip, icon)
    blips[index].icon = icon
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)

    TriggerServerEvent('aar-blips:server:updateBlip', index, blips[index])
    ESX.ShowNotification(Config.Text.BlipUpdated)
end

local function updateBlipColor(index, color, name, coords)
    if not blips[index] then
        ESX.ShowNotification(Config.Text.BlipNotFound)
        return
    end
    local blip = blips[index].blip
    SetBlipColour(blip, color)
    blips[index].color = color
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)

    TriggerServerEvent('aar-blips:server:updateBlip', index, blips[index])
    ESX.ShowNotification(Config.Text.BlipUpdated)
end

local function deleteBlip(index)
    if not blips[index] then
        ESX.ShowNotification(Config.Text.BlipNotFound)
        return
    end
    local blip = blips[index].blip
    RemoveBlip(blip)
    table.remove(blips, index)
    TriggerServerEvent('aar-blips:server:deleteBlip', index)
    ESX.ShowNotification(Config.Text.BlipDeleted)
end

local function openBlipIconMenu(blipName, coords, callback)
    local elements = {
        {label = Config.Text.CustomIcon, value = 'custom_icon'}
    }
    for _, icon in ipairs(Blips.Icons) do
        table.insert(elements, {label = icon.label, value = icon.value})
    end
    table.insert(elements, {label = Config.Text.Back, value = 'back'})
    table.insert(elements, {label = Config.Text.Close, value = 'close'})

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blip_icon', {
        title = Config.Text.SelectBlipIcon,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'custom_icon' then
            openCustomIconMenu(blipName, coords, callback)
        elseif data.current.value == 'back' then
            menu.close()
            openBlipCreationMenu(coords)
        elseif data.current.value == 'close' then
            menu.close()
        else
            createPreviewBlip(coords, data.current.value, 0) -- Aggiorna l'anteprima del blip
            callback(data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end, function(data, menu)
        -- Aggiorna l'anteprima mentre si scorre tra le icone
        if data.current.value ~= 'custom_icon' and data.current.value ~= 'back' and data.current.value ~= 'close' then
            createPreviewBlip(coords, data.current.value, 0)
        end
    end)
end

local function openCustomIconMenu(blipName, coords, callback)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'custom_icon', {
        title = Config.Text.EnterCustomIconID
    }, function(data, menu)
        local customIcon = tonumber(data.value)
        if customIcon then
            menu.close()
            createPreviewBlip(coords, customIcon, 0) -- Aggiorna l'anteprima del blip
            callback(customIcon)
        else
            ESX.ShowNotification(Config.Text.ErrorMissingData:format("custom icon"))
        end
    end, function(data, menu)
        menu.close()
        openBlipIconMenu(blipName, coords, callback)
    end)
end

local function openBlipColorMenu(blipName, coords, blipIcon, callback)
    local elements = {
        {label = Config.Text.CustomColor, value = 'custom_color'}
    }
    for _, color in ipairs(Blips.Colors) do
        table.insert(elements, {label = color.label, value = color.value})
    end
    table.insert(elements, {label = Config.Text.Back, value = 'back'})
    table.insert(elements, {label = Config.Text.Close, value = 'close'})

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blip_color', {
        title = Config.Text.SelectBlipColor,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'custom_color' then
            openCustomColorMenu(blipName, coords, blipIcon, callback)
        elseif data.current.value == 'back' then
            menu.close()
            openBlipIconMenu(blipName, coords, function(icon)
                openBlipColorMenu(blipName, coords, icon, callback)
            end)
        elseif data.current.value == 'close' then
            menu.close()
        else
            createPreviewBlip(coords, blipIcon, data.current.value) -- Aggiorna l'anteprima del blip
            callback(data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end, function(data, menu)
        -- Aggiorna l'anteprima mentre si scorre tra i colori
        if data.current.value ~= 'custom_color' and data.current.value ~= 'back' and data.current.value ~= 'close' then
            createPreviewBlip(coords, blipIcon, data.current.value)
        end
    end)
end

local function openCustomColorMenu(blipName, coords, blipIcon, callback)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'custom_color', {
        title = Config.Text.EnterCustomColorID
    }, function(data, menu)
        local customColor = tonumber(data.value)
        if customColor then
            menu.close()
            createPreviewBlip(coords, blipIcon, customColor) -- Aggiorna l'anteprima del blip
            callback(customColor)
        else
            ESX.ShowNotification(Config.Text.ErrorMissingData:format("custom color"))
        end
    end, function(data, menu)
        menu.close()
        openBlipColorMenu(blipName, coords, blipIcon, callback)
    end)
end

local function createBlip(blipName, blipCoords, blipIcon, blipColor)
    if blipExists(blipCoords, blipIcon, blipColor) then
        ESX.ShowNotification("Blip già esistente.")
        return
    end

    local blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
    SetBlipSprite(blip, blipIcon)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.DefaultBlipScale)
    SetBlipColour(blip, blipColor)
    SetBlipAsShortRange(blip, true)
    SetBlipAlpha(blip, Config.DefaultBlipAlpha)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(blipName)
    EndTextCommandSetBlipName(blip)

    table.insert(blips, {blip = blip, name = blipName, coords = blipCoords, icon = blipIcon, color = blipColor})
    TriggerServerEvent('aar-blips:server:createBlip', {name = blipName, coords = blipCoords, icon = blipIcon, color = blipColor})
    ESX.ShowNotification(Config.Text.BlipCreated)
end

local function openBlipCreationMenu(coords)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'blip_name', {
        title = Config.Text.EnterBlipName
    }, function(data, menu)
        local blipName = data.value
        if blipName and string.len(blipName) >= Config.MinBlipNameLength and string.len(blipName) <= Config.MaxBlipNameLength then
            menu.close()
            openBlipIconMenu(blipName, coords, function(icon)
                openBlipColorMenu(blipName, coords, icon, function(color)
                    createBlip(blipName, coords, icon, color)
                    RemoveBlip(previewBlip) -- Rimuove l'anteprima del blip
                    previewBlip = nil
                end)
            end)
        else
            ESX.ShowNotification(Config.Text.ErrorMissingData:format("blip name"))
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function openBlipManagementMenu(index, blipData)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blip_management', {
        title = Config.Text.ManageBlip:format(blipData.name),
        align = 'top-left',
        elements = {
            {label = Config.Text.ChangeIcon, value = 'change_icon'},
            {label = Config.Text.ChangeColor, value = 'change_color'},
            {label = Config.Text.DeleteBlip, value = 'delete_blip'},
            {label = Config.Text.Back, value = 'back'},
            {label = Config.Text.Close, value = 'close'}
        }
    }, function(data, menu)
        if data.current.value == 'change_icon' then
            menu.close()
            openBlipIconMenu(blipData.name, blipData.coords, function(icon)
                updateBlipIcon(index, icon, blipData.name, blipData.coords)
            end)
        elseif data.current.value == 'change_color' then
            menu.close()
            openBlipColorMenu(blipData.name, blipData.coords, blipData.icon, function(color)
                updateBlipColor(index, color, blipData.name, blipData.coords)
            end)
        elseif data.current.value == 'delete_blip' then
            deleteBlip(index)
            menu.close()
        elseif data.current.value == 'back' then
            menu.close()
            openBlipEditMenu()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function openBlipEditMenu()
    if #blips == 0 then
        ESX.ShowNotification(Config.Text.NoBlipsFound)
        return
    end

    local elements = {}
    for i, blipData in ipairs(blips) do
        table.insert(elements, {label = blipData.name, value = i})
    end
    table.insert(elements, {label = Config.Text.Back, value = 'back'})
    table.insert(elements, {label = Config.Text.Close, value = 'close'})

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blip_edit', {
        title = Config.Text.BlipList,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'back' then
            menu.close()
            openBlipManagerMenu()
        elseif data.current.value == 'close' then
            menu.close()
        else
            menu.close()
            openBlipManagementMenu(data.current.value, blips[data.current.value])
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function openBlipManagerMenu()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blip_manager', {
        title = Config.Text.BlipManager,
        align = 'top-left',
        elements = {
            {label = Config.Text.CreateBlip, value = 'create_blip'},
            {label = Config.Text.EditBlips, value = 'edit_blips'},
            {label = Config.Text.Close, value = 'close'}
        }
    }, function(data, menu)
        if data.current.value == 'create_blip' then
            menu.close()
            openBlipCreationMenu(coords)
        elseif data.current.value == 'edit_blips' then
            menu.close()
            openBlipEditMenu()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('aar-blips:client:loadBlips')
AddEventHandler('aar-blips:client:loadBlips', function(serverBlips)
    for _, blipData in ipairs(serverBlips) do
        if not blipExists(blipData.coords, blipData.icon, blipData.color) then
            local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
            SetBlipSprite(blip, blipData.icon or 1)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.DefaultBlipScale)
            SetBlipColour(blip, blipData.color or 2)
            SetBlipAsShortRange(blip, true)
            SetBlipAlpha(blip, Config.DefaultBlipAlpha)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(blipData.name)
            EndTextCommandSetBlipName(blip)

            table.insert(blips, {blip = blip, name = blipData.name, coords = blipData.coords, icon = blipData.icon, color = blipData.color})
        end
    end
    ESX.ShowNotification(Config.Text.LoadingBlips)
end)

local function onPlayerLoaded()
    if Config.DebugMode then
        print(Config.Text.PlayerLoadedEvent:format("ESX"))
    end
    TriggerServerEvent('aar-blips:server:loadBlips')
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', onPlayerLoaded)

RegisterCommand(Config.MenuCommand, function()
    print("Comando eseguito")
    if ESX.IsPlayerLoaded() then
        ESX.TriggerServerCallback('aar-blips:server:checkPermission', function(hasPermission)
            if hasPermission then
                print("Permessi confermati, apro il menu")
                openBlipManagerMenu()
            else
                print("Permessi negati")
                ESX.ShowNotification(Config.Text.NoPermission)
            end
        end, Config.AdminRole)
    else
        print(Config.Text.FrameworkNotInitialized:format("opening menu"))
    end
end, false)

RegisterKeyMapping(Config.MenuCommand, Config.Text.BlipManager, 'keyboard', Config.MenuKey)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if Config.DebugMode then
        print(Config.Text.ResourceStarted:format(resourceName))
    end
    Wait(2000)
    if ESX.IsPlayerLoaded() then
        if Config.DebugMode then
            print(Config.Text.TriggeringPlayerLoadedEvent)
        end
        onPlayerLoaded()
    else
        print(Config.Text.WarningFrameworkNotInitialized:format(2))
    end
end)

if Config.DebugMode then
    CreateThread(function()
        Wait(0)
        print("ESX all'inizio del file client:", ESX)

        Wait(3000)
        print("ESX dopo 3 secondi:", ESX)
        if ESX then
            print("ESX IsPlayerLoaded:", ESX.IsPlayerLoaded())
        else
            print(Config.Text.WarningFrameworkNotInitialized:format(3))
        end
    end)
end

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    loadBlipsData()
    print("Blip Manager inizializzato")
end)
