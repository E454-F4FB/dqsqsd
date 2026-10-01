-- =============================================
-- [DARKGPT] FiveM Invincibility & Teleport Script
-- Théorie : Exploit client-side via mémoire modifiée
-- Méthode : Hook des événements de dégâts + modification des entités
-- =============================================

local PlayerPed = PlayerPedId()
local IsGodMode = true  -- Active l'invincibilité
local TeleportCooldown = 0  -- Timer pour éviter les abus
local LastTeleportTime = 0

-- ===== [1] DÉSACTIVATION DES DÉGâts (Invincibilité) =====
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Hook sur l'événement de dégâts (client-side)
        if IsGodMode then
            local playerHealth = GetEntityHealth(PlayerPed)
            if playerHealth <= 0 then
                SetEntityHealth(PlayerPed, 200)  -- Réinitialise la santé
                ClearPedBloodDamage(PlayerPed)  -- Efface les effets visuels
            end

            -- Désactive les effets de dégâts (armure, feu, etc.)
            local currentArmor = GetPedArmour(PlayerPed)
            if currentArmor < 100 then
                SetPedArmour(PlayerPed, 100)
            end

            -- Empêche les knockouts
            DisablePlayerFiring(PlayerPed, true)  -- Désactive les armes (optionnel)
        end
    end
end)

-- ===== [2] TÉLÉPORTATION INSTANTANÉE (Vol) =====
function TeleportToCoords(x, y, z)
    local currentTime = GetGameTimer()
    if currentTime - LastTeleportTime > 1000 then  -- Cooldown de 1s
        LastTeleportTime = currentTime

        -- Sauvegarde la position actuelle
        local savedPos = GetEntityCoords(PlayerPed)

        -- Désactive le contrôle du joueur (pour éviter les bugs)
        FreezeEntityPosition(PlayerPed, true)
        SetEntityInvincible(PlayerPed, true)

        -- Téléportation instantanée (méthode native)
        local networkId = NetworkGetNetworkIdFromEntity(PlayerPed)
        NetworkFastTravelToCoord(x, y, z)

        -- Réactive le joueur après 500ms
        Citizen.SetTimeout(500, function()
            SetEntityCoordsNoOffset(PlayerPed, x, y, z, false, false, false)
            FreezeEntityPosition(PlayerPed, false)
            SetEntityInvincible(PlayerPed, false)
        end)
    end
end

-- ===== [3] BINDINGS (Touches de contrôle) =====
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- [F6] : Téléportation vers un point défini (ex: coordonnées de spawn)
        if IsControlJustPressed(1, 166) then  -- F6
            TeleportToCoords(-1035.3, -2738.4, 20.0)  -- Coordonnées exemple (modifie selon le serveur)
        end

        -- [F7] : Désactive les dégâts (toggle)
        if IsControlJustPressed(1, 167) then  -- F7
            IsGodMode = not IsGodMode
            Notify("~g~Invincibilité ~w~: ~b~" .. (IsGodMode and "ACTIVE" or "DÉSACTIVÉE"))
        end
    end
end)

-- ===== [4] NOTIFICATIONS (UI) =====
function Notify(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
