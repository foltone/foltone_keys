ESX               = nil
local playerCars = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end
end)

function OpenCloseVehicle()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed, true)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
	end

	ESX.TriggerServerCallback('foltone_vehiclelock:mykey', function(gotkey)
		if gotkey then
			local locked = GetVehicleDoorLockStatus(vehicle)
			if locked == 1 or locked == 0 then
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				SetVehicleLights(vehicle, 2)
				Wait(200)
				SetVehicleLights(vehicle, 0)
				Wait(200)
				SetVehicleLights(vehicle, 2)
				Wait(200)
				SetVehicleLights(vehicle, 0)
				Wait(200)
				SetVehicleLights(vehicle, 2)
				Wait(200)
				SetVehicleLights(vehicle, 0)
				SetNotificationBackgroundColor(6)
				ESX.ShowAdvancedNotification('Clés', 'Véhicule fermé', '', 'CHAR_FERME', 0, false, false)
			elseif locked == 2 then
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				SetVehicleLights(vehicle, 2)
				Wait(200)
				SetVehicleLights(vehicle, 0)
				Wait(200)
				SetVehicleLights(vehicle, 2)
				Wait(200)
				SetVehicleLights(vehicle, 0)
				Wait(200)
				SetVehicleLights(vehicle, 2)
				Wait(200)
				SetVehicleLights(vehicle, 0)
				SetNotificationBackgroundColor(18)
				ESX.ShowAdvancedNotification('Clés', 'Véhicule ouvert', '', 'CHAR_OUVERT', 0, false, false)
			end
		else
			ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
		end
	end, GetVehicleNumberPlateText(vehicle))
end


Keys.Register("U", "U", "Test", function()
	local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
	if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
		OpenCloseVehicle()
		vehicleKeys = CreateObject(GetHashKey("prop_cuff_keys_01"), 0, 0, 0, true, true, true) -- creates object
		AttachEntityToEntity(vehicleKeys, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.11, 0.03, -0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true) -- object is attached to right hand
		TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
		StopAnimTask = true
		Citizen.Wait(1000)
		DeleteObject(vehicleKeys)
	  else
		DeleteObject(vehicleKeys)
		ESX.ShowNotification("Impossible l'utiliser les clés !")
	 end
end)
