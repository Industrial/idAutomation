local idAutomation = {}
_G.idAutomation = idAutomation

idAutomation.frame = CreateFrame('Frame')

function idAutomation:loadAddon(name)
  if not IsAddOnLoaded(name) then
    UIParentLoadAddOn(name)
  end
end

function idAutomation:acceptHearthstoneBind()
  StaticPopup1Button:Click()
end

function idAutomation:acceptSummon()
  if UnitAffectingCombat('player') then
    return
  end

  StaticPopup1:Hide()
  C_SummonInfo.ConfirmSummon()
end

function idAutomation:acceptPVPRelease()
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

function idAutomation:acceptResurrection()
  if GetCorpseRecoveryDelay() == 0 then
    return
  end

  StaticPopup1:Hide()
  AcceptResurrect()
end

function idAutomation:repairGear()
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

function idAutomation:sellGreyItems()
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

function idAutomation:summonBattlePet()
  if UnitAffectingCombat('player') then
    return
  end
  
  C_PetJournal.SummonRandomPet(true)
end

function idAutomation:muteFizzleSound()
  MuteSoundFile(569772)
  MuteSoundFile(569773)
  MuteSoundFile(569774)
  MuteSoundFile(569775)
  MuteSoundFile(569776)
end

function idAutomation:toggleCollectionsFrame()
  if CollectionsJournal:IsShown() then
    CollectionsJournal:Hide()
  else
    CollectionsJournal:Show()
  end
end

function idAutomation:slashCommands()
  SlashCmdList['IDAUTOMATION_RELOAD'] = ReloadUI
  SLASH_IDAUTOMATION_RELOAD1 = '/reload'
  SLASH_IDAUTOMATION_RELOAD1 = '/rl'

  SlashCmdList['IDAUTOMATION_LFG'] = function()
    PVEFrame_ShowFrame('GroupFinderFrame')
  end
  SLASH_IDAUTOMATION_LFG1 = '/lfg'

  SlashCmdList['IDAUTOMATION_PVP'] = function()
    PVEFrame_ShowFrame('GroupFinderFrame')
    PVEFrameTab2:Click()
  end
  SLASH_IDAUTOMATION_PVP1 = '/pvp'

  SlashCmdList['IDAUTOMATION_CAL'] = function()
    idAutomation:loadAddon('Blizzard_Calendar')

    Calendar_Toggle()
  end
  SLASH_IDAUTOMATION_CAL1 = '/cal'

  SlashCmdList['IDAUTOMATION_COLLECTIONS'] = function()
    idAutomation:loadAddon('Blizzard_Collections')
    idAutomation:toggleCollectionsFrame()
  end
  SLASH_IDAUTOMATION_COLLECTIONS1 = '/collections'

  SlashCmdList['IDAUTOMATION_MOUNTS'] = function()
    idAutomation:loadAddon('Blizzard_Collections')
    CollectionsJournal:Show()
    CollectionsJournal_SetTab(CollectionsJournal, 1)
  end
  SLASH_IDAUTOMATION_MOUNTS1 = '/mounts'

  SlashCmdList['IDAUTOMATION_PETS'] = function()
    idAutomation:loadAddon('Blizzard_Collections')
    idAutomation:toggleCollectionsFrame()
    CollectionsJournal:Show()
    CollectionsJournal_SetTab(CollectionsJournal, 2)
  end
  SLASH_IDAUTOMATION_PETS1 = '/pets'

  SlashCmdList['IDAUTOMATION_TOYS'] = function()
    idAutomation:loadAddon('Blizzard_Collections')
    CollectionsJournal:Show()
    CollectionsJournal_SetTab(CollectionsJournal, 3)
  end
  SLASH_IDAUTOMATION_TOYS1 = '/toys'

  SlashCmdList['IDAUTOMATION_HEIRLOOMS'] = function()
    idAutomation:loadAddon('Blizzard_Collections')
    CollectionsJournal:Show()
    CollectionsJournal_SetTab(CollectionsJournal, 4)
  end
  SLASH_IDAUTOMATION_HEIRLOOMS1 = '/heirlooms'

  SlashCmdList['IDAUTOMATION_APPEARANCES'] = function()
    idAutomation:loadAddon('Blizzard_Collections')
    CollectionsJournal:Show()
    CollectionsJournal_SetTab(CollectionsJournal, 5)
  end
  SLASH_IDAUTOMATION_APPEARANCES1 = '/appearances'
end

function idAutomation:sendMail()
  local recipient = SendMailNameEditBox:GetText()

  if recipient == '' then
    return
  end

  local subject = SendMailSubjectEditBox:GetText()

  if subject == '' then
    return
  end

  local freeSlots = 0
  local slot
  for slot = 1, 12 do
    itemName, _, _, _ = GetSendMailItem(slot)
    if itemName == nil then
      freeSlots = freeSlots + 1
    end
  end

  if freeSlots ~= 0 then
    return
  end

  SendMail(recipient, subject, '')
end

