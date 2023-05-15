Config = {}

Config.UseRadialMenu = false

Config.MySQL = 'oxmysql' -- 'mysql-async', 'oxmysql', 'ghmattisql'

Config.FuelSystem = 'LegacyFuel' -- 'LegacyFuel', 'ox_fuel', 'custom' (client/main.lua:98 to set a custom export)

Config.PedEnabled = true

Config.JobGarajesEnabled = true -- enable the drawing of locations

Config.JobVehicleShopEnabled = true -- enable the drawing of locations

Config.Debug = false -- enable the drawing of locations

Config.ImpoundCommandEnabled = true

Config.ImpoundCommand = {
    command = 'impound',
    radius = 2.0,
    jobs = { -- jobs with access to this command 
        'police'
    }
}

Config.FinePrice = 50

Config.TransferVehiclePrice = 200

Config.DefaultPed = {
    model = 's_m_m_dockwork_01',
    task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
}

Config.GarageBlip = {
    sprite = 50,
    scale = 0.8,
    colour = 0
}

Config.ImpoundBlip = {
    sprite = 524,
    scale = 0.8,
    colour = 81
}

Config.VehiclesNames = {
    ['evo9'] = 'Mitsubishi evo 9'
}

Config.JobVehicles = {
    ['police'] = {
        ['police2'] = {price = 5000},
        ['police3'] = {price = 10000},
    }
}

Config.JobGarajes = {
    ['police'] = {
        ped = {
            model = 'csb_trafficwarden',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['Vespucci Police Garage'] = {
                access = vec4(440.3128, -1013.3806, 28.6250, 152.6308),
                store = vec4(423.4687, -1021.6505, 28.9481, 88.9128),
                spawn = vec4(450.7397, -1019.5090, 28.4583, 92.3000)
            }
        }
    },
    ['ambulance'] = {
        ped = {
            model = 'csb_trafficwarden',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['Strawberry EMS Garage'] = {
                access = vec4(353.1519, -603.6036, 28.7761, 267.1620),
                store = vec4(365.2415, -591.6791, 28.6921, 343.2072),
                spawn = vec4(380.5848, -585.6525, 28.6481, 201.6172)
            }
        }
    }
}

Config.Garages = {
    ['Central Garage'] = {
        access = vec4(214.5288, -807.0486, 30.8031, 342.1742),
        store = vec4(216.8447, -786.5744, 30.8161, 340.5844),
        spawn = vec4(230.7546, -795.9514, 30.5859, 160.6045),
        ped = {
            model = 'a_f_y_femaleagent',
        }
    },
    ['Aguja Street Garage'] = {
        access = vec4(-1183.1499, -1508.2714, 4.3797, 308.6074),
        store = vec4(-1191.9292, -1492.1295, 4.3797, 33.9222),
        spawn = vec4(-1177.7272, -1483.6582, 4.3797, 211.5811),
    },
    ['Olympic Garage'] = {
        access = vec4(-218.7779, -1171.8588, 23.0233, 89.9708),
        store = vec4(-238.2430, -1171.4512, 22.9386, 270.6689),
        spawn = vec4(-211.9449, -1181.9193, 23.0294, 90.7041),
    },
    ['Shambles Garage'] = {
        access = vec4(996.9217, -2360.1174, 30.5096, 351.5527),
        store = vec4(1015.7012, -2331.0493, 30.5096, 172.7233),
        spawn = vec4(1013.7295, -2364.3025, 30.5096, 352.7007),
    },
    ['Eclipse Garage'] = {
        access = vec4(-570.7280, 310.9371, 84.4977, 355.5518),
        store = vec4(-567.1437, 329.4330, 84.4461, 84.1943),
        spawn = vec4(-607.3918, 337.1939, 85.1167, 263.8757),
    },
    ['Great Ocean Garage'] = {
        access = vec4(-200.1778, 6234.4956, 31.5027, 235.2995),
        store = vec4(-200.5813, 6214.3184, 31.4893, 45.7559),
        spawn = vec4(-193.0426, 6225.6099, 31.4897, 141.6068),
    },
    ['Panorama Drive Garage'] = {
        access = vec4(1649.2954, 3567.1265, 35.3912, 45.3013),
        store = vec4(1634.6001, 3565.2202, 35.2683, 117.2702),
        spawn = vec4(1608.8293, 3602.7205, 35.1463, 30.0080),
    }
}

Config.Impounds = {
    ['Innocence Boulevard Impound'] = {
        access = vec4(409.2835, -1623.0498, 29.2919, 232.2472),
        spawn = vec4(407.1664, -1645.2323, 29.2919, 228.8734)
    },
    ['Vespucci Boulevard Impound'] = {
        access = vec4(-1057.9415, -840.6771, 5.0427, 214.2390),
        spawn = vec4(-1052.3311, -856.4564, 4.8715, 127.4942)
    },
    ['Paleto Impound'] = {
        access = vec4(-456.8438, 6017.9258, 31.4901, 38.0822),
        spawn = vec4(-467.4146, 6015.9771, 31.3405, 312.0559)
    },
    ['Zancudo Avenue Impound'] = {
        access = vec4(1852.5085, 3706.8975, 33.2539, 30.6991),
        spawn = vec4(1864.8422, 3700.9099, 33.5391, 214.8698)
    }
}
