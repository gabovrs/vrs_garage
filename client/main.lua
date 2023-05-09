lib.locale()
local cam = nil
local previewVehicle = nil
local inPreviewMode = false

function onEnter(self)
    lib.showTextUI(locale('access-' .. self.name), {
        icon = self.icon
    })
end

function onExit(self)
    lib.hideTextUI()
end

function inside(self)
    if IsControlJustReleased(0, 38) then
        TriggerEvent('vrs_garage:access-' .. self.name, self)
    end
end

function spawnVehicle(vehicleData, plate, coords)
    if not lib.getClosestVehicle(vector3(coords), 5.0, false) then
        ESX.Game.SpawnVehicle(GetDisplayNameFromVehicleModel(vehicleData.model), vector3(coords), coords.w,
            function(veh)
                SetPedIntoVehicle(PlayerPedId(), veh, -1)
                lib.setVehicleProperties(veh, vehicleData)
                lib.notify({
                    description = locale('vehicle_out'),
                    type = 'success'
                })
                TriggerServerEvent('vrs_garage:setVehicleOut', plate, false)
            end)
    else
        lib.notify({
            description = locale('vehicles_in_zone'),
            type = 'error'
        })
    end
end

RegisterNetEvent('vrs_garage:takeOutVehicle', function(args)
    DoScreenFadeOut(200)
    Wait(500)
    ExitPreviewMode()
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
        else
            print('error - not vehicle found', args.plate)
        end
        Wait(500)
        DoScreenFadeIn(200)
    end, args.plate)
end)

RegisterNetEvent('vrs_garage:sendVehicleConfiscated', function(targetPlate)
    TriggerServerEvent('vrs_garage:setVehicleImpound', targetPlate, true)
    lib.notify({
        description = locale('vehicle_sent_to_impounded'),
        type = 'info'
    })
    local vehicles = ESX.Game.GetVehicles()
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            if string.gsub(vehiclePlate, "%s+", "") == string.gsub(targetPlate, "%s+", "") then
                DeleteVehicle(vehicle)
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
            if string.gsub(vehiclePlate, "%s+", "") == string.gsub(targetPlate, "%s+", "") then
                SetNewWaypoint(vehicleCoords.x, vehicleCoords.y)
                found = true
                break
            end
        end
    end

    if found then
        lib.notify({
            description = locale('vehicle_found'),
            type = 'success'
        })
    else
        lib.notify({
            description = locale('vehicle_not_found'),
            type = 'error'
        })
    end
end)

function ExitPreviewMode()
    if inPreviewMode then
        inPreviewMode = false
        RenderScriptCams(false, true, 1000, true, true)
        TriggerServerEvent('vrs_garage:setPlayerRoutingBucket', 0)
        if previewVehicle then
            DeleteVehicle(previewVehicle)
            previewVehicle = nil
        end
    end
end

