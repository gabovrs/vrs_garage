lib.callback.register('vrs_garage:checkOwner', function(source, plate)
    local result = MySQL.query.await('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate})
    return result[1].owner or false
end)

lib.callback.register('vrs_garage:getVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', {identifier})
    return result
end)

lib.callback.register('vrs_garage:getVehicle', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    print(plate, identifier)
    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ? and owner = ?', {plate, identifier})
    return result[1]
end)

RegisterServerEvent('vrs_garage:updateVehicle', function(plate, vehicle, parking, stored)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.update('UPDATE owned_vehicles SET vehicle = ?, parking = ?, stored = ? WHERE plate = ? and owner = ?', {vehicle, parking, stored, plate, identifier}, function(affectedRows)
        if affectedRows then
            -- TriggerClientEvent('ox_lib:notify', source, ...)
            print(affectedRows)
        end
    end)
end)

RegisterServerEvent('vrs_garage:setVehicleOut', function(plate, stored)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.update('UPDATE owned_vehicles SET stored = ?, parking = NULL, impound = 0 WHERE plate = ? and owner = ?', {stored, plate, identifier})
end)

RegisterServerEvent('vrs_garage:setVehicleImpound', function(plate, impound)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.update('UPDATE owned_vehicles SET impound = ? WHERE plate = ? and owner = ?', {impound, plate, identifier})
end)

-- ESX.RegisterServerCallback('vrs_garage:checkOwner', function(src, cb, plate)
--     -- Logic needed to derive whatever data you would like to send back
--     -- using the passed params on the handler (src, param1, param2, etc)
--     MySQL.query('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate}, function(result)
--         if result then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
--     -- Send back our meme data to client handler
--     -- cb(myMemeServer)
-- end)
