local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(5)
		local playerPed = PlayerPedId()
		local pos = GetEntityCoords(playerPed)
		-- Golf Cart Rental
		if #(pos - vector3(Config.RentalStation.x, Config.RentalStation.y, Config.RentalStation.z)) < 15 then
			DrawMarker(2, Config.RentalStation.x, Config.RentalStation.y, Config.RentalStation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
			if #(pos - vector3(Config.RentalStation.x, Config.RentalStation.y, Config.RentalStation.z)) < 1.5 then
				DrawText3D(Config.RentalStation.x, Config.RentalStation.y, Config.RentalStation.z + 0.5, "~g~E~w~ - Rent Golf Cart ~n~~r~$" .. Config.RentalCost .. "~w~ Cost ~n~~y~$" ..Config.DepositCost.. "~w~ Deposit" )
				if IsControlJustReleased(0, 38) then
				TriggerServerEvent('GcartRental:server:rentCart')
					local vehicleName = 'caddy'
					local plate = "RENTAL"
					RequestModel(vehicleName)
					while not HasModelLoaded(vehicleName) do
						Wait(500)
					end
					local vehicle = CreateVehicle(vehicleName, Config.ParkingSpot.x, Config.ParkingSpot.y, Config.ParkingSpot.z, Config.ParkingSpot.w, true, false)
					local netid = NetworkGetNetworkIdFromEntity(vehicle)
					SetVehicleNumberPlateText(vehicle, plate)
					TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', plate)
					SetNetworkIdCanMigrate(netid, true)
					SetVehicleNeedsToBeHotwired(vehicle, false)
					SetPedIntoVehicle(playerPed, vehicle, -1)
					-- setup vehicle
					SetVehicleCanSaveInGarage(vehicle, false)
					SetVehRadioStation(vehicle, "OFF")
					SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
					SetVehicleFuelLevel(vehicle, 99.0)
					SetEntityAsNoLongerNeeded(vehicle)
					SetModelAsNoLongerNeeded(vehicleName)
				end
			end
		end
		-- Golf Cart Return
		if #(pos - vector3(Config.ReturnStation.x, Config.ReturnStation.y, Config.ReturnStation.z)) < 17 then
			DrawMarker(2, Config.ReturnStation.x, Config.ReturnStation.y, Config.ReturnStation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 0, 222, false, false, false, true, false, false, false)
			if #(pos - vector3(Config.ReturnStation.x, Config.ReturnStation.y, Config.ReturnStation.z)) < 1.7 then
				DrawText3D(Config.ReturnStation.x, Config.ReturnStation.y, Config.ReturnStation.z + 1, "~g~E~w~ - Return Golf Cart ~n~ Refund ~y~$" .. Config.DepositCost .. "~w~ Deposit")
				if IsControlJustReleased(0, 38) then
					local vehicle = GetVehiclePedIsIn(playerPed)
					local caddy = GetHashKey('caddy')
					local plate = GetVehicleNumberPlateText(vehicle) -- Note this text is always 8 chars and text is centered, so may have spaces before and after
					if (GetEntityModel(vehicle) == caddy and plate == " RENTAL ") then
						TriggerServerEvent('GcartRental:server:returnCart')
						SetEntityAsMissionEntity(vehicle, true, true)
						DeleteEntity(vehicle)
					end
				end
			end
		end
		-- Stop and return golf cart if too far from golf course
		local vehicle = GetVehiclePedIsIn(playerPed)
		local caddy = GetHashKey('caddy')
		local plate = GetVehicleNumberPlateText(vehicle) -- Note this text is always 8 chars and text is centered, so may have spaces before and after
		if (GetEntityModel(vehicle) == caddy and plate == " RENTAL ") then
			if #(pos - vector3(-1156.58, 47.08, 53.36)) > 304 then
				TriggerEvent('chat:addMessage', {
					color = {255, 255, 0},
					multiline = true,
					args = {"Golf Cart Rental Service", "You have driven too far from the golf course!"}
				})
				ClearPedTasks(playerPed)
				TaskLeaveVehicle(playerPed, vehicle, 0)
				for i = 4, 0, -1 do
					PlaySoundFrontend(-1, "CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", 1)
					SetVehicleForwardSpeed(vehicle, i * 5.0)
					Citizen.Wait(500)
				end
				TriggerServerEvent('GcartRental:server:returnCart')
				SetEntityAsMissionEntity(vehicle, true, true)
				DeleteEntity(vehicle)
			end
		end
	end
end)

function DrawText3D(x, y, z, text) -- allows for multiple lines from ~n~
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
	local textl = string.len(text)
	local t = {}
	t[1] = 0
    local i = 0
	local count = 1
    while true do
      i = string.find(text, " %~%n%~", i+1)
      if i == nil then break end
      t[count + 1] = i	  
	  count = count + 1
    end
	t[count + 1] = textl
	width = t[1]
	for lin = 2, #t do
		if(t[lin] - t[lin -1]) > width then
			width = t[lin] - t[lin -1]
		end
	end
    local factor = width / 370
    DrawRect(0.0, 0.0 + (0.01 * count) + 0.0025, 0.017 + factor, 0.02 * count + 0.01, 0, 0, 0, 75)
    ClearDrawOrigin()
end

