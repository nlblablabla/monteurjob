local mainblip = nil
local ped

local function Start()
    local testBlip = AddBlipForCoord(Config.Ped.loc.x, Config.Ped.loc.y, Config.Ped.loc.x) 
    SetBlipSprite(testBlip, Config.blip.sprite)
    SetBlipDisplay(testBlip, Config.blip.display)
    SetBlipScale(testBlip, Config.blip.scale)
    SetBlipColour(testBlip, Config.blip.colour)
    SetBlipAsShortRange(testBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.blip.text)
    EndTextCommandSetBlipName(testBlip)

    local pedhash = GetHashKey(Config.Ped.model)

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
        icon = CTarget.icon
    })
end



Start()

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
