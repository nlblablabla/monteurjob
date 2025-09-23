ESX = exports["es_extended"]:getSharedObject()

local mainblip = nil
local ped = nil
local Points = {}
local DienstVeh = nil
local workblip = nil

local function SendNotify(des, type, dur)
    lib.notify({
        id = des,
        title = Config.Notify.title,
        description = des,
        type = type,
        showDuration = Config.Notify.shordur,
        icon = Config.Notify.icon,
        duration = dur
    })
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(PlayerData)
	ESX.PlayerData = PlayerData
	ESX.PlayerLoaded = true
    
    TriggerEvent(GetCurrentResourceName()..'Client:PlayerLoaded')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	ESX.PlayerData.job = Job
	ESX.SetPlayerData('job', Job)

    -- changed
    lib.hideTextUI()

    TriggerEvent(GetCurrentResourceName()..'Client:Checkjob')
end)

local function CreateBlip()
    local MainBlip = AddBlipForCoord(Config.Ped.loc.x, Config.Ped.loc.y, Config.Ped.loc.x) 
    SetBlipSprite(MainBlip, Config.blip.sprite)
    SetBlipDisplay(MainBlip, Config.blip.display)
    SetBlipScale(MainBlip, Config.blip.scale)
    SetBlipColour(MainBlip, Config.blip.colour)
    SetBlipAsShortRange(MainBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.blip.text)
    EndTextCommandSetBlipName(MainBlip)
end

local function CreateWorkBlip(coords)
    if not DoesBlipExist(workblip) then
        workblip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(workblip, 465)
        SetBlipColour(workblip, 1)
        SetBlipRoute(workblip, true)
        SetBlipScale(workblip, 0.6)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Werk')
        EndTextCommandSetBlipName(workblip)
    end
end

local function Createped()
    local pedhash = GetHashKey(Config.Ped.model)

    if not IsModelInCdimage(pedhash) or not IsModelValid(pedhash) then
        print("^1[ERROR]^0 Ongeldig ped model:", Config.Ped.model)
        return
    end

    RequestModel(pedhash)

  

    while not HasModelLoaded(pedhash) do
        Wait(1)
    end




    ped = CreatePed(4, pedhash, Config.Ped.loc.x, Config.Ped.loc.y, Config.Ped.loc.z - 1, Config.Ped.loc.w, false, true)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityProofs(ped, true, true, true, true, true, true, true, true)
    SetPedCanBeTargetted(ped, false)
    SetPedAsEnemy(ped, false)
    TaskStandStill(ped, -1)

    local CTarget = Config.Ped.target
    exports.ox_target:addLocalEntity(ped, {
        label = CTarget.label,
        distance = CTarget.distance,
        icon = CTarget.icon,
        onSelect = function()
            local indienst = lib.callback.await(GetCurrentResourceName()..'Server:CheckInDienst', false)
            if indienst then
                TriggerEvent(GetCurrentResourceName()..'Client:OpenMenu', true)
            else
                TriggerEvent(GetCurrentResourceName()..'Client:OpenMenu', false)
            end
        end
    })
end

