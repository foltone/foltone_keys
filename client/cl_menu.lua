Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

local menuKeys = RageUI.CreateMenu("Liste Keys", 'Menu Keys');
local keyselected = RageUI.CreateSubMenu(menuKeys, "Keys", "Keys")

local stylevide = { BackgroundColor={255, 255, 255, 0}, Line = {250, 250 ,250, 250}, Line2 = {250, 250 ,250, 250}}

function RageUI.PoolMenus:Example()

	menuKeys:IsVisible(function(Items)
        if #KeysSql >= 1 then
            for Keys = 1, #KeysSql, 1 do
                Items:AddButton(KeysSql[Keys].value, nil, { RightLabel = ">", IsDisabled = false }, function(onSelected)
                    if (onSelected) then
                        KeySelected = KeysSql[Keys].value
                        IdSelected = KeysSql[Keys].id
                        KeysOpen()
                    end
                end, keyselected)
            end
        else
            RageUI.Line(stylevide, "~r~Aucune clé")
        end
	end, function(Panels)
	end)

    keyselected:IsVisible(function(Items)
		Items:AddButton("Numéro : ", nil, { RightLabel = IdSelected, IsDisabled = false }, function(onSelected)
        end)
        Items:AddButton("Plauqe : ", nil, { RightLabel = KeySelected, IsDisabled = false }, function(onSelected)
        end)
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        Items:AddButton("Préter", nil, { RightLabel = ">", IsDisabled = false }, function(onSelected)
            if (onSelected) then
                TriggerServerEvent('foltone_vehiclelock:preterkey', GetPlayerServerId(closestPlayer), KeySelected)
            end
        end, keys)
        Items:AddButton("Donner", nil, { RightLabel = ">", IsDisabled = false }, function(onSelected)
            if (onSelected) then
                TriggerServerEvent('foltone_vehiclelock:donnerkey', GetPlayerServerId(closestPlayer), KeySelected)
                TriggerServerEvent('foltone_vehiclelock:deletekey', KeySelected)
                RageUI.CloseAll()
            end
        end, keys)
        Items:AddButton("Supprimer", nil, { RightLabel = ">", IsDisabled = false }, function(onSelected)
            if (onSelected) then
                TriggerServerEvent('foltone_vehiclelock:deletekey', KeySelected)
                RageUI.CloseAll()
            end
        end, keys)
	end, function()
	end)
end

KeysSql = {}
function KeysOpen()
	ESX.TriggerServerCallback('</eDen:AfficheKeys', function(AffiKeys)
		KeysSql = AffiKeys
  end)
end

Keys.Register("F2", "F2", "menuKeys", function()
    KeysOpen()
	RageUI.Visible(menuKeys, not RageUI.Visible(menuKeys))
end)
