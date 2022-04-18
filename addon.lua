local idAutomationFrame = CreateFrame('Frame')

function idAutomationAcceptHearthstoneBind()
  StaticPopup1Button:Click()
end

function idAutomationAcceptSummon()
  if UnitAffectingCombat('player') then
    return
  end

  StaticPopup1:Hide()
  C_SummonInfo.ConfirmSummon()
end

function idAutomationAcceptPVPRelease()
  if UnitAffectingCombat('player') then
    return
  end

  if C_DeathInfo.GetSelfResurrectOptions() and #C_DeathInfo.GetSelfResurrectOptions() > 0 then
    return
  end

  local inInstance, instanceType = IsInInstance()
  if inInstance and instanceType == 'pvp' then
    RepopMe()
  end
end

function idAutomationAcceptResurrection()
  if GetCorpseRecoveryDelay() == 0 then
    return
  end

  StaticPopup1:Hide()
  AcceptResurrect()
end

function idAutomationRepairGear()
  if not CanMerchantRepair() then
    return
  end

  local cost = GetRepairAllCost()
  local funds = GetMoney()

  if cost == 0 then
    return
  end

  if funds < cost then
    return
  end

  if cost > 0 then
    RepairAllItems()
  end
end

function idAutomationSellGreyItems()
  local bag
  local slot
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      local itemLink = GetContainerItemLink(bag, slot)
      if itemLink then
        local _, _, itemRarity = GetItemInfo(itemLink)
        if itemRarity == 0 then
          UseContainerItem(bag, slot)
        end
      end
    end
  end
end

function idAutomationSummonBattlePet()
  if UnitAffectingCombat('player') then
    return
  end
  
  C_PetJournal.SummonRandomPet(true)
end

idAutomationFrame:RegisterEvent('CONFIRM_BINDER')
idAutomationFrame:RegisterEvent('CONFIRM_SUMMON')
idAutomationFrame:RegisterEvent('PLAYER_DEAD')
idAutomationFrame:RegisterEvent('RESURRECT_REQUEST')
idAutomationFrame:RegisterEvent('MERCHANT_SHOW')
idAutomationFrame:RegisterEvent('PLAYER_ALIVE')
idAutomationFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
idAutomationFrame:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
idAutomationFrame:RegisterEvent('PLAYER_UNGHOST')

idAutomationFrame:SetScript('OnEvent', function(self, event, ...)
  if (event == 'CONFIRM_BINDER') then
    idAutomationAcceptHearthstoneBind()
  elseif (event == 'CONFIRM_SUMMON') then
    idAutomationAcceptSummon()
  elseif (event == 'PLAYER_DEAD') then
    idAutomationAcceptPVPRelease()
  elseif (event == 'RESURRECT_REQUEST') then
    idAutomationAcceptResurrection()
  elseif (event == 'MERCHANT_SHOW') then
    idAutomationRepairGear()
    idAutomationSellGreyItems()
  elseif (event == 'PLAYER_ALIVE') then
    idAutomationSummonBattlePet()
  elseif (event == 'PLAYER_ENTERING_WORLD') then
    idAutomationSummonBattlePet()
  elseif (event == 'PLAYER_MOUNT_DISPLAY_CHANGED') then
    idAutomationSummonBattlePet()
  elseif (event == 'PLAYER_UNGHOST') then
    idAutomationSummonBattlePet()
  end
end)
