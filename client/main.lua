ESX = exports['es_extended']:getSharedObject()
lib.locale()
local isBusy = false
local cam = nil
local zoneIndex = nil
local previewVehicle = nil
local inPreviewMode = false
local jobBlips = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    ManageJobsBlips()
end)

function onEnter(self)
    zoneIndex = self.index
    if self.job then
        if ESX.PlayerData.job.name == self.job then
            if Config.UseRadialMenu then
                lib.addRadialItem({{
                    id = 'access-'.. self.name,
                    label = locale('radial-access-'.. self.name),
                    icon = self.icon,
                    onSelect = function()
                        TriggerEvent('vrs_garage:access-' .. self.name, self)
                    end
                }})
            else
                lib.showTextUI(locale('access-' .. self.name), {
                    icon = self.icon
                })
            end
        end
    else
        if Config.UseRadialMenu then
            lib.addRadialItem({{
                id = 'access-'.. self.name,
                label = locale('radial-access-'.. self.name),
                icon = self.icon,
                onSelect = function()
                    TriggerEvent('vrs_garage:access-' .. self.name, self)
                end
            }})
        else
            lib.showTextUI(locale('access-' .. self.name), {
                icon = self.icon
            })
        end
    end
end

function onExit(self)
    if zoneIndex then
        zoneIndex = nil
    end
    if Config.UseRadialMenu then
        lib.removeRadialItem('access-' ..self.name)
    else
        lib.hideTextUI()
    end
end

function inside(self)
    if IsControlJustReleased(0, 38) and not Config.UseRadialMenu and not isBusy then
        isBusy = true
        if self.job then
            if ESX.PlayerData.job.name == self.job then
                TriggerEvent('vrs_garage:access-' .. self.name, self)
            end
        else
            TriggerEvent('vrs_garage:access-' .. self.name, self)
        end
        Citizen.Wait(1000)
        isBusy = false
    end
end

function spawnVehicle(vehicleData, plate, coords)
    if not lib.getClosestVehicle(vector3(coords), 5.0, false) then
        ESX.Game.SpawnVehicle(vehicleData.model, vector3(coords), coords.w, function(veh)
            SetPedIntoVehicle(PlayerPedId(), veh, -1)
            lib.setVehicleProperties(veh, vehicleData)
            lib.notify({
                description = locale('vehicle_out'),
                type = 'success'
            })
            TriggerServerEvent('vrs_garage:setVehicleOut', plate, false)
            if Config.FuelSystem == 'LegacyFuel' then
                if vehicleData.fuelLevel then
                    exports["LegacyFuel"]:SetFuel(veh, vehicleData.fuelLevel)
                end
            elseif Config.FuelSystem == 'ox_fuel' then
                Entity(veh).state.fuel = vehicleData.fuelLevel
            elseif Config.FuelSystem == 'custom' then
                -- add your custom system export here
            end
            if Config.KeySystem == 'custom' then
                Entity(veh).state.owner = GetPlayerServerId(PlayerId())
                -- add your custom system export here
            end
        end)
    else
        lib.notify({
            description = locale('vehicles_in_zone'),
            type = 'error'
        })
    end
end

