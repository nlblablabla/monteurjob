local indienst = {}

RegisterNetEvent(GetCurrentResourceName()..'Server:UpdateInDienst', function(newindienst)
    local src = source
    if indienst[src] then
        indienst[src] = nil
    else
        indienst[src] = newindienst
    end
end)

RegisterNetEvent(GetCurrentResourceName()..'Server:RemoveBorg', function(amount)
    local src = source
    exports.ox_inventory:RemoveItem(source, src, amount)
end)

lib.callback.register(GetCurrentResourceName()..'Server:CheckInDienst', function(source)
    return indienst[source] or false
end)