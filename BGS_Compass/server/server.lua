local VORPcore = {} -- core object

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Register server event to check player inventory
RegisterServerEvent("BGS_Compass:checkPlayerInventory") 
AddEventHandler("BGS_Compass:checkPlayerInventory", function()
    local _source = source
    -- Error check for player inventory
    if not VORPcore.getUser(_source) then
        return
    end

    local compassCount = exports.vorp_inventory:getItemCount(_source, nil, Config.CompassItemToCheck)
    local mapCount = exports.vorp_inventory:getItemCount(_source, nil, Config.MapItemToCheck)

    if compassCount > 0 and mapCount == 0 and Config.UseCompass then
        -- Player has only the compass, show simple minimap
        TriggerClientEvent("BGS_Compass:showSimpleMiniMap", _source)
    elseif compassCount > 0 and mapCount > 0 and Config.UseCompass and Config.UseMap then
        -- Player has both compass and map, show normal minimap
        TriggerClientEvent("BGS_Compass:showMiniMap", _source)
    else
        -- Hide minimap if no compass or map
        TriggerClientEvent("BGS_Compass:hideMiniMap", _source)
    end

    if mapCount > 0 and Config.UseMap then
        TriggerClientEvent("BGS_Compass:enableMap", _source)
    elseif mapCount == 0 and Config.UseMap then
        TriggerClientEvent("BGS_Compass:disableMap", _source)
    end
end)