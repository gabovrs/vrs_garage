lib.locale()

function onEnter(self)
    local ped = PlayerPedId()
    -- print('entered zone', self.id)
    if self.name == 'store' then
        if IsPedInAnyVehicle(ped, false) then
            lib.showTextUI(locale('access-' .. self.name))
        end
    else
        lib.showTextUI(locale('access-' .. self.name))
    end
end

function onExit(self)
    -- print('exited zone', self.id)
    lib.hideTextUI()
end

function inside(self)
    if IsControlJustReleased(0, 38) then
        TriggerEvent('vrs_garage:access-' .. self.name, self)
    end
    -- print('you are inside zone ' .. self.id)
end

function spawnVehicle(vehicleData, plate, coords)
    -- TODO: Revisar si las coordenadas de spawn estan sin obstaculos
    ESX.Game.SpawnVehicle(GetDisplayNameFromVehicleModel(vehicleData.model),
    vector3(coords), coords.w, function(veh)
        -- print(DoesEntityExist(vehicle), 'this code is async!')
        lib.setVehicleProperties(veh, vehicleData)
        lib.notify({
            description = locale('vehicle_out'),
            type = 'success'
        })
        TriggerServerEvent('vrs_garage:setVehicleOut', plate, false)
    end)
end

RegisterNetEvent('vrs_garage:takeOutVehicle', function(args)
    lib.callback('vrs_garage:getVehicle', false, function(vehicle)
        if vehicle then
            if vehicle.stored == 1 then
                local vehicleData = json.decode(vehicle.vehicle)
                spawnVehicle(vehicleData, vehicle.plate, Config.Garages[args.zone.index].spawn)
            else
                lib.notify({
                    description = locale('vehicle_lost'),
                    type = 'error'
                })
            end
        end
    end, args.plate)
end)

RegisterNetEvent('vrs_garage:sendVehicleConfiscated', function(plate)
    TriggerServerEvent('vrs_garage:setVehicleImpound', plate, true)
    plate = string.gsub(plate, "%s+", "")
    local vehicles = ESX.Game.GetVehicles()
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            vehiclePlate = string.gsub(vehiclePlate, "%s+", "")
            if vehiclePlate == plate then
                DeleteVehicle(vehicle)
                -- print('Borrando auto', vehicle)
            end
        end
    end
end)

RegisterNetEvent('vrs_garage:findVehicle', function(targetPlate)
    local vehicles = ESX.Game.GetVehicles()
    local found = false
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            if vehiclePlate == targetPlate then
                SetNewWaypoint(vehicleCoords.x, vehicleCoords.y)
                found = true
                break
            end
        end
    end

    if found then
        lib.notify({
            description = locale('vehicle_found'),
            type = 'success',
        })
    else
        lib.notify({
            description = locale('vehicle_not_found'),
            type = 'error',
        })
    end
end)

RegisterNetEvent('vrs_garage:access-garage', function(zone)
    lib.callback('vrs_garage:getVehicles', false, function(vehicles)
        local options = {}
        for k, v in pairs(vehicles) do
            local vehicleData = json.decode(v.vehicle)
            local vehicleTitle = GetLabelText(GetMakeNameFromVehicleModel(vehicleData.model)) .. ' - ' ..
                                     GetLabelText(GetDisplayNameFromVehicleModel(vehicleData.model))

            local iconColor = 'rgb(29 78 216)'
            local disabled = false
            if v.stored == 0 then
                iconColor = 'rgb(250 204 21)'
            end
            
            if v.impound == 1 then
                iconColor = 'rgb(190 18 60)'
                disabled = true
                vehicleTitle = vehicleTitle ..' (Confiscado)'
            end
            table.insert(options, {
                title = vehicleTitle,
                icon = 'car',
                iconColor = iconColor,
                disabled = disabled,
                description = 'Patente: ' .. v.plate,
                metadata = {{
                    label = 'Gasolina',
                    value = vehicleData.fuelLevel .. '%',
                    progress = vehicleData.fuelLevel
                }, {
                    label = 'Motor',
                    value = vehicleData.engineHealth / 10 .. '%',
                    progress = vehicleData.engineHealth / 10
                }},
                onSelect = function()
                    local options = {}
                    if v.stored == 1 then
                        table.insert(options, {
                            title = 'Sacar vehiculo del garaje',
                            icon = 'right-from-bracket',
                            args = {plate = v.plate, zone = zone},
                            event = 'vrs_garage:takeOutVehicle'
                        })
                    else
                        table.insert(options, {
                            title = 'Enviar vehiculo al confiscado',
                            icon = 'warehouse',
                            args = v.plate,
                            event = 'vrs_garage:sendVehicleConfiscated'
                        })

                        table.insert(options, {
                            title = 'Localizar vehiculo',
                            icon = 'location-dot',
                            args = v.plate,
                            event = 'vrs_garage:findVehicle'
                        })
                    end
                    -- TriggerEvent('vrs_garage:takeOutVehicle', v.plate)
                    lib.registerContext({
                        id = 'garage_vehicle_options',
                        title = vehicleTitle,
                        options = options
                    })

                    lib.showContext('garage_vehicle_options')
                end
            })
        end

        lib.registerContext({
            id = 'garage_vehicles',
            title = Config.Garages[zone.index].name,
            options = options
        })

        lib.showContext('garage_vehicles')
    end)
end)

