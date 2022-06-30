ESX               = nil
local cars 		  = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Supprésion au démarrage des double de clés
MySQL.ready(function()
		MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE NB = @NB',
		{
		['@NB']   = 2
		},
		function(result)
		for i=1, #result, 1 do
			MySQL.Async.execute(
				'DELETE FROM open_car WHERE id = @id',
				{
					['@id'] = result[i].id
				}
			)
		end
	end)
end)


-- Véhicle appartenue mais sans clés

ESX.RegisterServerCallback('foltone_vehiclelock:getVehiclesnokey', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE identifier = @owner',
		{
			['@owner'] = xPlayer.identifier
		},
		function(result2)

			MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE owner = @owner',
		{
			['@owner'] = xPlayer.identifier
		},
		function(result)

			local vehicles = {}
			
			for i=1, #result, 1 do
				local found = false
				local vehicleData = json.decode(result[i].vehicle)
				for j=1, #result2, 1 do
					if result2[j].value == vehicleData.plate then
						
						found = true
						
					end
				end

				if found ~= true then
					
					table.insert(vehicles, vehicleData)
				end

			end
			cb(vehicles)
		end
	)
		end
	)
end)

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Véhicle appartenue mais sans clés

ESX.RegisterServerCallback('foltone_vehiclelock:getVehiclesnokeycardealer', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE identifier = @owner',
		{
			['@owner'] = xPlayer.identifier
		},
		function(result2)

			MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE owner = @owner',
		{
			['@owner'] = xPlayer.identifier
		},
		function(result)

			local vehicles = {}

			for i=1, #result, 1 do
				local found = false
				local vehicleData = json.decode(result[i].vehicle)
				for j=1, #result2, 1 do
					if result2[j].value == vehicleData.plate then
						found = true
					end
				end
				if found ~= true then
					table.insert(vehicles, vehicleData)
				end
			end
			cb(vehicles)
		end
	)
		end
	)
end)

-- Donné les clé
RegisterServerEvent('foltone_vehiclelock:givekeycardealer')
AddEventHandler('foltone_vehiclelock:givekeycardealer', function(target, plate)
local _source = source
local xPlayer = nil
local toplate = plate
xPlayertarget = ESX.GetPlayerFromId(target)
xPlayer = ESX.GetPlayerFromId(_source)
--print(target)
--print(xPlayer)
MySQL.Async.execute(
		'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
		{
			['@label']		  = 'Cles',
			['@value']  	  = toplate,
			['@NB']   		  = 1,
			['@got']  		  = 'true',
			['@identifier']   = xPlayertarget.identifier
		},
		function(result)
			TriggerClientEvent('esx:showNotification', xPlayertarget.source, '~g~Vous avez reçu les clés de votre véhicule ~g~')
		end)
end)

RegisterServerEvent('foltone_vehiclelock:deletekeycardealer')
AddEventHandler('foltone_vehiclelock:deletekeycardealer', function(target, plate)
local _source = source
local xPlayer = nil
local toplate = plate
xPlayer = ESX.GetPlayerFromId(_source)

MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE value = @plate AND NB = @NB AND identifier = @identifier',
		{
		['@NB']   		= 3,
		['@plate'] 		= toplate,
		['@identifier'] = xPlayer.identifier
		},
		function(result)

		for i=1, #result, 1 do
			MySQL.Async.execute(
			'DELETE FROM open_car WHERE id = @id',
			{
				['@id'] = result[i].id
			}
		)
		end
		TriggerClientEvent('esx:showNotification', xPlayer.source, "~g~Vous avez donné les clé à l'acheteur ~g~")
	end)
end)


RegisterServerEvent('foltone_vehiclelock:registerkeycardealer')
AddEventHandler('foltone_vehiclelock:registerkeycardealer', function(plate, target)
local _source = source
local xPlayer = nil
if target == 'no' then
	 xPlayer = ESX.GetPlayerFromId(_source)
else
	 xPlayer = ESX.GetPlayerFromId(target)
end
MySQL.Async.execute(
		'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
		{
			['@label']		  = 'Cles',
			['@value']  	  = plate,
			['@NB']   		  = 3,
			['@got']  		  = 'true',
			['@identifier']   = xPlayer.identifier

		},
		function(result)
				TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez un nouvelle paire de clés ! ')
				TriggerClientEvent('esx:showNotification', _source, 'Clés bien enregistrer ! ')
		end)
end)
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--Clés appartenue par rapport a la plaque
ESX.RegisterServerCallback('foltone_vehiclelock:mykey', function(source, cb, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	--print(plate)
	--print(xPlayer.identifier)
	MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE value = @plate AND identifier = @identifier', 
		{
			['@plate'] = plate,
			['@identifier'] = xPlayer.identifier
		},
		function(result)
			--print(json.encode(result))

			local found = false
			if result[1] ~= nil then
				
				if xPlayer.identifier == result[1].identifier then 
					found = true
				end
			end
			if found then
				cb(true)
	
			else
				cb(false)
			end

		end
	)
end)

