lib.locale()

Config = {}

Config.UseRadialMenu = false

Config.AccessDistance = 3.0

Config.StoreDistance = 10.0

Config.MySQL = 'oxmysql' -- 'mysql-async', 'oxmysql', 'ghmattisql'

Config.FuelSystem = 'ox_fuel' -- 'LegacyFuel', 'ox_fuel', 'custom' (client/main.lua:98 to set a custom export)

Config.KeySystem = 'custom'

Config.PedEnabled = true

Config.JobGarajesEnabled = true

Config.JobVehicleShopEnabled = true

Config.ImpoundCommandEnabled = true

Config.ImpoundCommand = {
    command = 'impound',
    radius = 2.0,
    jobs = { -- jobs with access to this command 
        'police'
    }
}

Config.ImpoundFine = {
    ['car'] = 50,
    ['boat'] = 1000,
    ['plane'] = 3000,
}

Config.TransferVehiclePrice = {
    ['car'] = 200,
    ['boat'] = 10000,
    ['plane'] = 4000,
}

Config.DefaultPed = {
    ['car'] = {
        model = 's_m_m_dockwork_01',
        task = 'WORLD_HUMAN_CLIPBOARD' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
    },
    ['plane'] = {
        model = 's_m_y_airworker',
        task = 'WORLD_HUMAN_CLIPBOARD' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
    },
    ['boat'] = {
        model = 's_m_y_baywatch_01',
        task = 'WORLD_HUMAN_CLIPBOARD' --animation https://gtaforums.com/topic/796181-list-of-scenarios-for-peds/
    }
}

Config.GarageBlip = {
    ['car'] = {
        sprite = 357,
        scale = 0.8,
        colour = 18
    },
    ['plane'] = {
        sprite = 569,
        scale = 0.8,
        colour = 18
    },
    ['boat'] = {
        sprite = 473,
        scale = 0.8,
        colour = 18
    }
}

Config.ImpoundBlip = {
    sprite = 317,
    scale = 0.8,
    colour = 6
}

Config.VehiclesNames = {
    -- ['model'] = 'Vehicle Name',
}

Config.JobVehicles = {
    ['police'] = {
        ['police'] = {price = 1000},
        ['police2'] = {price = 1000},
        ['police3'] = {price = 1000},
    },
    ['ambulance'] = {
        ['ambulance'] = {price = 1000},
    },
    ['miner'] = {
        ['sadler'] = {price = 1000000},
    },
    ['taxi'] = {
        ['taxi'] = {price = 1000000},
    },
    ['mechanic'] = {
        ['towtruck'] = {price = 1000000},
    }
}