RegisterNetEvent('vrs_garage:impoundVehicle', function()
    local ped = PlayerPedId()
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(ped), Config.ImpoundCommand.radius, false)
    if closestVehicle then
        if not IsPedInAnyVehicle(ped) then
            if lib.progressBar({
                duration = 8000,
                label = locale('impounding_progress'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    combat = true,
                    car = true
                },
                anim = {
                    dict = 'mini@repair',
                    clip = 'fixing_a_ped'
                }
            }) then
                TriggerServerEvent('vrs_garage:setVehicleImpound', string.gsub(GetVehicleNumberPlateText(closestVehicle), "%s", ""), true)
                SetEntityAsMissionEntity(closestVehicle, true, true)
                NetworkFadeOutEntity(closestVehicle, true, true)
                Wait(1000)
                DeleteVehicle(closestVehicle)
                lib.notify({
                    description = locale('vehicle_impounded'),
                    type = 'success'
                })
            end
        end
    else
        lib.notify({
            description = locale('no_vehicles_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('vrs_garage:takeOutVehicle', function(args)
    DoScreenFadeOut(200)
    Wait(500)
    ExitPreviewMode()
    lib.callback('vrs_garage:getVehicle', false, function(vehicle)
        if vehicle then
            if vehicle.stored then
                local vehicleData = json.decode(vehicle.vehicle)
                spawnVehicle(vehicleData, vehicle.plate, args.spawn)
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

RegisterNetEvent('vrs_garage:sendVehicleImpound', function(targetPlate)
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

RegisterNetEvent('vrs_garage:transferVehicle', function(args)
    lib.callback('vrs_garage:canPay', false, function(canPay)
        if canPay then
            TriggerServerEvent('vrs_garage:setVehicleParking', args.plate, args.zone.parking)
            lib.notify({
                description = locale('vehicle_moved'),
                type = 'success'
            })
        else
            lib.notify({
                description = locale('not_enought_money'),
                type = 'error'
            })
        end
    end, Config.TransferVehiclePrice[args.zone.type])
end)

RegisterNetEvent('vrs_garage:access-garage-job', function(zone)
    local options = {}

    if Config.JobVehicleShopEnabled then
        table.insert(options, {
            title = locale('garage_shop'),
            icon = 'shop',
            menu = 'garage_shop_' ..zone.job
        })
    end

    table.insert(options, {
        title = locale('stored_vehicles'),
        icon = 'warehouse',
        arrow = true,
        onSelect = function()
            TriggerEvent('vrs_garage:access-garage', zone)
        end
    })

    lib.registerContext({
        id = 'garage_job',
        title = locale(zone.index),
        options = options
    })

    lib.showContext('garage_job')
end)

function EnterPreviewMode(vehicleData, spawn)
    inPreviewMode = true
    if previewVehicle then
        DeleteVehicle(previewVehicle)
        previewVehicle = nil
    end
    lib.callback('vrs_garage:setPlayerRoutingBucket', false, function(canContinue)
        if canContinue then
            ESX.Game.SpawnVehicle(vehicleData.model, vector3(spawn), spawn.w, function(veh)
                previewVehicle = veh
                lib.setVehicleProperties(veh, vehicleData)
                FreezeEntityPosition(veh, true)
                cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
                    GetOffsetFromEntityInWorldCoords(previewVehicle, -3.0, 3.0, 0.5), 0.0, 0.0, GetEntityHeading(veh) - 130.0,
                    60.0)
                SetCamActive(cam, true)
                RenderScriptCams(true, true, 1000, true, false)
            end)
        end
    end)
end

function ExitPreviewMode()
    if inPreviewMode then
        inPreviewMode = false
        RenderScriptCams(false, true, 1000, true, true)
        lib.callback('vrs_garage:setPlayerRoutingBucket', false, function(canContinue)
            if canContinue then
                if previewVehicle then
                    DeleteVehicle(previewVehicle)
                    previewVehicle = nil
                end
            end
        end, 0)
    end
end

function GetVehicleName(model)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local name = GetLabelText(displayName)
    if name == 'NULL' then
        name = Config.VehiclesNames[string.lower(displayName)] or displayName
    end
    return name
end

function GetVehicleMetaData(vehicleData)
    local metadata = {}

    if vehicleData.fuelLevel then
        table.insert(metadata, {
            label = locale('fuel'),
            value = vehicleData.fuelLevel .. '%',
            progress = vehicleData.fuelLevel
        })
    end

    if vehicleData.engineHealth then
        table.insert(metadata, {
            label = locale('engine'),
            value = vehicleData.engineHealth / 10 .. '%',
            progress = vehicleData.engineHealth / 10
        })
    end
    return metadata
end

RegisterNetEvent('vrs_garage:access-garage', function(zone)
    lib.callback('vrs_garage:getVehicles', false, function(vehicles)
        local options = {}
        if #vehicles > 0 then
            for k, v in pairs(vehicles) do
                if v then
                    local vehicleData = json.decode(v.vehicle)
                    local vehicleTitle = GetVehicleName(vehicleData.model)
                    local iconColor = 'rgb(29 78 216)'
                    local icon = 'car'
                    local description = locale('plate', v.plate)
                    local metadata = GetVehicleMetaData(vehicleData)

                    if v.stored == 0 or v.stored == false then
                        iconColor = 'rgb(250 204 21)' --Yellow
                    end

                    if v.impound == 1 or v.impound == true then
                        iconColor = 'rgb(190 18 60)' --Red
                        vehicleTitle = vehicleTitle .. ' ' .. locale('impounded')
                    end

                    if v.parking ~= nil and v.parking ~= zone.index and (v.stored == 1 or v.stored == true) then
                        iconColor = 'rgb(96 165 250)'
                        description = description .. ', ' .. locale('parked_in') .. ' ' .. locale(v.parking)
                    end

                    if zone.job then
                        table.insert(options, {
                            title = vehicleTitle .. ' ' .. locale('job'),
                            icon = icon,
                            iconColor = iconColor,
                            disabled = v.impound == 1 or v.impound == true,
                            description = description,
                            metadata = metadata,
                            arrow = true,
                            onSelect = function()
                                local options = {}
                                if v.stored == 1 or v.stored == true then
                                    if v.parking ~= nil and v.parking ~= zone.index then
                                        table.insert(options, {
                                            title = locale('transfer_vehicle'),
                                            description = '',
                                            icon = 'right-from-bracket',
                                            args = {
                                                plate = v.plate,
                                                zone = zone
                                            },
                                            event = 'vrs_garage:transferVehicle'
                                        })
                                    else
                                        EnterPreviewMode(vehicleData,
                                            Config.JobGarajes[zone.job].locations[zone.index].spawn)
                                        table.insert(options, {
                                            title = locale('take_out_vehicle'),
                                            icon = 'right-from-bracket',
                                            args = {
                                                plate = v.plate,
                                                zone = zone,
                                                spawn = Config.JobGarajes[zone.job].locations[zone.index].spawn
                                            },
                                            event = 'vrs_garage:takeOutVehicle'
                                        })
                                    end
                                else
                                    ExitPreviewMode()
                                    table.insert(options, {
                                        title = locale('send_vehicle_to_impound'),
                                        icon = 'warehouse',
                                        args = v.plate,
                                        event = 'vrs_garage:sendVehicleImpound'
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
                                })
                                lib.showContext('garage_vehicle_options')
                            end
                        })
                    else
                        if not v.job then
                            table.insert(options, {
                                title = vehicleTitle,
                                icon = icon,
                                iconColor = iconColor,
                                disabled = v.impound == 1 or v.impound == true,
                                description = description,
                                metadata = metadata,
                                arrow = true,
                                onSelect = function()
                                    local options = {}
                                    if v.stored == 1 or v.stored == true then
                                        if v.parking ~= nil and v.parking ~= zone.index then
                                            table.insert(options, {
                                                title = locale('transfer_vehicle', Config.TransferVehiclePrice[zone.type]),
                                                icon = 'right-from-bracket',
                                                args = {
                                                    plate = v.plate,
                                                    zone = zone
                                                },
                                                event = 'vrs_garage:transferVehicle'
                                            })
                                        else
                                            EnterPreviewMode(vehicleData, Config.Garages[zone.index].spawn)
                                            table.insert(options, {
                                                title = locale('take_out_vehicle'),
                                                icon = 'right-from-bracket',
                                                args = {
                                                    plate = v.plate,
                                                    zone = zone,
                                                    spawn = Config.Garages[zone.index].spawn
                                                },
                                                event = 'vrs_garage:takeOutVehicle'
                                            })
                                        end
                                    else
                                        ExitPreviewMode()
                                        table.insert(options, {
                                            title = locale('send_vehicle_to_impound'),
                                            icon = 'warehouse',
                                            args = v.plate,
                                            event = 'vrs_garage:sendVehicleImpound'
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
                                    })
                                    lib.showContext('garage_vehicle_options')
                                end
                            })
                        end
                    end
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
    end, zone.job, zone.type)
end)

RegisterNetEvent('vrs_garage:access-store', function(zone)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local currentVehicle = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(currentVehicle, -1) == ped then
            local plate = GetVehicleNumberPlateText(currentVehicle)
            lib.callback('vrs_garage:checkOwner', false, function(isOwner)
                if isOwner then
                    lib.callback('vrs_garage:getVehicle', false, function(vehicle)
                        if vehicle then
                            if zone.job then
                                if zone.job == vehicle.job and zone.type == vehicle.type then
                                    local vehicleProperties = json.encode(lib.getVehicleProperties(currentVehicle))
                                    TriggerServerEvent('vrs_garage:updateVehicle', plate, vehicleProperties, zone.index, true)
                                    lib.notify({
                                        description = locale('vehicle_stored'),
                                        type = 'success'
                                    })
                                    -- NetworkFadeOutEntity(currentVehicle, true, true)
                                    ESX.Game.DeleteVehicle(currentVehicle)
                                else
                                    lib.notify({
                                        description = locale('vehicle_not_allowed'),
                                        type = 'error'
                                    })
                                end
                            else
                                if not vehicle.job and zone.type == vehicle.type then
                                    local vehicleProperties = json.encode(lib.getVehicleProperties(currentVehicle))
                                    TriggerServerEvent('vrs_garage:updateVehicle', plate, vehicleProperties, zone.index, true)
                                    lib.notify({
                                        description = locale('vehicle_stored'),
                                        type = 'success'
                                    })
                                    ESX.Game.DeleteVehicle(currentVehicle)
                                else
                                    lib.notify({
                                        description = locale('vehicle_not_allowed'),
                                        type = 'error'
                                    })
                                end
                            end
                        end
                    end, plate)
                else
                    lib.notify({
                        description = locale('not_owner'),
                        type = 'error'
                    })
                end
            end, plate)
        end
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
        if vehicles and #vehicles > 0 then
            for k, v in pairs(vehicles) do
                local vehicleData = json.decode(v.vehicle)
                local vehicleTitle = GetVehicleName(vehicleData.model)
                local iconColor = 'rgb(190 18 60)'
                local icon = 'car'
                local metadata = GetVehicleMetaData(vehicleData)

                table.insert(options, {
                    title = vehicleTitle,
                    icon = icon,
                    iconColor = iconColor,
                    description = locale('plate', v.plate),
                    metadata = metadata,
                    arrow = true,
                    onSelect = function()
                        local options = {}
                        table.insert(options, {
                            title = locale('recover_vehicle', Config.ImpoundFine[zone.type]),
                            icon = 'file-invoice',
                            args = {
                                plate = v.plate,
                                zone = zone
                            },
                            event = 'vrs_garage:recoverVehicle'
                        })
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
    end, zone.type)
end)

RegisterNetEvent('vrs_garage:recoverVehicle', function(args)
    lib.callback('vrs_garage:getVehicle', false, function(vehicle)
        if vehicle then
            if vehicle.impound then
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
                end, Config.ImpoundFine[args.zone.type])
            else
                lib.notify({
                    description = locale('vehicle_not_impound'),
                    type = 'error'
                })
            end
        end
    end, args.plate)
end)

RegisterNetEvent('vrs_garage:buyVehicle', function(args)
    lib.callback('vrs_garage:canPay', false, function(canPay)
        if canPay then
            local vehicle = lib.getVehicleProperties(previewVehicle)
            TriggerServerEvent('vrs_garage:buyVehicle', vehicle.plate, vehicle, zoneIndex, args.job)
            ExitPreviewMode()
            lib.notify({
                description = locale('vehicle_purchased'),
                type = 'success'
            })
        else
            ExitPreviewMode()
            lib.notify({
                description = locale('not_enought_money'),
                type = 'error'
            })
        end
    end, args.price)
end)

function ManageJobsBlips()
    for k, v in pairs(jobBlips) do
        RemoveBlip(v)
        table.remove(jobBlips, k)
    end
    for job, v in pairs(Config.JobGarajes) do
        if job == ESX.PlayerData.job.name then
            for k, v in pairs(v.locations) do 
                if v.blip then
                    local blip = AddBlipForCoord(v.access.x, v.access.y)
            
                    SetBlipSprite(blip, v.blip.sprite)
                    SetBlipDisplay(blip, 4)
                    SetBlipScale(blip, v.blip.scale)
                    SetBlipColour(blip, v.blip.colour)
                    SetBlipAsShortRange(blip, true)
            
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName(v.blip.label)
                    EndTextCommandSetBlipName(blip) 
                    table.insert(jobBlips, blip)
                end
            end
        end
    end
end

function CreatePeds(ped, location, type)
    if Config.PedEnabled then
        local pedModel = Config.DefaultPed[type].model
        local pedTask = Config.DefaultPed[type].task
        if ped then
            pedModel = ped.model
            if ped.task then
                pedTask = ped.task
            end
        end
        lib.requestModel(pedModel)

        local ped = CreatePed(0, GetHashKey(pedModel), vector3(location.x, location.y, location.z - 1.0), location.w,
            false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, pedTask, true, true)
    end
end

function CreateGarages()
    for k, v in pairs(Config.Garages) do
        CreatePeds(v.ped, v.access, v.type)
        if v.blip then
            local blip = AddBlipForCoord(v.store.x, v.store.y)

            SetBlipSprite(blip, Config.GarageBlip[v.type].sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.GarageBlip[v.type].scale)
            SetBlipColour(blip, Config.GarageBlip[v.type].colour)
            SetBlipAsShortRange(blip, true)
    
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locale(v.type..'_garage_blip'))
            EndTextCommandSetBlipName(blip) 
        end

        RemoveVehiclesFromGeneratorsInArea(v.store.x - 20.0, v.store.y - 20.0, v.store.z - 20.0, v.store.x + 20.0, v.store.y + 20.0, v.store.z + 20.0)

        lib.points.new({
            index = k,
            type = v.type,
            name = 'garage',
            icon = 'warehouse',
            coords = v.access,
            distance = Config.AccessDistance,
            nearby = inside,
            onEnter = onEnter,
            onExit = onExit
        })

        lib.points.new({
            index = k,
            type = v.type,
            name = 'store',
            icon = 'square-parking',
            coords = v.store,
            distance = Config.StoreDistance,
            nearby = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

function CreateImpounds()
    for k, v in pairs(Config.Impounds) do
        CreatePeds(v.ped, v.access, v.type)
        if v.blip then
            local blip = AddBlipForCoord(v.access.x, v.access.y)

            SetBlipSprite(blip, Config.ImpoundBlip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.ImpoundBlip.scale)
            SetBlipColour(blip, Config.ImpoundBlip.colour)
            SetBlipAsShortRange(blip, true)
    
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locale('impound_blip'))
            EndTextCommandSetBlipName(blip) 
        end

        RemoveVehiclesFromGeneratorsInArea(v.access.x - 20.0, v.access.y - 20.0, v.access.z - 20.0, v.access.x + 20.0, v.access.y + 20.0, v.access.z + 20.0)

        lib.points.new({
            index = k,
            type = v.type,
            name = 'impound',
            icon = 'building-shield',
            coords = v.access,
            distance = Config.AccessDistance,
            nearby = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end

function CreateJobGarages()
    if Config.JobGarajesEnabled then
        for job, v in pairs(Config.JobGarajes) do
            for garage, w in pairs(v.locations) do
                CreatePeds(v.ped, w.access, w.type)
                RemoveVehiclesFromGeneratorsInArea(w.store.x - 20.0, w.store.y - 20.0, w.store.z - 20.0, w.store.x + 20.0, w.store.y + 20.0, w.store.z + 20.0)

                lib.points.new({
                    index = garage,
                    type = w.type,
                    name = 'garage-job',
                    job = job,
                    icon = 'warehouse',
                    coords = w.access,
                    distance = Config.AccessDistance,
                    nearby = inside,
                    onEnter = onEnter,
                    onExit = onExit
                })

                lib.points.new({
                    index = garage,
                    type = w.type,
                    name = 'store',
                    job = job,
                    icon = 'square-parking',
                    coords = w.store,
                    distance = Config.StoreDistance,
                    nearby = inside,
                    onEnter = onEnter,
                    onExit = onExit
                })
            end
        end
    end
end

for job, vehicles in pairs(Config.JobVehicles) do
    local options = {}
    local menuName = 'garage_shop_' .. job
    for name, info in pairs(vehicles) do
        table.insert(options, {
            title = GetVehicleName(name) .. ' $' .. info.price,
            icon = 'car',
            arrow = true,
            onSelect = function()
                local vehicle = {
                    model = name
                }
                EnterPreviewMode(vehicle, Config.JobGarajes[job].locations[zoneIndex].spawn)
                lib.registerContext({
                    id = 'garage_shop_buy',
                    menu = menuName,
                    canClose = false,
                    title = locale('garage_shop'),
                    options = {{
                        title = locale('buy', info.price),
                        icon = 'money-bill',
                        args = {
                            price = info.price,
                            job = job
                        },
                        event = 'vrs_garage:buyVehicle'
                    }}
                })

                lib.showContext('garage_shop_buy')
            end
        })
    end
    lib.registerContext({
        id = menuName,
        title = locale('garage_shop'),
        options = options,
        onExit = function()
            ExitPreviewMode()
        end
    })
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    CreateGarages()
    CreateImpounds()
    CreateJobGarages()
    ManageJobsBlips()
end)