-- Toutes les clés appartenu par le joueur
ESX.RegisterServerCallback('foltone_vehiclelock:allkey', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE identifier = @identifier', 
		{
			['@identifier'] = xPlayer.identifier

		},
		function(result)
			key = {}
			for i=1, #result, 1 do
				
				keyadd = { plate = result[i].value,
							  NB = result[i].NB,
							 got = result[i].got }
					
					table.insert(key, keyadd)
			end
			cb(key)
		end
	)
end)

-- Donné un double
RegisterServerEvent('foltone_vehiclelock:givekey')
AddEventHandler('foltone_vehiclelock:givekey', function(target, plate)
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
local toplate = plate
if target == 'no' then
	 xPlayer = ESX.GetPlayerFromId(_source)
else
	 xPlayer = ESX.GetPlayerFromId(target)
end
MySQL.Async.execute(
	'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
	{
		['@label']		  = 'Cles',
		['@value']  	  = toplate,
		['@NB']   		  = 2,
		['@got']  		  = 'true',
		['@identifier']   = xPlayer.identifier

	},
	function(result)
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez recu un double de clés ')
	end)
end)



--Enregistrement d'une nouvelle paire de clés
RegisterServerEvent('foltone_vehiclelock:registerkey')
AddEventHandler('foltone_vehiclelock:registerkey', function(plate, target)
local _source = source
local xPlayer = nil
if target == 'no' then
	 xPlayer = ESX.GetPlayerFromId(_source)
else
	 xPlayer = ESX.GetPlayerFromId(target)
end
MySQL.Async.execute(
		'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
		{
			['@label']		  = 'Cles',
			['@value']  	  = plate,
			['@NB']   		  = 1,
			['@got']  		  = 'true',
			['@identifier']   = xPlayer.identifier

		},
		function(result)
				TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez un nouvelle pair de clés ! ')
				TriggerClientEvent('esx:showNotification', _source, 'Clés bien enregistrer ! ')
		end)

end)


RegisterServerEvent('foltone_vehiclelock:registerkeyliquide')
AddEventHandler('foltone_vehiclelock:registerkeyliquide', function(plate, target)
    local _source = source
    local xPlayer = nil
    if target == 'no' then
        xPlayer = ESX.GetPlayerFromId(_source)
    else
        xPlayer = ESX.GetPlayerFromId(target)
    end
    local LiquideJoueur = xPlayer.getMoney()
    if LiquideJoueur >= (50) then
        MySQL.Async.execute(
            'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
            {
                ['@label']		  = 'Cles',
                ['@value']  	  = plate,
                ['@NB']   		  = 1,
                ['@got']  		  = 'true',
                ['@identifier']   = xPlayer.identifier

            },
        function(result)
                TriggerClientEvent('esx:showNotification', _source, 'Clés bien enregistrer ! ')
                xPlayer.removeMoney(50)
        end)
    else
        TriggerClientEvent('esx:showAdvancedNotification', source, 'Information!', "~r~Pas assez de liquide!", '', 'CHAR_BLOCKED', 9)
    end
end)

RegisterServerEvent('foltone_vehiclelock:registerkeybanque')
AddEventHandler('foltone_vehiclelock:registerkeybanque', function(plate, target)
    local _source = source
    local xPlayer = nil
    if target == 'no' then
        xPlayer = ESX.GetPlayerFromId(_source)
    else
        xPlayer = ESX.GetPlayerFromId(target)
    end
    local BanqueJoueur = xPlayer.getAccount("bank").money
    if BanqueJoueur >= (50) then
        MySQL.Async.execute(
            'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
            {
                ['@label']		  = 'Cles',
                ['@value']  	  = plate,
                ['@NB']   		  = 1,
                ['@got']  		  = 'true',
                ['@identifier']   = xPlayer.identifier

            },
        function(result)
                TriggerClientEvent('esx:showNotification', _source, 'Clés bien enregistrer ! ')
                xPlayer.removeAccountMoney("bank", 50)
        end)
    else
        TriggerClientEvent('esx:showAdvancedNotification', source, 'Information!', "~r~Pas assez d'argent en banque!", '', 'CHAR_BLOCKED', 9)
    end
end)