local function SelectJob()

    local keys = {}
    for k,_ in pairs(Config.Types) do
        table.insert(keys, k)
    end
    local key = math.random(1, #keys)
    local type = keys[key]
    local locKey = math.random(#Config.Work[type])
    local loc = Config.Work[type][locKey]
    local Cwerk = Config.Types[type]

    SendNotify('Ga naar de locatie om een '..type..' te repareren', 'info', 5000)
    CreateWorkBlip(loc)
    exports.ox_target:addBoxZone({
        coords = loc,
        name = type..'WorkingZone',
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = Config.debug,
        options = {
            label = Cwerk.label,
            icon = "fa-solid fa-wrench",
            distance = 2.0,
            onSelect = function()
                if lib.progressBar({
                    duration = Cwerk.time * 1000,
                    label = 'Bezig met repareren',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                    },
                    anim = {
                        dict = "mini@repair",
                        clip = "fixing_a_player",
                        flag = 16,
                    },
                }) then
                    SendNotify('Je hebt de '..type..' gerepareerd en €'..Cwerk.price..' verdiend', 'success', 5000)
                    TriggerServerEvent(GetCurrentResourceName()..'Server:GiveMoney', Cwerk.price)
                    exports.ox_target:removeZone(type..'WorkingZone')
                    RemoveBlip(workblip)
                    SelectJob()
                else
                    SendNotify('Je hebt de reparatie geannuleerd', 'error', 3000)
                end
            end
        }
    })
end

local function StopShift()
    TriggerServerEvent(GetCurrentResourceName()..'Server:UpdateInDienst', false)
    SendNotify('Je bent nu uit dienst', 'info', 3000)
    Wait(100)
    lib.hideTextUI()
    TriggerServerEvent(GetCurrentResourceName()..'Server:AddBorg', Config.Borg.price)

    RemoveBlip(workblip)
end

local function CreateRemovePoint()
    local dis = 10
    
    if not Points['Remove'] then
        Points['Remove'] = lib.points.new({
            coords = Config.car.removeloc.xyz,
            distance = dis,
        })  
    end

    local marker = lib.marker.new({
        coords = Config.car.removeloc.xyz,
        type = 2,
        width = .3, 
        height = .3,
        color = { r = 255, g = 0, b = 0, a = 0.8 }
    })

    local functions = Points['Remove']
    local dienst = true

    function functions:nearby()
        if dienst then
            marker:draw()
            if self.currentDistance < 1.5 then
                lib.showTextUI('Druk op E om je voertuig in te leveren')
                
                if IsControlJustReleased(0, 38) then
                    local ped = PlayerPedId()
                    if IsPedInAnyVehicle(ped, false) then
                        local veh = GetVehiclePedIsIn(ped, false)
                        if DienstVeh ~= veh then SendNotify('Dit is niet jouw dienst voertuig', 'error', 3000) return end
                        ESX.Game.DeleteVehicle(veh)
                        dienst = false
                        StopShift()
                    else
                        SendNotify('Je zit niet in een voertuig', 'error', 3000)
                    end
                end
            else
                lib.hideTextUI()
            end
        else
            lib.hideTextUI()
        end


    end
end

Citizen.CreateThread(function ()
    CreateBlip()


    while not ESX.PlayerLoaded do
        Citizen.Wait(100)
    end

    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName then
        Createped()
    end
end)

RegisterNetEvent(GetCurrentResourceName()..'Client:Checkjob', function ()
    if ESX.PlayerData.job.name == Config.JobName then
        if not ped then
            Createped()
        end
    else
        if ped then
            DeletePed(ped)
            ped = nil
        end
    end
end)

RegisterNetEvent(GetCurrentResourceName()..'Client:OpenMenu', function (indienst)
    if not indienst then
        lib.registerContext({
            id = 'monteurjob-menu_on',
            title = 'Monteur Job',
            options = {
                {
                    title = 'Start shift',
                    description = 'Begin met werken',
                    icon = 'file',
                    onSelect = function()
                        if Config.Borg.Enabled then
                            local cashAmount = exports.ox_inventory:GetItemCount('Cash')
                            if cashAmount < Config.Borg.price then
                                SendNotify('Je hebt niet genoeg contant geld om borg te betalen', 'error', 3000)
                                return
                            end
                            SendNotify('Je hebt €'..Config.Borg.price..' borg betaald', 'info', 3000)
                            TriggerServerEvent(GetCurrentResourceName()..'Server:RemoveBorg', Config.Borg.price)
                            TriggerServerEvent(GetCurrentResourceName()..'Server:UpdateInDienst', true)
                            SendNotify('Je bent nu in dienst', 'success', 3000)
                            TaskWarpPedIntoVehicle(PlayerPedId(), DienstVeh, -1)
                            CreateRemovePoint()
                            DienstVeh = ESX.Game.SpawnVehicle(Config.car.model, Config.car.loc.xyz, Config.car.loc.w, nil, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), DienstVeh, -1)
                            CreateRemovePoint()
                            SelectJob()
                        else
                            TriggerServerEvent(GetCurrentResourceName()..'Server:UpdateInDienst', true)
                            SendNotify('Je bent nu in dienst', 'success', 3000)
                            DienstVeh = ESX.Game.SpawnVehicle(Config.car.model, Config.car.loc.xyz, Config.car.loc.w, nil, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), DienstVeh, -1)
                            CreateRemovePoint()
                            SelectJob()
                        end
                    end,
                },
            }
        })
        lib.showContext('monteurjob-menu_on')
    else
        lib.registerContext({
            id = 'monteurjob-menu_off',
            title = 'Monteur Job',
            options = {
                {
                    title = 'Stop shift',
                    description = 'Eindig met werken',
                    icon = 'file',
                    onSelect = function()
                        if Config.Borg.Enabled then
                            local alert = lib.alertDialog({
                                header = 'Je krijgt je borg nu niet terug!',
                                content = 'Lever je voertuig in om je borg terug te krijgen \n ben je zeker dat je wilt stoppen?',
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                StopShift(  )
                            end
                        else
                            TriggerServerEvent(GetCurrentResourceName()..'Server:UpdateInDienst', true)
                            SendNotify('Je bent nu in dienst', 'success', 3000)
                            DienstVeh = ESX.Game.SpawnVehicle(Config.car.model, Config.car.loc.xyz, Config.car.loc.w, nil, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), DienstVeh, -1)
                            CreateRemovePoint()
                        end
                    end,
                },
            }
        })
        lib.showContext('monteurjob-menu_off')
    end

end)


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end


    lib.hideTextUI()
    if ped then
        DeletePed(ped)
    end

    lib.hideTextUI()
end)
