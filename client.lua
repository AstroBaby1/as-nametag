local playerPed = nil
local hudEnabled = true

function GetPlayerFrameworkName()
    local playerName = "Unknown"
    
    if Config.Framework == "QBCore" then
        if exports['qb-core']:GetCoreObject() then
            local QBCore = exports['qb-core']:GetCoreObject()
            local playerData = QBCore.Functions.GetPlayerData()
            playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
        end
    elseif Config.Framework == "ESX" then
        if ESX then
            local playerData = ESX.GetPlayerData()
            playerName = playerData.name
        end
    else
        playerName = GetPlayerName(PlayerId())
    end

    return playerName
end

function NotifyUser(message)
    if Config.Framework == "QBCore" then
        if exports['qb-core']:GetCoreObject() then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.Notify(message, "primary")
        end
    elseif Config.Framework == "ESX" then
        if ESX then
            ESX.ShowNotification(message)
        end
    else
        TriggerEvent('chat:addMessage', { args = { message } })
    end
end

function DrawPlayerHUD(playerHealth, playerArmor, playerName, screenX, screenY)
    local barWidth = 0.06
    local barHeight = 0.008
    local outlineWidth = barWidth + 0.003
    local outlineHeight = barHeight + 0.004
    local spacing = 0.013
    local outlineOpacity = 200
    local centerX = screenX
    local healthRatio = (playerHealth - 100) / (GetEntityMaxHealth(playerPed) - 100)
    healthRatio = math.max(healthRatio, 0)

    DrawRect(centerX, screenY - 0.085, outlineWidth, outlineHeight, 0, 0, 0, outlineOpacity)
    DrawRect(centerX - ((1 - healthRatio) * barWidth) / 2, screenY - 0.085, barWidth * healthRatio, barHeight, 255, 0, 0, 255)

    DrawRect(centerX, screenY - 0.085 + spacing, outlineWidth, outlineHeight, 0, 0, 0, outlineOpacity)
    DrawRect(centerX - ((1 - (playerArmor / 100.0)) * barWidth) / 2, screenY - 0.085 + spacing, barWidth * (playerArmor / 100.0), barHeight, 255, 255, 255, 255)

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.30)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(playerName)
    DrawText(centerX - (0.5 * (string.len(playerName) * 0.005)), screenY - 0.085 - 0.03)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if hudEnabled then
            playerPed = playerPed or PlayerPedId()
            local playerHealth = GetEntityHealth(playerPed)
            local playerArmor = GetPedArmour(playerPed)
            local coords = GetEntityCoords(playerPed)
            local _, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z + 0.75)
            local playerName = GetPlayerFrameworkName()

            if screenX and screenY then
                DrawPlayerHUD(playerHealth, playerArmor, playerName, screenX, screenY)
            end
        end
    end
end)

RegisterCommand(Config.ToggleCommand, function()
    hudEnabled = not hudEnabled
    local status = hudEnabled and "enabled" or "disabled"
    NotifyUser("HUD is now " .. status)
end, false)