Config.JobGarajes = {
    ['police'] = {
        ped = {
            model = 'csb_trafficwarden',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['vespucci_police'] = {
                blip = { -- only visible to those who have the job
                    label = locale('police_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 29
                },
                access = vec4(440.3128, -1013.3806, 28.6250, 152.6308),
                store = vec4(423.4687, -1021.6505, 28.9481, 88.9128),
                spawn = vec4(450.7397, -1019.5090, 28.4583, 92.3000),
                type = 'car'
            }
        }
    },
    ['ambulance'] = {
        ped = {
            model = 'csb_trafficwarden',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['strawberry_ambulance'] = {
                blip = {
                    label = locale('ambulance_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 6
                },
                access = vec4(353.1519, -603.6036, 28.7761, 267.1620),
                store = vec4(365.2415, -591.6791, 28.6921, 343.2072),
                spawn = vec4(380.5848, -585.6525, 28.6481, 201.6172),
                type = 'car'
            }
        }
    },
    ['miner'] = {
        ped = {
            model = 's_m_m_dockwork_01',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['orchardville_miner'] = {
                blip = {
                    label = locale('miner_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 5
                },
                access = vec4(870.4711, -2366.2339, 30.3462, 356.0012),
                store = vec4(880.8738, -2350.4807, 30.3312, 87.9480),
                spawn = vec4(843.8577, -2346.4854, 30.3346, 265.2579),
                type = 'car'
            }
        }
    },
    ['taxi'] = {
        ped = {
            model = 'u_m_y_proldriver_01',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['tangerine_taxi'] = {
                blip = {
                    label = locale('taxi_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 5
                },
                access = vec4(918.7134, -160.3715, 74.9114, 142.9251),
                store = vec4(910.5366, -177.4915, 74.2616, 237.7346),
                spawn = vec4(902.5016, -184.1103, 73.8883, 332.9777),
                type = 'car'
            }
        }
    },
    ['mechanic'] = {
        ped = {
            model = 's_m_m_dockwork_01',
            task = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT'
        },
        locations = {
            ['olympic_mechanic'] = {
                blip = {
                    label = locale('mechanic_garage_blip'),
                    sprite = 357,
                    scale = 0.8,
                    colour = 39
                },
                access = vec4(-192.9804, -1290.3110, 31.2965, 272.3626),
                store = vec4(-182.0340, -1301.9659, 31.2965, 272.7176),
                spawn = vec4(-160.9252, -1301.6703, 31.3432, 89.9771),
                type = 'car'
            }
        }
    }
}

Config.Garages = {
    ['elgin'] = {
        access = vec4(214.5288, -807.0486, 30.8031, 342.1742),
        store = vec4(216.8447, -786.5744, 30.8161, 340.5844),
        spawn = vec4(230.7546, -795.9514, 30.5859, 160.6045),
        type = 'car',
        blip = true
    },
    ['aguja'] = {
        access = vec4(-1183.1499, -1508.2714, 4.3797, 308.6074),
        store = vec4(-1191.9292, -1492.1295, 4.3797, 33.9222),
        spawn = vec4(-1177.7272, -1483.6582, 4.3797, 211.5811),
        type = 'car',
        blip = true
    },
    ['shambles'] = {
        access = vec4(996.9217, -2360.1174, 30.5096, 351.5527),
        store = vec4(1015.7012, -2331.0493, 30.5096, 172.7233),
        spawn = vec4(1013.7295, -2364.3025, 30.5096, 352.7007),
        type = 'car',
        blip = true
    },
    ['eclipse'] = {
        access = vec4(-570.7280, 310.9371, 84.4977, 355.5518),
        store = vec4(-567.1437, 329.4330, 84.4461, 84.1943),
        spawn = vec4(-607.3918, 337.1939, 85.1167, 263.8757),
        type = 'car',
        blip = true
    },
    ['great_ocean'] = {
        access = vec4(-200.1778, 6234.4956, 31.5027, 235.2995),
        store = vec4(-200.5813, 6214.3184, 31.4893, 45.7559),
        spawn = vec4(-193.0426, 6225.6099, 31.4897, 141.6068),
        type = 'car',
        blip = true
    },
    ['panorama_drive'] = {
        access = vec4(1649.2954, 3567.1265, 35.3912, 45.3013),
        store = vec4(1634.6001, 3565.2202, 35.2683, 117.2702),
        spawn = vec4(1608.8293, 3602.7205, 35.1463, 30.0080),
        type = 'car',
        blip = true
    },
    ['new_empire'] = {
        access = vec4(-942.2376, -2956.1157, 13.9451, 129.7652),
        store = vec4(-974.9199, -2997.5334, 13.9450, 240.2666),
        spawn = vec4(-974.8014, -3298.9353, 14.0472, 65.6655),
        type = 'plane',
        blip = true
    }
}

Config.Impounds = {
    ['innocence'] = {
        access = vec4(409.2835, -1623.0498, 29.2919, 232.2472),
        spawn = vec4(407.1664, -1645.2323, 29.2919, 228.8734),
        type = 'car',
        blip = true
    },
    ['vespucci'] = {
        access = vec4(-1057.9415, -840.6771, 5.0427, 214.2390),
        spawn = vec4(-1052.3311, -856.4564, 4.8715, 127.4942),
        type = 'car',
        blip = true
    },
    ['paleto'] = {
        access = vec4(-456.8438, 6017.9258, 31.4901, 38.0822),
        spawn = vec4(-467.4146, 6015.9771, 31.3405, 312.0559),
        type = 'car',
        blip = true
    },
    ['zancudo'] = {
        access = vec4(1852.5085, 3706.8975, 33.2539, 30.6991),
        spawn = vec4(1864.8422, 3700.9099, 33.5391, 214.8698),
        type = 'car',
        blip = true
    },
    ['pista_1'] = {
        access = vec4(-1229.4432, -3377.8064, 13.9450, 332.6432),
        spawn = vec4(-1270.8102, -3376.1331, 13.9401, 329.9285),
        type = 'plane',
        blip = true
    },
}
