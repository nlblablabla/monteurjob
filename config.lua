Config = {}

Config.Ped = {
    loc = vec4(535.9880, -1868.0286, 25.3320, 308.1917),
    model = 's_m_y_dockwork_01',
    target = {
        label = 'Open werkmenu',
        icon = "fa-solid fa-briefcase",
        distance = 1
    }
}

Config.Borg = {
    Enabled = true,
    price = 1000,
}

Config.Notify = {
    title = 'Montuer job',
    icon = "wrench",
    shordur = false
}

Config.blip = {
    sprite = 351,
    display = 2,
    scale = 1.0,
    colour = 5,
    text = "Monteur job"
}



Config.car = {
    model = 'burrito',
    loc = vec4(538.5888, -1859.5060, 25.3320, 213.9843),
    removeloc = vec3(530.0685, -1857.0869, 25.3320)
}

Config.JobName = 'monteur'

Config.Types = {
    ['BusHokjes'] = {
        label = 'Bus hokje repareren',
        time = 10,
        price = 50
    },
    ['DakGoot'] = {
        label = 'Dakgoot repareren',
        time = 15,
        price = 75
    },
}


Config.Work = {
    ['BusHokjes'] = {
        vector3(-267.94165, -824.3837, 30.842802),
        vector3(-250.16788, -887.0839, 29.626638),
        vector3(474.52, -589.28, 29.32),
        vector3(307.44, -766.68, 29.24),
        vector3(114.08, -784.56, 31.32),
    },
    ['DakGoot'] = {
        vector3(336.2847, -1830.1257, 27.9479),
        vector3(406.0484, -1748.7415, 29.3004),
    },
}