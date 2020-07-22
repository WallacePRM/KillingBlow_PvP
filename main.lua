
killingblow_pvp_onlyPlayer = true
killingblow_pvp_frameVisible = false
killingblow_pvp_count = 0

local totalSeconds = 0
local frameAlpha = 1

function registerAddonEvents()
    killingblow_pvp_mainFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    killingblow_pvp_mainFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    killingblow_pvp_mainFrame:RegisterEvent('PLAYER_ENTERING_BATTLEGROUND')
end

function handleEvent(self, event, ...)

    if (event == 'PLAYER_ENTERING_WORLD') then

        local instanceType = select(2, GetInstanceInfo())

        if (instanceType == 'none') then

            resetKillingBlow()
        end

        return
    end

    if (event == 'PLAYER_ENTERING_BATTLEGROUND') then

        resetKillingBlow()
        return
    end

    if (event == 'COMBAT_LOG_EVENT_UNFILTERED') then

        -- Obter dados dos eventos, jogadores e unidades mortas

        local combatEvent = select(2, CombatLogGetCurrentEventInfo())
        local unitDead = combatEvent == 'PARTY_KILL'

        if (unitDead == false) then

            return
        end

        local sourceGUID = select(4, CombatLogGetCurrentEventInfo())
        local playerGUID = UnitGUID("player")
        local name = select(6, GetPlayerInfoByGUID(playerGUID))
        local source = select(6, GetPlayerInfoByGUID(sourceGUID))
        
        local playerKill = name == source

        if (playerKill == false) then

            return
        end

        local destGuid = select(8, CombatLogGetCurrentEventInfo())
        local playerName = nil
        
        if (destGuid ~= nil) then

            playerName = select(6, GetPlayerInfoByGUID(destGuid))
        end

        -- Verificar a facção do jogador
        -- Alterar a imagem de morte de acordo com a sua facção

        local factionName = UnitFactionGroup(name)

        if (factionName == 'Horde') then

            killingblow_pvp_mainFrame:SetBackdrop({
                bgFile = 'Interface\\AddOns\\KillingBlow_PvP\\textures\\horde.tga'
            })
        else
            killingblow_pvp_mainFrame:SetBackdrop({
                bgFile = 'Interface\\AddOns\\KillingBlow_PvP\\textures\\alliance.tga'
            })
        end

        -- Verificar se foi um jogador que chamou a função

        if (killingblow_pvp_onlyPlayer == true and playerName ~= nil) then

            killingBlow()
        elseif (killingblow_pvp_onlyPlayer == false and playerName == nil) then

            killingBlow()
        end
    end
end

-- Adicionar um 'fade' no Frame e deixa-lo invisivel

function handleUpdate(self, elapsed)

    if (killingblow_pvp_frameVisible) then

        local expectedSeconds = 2
        local factor = 1 / (expectedSeconds * 100)

        totalSeconds = totalSeconds + elapsed
        frameAlpha = frameAlpha - factor

        if (frameAlpha >= 0) then

            killingblow_pvp_mainFrame:SetAlpha(frameAlpha)
        end

        if (totalSeconds > expectedSeconds) then
    
            totalSeconds = 0
            frameAlpha = 1 
            killingblow_pvp_frameVisible = false

            killingblow_pvp_mainFrame:Hide()
        end
    end
end

function killingBlow()

     -- Adicionar um som na morte

     PlaySoundFile('Interface\\AddOns\\KillingBlow_PvP\\sounds\\heroism_track.mp3')

     -- Deixar o Frame visivel

     killingblow_pvp_mainFrame:Show()

     killingblow_pvp_frameVisible = true
     killingblow_pvp_count = killingblow_pvp_count + 1

     killingblow_pvp_killDisplay:SetText(killingblow_pvp_count)

     print('|cffe2c123KillingBlow_PvP|r: ' .. killingblow_pvp_count)
end

function resetKillingBlow()

    if (killingblow_pvp_count > 0) then

        killingblow_pvp_count = 0

        killingblow_pvp_killDisplay:SetText(killingblow_pvp_count)
        print('|cff1ead1cKillingBlow_PvP|r: All Kill has been reset.')
    end
end