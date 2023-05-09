ESX = exports['es_extended']:getSharedObject()

lib.versionCheck('gabovrs/vrs_garage')

lib.callback.register('vrs_garage:checkOwner', function(source, plate)
    local result = CustomSQL('query', 'SELECT owner FROM owned_vehicles WHERE plate = ?', {plate})
    return result[1].owner or false
end)

lib.callback.register('vrs_garage:getVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE owner = ?', {identifier})
    return result
end)

lib.callback.register('vrs_garage:getImpoundedVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE owner = ? and impound = 1', {identifier})
    return result
end)

lib.callback.register('vrs_garage:canPay', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local PlayerMoney = xPlayer.getMoney() -- Get the Current Player`s Balance.
    if PlayerMoney >= amount then -- check if the Player`s Money is more or equal to the cost.
        xPlayer.removeMoney(amount) -- remove Cost from balance
        return true
    else
        return false
    end
end)

lib.callback.register('vrs_garage:getVehicle', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE plate = ? and owner = ?', {plate, identifier})
    return result[1]
end)

RegisterServerEvent('vrs_garage:updateVehicle', function(plate, vehicle, parking, stored)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    CustomSQL('update', 'UPDATE owned_vehicles SET vehicle = ?, parking = ?, stored = ? WHERE plate = ? and owner = ?',
        {vehicle, parking, stored, plate, identifier})
end)

RegisterServerEvent('vrs_garage:setVehicleOut', function(plate, stored)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    CustomSQL('update',
        'UPDATE owned_vehicles SET stored = ?, parking = NULL, impound = NULL WHERE plate = ? and owner = ?',
        {stored, plate, identifier})
end)

RegisterServerEvent('vrs_garage:setVehicleImpound', function(plate, impound)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    CustomSQL('update', 'UPDATE owned_vehicles SET impound = ? WHERE plate = ? and owner = ?',
        {impound, plate, identifier})
end)

RegisterServerEvent('vrs_garage:setPlayerRoutingBucket', function(bucket)
    if not bucket then
        bucket = math.random(1000)
    end
    SetPlayerRoutingBucket(source, bucket)
end)

function CustomSQL(type, action, placeholder)
    local result = nil
    if Config.MySQL == 'oxmysql' then
        if type == 'query' then
            result = MySQL.query.await(action, placeholder)
        elseif type == 'update' then
            result = MySQL.update(action, placeholder)
        end
    elseif Config.MySQL == 'mysql-async' then
        if type == 'query' then
            result = MySQL.Sync.query(action, placeholder)
        elseif type == 'update' then
            result = MySQL.Async.execute(action, placeholder)
        end
    elseif Config.MySQL == 'ghmattisql' then
        if type == 'query' then
            result = exports.ghmattimysql:executeSync(action, placeholder)
        elseif type == 'update' then
            result = exports.ghmattimysql:execute(action, placeholder)
        end
    end
    return result
end