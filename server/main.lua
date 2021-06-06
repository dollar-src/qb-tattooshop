ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Code

ESX.RegisterServerCallback('qb-tattooshop:GetPlayerTattoos', function(source, cb, data)
	local src = source
    local Player = ESX.GetPlayerFromId(src)
	local identifiertest = GetPlayerIdentifiers(src)[1]


	if Player then
		 exports['ghmattimysql']:execute('SELECT tattoos FROM users WHERE identifier = @identifier', {
			['@identifier'] = identifiertest,
			["@cid"] = cid
		}, function(result)
			if result[1].tattoos then
				cb(json.decode(result[1].tattoos))
			else
				cb()
			end
		end)
	else
		cb()
	end
end)

ESX.RegisterServerCallback('qb-tattooshop:PurchaseTattoo', function(source, cb, tattooList, price, tattoo, tattooName)
	local Player = ESX.GetPlayerFromId(source)


	if Player.getQuantity('cash') >= price then
        Player.removeInventoryItem('cash', price)

		table.insert(tattooList, tattoo)
		-- local cid = tonumber(data.cid)
		exports['ghmattimysql']:execute('UPDATE users SET tattoos = @tattoos WHERE identifier = @identifier', {
			['@tattoos'] = json.encode(tattooList),
			['@identifier'] = Player.identifier
		})

		TriggerClientEvent('QBCore:Notify', source, "You have bought the " .. tattooName .. " tattoo for $" .. price, 'success')
		cb(true)
	else
		TriggerClientEvent('QBCore:Notify', source, "You do not have enough money for this tattoo", 'success')

		cb(false)
	end
end)

RegisterServerEvent('qb-tattooshop:server:RemoveTattoo')
AddEventHandler('qb-tattooshop:server:RemoveTattoo', function (tattooList)
	local Player = ESX.GetPlayerFromId(source)

	exports['ghmattimysql']:execute('UPDATE users SET tattoos = @tattoos WHERE citizenid = @citizenid', {
		['@tattoos'] = json.encode(tattooList),
		['@citizenid'] = Player.identifier
	})
end)
