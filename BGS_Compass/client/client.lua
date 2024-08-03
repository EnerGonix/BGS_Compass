-- Define map types
local mapTypeOnFoot = Config.MapTypeOnFoot
local mapTypeOnMount = Config.MapTypeOnMount
local mapTypeNoCompass = Config.MapTypeNoCompass
local mapTypeCompassOnly = Config.MapTypeCompassOnly

local hasMapItem = false
local userGroup

local function contains(table, element)
    if table ~= 0 then
        for k, v in pairs(table) do
            if v == element then
                return true
            end
        end
    end
    return false
end

-- Register set minimap type event
RegisterNetEvent('BGS_Compass:setMinimapType')
AddEventHandler('BGS_Compass:setMinimapType', function(minimapType)
    local player = PlayerPedId()
    local playerOnMount = IsPedOnMount(player)
    local playerOnVeh = IsPedInAnyVehicle(player, false)

    if minimapType == mapTypeCompassOnly then
        SetMinimapType(mapTypeCompassOnly) -- Tipo 3 para bússola simples
        DisplayRadar(true)
    elseif not playerOnMount and not playerOnVeh then
        SetMinimapType(mapTypeOnFoot)
        DisplayRadar(true)
    elseif playerOnMount or playerOnVeh then
        SetMinimapType(mapTypeOnMount)
        DisplayRadar(true)
    else
        DisplayRadar(true)
    end
end)

-- Register hide minimap event
RegisterNetEvent('BGS_Compass:hideMiniMap')
AddEventHandler('BGS_Compass:hideMiniMap', function()
    DisplayRadar(false)
end)

-- Register show map event
RegisterNetEvent('BGS_Compass:enableMap')
AddEventHandler('BGS_Compass:enableMap', function()
    hasMapItem = true
end)

-- Register hide map event
RegisterNetEvent('BGS_Compass:disableMap')
AddEventHandler('BGS_Compass:disableMap', function()
    hasMapItem = false
end)

RegisterNetEvent("BGS_Compass:storeUserGroup", function(group)
    userGroup = group
end)

-- Add character selected event handler to check for inventory
RegisterNetEvent("vorp:SelectedCharacter", function()
    local playerPed = PlayerPedId()
    TriggerServerEvent("BGS_Compass:getUserGroup")
    Wait(100)
    -- Create thread loop for checking inventory on player spawn
    if not contains(Config.Exempted, userGroup) then
        CreateThread(function()
            while Config.UseCompass or Config.UseMap do
                Wait(0)
                TriggerServerEvent("BGS_Compass:checkPlayerInventory")
                Citizen.Wait(Config.TimeToCheck) -- Check inventory every X seconds
            end
        end)
        if Config.UseMap then
            TriggerEvent("BGS_Compass:disableMap", playerPed)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1)
        if contains(Config.Exempted, userGroup) then
            return
        end
        if Config.UseMap and not contains(Config.Exempted, userGroup) then
            if not hasMapItem then
                ClearGpsPlayerWaypoint()
                ClearGpsMultiRoute()
                if Citizen.InvokeNative(0x4E511D093A86AD49, joaat("map")) then
                    Citizen.InvokeNative(0x04428420A248A354, joaat("map"))
                end
            end
        end
        if Config.DisableTabWheelCompass and not contains(Config.Exempted, userGroup) then
            if Citizen.InvokeNative(0x96FD694FE5BE55DC, joaat("hud_quick_select")) == 1322164459 or Citizen.InvokeNative(0x96FD694FE5BE55DC, joaat("hud_quick_select")) == 400623090 then
                DisplayRadar(false)
            end
        end
    end
end)