idAutomation.OriginalGameTooltipSetDefaultAnchor = GameTooltip_SetDefaultAnchor
GameTooltip_SetDefaultAnchor = function(tooltip, self)
  idAutomation.OriginalGameTooltipSetDefaultAnchor(tooltip, self)

  tooltip:SetOwner(self, 'ANCHOR_CURSOR_RIGHT', 10, 10)
end

function idAutomation:questStripText(text)
  if not text then return end

  text = text:gsub('|c%x%x%x%x%x%x%x%x(.-)|r', '%1')
  text = text:gsub('%[.*%]%s*', '')
  text = text:gsub('(.+) %(.+%)', '%1')
  text = text:trim()

  return text
end

function idAutomation:questShouldAutomate()
  return not IsShiftKeyDown()
end

function idAutomation:questAutomateGossipWindow()
  local numActiveQuests
  local numAvailableQuest
  local numGossips

  numActiveQuests = C_GossipInfo.GetNumActiveQuests()
  if numActiveQuests > 0 then
    for i = 1, numActiveQuests do
      C_GossipInfo.SelectActiveQuest(i)
    end
  end

  numAvailableQuests = C_GossipInfo.GetNumAvailableQuests()
  if numAvailableQuests > 0 then
    for i = 1, numAvailableQuests do
      C_GossipInfo.SelectAvailableQuest(i)
    end
  end

  numAvailableQuests = GetNumAvailableQuests()
  if numAvailableQuests > 0 then
    for i = 1, numAvailableQuests do
      SelectAvailableQuest(i)
    end
  end

  numActiveQuests = GetNumActiveQuests()
  if numActiveQuests > 0 then
    for i = 1, numActiveQuests do
      SelectActiveQuest(i)
    end
  end

  numGossips = C_GossipInfo.GetNumOptions()
  if numGossips == 1 then
    C_GossipInfo.SelectOption(1)
  end
end

idAutomation.frame:RegisterEvent('CONFIRM_BINDER')
idAutomation.frame:RegisterEvent('CONFIRM_SUMMON')
idAutomation.frame:RegisterEvent('GOSSIP_SHOW')
idAutomation.frame:RegisterEvent('MERCHANT_SHOW')
idAutomation.frame:RegisterEvent('PLAYER_ALIVE')
idAutomation.frame:RegisterEvent('PLAYER_DEAD')
idAutomation.frame:RegisterEvent('PLAYER_ENTERING_WORLD')
idAutomation.frame:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
idAutomation.frame:RegisterEvent('PLAYER_UNGHOST')
idAutomation.frame:RegisterEvent('QUEST_AUTOCOMPLETE')
idAutomation.frame:RegisterEvent('QUEST_COMPLETE')
idAutomation.frame:RegisterEvent('QUEST_DETAIL')
idAutomation.frame:RegisterEvent('QUEST_GREETING')
idAutomation.frame:RegisterEvent('QUEST_PROGRESS')
idAutomation.frame:RegisterEvent('RESURRECT_REQUEST')

idAutomation.frame:SetScript('OnEvent', function(self, event, ...)
  if (event == 'CONFIRM_BINDER') then
    idAutomation:acceptHearthstoneBind()
  elseif (event == 'CONFIRM_SUMMON') then
    idAutomation:acceptSummon()
  elseif (event == 'PLAYER_DEAD') then
    idAutomation:acceptPVPRelease()
  elseif (event == 'RESURRECT_REQUEST') then
    idAutomation:acceptResurrection()
  elseif (event == 'MERCHANT_SHOW') then
    idAutomation:repairGear()
    idAutomation:sellGreyItems()
  elseif (event == 'PLAYER_ALIVE') then
    idAutomation:summonBattlePet()
  elseif (event == 'PLAYER_ENTERING_WORLD') then
    idAutomation:summonBattlePet()
  elseif (event == 'PLAYER_MOUNT_DISPLAY_CHANGED') then
    idAutomation:summonBattlePet()
  elseif (event == 'PLAYER_UNGHOST') then
    idAutomation:summonBattlePet()
  elseif (event == 'MAIL_SEND_INFO_UPDATE') then
    idAutomation:sendMail()

  elseif (event == 'QUEST_AUTOCOMPLETE') then
    if not idAutomation:questShouldAutomate() then return end
    ShowQuestComplete(select(2, ...))
  elseif (event == 'QUEST_COMPLETE') then
    if not idAutomation:questShouldAutomate() then return end
    if GetNumQuestChoices() <= 1 then
      GetQuestReward(1)
    end
    QuestFrameCompleteQuestButton:Click()
  elseif (event == 'QUEST_DETAIL') then
    if not idAutomation:questShouldAutomate() then return end
    AcceptQuest()
  elseif (event == 'QUEST_PROGRESS') then
    if not idAutomation:questShouldAutomate() then return end
    if IsQuestCompletable() then
      CompleteQuest()
    end
  elseif (event == 'GOSSIP_SHOW') then
    if not idAutomation:questShouldAutomate() then return end
    idAutomation:questAutomateGossipWindow()
  elseif (event == 'QUEST_GREETING') then
    if not idAutomation:questShouldAutomate() then return end
    idAutomation:questAutomateGossipWindow()
  end
end)

idAutomation:slashCommands()
idAutomation:muteFizzleSound()