RegisterNetEvent('vrs_garage:access-garage', function(zone)
    lib.callback('vrs_garage:getVehicles', false, function(vehicles)
        local options = {}
        if #vehicles > 0 then
            for k, v in pairs(vehicles) do
                if v then
                    local vehicleData = json.decode(v.vehicle)
                    local vehicleTitle = GetLabelText(GetMakeNameFromVehicleModel(vehicleData.model)) .. ' - ' ..
                                             GetLabelText(GetDisplayNameFromVehicleModel(vehicleData.model))

                    local iconColor = 'rgb(29 78 216)'
                    local description = locale('plate', v.plate)
                    local disabled = false

                    if v.stored == 0 then
                        iconColor = 'rgb(250 204 21)'
                    end

                    if v.impound == 1 then
                        iconColor = 'rgb(190 18 60)'
                        disabled = true
                        vehicleTitle = vehicleTitle .. ' ' .. locale('impounded')
                    end

                    if v.parking ~= nil and v.parking ~= zone.index and v.stored == 1 then
                        disabled = true
                        description = description .. ', ' .. locale('parked_in') .. ' ' .. locale(v.parking)
                    end

                    table.insert(options, {
                        title = vehicleTitle,
                        icon = 'car',
                        iconColor = iconColor,
                        disabled = disabled,
                        description = description,
                        metadata = {{
                            label = locale('fuel'),
                            value = vehicleData.fuelLevel .. '%',
                            progress = vehicleData.fuelLevel
                        }, {
                            label = locale('engine'),
                            value = vehicleData.engineHealth / 10 .. '%',
                            progress = vehicleData.engineHealth / 10
                        }},
                        onSelect = function()
                            local options = {}
                            if v.stored == 1 then
                                inPreviewMode = true
                                TriggerServerEvent('vrs_garage:setRandomPlayerRoutingBucket')
                                Wait(100)
                                if previewVehicle then
                                    DeleteVehicle(previewVehicle)
                                    previewVehicle = nil
                                end
                                ESX.Game.SpawnVehicle(GetDisplayNameFromVehicleModel(vehicleData.model),
                                    vector3(Config.Garages[zone.index].spawn), Config.Garages[zone.index].spawn.w,
                                    function(veh)
                                        previewVehicle = veh
                                        lib.setVehicleProperties(veh, vehicleData)
                                        FreezeEntityPosition(veh, true)
                                        cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
                                            GetOffsetFromEntityInWorldCoords(previewVehicle, -3.0, 3.0, 0.5), 0.0, 0.0,
                                            GetEntityHeading(veh) - 130.0, 60.0)
                                        SetCamActive(cam, true)
                                        RenderScriptCams(true, true, 1000, true, false)
                                    end)
                                table.insert(options, {
                                    title = locale('take_out_vehicle'),
                                    icon = 'right-from-bracket',
                                    args = {
                                        plate = v.plate,
                                        zone = zone
                                    },
                                    event = 'vrs_garage:takeOutVehicle'
                                })
                            else
                                ExitPreviewMode()
                                table.insert(options, {
                                    title = locale('send_vehicle_to_impound'),
                                    icon = 'warehouse',
                                    args = v.plate,
                                    event = 'vrs_garage:sendVehicleConfiscated'
                                })

                                table.insert(options, {
                                    title = locale('find_vehicle'),
                                    icon = 'location-dot',
                                    args = v.plate,
                                    event = 'vrs_garage:findVehicle'
                                })
                            end
                            lib.registerContext({
                                id = 'garage_vehicle_options',
                                menu = 'garage_vehicles',
                                title = vehicleTitle,
                                options = options,
                                canClose = false
                                -- onExit = function()
                                --     ExitPreviewMode()
                                -- end
                            })

                            lib.showContext('garage_vehicle_options')
                        end
                    })
                end
            end
        else
            table.insert(options, {
                title = locale('no_vehicles_found'),
                icon = 'x',
                disabled = true
            })
        end

        lib.registerContext({
            id = 'garage_vehicles',
            title = locale(zone.index),
            options = options,
            onExit = function()
                ExitPreviewMode()
            end
        })

        lib.showContext('garage_vehicles')
    end)
end)

