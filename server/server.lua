local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('GcartRental:server:rentCart')
AddEventHandler('GcartRental:server:rentCart', function()
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local cash = pData.PlayerData.money["cash"]
    local bank = pData.PlayerData.money["bank"]
    local vehiclePrice = Config.RentalCost + Config.DepositCost
    if (cash - vehiclePrice) >= 0 then
        TriggerClientEvent("QBCore:Notify", src, "Golf cart rented for $" .. vehiclePrice, "success", 5000)
        pData.Functions.RemoveMoney('cash', vehiclePrice, "golf-cart-rented")
    elseif (bank - vehiclePrice) >= 0 then
        TriggerClientEvent("QBCore:Notify", src, "Golf cart rented for $" .. vehiclePrice, "success", 5000)
        pData.Functions.RemoveMoney('bank', vehiclePrice, "golf-cart-rented")
    elseif (cash - vehiclePrice) < 0 then
        TriggerClientEvent("QBCore:Notify", src, "You don't have enough money, you're missing $"..format_thousand(vehiclePrice - cash).." cash", "error", 5000)
    elseif (bank - vehiclePrice) < 0 then
        TriggerClientEvent("QBCore:Notify", src, "You don't have enough money, you're missing $"..format_thousand(vehiclePrice - bank).." in the bank", "error", 5000)
    end
end)

RegisterNetEvent('GcartRental:server:returnCart')
AddEventHandler('GcartRental:server:returnCart', function()
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    local vehiclePrice = Config.DepositCost
    TriggerClientEvent("QBCore:Notify", src, "Golf cart returned for $" .. vehiclePrice .. " refund", "success", 5000)
    pData.Functions.AddMoney('bank', vehiclePrice, "golf-cart-returned")
end)