--Perte des clés 
RegisterServerEvent('foltone_vehiclelock:onplayerdeath')
AddEventHandler('foltone_vehiclelock:onplayerdeath', function()
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)

MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE identifier = @identifier',
		{
		['@identifier']   = xPlayer.identifier

		},
		function(result)

		for i=1, #result, 1 do
			if result[i].NB == 1 then 
			MySQL.Async.execute(
						'UPDATE open_car SET got = @got WHERE id = @id',
						{
							['@id'] = result[i].id,
							['@got'] = 'false'
						}
					)
			else
				MySQL.Async.execute(
						'DELETE FROM open_car WHERE id = @id',
						{
							['@id'] = result[i].id
						}
					)
			end
		end
	end)
end)


---------------------------------------------------------------------------------------------
--------------------------------- Menu pour donner / preter clé -----------------------------
---------------------------------------------------------------------------------------------
--
---- changement de propriétaire
RegisterServerEvent('foltone_vehiclelock:changeowner')
AddEventHandler('foltone_vehiclelock:changeowner', function(target, plate)
local _source = source
local xPlayer = nil
local toplate = plate
xPlayertarget = ESX.GetPlayerFromId(target)
xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('UPDATE owned_vehicles SET owner=@owner WHERE plate=@plate',
		{
		['@owner'] = xPlayertarget.identifier,
		['@plate'] = vehicleProps.plate
		},
		function(rowsChanged)
			--print("insert into terminé")
	end)
end)

------ Donné clé
RegisterServerEvent('foltone_vehiclelock:donnerkey')
AddEventHandler('foltone_vehiclelock:donnerkey', function(target, plate)
local _source = source
local xPlayer = nil
local toplate = plate
xPlayertarget = ESX.GetPlayerFromId(target)
xPlayer = ESX.GetPlayerFromId(_source)

MySQL.Async.execute(
		'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
		{
			['@label']		  = 'Cles',
			['@value']  	  = toplate,
			['@NB']   		  = 1,
			['@got']  		  = 'true',
			['@identifier']   = xPlayertarget.identifier

		},
		function(result)
				TriggerClientEvent('esx:showNotification', xPlayertarget.source, 'Vous avez reçu de nouvelle clé ')
				TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez donné votre clé, vous ne les avez plus !')
		end)
end)

--- suppression des clés
RegisterServerEvent('foltone_vehiclelock:deletekey')
AddEventHandler('foltone_vehiclelock:deletekey', function(plate)
local _source = source
local xPlayer = nil
local toplate = plate
xPlayer = ESX.GetPlayerFromId(_source)

MySQL.Async.fetchAll(
		'SELECT * FROM open_car WHERE value = @plate AND identifier = @identifier',
		{
		['@plate'] 		= toplate,
		['@identifier'] = xPlayer.identifier
		},
		function(result)

		for i=1, #result, 1 do
			MySQL.Async.execute(
			'DELETE FROM open_car WHERE id = @id',
			{
				['@id'] = result[i].id
			}
		)
		end
	end)
end)

------- Préter clé
RegisterServerEvent('foltone_vehiclelock:preterkey')
AddEventHandler('foltone_vehiclelock:preterkey', function(target, plate)
local _source = source
local xPlayer = nil
local toplate = plate
xPlayertarget = ESX.GetPlayerFromId(target)
xPlayer = ESX.GetPlayerFromId(_source)

MySQL.Async.execute(
		'INSERT INTO open_car (label, value, NB, got, identifier) VALUES (@label, @value, @NB, @got, @identifier)',
		{
			['@label']		  = 'Cles',
			['@value']  	  = toplate,
			['@NB']   		  = 2,
			['@got']  		  = 'true',
			['@identifier']   = xPlayertarget.identifier

		},
		function(result)
				TriggerClientEvent('esx:showNotification', xPlayertarget.source, 'Vous avez reçu un double de clé ')
				TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez prété votre clé')
		end)

end)

ESX.RegisterServerCallback('</eDen:AfficheKeys', function(source, cb, plate)
    local xPlayer  = ESX.GetPlayerFromId(source)
    local AffiKeys = {}

    if xPlayer ~= nil then
        MySQL.Async.fetchAll('SELECT * FROM open_car WHERE identifier = @identifier ', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            for k, v in pairs(result) do
                table.insert(AffiKeys, {
                    id = v.id, 
                    label = v.label,
                    value = v.value,
                    got = v.got,
                    nb = v.nb,
                })
            end
            cb(AffiKeys)
        end)
    end
end)