RegisterNetEvent('vrs_garage:access-store', function(zone)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local currentVehicle = GetVehiclePedIsIn(ped, false)
        local plate = GetVehicleNumberPlateText(currentVehicle)
        lib.callback('vrs_garage:checkOwner', false, function(isOwner)
            if isOwner then
                local vehicleProperties = json.encode(lib.getVehicleProperties(currentVehicle))
                TaskLeaveVehicle(ped, currentVehicle, 0)
                Wait(2000)
                TriggerServerEvent('vrs_garage:updateVehicle', plate, vehicleProperties, zone.index, true)
                lib.notify({
                    description = locale('vehicle_stored'),
                    type = 'success'
                })
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
    else
        lib.notify({
            description = locale('not_in_vehicle'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('vrs_garage:access-impound', function(zone)
    lib.callback('vrs_garage:getImpoundedVehicles', false, function(vehicles)
        local options = {}
        if #vehicles > 0 then
            for k, v in pairs(vehicles) do
                local vehicleData = json.decode(v.vehicle)
                local vehicleTitle = GetLabelText(GetMakeNameFromVehicleModel(vehicleData.model)) .. ' - ' ..
                                         GetLabelText(GetDisplayNameFromVehicleModel(vehicleData.model))

                local iconColor = 'rgb(190 18 60)'
                table.insert(options, {
                    title = vehicleTitle,
                    icon = 'car',
                    iconColor = iconColor,
                    description = locale('plate', v.plate),
                    metadata = {{
                        label = locale('fuel'),
                        value = vehicleData.fuelLevel .. '%',
                        progress = vehicleData.fuelLevel
                    }, {
                        label = locale('engine'),
                        value = vehicleData.engineHealth / 10 .. '%',
                        progress = vehicleData.engineHealth / 10
                    }},
                    onSelect = function()
                        local options = {}
                        table.insert(options, {
                            title = locale('recover_vehicle', Config.Fine),
                            icon = 'file-invoice',
                            args = {
                                plate = v.plate,
                                zone = zone
                            },
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
        else
            table.insert(options, {
                title = locale('no_vehicles_found'),
                icon = 'x',
                disabled = true
            })
        end

        lib.registerContext({
            id = 'garage_vehicles',
            title = locale(zone.index),
            options = options
        })

        lib.showContext('garage_vehicles')
    end)
end)

RegisterNetEvent('vrs_garage:recoverVehicle', function(args)
    lib.callback('vrs_garage:getVehicle', false, function(vehicle)
        if vehicle then
            if vehicle.impound == 1 then
                lib.callback('vrs_garage:canPay', false, function(canPay)
                    if canPay then
                        local vehicleData = json.decode(vehicle.vehicle)
                        spawnVehicle(vehicleData, vehicle.plate, Config.Impounds[args.zone.index].spawn)
                        TriggerServerEvent('vrs_garage:setVehicleOut', vehicle.plate, false)
                    else
                        lib.notify({
                            description = locale('not_enought_money'),
                            type = 'error'
                        })
                    end
                end, Config.Fine)
            else
                lib.notify({
                    description = locale('vehicle_not_impound'),
                    type = 'error'
                })
            end
        end
    end, args.plate)
end)

function CreateGarages()
    for k, v in pairs(Config.Garages) do
        local pedModel = 's_m_m_dockwork_01'
        lib.requestModel(pedModel)

        local ped = CreatePed(0, GetHashKey(pedModel), vector3(v.access.x, v.access.y, v.access.z - 1.0), v.access.w,
            false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        local blip = AddBlipForCoord(v.store.x, v.store.y)

        SetBlipSprite(blip, Config.GarageBlip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.GarageBlip.scale)
        SetBlipColour(blip, Config.GarageBlip.colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('garage_blip'))
        EndTextCommandSetBlipName(blip)
        -- TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', true, true)

        v.access_zone = lib.zones.sphere({
            index = k,
            name = 'garage',
            icon = 'warehouse',
            coords = v.access,
            radius = 3,
            debug = Config.Debug,
            inside = inside,
            onEnter = onEnter,
            onExit = onExit
        })

        v.store_zone = lib.zones.sphere({
            index = k,
            name = 'store',
            icon = 'square-parking',
            coords = v.store,
            radius = 10,
            debug = Config.Debug,
            inside = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

function CreateImpounds()
    for k, v in pairs(Config.Impounds) do
        local pedModel = 's_m_m_dockwork_01'
        lib.requestModel(pedModel)

        local ped = CreatePed(0, GetHashKey(pedModel), vector3(v.access.x, v.access.y, v.access.z - 1.0), v.access.w,
            false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        local blip = AddBlipForCoord(v.access.x, v.access.y)

        SetBlipSprite(blip, Config.ImpoundBlip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.ImpoundBlip.scale)
        SetBlipColour(blip, Config.ImpoundBlip.colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('impound_blip'))
        EndTextCommandSetBlipName(blip)

        v.access_zone = lib.zones.sphere({
            index = k,
            name = 'impound',
            coords = v.access,
            radius = 3,
            debug = Config.Debug,
            inside = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

Citizen.CreateThread(function()
    CreateGarages()
    CreateImpounds()
end)
