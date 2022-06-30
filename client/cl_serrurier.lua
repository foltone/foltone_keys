ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end
end)

KeysSql = {}
VehNoKeys = {}

KeysOpen = function()
	ESX.TriggerServerCallback('</eDen:AfficheKeys', function(AffiKeys)
		KeysSql = AffiKeys
  end)
end

NewKeys = function()
    ESX.TriggerServerCallback("foltone_vehiclelock"..':getVehiclesnokey', function(Vehicles2)
		VehNoKeys = Vehicles2
   end)
end

PlayerMarker = function()
    local closestPlayer = GetPlayerPed(ESX.Game.GetClosestPlayer())
    local pos = GetEntityCoords(closestPlayer);
    local target, distance = ESX.Game.GetClosestPlayer();
    if distance <= 2.0 then
		DrawMarker(20, pos.x, pos.y, pos.z+1.2, 1.0, 0.0, 1.0, 5.0, 0.0, 0.0, 0.35, 0.35, 0.35, 0, 96, 125, 139, 5, 1, 2, 0, nil, nil, 0);
    end
end

local MenuSerrurier = RageUI.CreateMenu("Serrurier", 'Serrurier', nil, nil, nil, nil);
local listkey = RageUI.CreateSubMenu(MenuSerrurier, "Serrurier", "Serrurier")

local ListIndex = 1;
local ListPay = {
    "Liquide",
    "Banque",
}

local Trigger = 'foltone:registerkeyliquide'

function RageUI.PoolMenus:Foltone()
    MenuSerrurier:IsVisible(function(Items)
        Items:AddButton("Enregistrer un clé", nil, {RightLabel = ">", IsDisabled = false }, function(onSelected)
            if (onSelected) then
                NewKeys()
            end
        end, listkey)
        
    end, function(Panels)
    end)
    listkey:IsVisible(function(Items)
        Items:AddList("Mode de paiement", ListPay, ListIndex, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
			if (onListChange) then
				ListIndex = Index;
			end
            if (Index) == 1 then
                Trigger = 'foltone_vehiclelock:registerkeyliquide'
            end
            if (Index) == 2 then
                Trigger = 'foltone_vehiclelock:registerkeybanque'
            end
		end)
		if #VehNoKeys >= 1 then
            for Vehicles2 = 1, #VehNoKeys, 1 do
                Items:AddButton(VehNoKeys[Vehicles2].plate, nil, {RightLabel = "~b~50$", IsDisabled = false }, function(onSelected)
                    if (onSelected) then
                        RageUI.GoBack()
                        TriggerServerEvent(Trigger, VehNoKeys[Vehicles2].plate, 'no')
                    end
                end)
            end
        end
	end, function()
	end)
end

Citizen.CreateThread(function()
	while true do
		local wait = 500
		local playerCoords = GetEntityCoords(PlayerPedId())
		for k, v in pairs(FoltoneKey.Position) do
			local distance = GetDistanceBetweenCoords(playerCoords, v.x, v.y, v.z, true)
            if distance <= 2.0 then
				wait = 0
				ESX.ShowHelpNotification("Appuyer sur ~b~[E]~s~ pour parler au ~b~serrurier", 1) 
                if IsControlJustPressed(1, 51) then
					RageUI.Visible(MenuSerrurier, not RageUI.Visible(MenuSerrurier))
                end
            end
        end
        Citizen.Wait(wait)
	end
end)

Citizen.CreateThread(function()
    DecorRegister("Yay", 4)
    PedSerrurier = nil
    function LoadModel(model)
		while not HasModelLoaded(model) do
			RequestModel(model)
			Wait(500)
		end
	end
    for k, v in pairs(FoltoneKey.Position) do
        --ped
        LoadModel("a_m_m_hillbilly_01")
        PedSerrurier = CreatePed(2, GetHashKey("a_m_m_hillbilly_01"), v.x, v.y, v.z, v.h, 0, 0)
        DecorSetInt(PedSerrurier, "Yay", 5431)
        FreezeEntityPosition(PedSerrurier, 1)
        TaskStartScenarioInPlace(PedSerrurier, "WORLD_HUMAN_CLIPBOARD", 0, false)
        SetEntityInvincible(PedSerrurier, true)
        SetBlockingOfNonTemporaryEvents(PedSerrurier, 1)
	
        --blip
		local BlipSerrurier = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(BlipSerrurier, 811)
		SetBlipScale (BlipSerrurier, 0.8)
		SetBlipColour(BlipSerrurier, 29)
		SetBlipAsShortRange(BlipSerrurier, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Serrurier')
		EndTextCommandSetBlipName(BlipSerrurier)
	end
end)