RegisterNetEvent('vrs_garage:access-store', function(zone)
    print(zone)
    local ped = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateText(currentVehicle)
    lib.callback('vrs_garage:checkOwner', false, function(isOwner)
        if isOwner then
            local vehicleProperties = json.encode(lib.getVehicleProperties(currentVehicle))
            TaskLeaveVehicle(ped, currentVehicle, 0)
            Wait(2000)
            TriggerServerEvent('vrs_garage:updateVehicle', plate, vehicleProperties, zone.index, true)
            SetEntityAsMissionEntity(currentVehicle, true, true)
            NetworkFadeOutEntity(currentVehicle, true, true)
            Wait(1000)
            DeleteVehicle(currentVehicle)
        else
            lib.notify({
                description = locale('not_owner'),
                type = 'error'
            })
        end
    end, plate)
    -- TaskLeaveVehicle(ped, )
end)

RegisterNetEvent('vrs_garage:access-impound', function(zone)
    lib.callback('vrs_garage:getVehicles', false, function(vehicles)
        local options = {}
        for k, v in pairs(vehicles) do
            if v.impound then
                local vehicleData = json.decode(v.vehicle)
                local vehicleTitle = GetLabelText(GetMakeNameFromVehicleModel(vehicleData.model)) .. ' - ' ..
                                         GetLabelText(GetDisplayNameFromVehicleModel(vehicleData.model))
    
                local iconColor = 'rgb(190 18 60)'
                table.insert(options, {
                    title = vehicleTitle,
                    icon = 'car',
                    iconColor = iconColor,
                    description = 'Patente: ' .. v.plate,
                    metadata = {{
                        label = 'Gasolina',
                        value = vehicleData.fuelLevel .. '%',
                        progress = vehicleData.fuelLevel
                    }, {
                        label = 'Motor',
                        value = vehicleData.engineHealth / 10 .. '%',
                        progress = vehicleData.engineHealth / 10
                    }},
                    onSelect = function()
                        local options = {}
                        table.insert(options, {
                            title = 'Recuperar vehiculo ($' .. Config.Fine ..')',
                            icon = 'file-invoice',
                            args = {plate = v.plate, zone = zone},
                            event = 'vrs_garage:recoverVehicle'
                        })
                        -- TriggerEvent('vrs_garage:takeOutVehicle', v.plate)
                        lib.registerContext({
                            id = 'garage_vehicle_options',
                            title = vehicleTitle,
                            options = options
                        })
    
                        lib.showContext('garage_vehicle_options')
                    end
                })
            end
        end

        lib.registerContext({
            id = 'garage_vehicles',
            title = Config.Impounds[zone.index].name,
            options = options
        })

        lib.showContext('garage_vehicles')
    end)
end)

RegisterNetEvent('vrs_garage:recoverVehicle', function(args)
    print(args.plate, args.zone.index)
    lib.callback('vrs_garage:getVehicle', false, function(vehicle)
        if vehicle then
            if vehicle.impound == 1 then
                local vehicleData = json.decode(vehicle.vehicle)
                spawnVehicle(vehicleData, vehicle.plate, Config.Impounds[args.zone.index].spawn)
            else
                lib.notify({
                    description = locale('vehicle_not_impound'),
                    type = 'error'
                })
            end
        end
    end, args.plate)
end)

for k, v in pairs(Config.Garages) do
    v.access_zone = lib.zones.sphere({
        index = k,
        name = 'garage',
        coords = v.access,
        radius = 3,
        debug = true,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit
    })

    v.store_zone = lib.zones.sphere({
        index = k,
        name = 'store',
        coords = v.store,
        radius = 10,
        debug = true,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit
    })
end

for k, v in pairs(Config.Impounds) do
    v.access_zone = lib.zones.sphere({
        index = k,
        name = 'impound',
        coords = v.access,
        radius = 3,
        debug = true,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit
    })
end

lib.registerContext({
    id = 'some_menuxd',
    title = 'Some context menu',
    options = {{
        title = 'Empty button'
    }, {
        title = 'Disabled button',
        description = 'This button is disabled',
        icon = 'hand',
        disabled = true
    }, {
        title = 'Example button',
        description = 'Example button description',
        icon = 'circle',
        onSelect = function()
            print("Pressed the button!")
        end,
        metadata = {{
            label = 'Value 1',
            value = 'Some value'
        }, {
            label = 'Value 2',
            value = 300
        }}
    }, {
        title = 'Menu button',
        description = 'Takes you to another menu!',
        menu = 'other_menu',
        icon = 'bars'
    }, {
        title = 'Event button',
        description = 'Open a menu from the event and send event data',
        icon = 'check',
        event = 'test_event',
        arrow = true,
        args = {
            someValue = 500
        }
    }}
})
