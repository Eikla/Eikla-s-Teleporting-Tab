local _, tpm = ...

--------------------------------------
-- Libraries
--------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("EiklasTeleportingTab")
local MSQ = LibStub("Masque", true)
local MasqueGroup = MSQ and MSQ:Group(L["ADDON_NAME"])

--------------------------------------
-- Locales
--------------------------------------

local db = {}
local APPEND = L["AddonNamePrint"]
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local globalWidth, globalHeight = 40, 40 -- defaults
tpm.TEXTURE_SCALE = 0

local IsSpellKnown = C_SpellBook.IsSpellKnown

local issecretvalue = issecretvalue or function() return false end
function tpm:IsSecret(value)
	return issecretvalue(value)
end

--------------------------------------
-- Teleport Tables
--------------------------------------

local availableSeasonalTeleports = {}

local shortNames = {
	-- CATA
	[410080] = L["The Vortex Pinnacle"],
	[424142] = L["Throne of the Tides"],
	[445424] = L["Grim Batol"],
	-- WLK
	[1254555] = L["Pit of Saron"],	-- Midnight S1
	-- MoP
	[131204] = L["Temple of the Jade Serpentl"],
	[131205] = L["Stormstout Brewery"],
	[131206] = L["Shado-Pan Monastery"],
	[131222] = L["Mogu'shan Palace"],
	[131225] = L["Gate of the Setting Sun"],
	[131228] = L["Siege of Niuzao Temple"],
	[131229] = L["Scarlet Monastery"],
	[131231] = L["Scarlet Halls"],
	[131232] = L["Scholomance"],
	-- WoD
	[159901] = L["The Everblooml"],
	[159899] = L["Shadowmoon Burial Grounds"],
	[159900] = L["Grimrail Depot"],
	[159896] = L["Iron Docks"],
	[159895] = L["Bloodmaul Slag Mines"],
	[159897] = L["Auchindoun"],
	[159898] = L["Skyreach"],
	[159902] = L["Upper Blackrock Spire"],
	[1254557] = L["Skyreach"], -- Midnight S1
	-- Legion
	[393764] = L["Halls of Valor"],
	[410078] = L["Neltharion's Lair"],
	[393766] = L["Court of Stars"],
	[373262] = L["Karazhan"],
	[424153] = L["Black Rook Hold"],
	[424163] = L["Darkheart Thicket"],
	[1254551] = L["Seat of the Triumvirate"], -- Midnight S1
	-- BFA
	[410071] = L["Freehold"],
	[410074] = L["The Underrot"],
	[373274] = L["Mechagon"],
	[424167] = L["Waycrest Manor"],
	[424187] = L["Atal'Dazar"],
	[445418] = L["Siege of Boralus"],
	[464256] = L["Siege of Boralus"],
	[467553] = L["The MOTHERLODE!!"],
	[467555] = L["The MOTHERLODE!!"],
	-- SL
	[354462] = L["The Necrotic Wake"],
	[354463] = L["Plaguefall"],
	[354464] = L["Mists of Tirna Scithe"],
	[354465] = L["Halls of Atonement"],
	[354466] = L["Bastion"],
	[354467] = L["Theater of Pain"],
	[354468] = L["De Other Side"],
	[354469] = L["Sanguine Depths"],
	[367416] = L["Tazavesh, the Veiled Market"],
	-- SL R
	[373190] = L["Castle Nathria"],
	[373191] = L["Sanctum of Domination"],
	[373192] = L["Sepulcher of the First Ones"],
	-- DF
	[393256] = L["Ruby Life Pools"],
	[393262] = L["The Nokhud Offensive"],
	[393267] = L["Brackenhide Hollow"],
	[393273] = L["Algeth'ar Academy"],  -- Midnight S1
	[393276] = L["Neltharus"],
	[393279] = L["The Azure Vault"],
	[393283] = L["Halls of Infusion"],
	[393222] = L["Uldaman"],
	[424197] = L["Dawn of the Infinite"],
	-- DF R
	[432254] = L["Vault of the Incarnates"],
	[432257] = L["Aberrus, the Shadowed Crucible"],
	[432258] = L["Amirdrassil, the Dream's Hope"],
	-- TWW
	[445416] = L["City of Threads"],
	[445414] = L["The Dawnbreaker"],
	[445269] = L["The Stonevault"],
	[445443] = L["The Rookery"],
	[445440] = L["Cinderbrew Meadery"],
	[445444] = L["Priory of the Sacred Flame"],
	[445417] = L["Ara-Kara, City of Echoes"],
	[445441] = L["Darkflame Cleft"],
	[1216786] = L["Operation: Floodgate"],
	[1237215] = L["Eco-Dome Al'dani"],
	-- TWW R
	[1226482] = L["Liberation of Undermine"],
	[1239155] = L["Manaforge Omega"],
	-- Midnight
	[1254400] = L["Windrunner Spire"], -- Midnight S1
	[1254559] = L["Maisara Caverns"], -- Midnight S1
	[1254563] = L["Nexus-Point Xenas"], -- Midnight S1
	[1254572] = L["Magisters' Terrace"], -- Midnight S1
	-- Midnight R
	-- Mage teleports
	[3561] = L["Stormwind"],
	[3562] = L["Ironforge"],
	[3563] = L["Undercity"],
	[3565] = L["Darnassus"],
	[3566] = L["Thunder Bluff"],
	[3567] = L["Orgrimmar"],
	[32271] = L["Exodar"],
	[32272] = L["Silvermoon"],
	[33690] = L["Shattrath"],
	[35715] = L["Shattrath"],
	[49358] = L["Stonard"],
	[49359] = L["Theramore"],
	[53140] = L["Dalaran - Northrend"],
	[88342] = L["Tol Barad"], -- Alliance
	[88344] = L["Tol Barad"], -- Horde
	[120145] = L["Dalaran - Ancient"],
	[132621] = L["Vale of Eternal Blossoms"], -- Alliance
	[132627] = L["Vale of Eternal Blossoms"], -- Horde
	[176242] = L["Warspear"],
	[176248] = L["Stormshield"],
	[193759] = L["Hall of the Guardian"],
	[224869] = L["Dalaran - Broken Isles"],
	[281403] = L["Boralus"],
	[281404] = L["Dazar'alor"],
	[344587] = L["Oribos"],
	[395277] = L["Valdrakken"],
	[446540] = L["Dornogal"],
	-- Mage portals
	[10059] = L["Stormwind"],
	[11416] = L["Ironforge"],
	[11417] = L["Orgrimmar"],
	[11418] = L["Undercity"],
	[11419] = L["Darnassus"],
	[11420] = L["Thunder Bluff"],
	[32266] = L["Exodar"],
	[32267] = L["Silvermoon"],
	[33691] = L["Shattrath"],
	[35717] = L["Shattrath"],
	[49360] = L["Theramore"],
	[49361] = L["Stonard"],
	[53142] = L["Dalaran - Northrend"],
	[88345] = L["Tol Barad"], -- Alliance
	[88346] = L["Tol Barad"], -- Horde
	[120146] = L["Dalaran - Ancient"],
	[132620] = L["Vale of Eternal Blossoms"], -- Alliance
	[132626] = L["Vale of Eternal Blossoms"], -- Horde
	[176244] = L["Warspear"],
	[176246] = L["Stormshield"],
	[224871] = L["Dalaran - Broken Isles"],
	[281400] = L["Boralus"],
	[281402] = L["Dazar'alor"],
	[344597] = L["Oribos"],
	[395289] = L["Valdrakken"],
	[446534] = L["Dornogal"],
	[1259194] = L["Silvermoon City"], -- Midnight
}

local tpTable = {
	-- Hearthstones
	{ id = 6948, type = "item", hearthstone = true }, -- Hearthstone
	{ id = 1233637, type = "housing", faction = "Alliance"}, -- Teleport Home (Alliance House)
	{ id = 1233637, type = "housing", faction = "Horde"}, -- Teleport Home (Horde House)
	{ id = 556, type = "spell" }, -- Astral Recall (Shaman)
	{ id = 110560, type = "toy", quest = { 34378, 34586 } }, -- Garrison Hearthstone
	{ id = 140192, type = "toy", quest = { 44184, 44663 } }, -- Dalaran Hearthstone
	-- Engineering
	{ type = "wormholes", iconId = 4620673 }, -- Engineering Wormholes
	{ type = "item_teleports", iconId = 133655 }, -- Item Teleports
	-- Class Teleports
	{ id = 1, type = "flyout", iconId = 237509, subtype = "mage" }, -- Teleport (Mage) (Horde)
	{ id = 8, type = "flyout", iconId = 237509, subtype = "mage" }, -- Teleport (Mage) (Alliance)
	{ id = 11, type = "flyout", iconId = 135744, subtype = "mage" }, -- Portals (Mage) (Horde)
	{ id = 12, type = "flyout", iconId = 135748, subtype = "mage" }, -- Portals (Mage) (Alliance)
	{ id = 126892, type = "spell" }, -- Zen Pilgrimage (Monk)
	{ id = 50977, type = "spell" }, -- Death Gate (Death Knight)
	{ id = 18960, type = "spell" }, -- Teleport: Moonglade (Druid)
	{ id = 193753, type = "spell" }, -- Dreamwalk (Druid) (replaces Teleport: Moonglade)
	-- Racials
	{ id = 312370, type = "spell" }, -- Make Camp (Vulpera)
	{ id = 312372, type = "spell" }, -- Return to Camp (Vulpera)
	{ id = 265225, type = "spell" }, -- Mole Machine (Dark Iron Dwarf)
	{ id = 1238686, type = "spell" }, -- Rootwalking (Haranir)

	-- Dungeon/Raid Teleports
	{ id = 230, type = "flyout", iconId = 574788, name = L["Cataclysm"], subtype = "path" }, -- Hero's Path: Cataclysm
	{ id = 84, type = "flyout", iconId = 328269, name = L["Mists of Pandaria"], subtype = "path" }, -- Hero's Path: Mists of Pandaria
	{ id = 96, type = "flyout", iconId = 1413856, name = L["Warlords of Draenor"], subtype = "path" }, -- Hero's Path: Warlords of Draenor
	{ id = 224, type = "flyout", iconId = 1260827, name = L["Legion"], subtype = "path" }, -- Hero's Path: Legion
	{ id = 223, type = "flyout", iconId = 1869493, name = L["Battle for Azeroth"], subtype = "path" }, -- Hero's Path: Battle for Azeroth
	{ id = 220, type = "flyout", iconId = 236798, name = L["Shadowlands"], subtype = "path" }, -- Hero's Path: Shadowlands
	{ id = 222, type = "flyout", iconId = 4062765, name = L["Shadowlands Raids"], subtype = "path" }, -- Hero's Path: Shadowlands Raids
	{ id = 227, type = "flyout", iconId = 4640496, name = L["Dragonflight"], subtype = "path" }, -- Hero's Path: Dragonflight
	{ id = 231, type = "flyout", iconId = 5342925, name = L["Dragonflight Raids"], subtype = "path" }, -- Hero's Path: Dragonflight Raids
	{ id = 232, type = "flyout", iconId = 5872031, name = L["The War Within"], subtype = "path" }, -- Hero's Path: The War Within
	{ id = 242, type = "flyout", iconId = 6997112, name = L["The War Within Raids"], subtype = "path" }, -- Hero's Path: The War Within Raids
	{ id = 246, type = "flyout", iconId = 7266215, name = L["Midnight"], subtype = "path", currentExpansion=true }, -- Hero's Path: Midnight
	--{ id = 246, type = "flyout", iconId = 7266215, name = L["Midnight Raids"], subtype = "path" }, -- Hero's Path: Midnight Raids
}

local GetItemCount = C_Item.GetItemCount

--------------------------------------
-- Texture Stuff
--------------------------------------

local function SetTextureByItemId(frame, itemId)
	frame.icon:SetTexture(DEFAULT_ICON) -- Temp while loading
	local item = Item:CreateFromItemID(tonumber(itemId))
	item:ContinueOnItemLoad(function()
		local icon = item:GetItemIcon()
		frame.icon:SetTexture(icon)
	end)
end

--------------------------------------
--- Tooltip
--------------------------------------

local function setCombatTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(L["Not In Combat Tooltip"], 1, 1, 1)
	GameTooltip:Show()
end

local function setToolTip(self, tpType, id, hs)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if hs and db["Teleports:Hearthstone"] and db["Teleports:Hearthstone"] == "rng" then
		local bindLocation = GetBindLocation()
		GameTooltip:SetText(L["Random Hearthstone"], 1, 1, 1)
		GameTooltip:AddLine(L["Random Hearthstone Tooltip"], 1, 1, 1)
		GameTooltip:AddLine(L["Random Hearthstone Location"]:format(bindLocation), 1, 1, 1, true)
	elseif tpType == "item" then
		GameTooltip:SetItemByID(id)
	elseif tpType == "item_teleports" then
		GameTooltip:SetText(L["Item Teleports"] .. "\n" .. L["Item Teleports Tooltip"], 1, 1, 1)
	elseif tpType == "toy" then
		GameTooltip:SetToyByItemID(tonumber(id) or id)
	elseif tpType == "spell" then
		GameTooltip:SetSpellByID(id)
	elseif tpType == "profession" then
		local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(id)
		if professionInfo then
			GameTooltip:SetText(professionInfo.professionName, 1, 1, 1)
		end
	elseif tpType == "seasonalteleport" then
		local currExpID = GetExpansionLevel()
		local expName = _G["EXPANSION_NAME" .. currExpID]
		local title = MYTHIC_DUNGEON_SEASON:format(expName, tpm.settings.current_season)
		GameTooltip:SetText(title, 1, 1, 1)
		GameTooltip:AddLine(L["Seasonal Teleports Tooltip"], 1, 1, 1)
	end
	GameTooltip:Show()
end

--------------------------------------
-- Frames
--------------------------------------

local GRID_SPACING = 8
local CONTENT_PADDING_X = 12
local CONTENT_PADDING_Y = 12
local SECTION_HEADER_HEIGHT = 22
local SECTION_HEADER_GAP = 10
local SECTION_BOTTOM_PADDING = 8
local SECTION_GAP = 10
local SETTINGS_PANEL_HEIGHT = 214
local TAB_ICON_FALLBACK = "Interface\\Icons\\Spell_Arcane_PortalDalaran"
local TAB_ICON_ATLASES = {
	"Waypoint-MapPin-Portal",
	"TaxiNode_Continent_Neutral",
}
local LIST_LEFT_PADDING = 8
local LIST_RIGHT_PADDING = 8
local ROW_CONTENT_LEFT_OFFSET = 2
local UNIFIED_BG_TEXTURE = "Interface\\FrameGeneral\\UI-Background-Rock"
local UNIFIED_BG_ATLAS = "QuestLog-main-background"
local UNIFIED_BG_VERTEX_R, UNIFIED_BG_VERTEX_G, UNIFIED_BG_VERTEX_B, UNIFIED_BG_VERTEX_A = 0.24, 0.18, 0.1, 0.95

local secureButtonsPool = {}
local sectionFramePool = {}
local activeSecureButtons = {}
local activeSectionFrames = {}
local displayedSections = {}
local pendingReload = false
local toyCollectionInitialized = false

local mapTabLib
local mapTab
local mapContentFrame
local mapRootFrame
local headerFrame
local headerTitle
local settingsFrame
local teleportsScrollFrame
local teleportsScrollChild
local statusText
local settingsWidgets = {}

local function createCooldownFrame(frame)
	if frame.cooldownFrame then
		return frame.cooldownFrame
	end

	local cooldownFrame = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	cooldownFrame:SetAllPoints()

	function cooldownFrame:CheckCooldown(id, type)
		if type ~= "housing" and not id then
			return
		end
		local start, duration, enabled
		if type == "toy" or type == "item" then
			start, duration, enabled = C_Item.GetItemCooldown(id)
		elseif type == "housing" then
			local cdInfo = C_Housing.GetVisitCooldownInfo()
			start = cdInfo.startTime
			duration = cdInfo.duration
			enabled = cdInfo.isEnabled
		else
			local cooldown = C_Spell.GetSpellCooldown(id)
			start = cooldown.startTime
			duration = cooldown.duration
			enabled = true
		end
		if enabled and not tpm:IsSecret(duration) and duration > 0 then
			self:SetCooldown(start, duration)
		else
			self:Clear()
		end
	end

	return cooldownFrame
end

---@param id ItemInfo
---@return boolean
local function IsItemEquipped(id)
	return C_Item.IsEquippableItem(id) and C_Item.IsEquippedItem(id)
end

local function ClearAllInvalidHighlights()
	for _, button in ipairs(activeSecureButtons) do
		button:ClearHighlightTexture()

		if button:GetAttribute("item") ~= nil then
			local equippedItemId = string.match(button:GetAttribute("item"), "%d+")
			if equippedItemId and IsItemEquipped(equippedItemId) then
				button:Highlight()
			end
		end
	end
end

local function RecycleSecureButtons()
	for _, button in ipairs(activeSecureButtons) do
		button:Recycle()
	end
	wipe(activeSecureButtons)
end

local function ApplyUnifiedBackground(texture)
	local hasQuestLogAtlas = pcall(texture.SetAtlas, texture, UNIFIED_BG_ATLAS, false)
	if hasQuestLogAtlas then
		texture:SetVertexColor(1, 1, 1, 1)
		texture:SetAlpha(1)
	else
		texture:SetTexture(UNIFIED_BG_TEXTURE)
		texture:SetHorizTile(true)
		texture:SetVertTile(true)
		texture:SetTexCoord(0, 1.6, 0, 1.6)
		texture:SetVertexColor(UNIFIED_BG_VERTEX_R, UNIFIED_BG_VERTEX_G, UNIFIED_BG_VERTEX_B, UNIFIED_BG_VERTEX_A)
	end
end

local function GetTabIconData()
	if C_Texture and C_Texture.GetAtlasInfo then
		for _, atlas in ipairs(TAB_ICON_ATLASES) do
			if C_Texture.GetAtlasInfo(atlas) then
				return {
					activeAtlas = atlas,
					inactiveAtlas = atlas,
					useAtlasSize = false,
				}
			end
		end
	end

	return {
		activeTexture = TAB_ICON_FALLBACK,
		inactiveTexture = TAB_ICON_FALLBACK,
	}
end

local function AcquireSectionFrame()
	local frame
	if #sectionFramePool > 0 then
		frame = table.remove(sectionFramePool)
	else
		frame = CreateFrame("Frame")
		frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		frame.title:SetJustifyH("LEFT")
		frame.title:SetHeight(SECTION_HEADER_HEIGHT)
		frame.title:SetTextColor(1, 1, 1)

		frame.headerButton = CreateFrame("Button", nil, frame)
		frame.headerButton:SetHeight(SECTION_HEADER_HEIGHT)
		frame.headerButton:RegisterForClicks("LeftButtonUp")
		frame.headerButton.highlight = frame.headerButton:CreateTexture(nil, "HIGHLIGHT")
		frame.headerButton.highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
		frame.headerButton.highlight:SetAllPoints()
		frame.headerButton.highlight:SetBlendMode("ADD")
		frame.headerButton.highlight:SetVertexColor(1, 1, 1, 0.12)

		frame.headerBg = frame:CreateTexture(nil, "BACKGROUND")
		frame.headerBg:SetColorTexture(0, 0, 0, 0.3)

		frame.headerBorder = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
		if frame.headerBorder.SetBackdrop then
			frame.headerBorder:SetBackdrop({
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				edgeSize = 11,
				insets = { left = 2, right = 2, top = 2, bottom = 2 },
			})
			frame.headerBorder:SetBackdropBorderColor(0.62, 0.62, 0.62, 0.9)
		end

		frame.headerTopEdge = frame:CreateTexture(nil, "BORDER")
		frame.headerTopEdge:SetColorTexture(0, 0, 0, 0)
		frame.headerBottomEdge = frame:CreateTexture(nil, "BORDER")
		frame.headerBottomEdge:SetColorTexture(0, 0, 0, 0)

		frame.separator = frame:CreateTexture(nil, "BORDER")
		frame.separator:SetColorTexture(0, 0, 0, 0)
		frame.separator:SetHeight(1)

		frame.toggle = CreateFrame("Button", nil, frame)
		frame.toggle:SetSize(18, 18)
		frame.toggle:RegisterForClicks("LeftButtonUp")
		frame.toggle:SetHitRectInsets(-3, -3, -3, -3)
		frame.toggle.icon = frame.toggle:CreateTexture(nil, "ARTWORK")
		frame.toggle.icon:SetPoint("CENTER")
		frame.toggle.icon:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true)
		frame.toggle.icon:SetAlpha(0.9)
		frame.toggle.highlight = frame.toggle:CreateTexture(nil, "HIGHLIGHT")
		frame.toggle.highlight:SetPoint("CENTER", frame.toggle.icon, "CENTER")
		frame.toggle.highlight:SetSize(18, 18)
		frame.toggle.highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		frame.toggle.highlight:SetBlendMode("ADD")
		frame.toggle.highlight:SetAlpha(0.6)

		frame.headerBorder:SetFrameLevel(frame:GetFrameLevel() + 1)
		frame.headerButton:SetFrameLevel(frame:GetFrameLevel() + 1)
		frame.toggle:SetFrameLevel(frame:GetFrameLevel() + 2)
	end

	frame:SetParent(teleportsScrollChild)
	frame:Show()
	table.insert(activeSectionFrames, frame)
	return frame
end

local function RecycleSectionFrames()
	for _, frame in ipairs(activeSectionFrames) do
		frame:Hide()
		frame:ClearAllPoints()
		frame:SetParent(nil)
		frame.sectionKey = nil
		frame.headerButton:SetScript("OnClick", nil)
		frame.toggle:SetScript("OnClick", nil)
		table.insert(sectionFramePool, frame)
	end
	wipe(activeSectionFrames)
end

local function RecycleDisplayedButtons()
	RecycleSecureButtons()
	RecycleSectionFrames()
	tpm.Housing:RecycleHousingButtons()
	wipe(displayedSections)
end

---@param frame Frame
---@param buttonType string
---@param text string|nil
---@param id integer
---@param hearthstone? boolean
---@return Frame
local function CreateSecureButton(frame, buttonType, text, id, hearthstone)
	local button

	if #secureButtonsPool > 0 then
		button = table.remove(secureButtonsPool)
	else
		button = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")

		function button:Recycle()
			self.buttonType = nil
			self.id = nil
			self.hearthstone = nil

			self:ClearHighlightTexture()
			self:SetParent(nil)
			self:ClearAllPoints()
			self:Hide()
			table.insert(secureButtonsPool, self)

			if MasqueGroup then
				MasqueGroup:RemoveButton(self)
			end
		end

		button.icon = button:CreateTexture(nil, "BACKGROUND")
		button.icon:SetAllPoints()

		button.cooldownFrame = createCooldownFrame(button)
		function button:CheckCooldown()
			self.cooldownFrame:CheckCooldown(self.id, self.buttonType)
		end

		button.text = button:CreateFontString(nil, "OVERLAY")
		button.text:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 1)
		button.text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 1)
		button.text:SetJustifyH("CENTER")
		button.text:SetJustifyV("BOTTOM")
		button.text:SetTextColor(1, 1, 1, 1)
		button.text:SetWordWrap(false)
		if button.text.SetNonSpaceWrap then
			button.text:SetNonSpaceWrap(false)
		end
		if button.text.SetMaxLines then
			button.text:SetMaxLines(1)
		end

		function button:Highlight()
			self:SetHighlightAtlas("talents-node-choiceflyout-square-green")
		end
		button:LockHighlight()

		button:EnableMouse(true)
		button:RegisterForClicks("AnyDown", "AnyUp")
		button:SetAttribute("useOnKeyDown", true)

		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		button:SetScript("PostClick", function(self)
			if self.buttonType == "item" and self.id and C_Item.IsEquippableItem(self.id) then
				C_Timer.After(0.25, function()
					if IsItemEquipped(self.id) then
						ClearAllInvalidHighlights()
						self:Highlight()
					end
				end)
				if IsItemEquipped(self.id) then
					tpm:CloseMainMenu()
				end
			else
				tpm:CloseMainMenu()
			end
		end)

		button:SetScript("OnEnter", function(self)
			setToolTip(self, self.buttonType, self.id, self.hearthstone)
		end)

		button:SetScript("OnShow", function(self)
			self:CheckCooldown()
		end)
	end

	button.buttonType = buttonType
	button.id = id
	button.hearthstone = hearthstone

	button.text:Hide()
	if db["Button:Text:Show"] == true and text then
		local fontSize = math.max(6, db["Button:Text:Size"] or 12)
		local textHeight = math.max(8, math.min(globalHeight - 2, fontSize + 2))
		button.text:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
		button.text:SetHeight(textHeight)
		button.text:SetText(text)
		button.text:Show()
	end

	button:CheckCooldown()

	if buttonType == "spell" then
		local spellTexture = C_Spell.GetSpellTexture(id)
		button.icon:SetTexture(spellTexture)
	else
		SetTextureByItemId(button, id)
	end

	local zoomFactor = tpm.TEXTURE_SCALE
	local offset = zoomFactor / 2
	button.icon:SetTexCoord(offset, 1 - offset, offset, 1 - offset)

	button:SetAttribute("type", buttonType)
	if buttonType == "item" then
		button:SetAttribute(buttonType, "item:" .. id)
		if C_Item.IsEquippableItem(id) and IsItemEquipped(id) then
			button:Highlight()
		end
	else
		button:SetAttribute(buttonType, id)
	end

	button:SetParent(frame)
	button:SetSize(globalWidth, globalHeight)
	button:SetFrameStrata("HIGH")
	button.text:SetWidth(math.max(1, button:GetWidth() - 4))
	button.text:SetHeight(math.max(8, math.min(globalHeight - 2, (db["Button:Text:Size"] or 12) + 2)))

	if MasqueGroup then
		MasqueGroup:AddButton(button, { Icon = button.icon })
	end

	table.insert(activeSecureButtons, button)
	button:Show()
	return button
end

--------------------------------------
-- Functions
--------------------------------------

function tpm:GetIconText(spellId)
	local text = shortNames[spellId]
	if text then
		return text
	end
	print(APPEND .. "No short name found for spellID " .. spellId .. ", please report this on GitHub")
end

function tpm:UpdateAvailableSeasonalTeleports()
	availableSeasonalTeleports = {}

	local factionTeleports = {
		Alliance = { motherlode = 467553 },
		Horde = { motherlode = 467555 }
	}
	local playerFaction = UnitFactionGroup("player")
	local factionData = factionTeleports[playerFaction] or {}
	local motherlode = factionData.motherlode

	local seasonalTeleports = {
		-- Midnight S1
		[1] = {
			1254572, -- Magisters' Terrace
			1254559, -- Maisara Caverns
			1254563, -- Nexus-Point Xenas
			1254400, -- Windrunner Spire
			393273, -- Algeth'ar Academy
			1254551, -- Seat of the Triumvirate
			1254557, -- Skyreach
			1254555, -- Pit of Saron
		},
		-- TWW S2
		[2] = {
			motherlode, -- The MOTHERLODE!!
			373274, -- Operation: Mechagon - Workshop
			354467, -- Theater of Pain
			445444, -- Priory of the Sacred Flame
			445443, -- The Rookery
			445441, -- Darkflame Cleft
			445440, -- Cinderbrew Meadery
			1216786, -- Operation: Floodgate
		},
		-- TWW S3
		[3] = {
			445444, -- Priory of the Sacred Flame
			1237215, -- Eco-Dome Al'dani
			354465, -- Halls of Atonement
			1216786, -- Operation: Floodgate
			445417, -- Ara-Kara, City of Echoes
			367416, -- Tazavesh: So'leah's Gambit
			445414, -- The Dawnbreaker
		},
	}

	local seasonData = seasonalTeleports[tpm.settings.current_season] or {}
	local addedSpellIds = {}
	for _, spellID in ipairs(seasonData) do
		if spellID and not addedSpellIds[spellID] and IsSpellKnown(spellID) then
			addedSpellIds[spellID] = true
			table.insert(availableSeasonalTeleports, spellID)
		end
	end
end

function tpm:checkQuestCompletion(quest)
	if type(quest) == "table" then
		for _, questID in ipairs(quest) do
			if C_QuestLog.IsQuestFlaggedCompleted(questID) then
				return true
			end
		end
	else
		return C_QuestLog.IsQuestFlaggedCompleted(quest)
	end
end

local function AddFlyoutSpellsToSection(section, flyoutData)
	if db["Teleports:Seasonal:Only"] and (flyoutData.subtype == "path" and not flyoutData.currentExpansion) then
		return
	end

	local _, _, spells, flyoutKnown = GetFlyoutInfo(flyoutData.id)
	if not flyoutKnown then
		return
	end

	local addedSpellIds = {}
	local inverse = db["Teleports:Mage:Reverse"] and flyoutData.subtype == "mage"
	local startIndex, endIndex, step = 1, spells, 1
	if inverse then
		startIndex, endIndex, step = spells, 1, -1
	end

	for i = startIndex, endIndex, step do
		local spellId, overrideSpellId, isKnown = GetFlyoutSlotInfo(flyoutData.id, i)
		local effectiveSpellId = overrideSpellId and overrideSpellId > 0 and overrideSpellId or spellId
		if effectiveSpellId and (isKnown or IsSpellKnown(effectiveSpellId)) and not addedSpellIds[effectiveSpellId] then
			addedSpellIds[effectiveSpellId] = true
			table.insert(section.entries, {
				buttonType = "spell",
				id = effectiveSpellId,
				text = shortNames[effectiveSpellId],
			})
		end
	end
end

local function CreateSection(key, title)
	return {
		key = key,
		title = title,
		entries = {},
	}
end

local function BuildTeleportSections(allowMissingHearthstoneWarning)
	local sections = {}
	local coreSection = CreateSection("core", "Core Teleports")
	local showHearthstone = db["Teleports:Hearthstone"] ~= "disabled"
	local missingHearthstoneWarned = false
	local housingAdded = false

	for _, teleport in ipairs(tpTable) do
		local tpType = teleport.type
		local tpId = teleport.id
		local known = false
		local preferredHearthstone

		if showHearthstone and teleport.hearthstone then
			preferredHearthstone = tostring(db["Teleports:Hearthstone"] or tpm.SettingsBase["Teleports:Hearthstone"] or "normal")
			if preferredHearthstone == "rng" then
				tpId = tpm:GetRandomHearthstone()
				if tpId then
					tpType = "toy"
					known = true
				else
					tpType = "item"
					tpId = 6948
					known = C_Item.GetItemCount(tpId) > 0
				end
			elseif preferredHearthstone == "normal" then
				tpType = "item"
				tpId = 6948
				known = C_Item.GetItemCount(tpId) > 0
			else
				tpType = "toy"
				tpId = tonumber(preferredHearthstone) or preferredHearthstone
				known = type(tpId) == "number" and PlayerHasToy(tpId)
				if not known then
					local fallbackToyId = tpm.AvailableHearthstones and tpm.AvailableHearthstones[1]
					if fallbackToyId then
						tpId = fallbackToyId
						known = true
					end
				end
			end
		elseif tpType == "item" and C_Item.GetItemCount(tpId) > 0 and (not teleport.hearthstone or showHearthstone) then
			known = true
		elseif tpType == "toy" and tpId and PlayerHasToy(tpId) then
			if teleport.quest then
				known = tpm:checkQuestCompletion(teleport.quest)
			else
				known = true
			end
		elseif tpType == "spell" and tpId and IsSpellKnown(tpId) then
			known = true
		end

		if known and (tpType == "toy" or tpType == "item" or tpType == "spell" or (showHearthstone and teleport.hearthstone)) then
			table.insert(coreSection.entries, {
				buttonType = tpType,
				id = tpId,
				text = tpType == "spell" and shortNames[tpId] or nil,
				hearthstone = teleport.hearthstone,
			})
		elseif allowMissingHearthstoneWarning and showHearthstone and teleport.hearthstone and not known and not missingHearthstoneWarned then
			local toyBasedSelection = preferredHearthstone == "rng" or (preferredHearthstone and preferredHearthstone ~= "normal" and preferredHearthstone ~= "disabled")
			if not toyBasedSelection or toyCollectionInitialized then
				missingHearthstoneWarned = true
				print(APPEND .. L["No Hearthtone In Bags"])
			end
		elseif tpType == "housing" and not housingAdded and C_Housing then
			local playerFaction = UnitFactionGroup("player")
			local hasSingleHouse = tpm.Housing:GetHouseCount() == 1
			local canReturnHome = tpm.Housing:CanReturn()
			local hasHousingPlot = tpm.Housing:HasAPlot()
			if canReturnHome or (hasHousingPlot and (hasSingleHouse or playerFaction == teleport.faction)) then
				housingAdded = true
				table.insert(coreSection.entries, {
					buttonType = "housing",
					faction = teleport.faction,
				})
			end
		elseif tpType == "wormholes" then
			local section = CreateSection("wormholes", "Engineering Wormholes")
			local usableWormholes = tpm.AvailableWormholes and tpm.AvailableWormholes.GetUsable and tpm.AvailableWormholes:GetUsable() or {}
			for _, wormholeId in ipairs(usableWormholes) do
				table.insert(section.entries, {
					buttonType = "toy",
					id = wormholeId,
				})
			end
			if #section.entries > 0 then
				table.insert(sections, section)
			end
		elseif tpType == "item_teleports" then
			local section = CreateSection("item_teleports", L["Item Teleports"])
			for _, itemTeleportId in ipairs(tpm.AvailableItemTeleports or {}) do
				local isToy = tpm:IsToyTeleport(itemTeleportId)
				table.insert(section.entries, {
					buttonType = isToy and "toy" or "item",
					id = itemTeleportId,
				})
			end
			if #section.entries > 0 then
				table.insert(sections, section)
			end
		elseif tpType == "flyout" then
			local sectionName = teleport.name or select(1, GetFlyoutInfo(teleport.id)) or ("Flyout " .. tostring(teleport.id))
			local section = CreateSection("flyout:" .. tostring(teleport.id), sectionName)
			AddFlyoutSpellsToSection(section, teleport)
			if #section.entries > 0 then
				table.insert(sections, section)
			end
		end
	end

	if #coreSection.entries > 0 then
		table.insert(sections, 1, coreSection)
	end

	local seasonalSection = CreateSection("seasonal", L["Seasonal Teleports"])
	for _, spellId in ipairs(availableSeasonalTeleports) do
		if IsSpellKnown(spellId) then
			table.insert(seasonalSection.entries, {
				buttonType = "spell",
				id = spellId,
				text = tpm:GetIconText(spellId),
			})
		end
	end
	if #seasonalSection.entries > 0 then
		table.insert(sections, seasonalSection)
	end

	return sections
end

local function GetSectionCollapsedDbKey(sectionKey)
	return "Section:Collapsed:" .. tostring(sectionKey)
end

local function UpdateSectionToggleIcon(toggleButton, isCollapsed)
	if not toggleButton or not toggleButton.icon then
		return
	end
	local atlas = isCollapsed and "UI-QuestTrackerButton-Secondary-Expand" or "UI-QuestTrackerButton-Secondary-Collapse"
	toggleButton.icon:SetAtlas(atlas, true)
end

local function LayoutDisplayedButtons()
	if not teleportsScrollChild or not teleportsScrollFrame then
		return
	end

	local configuredColumns = math.max(1, db["Flyout:Max_Per_Row"] or 5)
	local xStep = globalWidth + GRID_SPACING
	local yStep = globalHeight + GRID_SPACING
	local listTopPadding = 8

	local frameWidth = math.max(1, teleportsScrollFrame:GetWidth())
	local sidePaddingLeft = LIST_LEFT_PADDING
	local sidePaddingRight = LIST_RIGHT_PADDING
	local scrollbarInset = 0
	local scrollBar = teleportsScrollFrame.ScrollBar
	if scrollBar then
		if scrollBar:IsShown() then
			local frameRight = teleportsScrollFrame:GetRight()
			local scrollBarLeft = scrollBar:GetLeft()
			if frameRight and scrollBarLeft then
				scrollbarInset = math.max(0, math.floor(frameRight - scrollBarLeft))
			end
		end
		if scrollBar.GetWidth then
			scrollbarInset = math.max(scrollbarInset, math.floor(scrollBar:GetWidth()))
		end
		if scrollbarInset > 0 then
			scrollbarInset = scrollbarInset + 2
		end
	end
	local availableWidth = math.max(1, frameWidth - sidePaddingLeft - sidePaddingRight - scrollbarInset)
	local maxFitColumns = math.max(1, math.floor((availableWidth + GRID_SPACING) / xStep))
	local columns = math.max(1, math.min(configuredColumns, maxFitColumns))

	if statusText then
		statusText:ClearAllPoints()
		statusText:SetPoint("TOPLEFT", teleportsScrollChild, "TOPLEFT", sidePaddingLeft, -listTopPadding)
		statusText:SetPoint("RIGHT", teleportsScrollChild, "RIGHT", -(sidePaddingRight + scrollbarInset), 0)
	end

	local offsetY = listTopPadding
	local buttonCount = 0
	local headerTextPadding = 8

	for _, section in ipairs(displayedSections) do
		local buttons = section.buttons
		local sectionFrame = section.frame
		local count = #buttons
		buttonCount = buttonCount + count
		local sectionDbKey = GetSectionCollapsedDbKey(section.key)
		local isCollapsed = db[sectionDbKey] == true

		sectionFrame:ClearAllPoints()
		sectionFrame:SetPoint("TOPLEFT", teleportsScrollChild, "TOPLEFT", sidePaddingLeft, -offsetY)
		sectionFrame:SetWidth(availableWidth)
		sectionFrame.sectionKey = section.key
		local headerLeftInset = 0
		local headerRightInset = 0
		sectionFrame.headerButton:ClearAllPoints()
		sectionFrame.headerButton:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", headerLeftInset, 0)
		sectionFrame.headerButton:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", headerRightInset, 0)
		sectionFrame.headerBg:ClearAllPoints()
		sectionFrame.headerBg:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", headerLeftInset, 0)
		sectionFrame.headerBg:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", headerRightInset, 0)
		sectionFrame.headerBg:SetHeight(SECTION_HEADER_HEIGHT)
		sectionFrame.headerBorder:ClearAllPoints()
		sectionFrame.headerBorder:SetPoint("TOPLEFT", sectionFrame.headerBg, "TOPLEFT", -2, 2)
		sectionFrame.headerBorder:SetPoint("BOTTOMRIGHT", sectionFrame.headerBg, "BOTTOMRIGHT", 2, -2)
		sectionFrame.headerTopEdge:ClearAllPoints()
		sectionFrame.headerTopEdge:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", headerLeftInset, 0)
		sectionFrame.headerTopEdge:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", headerRightInset, 0)
		sectionFrame.headerTopEdge:SetHeight(1)
		sectionFrame.headerBottomEdge:ClearAllPoints()
		sectionFrame.headerBottomEdge:SetPoint("BOTTOMLEFT", sectionFrame.headerBg, "BOTTOMLEFT", 0, 0)
		sectionFrame.headerBottomEdge:SetPoint("BOTTOMRIGHT", sectionFrame.headerBg, "BOTTOMRIGHT", 0, 0)
		sectionFrame.headerBottomEdge:SetHeight(1)
		sectionFrame.toggle:ClearAllPoints()
		sectionFrame.toggle:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", -6, -2)
		UpdateSectionToggleIcon(sectionFrame.toggle, isCollapsed)
		local function ToggleSectionCollapsed()
			db[sectionDbKey] = not (db[sectionDbKey] == true)
			LayoutDisplayedButtons()
		end
		sectionFrame.headerButton:SetScript("OnClick", ToggleSectionCollapsed)
		sectionFrame.toggle:SetScript("OnClick", ToggleSectionCollapsed)

		sectionFrame.title:SetText(("%s |cff9aa7b6(%d)|r"):format(section.title, count))
		sectionFrame.title:ClearAllPoints()
		sectionFrame.title:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", headerTextPadding, -2)
		sectionFrame.title:SetPoint("TOPRIGHT", sectionFrame.toggle, "TOPLEFT", -8, 0)
		sectionFrame.separator:ClearAllPoints()
		sectionFrame.separator:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, -SECTION_HEADER_HEIGHT)
		sectionFrame.separator:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", 0, -SECTION_HEADER_HEIGHT)

		local sectionHeight
		if isCollapsed then
			for _, button in ipairs(buttons) do
				button:Hide()
			end
			sectionHeight = SECTION_HEADER_HEIGHT + SECTION_BOTTOM_PADDING
		else
			local rows = math.max(1, math.ceil(count / columns))
			local firstButtonYOffset = SECTION_HEADER_HEIGHT + SECTION_HEADER_GAP
			for i, button in ipairs(buttons) do
				local row = math.floor((i - 1) / columns)
				local col = (i - 1) % columns
				button:Show()
				button:ClearAllPoints()
				button:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", ROW_CONTENT_LEFT_OFFSET + (col * xStep), -(firstButtonYOffset + row * yStep))
			end

			local buttonsHeight = math.max(1, rows * yStep - GRID_SPACING)
			sectionHeight = firstButtonYOffset + buttonsHeight + SECTION_BOTTOM_PADDING
		end
		sectionFrame:SetHeight(sectionHeight)
		offsetY = offsetY + sectionHeight + SECTION_GAP
	end

	if #displayedSections > 0 then
		offsetY = offsetY - SECTION_GAP
	end

	teleportsScrollChild:SetSize(frameWidth, math.max(1, offsetY))

	if statusText then
		if buttonCount == 0 then
			statusText:SetText("No teleports available for this character.")
			statusText:Show()
		else
			statusText:Hide()
		end
	end
end

local function EnsureWorldMapLoaded()
	if QuestMapFrame and WorldMapFrame then
		return true
	end

	local loader = UIParentLoadAddOn
	if C_AddOns and C_AddOns.LoadAddOn then
		loader = C_AddOns.LoadAddOn
	end

	if loader then
		pcall(loader, "Blizzard_WorldMap")
	end

	return QuestMapFrame and WorldMapFrame
end

local function AddSettingUpdater(func)
	table.insert(settingsWidgets, func)
end

local function CreateCheckbox(parent, key, label, x, y)
	local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	if checkbox.Text then
		checkbox.Text:SetText(label)
	end
	checkbox:SetScript("OnClick", function(self)
		db[key] = self:GetChecked() and true or false
		tpm:ReloadFrames()
	end)

	AddSettingUpdater(function()
		checkbox:SetChecked(db[key])
	end)

	return checkbox
end

local function CreateStepper(parent, key, label, minValue, maxValue, step, x, y, formatter)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(22)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	frame:SetPoint("RIGHT", parent, "RIGHT", -8, 0)

	local labelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("LEFT", frame, "LEFT", 0, 0)
	labelText:SetText(label)
	labelText:SetJustifyH("LEFT")

	local minus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	minus:SetSize(20, 20)
	minus:SetText("-")

	local valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	valueText:SetWidth(52)
	valueText:SetJustifyH("CENTER")

	local plus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	plus:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	plus:SetSize(20, 20)
	plus:SetText("+")

	valueText:SetPoint("RIGHT", plus, "LEFT", -6, 0)
	minus:SetPoint("RIGHT", valueText, "LEFT", -6, 0)
	labelText:SetPoint("RIGHT", minus, "LEFT", -8, 0)

	local function Normalize(value)
		if step < 1 then
			value = math.floor((value / step) + 0.5) * step
			value = tonumber(("%.2f"):format(value))
		end
		return math.max(minValue, math.min(maxValue, value))
	end

	local function ApplyDelta(delta)
		local current = db[key]
		if current == nil then
			current = tpm.SettingsBase[key] or minValue
		end
		db[key] = Normalize(current + delta)
		tpm:ReloadFrames()
	end

	minus:SetScript("OnClick", function()
		ApplyDelta(-step)
	end)

	plus:SetScript("OnClick", function()
		ApplyDelta(step)
	end)

	AddSettingUpdater(function()
		local value = db[key]
		if value == nil then
			value = tpm.SettingsBase[key] or minValue
		end
		if formatter then
			valueText:SetText(formatter(value))
		else
			valueText:SetText(tostring(value))
		end
	end)

	return frame
end

local function BuildHearthstoneOptions()
	local normalHearthstoneTexture = C_Item.GetItemIconByID and C_Item.GetItemIconByID(6948) or "Interface\\Icons\\inv_misc_rune_01"
	local options = {
		{ value = "normal", text = ("|T%s:14:14:0:0:64:64:4:60:4:60|t %s"):format(normalHearthstoneTexture, L["Normal Hearthstone"]) },
		{ value = "disabled", text = L["Disabled"] },
		{ value = "rng", text = ("|T1669494:14:14:0:0:64:64:4:60:4:60|t %s"):format(L["Random"]) },
	}

	local hearthstones = tpm:GetAvailableHearthstoneToys()
	local toys = {}
	for id, info in pairs(hearthstones) do
		table.insert(toys, {
			value = tostring(id),
			name = info.name or tostring(id),
			texture = info.texture or "Interface\\Icons\\inv_hearthstonepet",
		})
	end

	table.sort(toys, function(a, b)
		return a.name < b.name
	end)

	for _, toy in ipairs(toys) do
		table.insert(options, {
			value = toy.value,
			text = ("|T%s:14:14:0:0:64:64:4:60:4:60|t %s"):format(toy.texture, toy.name),
		})
	end

	return options
end

local function CreateHearthstoneSelector(parent, x, y)
	local key = "Teleports:Hearthstone"
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(24)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	frame:SetPoint("RIGHT", parent, "RIGHT", -8, 0)

	local labelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("LEFT", frame, "LEFT", 0, 0)
	labelText:SetWidth(86)
	labelText:SetText(L["Hearthstone Toy"])
	labelText:SetJustifyH("LEFT")

	local dropdown = CreateFrame("Frame", "EiklasTeleportingTab_HearthstoneSelectorDropdown", frame, "UIDropDownMenuTemplate")
	dropdown:SetPoint("RIGHT", frame, "RIGHT", 12, -2)
	UIDropDownMenu_SetWidth(dropdown, 170)
	UIDropDownMenu_JustifyText(dropdown, "LEFT")

	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Hearthstone Toy"], 1, 1, 1)
		GameTooltip:AddLine(L["Hearthstone Toy Tooltip"], 1, 1, 1, true)
		GameTooltip:Show()
		end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local function GetSelectedOption(options)
		local current = db[key]
		if current == nil then
			current = tpm.SettingsBase[key] or "normal"
		end
		current = tostring(current)

		for _, option in ipairs(options) do
			if tostring(option.value) == current then
				return option, true
			end
		end
		return options[1], false
	end

	local function UpdateDropdownDisplay()
		local options = BuildHearthstoneOptions()
		if #options == 0 then
			UIDropDownMenu_SetText(dropdown, L["Normal Hearthstone"])
			UIDropDownMenu_SetSelectedValue(dropdown, "normal")
			return
		end

		local selected, hasExactMatch = GetSelectedOption(options)
		if selected then
			if hasExactMatch then
				UIDropDownMenu_SetSelectedValue(dropdown, tostring(selected.value))
			else
				UIDropDownMenu_SetSelectedValue(dropdown, nil)
			end
			UIDropDownMenu_SetText(dropdown, selected.text)
		end
	end

	local function InitializeDropdown(_, level)
		if level ~= 1 then
			return
		end

		local options = BuildHearthstoneOptions()
		local selected, hasExactMatch = GetSelectedOption(options)
		local selectedValue = (hasExactMatch and selected and tostring(selected.value)) or nil

		for _, option in ipairs(options) do
			local optionValue = option.value
			local optionText = option.text
			local info = UIDropDownMenu_CreateInfo()
			info.text = optionText
			info.value = tostring(optionValue)
			info.checked = (selectedValue ~= nil and selectedValue == tostring(optionValue))
			info.func = function()
				db[key] = optionValue
				UpdateDropdownDisplay()
				CloseDropDownMenus()
				tpm:ReloadFrames()
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end

	UIDropDownMenu_Initialize(dropdown, InitializeDropdown)

	AddSettingUpdater(function()
		UpdateDropdownDisplay()
		UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
	end)

	return frame
end

function tpm:RefreshSettingsWidgets()
	for _, updater in ipairs(settingsWidgets) do
		updater()
	end
end

function tpm:UpdateMapLayout()
	if not mapRootFrame or not teleportsScrollFrame then
		return
	end

	local topAnchor = settingsFrame:IsShown() and settingsFrame or headerFrame
	teleportsScrollFrame:ClearAllPoints()
	teleportsScrollFrame:SetPoint("TOPLEFT", topAnchor, "BOTTOMLEFT", CONTENT_PADDING_X, -8)
	teleportsScrollFrame:SetPoint("TOPRIGHT", topAnchor, "BOTTOMRIGHT", -CONTENT_PADDING_X, -8)
	teleportsScrollFrame:SetPoint("BOTTOMLEFT", mapRootFrame, "BOTTOMLEFT", CONTENT_PADDING_X, CONTENT_PADDING_Y)
	teleportsScrollFrame:SetPoint("BOTTOMRIGHT", mapRootFrame, "BOTTOMRIGHT", -CONTENT_PADDING_X, CONTENT_PADDING_Y)

	LayoutDisplayedButtons()
end

function tpm:InitializeMapTab()
	if mapRootFrame then
		return true
	end

	if not EnsureWorldMapLoaded() then
		return false
	end

	mapTabLib = LibStub("LibWorldMapTabs", true)
	if not mapTabLib then
		return false
	end

	local tabIconData = GetTabIconData()
	tabIconData.tooltipText = L["ADDON_NAME"]
	mapTab = mapTabLib:CreateTab(tabIconData, "EiklasTeleportingTab_MapTab")
	mapContentFrame = mapTabLib:CreateContentFrameForTab(mapTab, nil, "EiklasTeleportingTab_ContentFrame")

	mapRootFrame = CreateFrame("Frame", "EiklasTeleportingTab_RootFrame", mapContentFrame)
	mapRootFrame:SetAllPoints(mapContentFrame)

	local bg = mapRootFrame:CreateTexture(nil, "BACKGROUND")
	ApplyUnifiedBackground(bg)
	bg:SetPoint("TOPLEFT", mapRootFrame, "TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", mapRootFrame, "BOTTOMRIGHT", -2, 2)

	local okBorder, borderFrame = pcall(CreateFrame, "Frame", nil, mapRootFrame, "QuestLogBorderFrameTemplate")
	if okBorder and borderFrame then
		borderFrame:SetAllPoints(mapRootFrame)
		borderFrame:SetFrameLevel(mapRootFrame:GetFrameLevel() + 1)
	end

	headerFrame = CreateFrame("Frame", nil, mapRootFrame)
	headerFrame:SetPoint("TOPLEFT", mapRootFrame, "TOPLEFT", CONTENT_PADDING_X, -CONTENT_PADDING_Y)
	headerFrame:SetPoint("TOPRIGHT", mapRootFrame, "TOPRIGHT", -CONTENT_PADDING_X, -CONTENT_PADDING_Y)
	headerFrame:SetHeight(26)

	local headerBg = headerFrame:CreateTexture(nil, "BACKGROUND")
	headerBg:SetColorTexture(0, 0, 0, 0)
	headerBg:SetAllPoints()

	headerTitle = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	headerTitle:SetPoint("CENTER", headerFrame, "CENTER", 0, 0)
	headerTitle:SetJustifyH("CENTER")
	headerTitle:SetText(L["ADDON_NAME"])
	headerTitle:SetTextColor(1, 0.82, 0)

	local headerDivider = headerFrame:CreateTexture(nil, "BORDER")
	headerDivider:SetColorTexture(0, 0, 0, 0)
	headerDivider:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 0, -1)
	headerDivider:SetPoint("BOTTOMRIGHT", headerFrame, "BOTTOMRIGHT", 0, -1)
	headerDivider:SetHeight(1)

	local listBackground = mapRootFrame:CreateTexture(nil, "BACKGROUND")
	ApplyUnifiedBackground(listBackground)
	listBackground:SetPoint("TOPLEFT", headerDivider, "BOTTOMLEFT", 0, -1)
	listBackground:SetPoint("TOPRIGHT", headerDivider, "BOTTOMRIGHT", 0, -1)
	listBackground:SetPoint("BOTTOMLEFT", mapRootFrame, "BOTTOMLEFT", 2, 2)
	listBackground:SetPoint("BOTTOMRIGHT", mapRootFrame, "BOTTOMRIGHT", -2, 2)

	local listBackgroundShade = mapRootFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
	listBackgroundShade:SetAllPoints(listBackground)
	listBackgroundShade:SetColorTexture(0, 0, 0, 0)

	local configButton = CreateFrame("Button", nil, headerFrame)
	configButton:SetPoint("RIGHT", headerFrame, "RIGHT", 0, 0)
	configButton:SetSize(15, 16)
	configButton:SetHitRectInsets(-4, -4, -4, -4)
	configButton.Icon = configButton:CreateTexture(nil, "ARTWORK")
	configButton.Icon:SetAtlas("questlog-icon-setting", true)
	configButton.Icon:SetPoint("CENTER")
	configButton.Highlight = configButton:CreateTexture(nil, "HIGHLIGHT")
	configButton.Highlight:SetAtlas("questlog-icon-setting", true)
	configButton.Highlight:SetPoint("CENTER", configButton.Icon, "CENTER")
	configButton.Highlight:SetAlpha(0.35)
	configButton:SetScript("OnMouseDown", function(self)
		if self:IsEnabled() then
			self.Icon:AdjustPointsOffset(1, -1)
		end
	end)
	configButton:SetScript("OnMouseUp", function(self)
		if self:IsEnabled() then
			self.Icon:AdjustPointsOffset(-1, 1)
		end
	end)

	settingsFrame = CreateFrame("Frame", nil, mapRootFrame)
	settingsFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -6)
	settingsFrame:SetPoint("TOPRIGHT", headerFrame, "BOTTOMRIGHT", 0, -6)
	settingsFrame:SetHeight(SETTINGS_PANEL_HEIGHT)
	settingsFrame:Hide()

	local function UpdateConfigButtonVisual()
		if settingsFrame:IsShown() then
			configButton.Icon:SetAtlas("common-search-clearbutton", false)
			configButton.Highlight:SetAtlas("common-search-clearbutton", false)
		else
			configButton.Icon:SetAtlas("questlog-icon-setting", false)
			configButton.Highlight:SetAtlas("questlog-icon-setting", false)
		end
		configButton.Icon:SetSize(15, 15)
		configButton.Highlight:SetSize(15, 15)
	end

	configButton:SetScript("OnClick", function()
		settingsFrame:SetShown(not settingsFrame:IsShown())
		UpdateConfigButtonVisual()
		tpm:UpdateMapLayout()
	end)
	settingsFrame:HookScript("OnShow", UpdateConfigButtonVisual)
	settingsFrame:HookScript("OnHide", UpdateConfigButtonVisual)
	UpdateConfigButtonVisual()

	local settingsBg = settingsFrame:CreateTexture(nil, "BACKGROUND")
	ApplyUnifiedBackground(settingsBg)
	settingsBg:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 0, 0)
	settingsBg:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
	settingsBg:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 0, 0)
	settingsBg:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", 0, 0)

	local settingsShade = settingsFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
	settingsShade:SetAllPoints()
	settingsShade:SetColorTexture(0, 0, 0, 0)

	local settingsTopBorder = settingsFrame:CreateTexture(nil, "BORDER")
	settingsTopBorder:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 0, 0)
	settingsTopBorder:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
	settingsTopBorder:SetHeight(1)
	settingsTopBorder:SetColorTexture(1, 1, 1, 0.08)

	local settingsBottomBorder = settingsFrame:CreateTexture(nil, "BORDER")
	settingsBottomBorder:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 0, 0)
	settingsBottomBorder:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", 0, 0)
	settingsBottomBorder:SetHeight(1)
	settingsBottomBorder:SetColorTexture(0, 0, 0, 0.6)

	CreateHearthstoneSelector(settingsFrame, 6, -6)
	CreateCheckbox(settingsFrame, "Button:Text:Show", L["ButtonText"], 6, -34)
	CreateCheckbox(settingsFrame, "General:AutoClose", L["Auto Close"], 6, -58)
	CreateCheckbox(settingsFrame, "Teleports:Seasonal:Only", L["Seasonal Teleports"], 6, -82)
	CreateCheckbox(settingsFrame, "Teleports:Mage:Reverse", L["Reverse Mage Flyouts"], 6, -106)

	CreateStepper(settingsFrame, "Button:Size", L["Icon Size"], 10, 75, 1, 6, -138, function(value)
		return ("%d px"):format(value)
	end)

	CreateStepper(settingsFrame, "Button:Text:Size", L["BUTTON_FONT_SIZE"], 6, 40, 1, 6, -164, function(value)
		return ("%d px"):format(value)
	end)

	CreateStepper(settingsFrame, "Flyout:Max_Per_Row", L["Icons Per Flyout Row"], 1, 20, 1, 6, -190, function(value)
		return tostring(value)
	end)

	local ok, frameWithTemplate = pcall(CreateFrame, "ScrollFrame", "EiklasTeleportingTab_ScrollFrame", mapRootFrame, "ScrollFrameTemplate")
	teleportsScrollFrame = (ok and frameWithTemplate) or CreateFrame("ScrollFrame", "EiklasTeleportingTab_ScrollFrame", mapRootFrame, "UIPanelScrollFrameTemplate")
	teleportsScrollChild = CreateFrame("Frame", nil, teleportsScrollFrame)
	teleportsScrollChild:SetPoint("TOPLEFT", 0, 0)
	teleportsScrollChild:SetSize(1, 1)
	teleportsScrollFrame:SetScrollChild(teleportsScrollChild)
	teleportsScrollFrame:SetScript("OnSizeChanged", function()
		LayoutDisplayedButtons()
	end)
	if teleportsScrollFrame.ScrollBar and teleportsScrollFrame.ScrollBar.SetHideIfUnscrollable then
		teleportsScrollFrame.ScrollBar:SetHideIfUnscrollable(true)
	end
	if teleportsScrollFrame.ScrollBar and teleportsScrollFrame.ScrollBar.SetHideTrackIfThumbExceedsTrack then
		teleportsScrollFrame.ScrollBar:SetHideTrackIfThumbExceedsTrack(true)
	end

	statusText = teleportsScrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	statusText:SetPoint("TOPLEFT", teleportsScrollChild, "TOPLEFT", LIST_LEFT_PADDING, 0)
	statusText:SetPoint("RIGHT", teleportsScrollChild, "RIGHT", -LIST_RIGHT_PADDING, 0)
	statusText:SetJustifyH("LEFT")
	statusText:SetText("")
	statusText:Hide()

	mapContentFrame:HookScript("OnShow", function()
		C_Timer.After(0, function()
			if mapContentFrame and mapContentFrame:IsShown() then
				tpm:UpdateMapLayout()
				tpm:ReloadFrames()
			end
		end)
	end)

	tpm:RefreshSettingsWidgets()
	tpm:UpdateMapLayout()
	return true
end

function tpm:OpenMapTab()
	if not self:InitializeMapTab() then
		return
	end

	if WorldMapFrame and not WorldMapFrame:IsShown() then
		ToggleWorldMap()
	end

	if mapTabLib and mapTab and mapTab.displayMode then
		mapTabLib:SetDisplayMode(mapTab.displayMode)
	end

	tpm:ReloadFrames(true)
end

function tpm:ReloadFrames(showWarnings)
	if InCombatLockdown() then
		pendingReload = true
		if statusText and mapContentFrame and mapContentFrame:IsShown() then
			statusText:SetText(L["Not In Combat Tooltip"])
			statusText:Show()
		end
		return
	end

	pendingReload = false

	if not mapRootFrame and not self:InitializeMapTab() then
		return
	end

	-- Keep availability lists current; some collections/spell data can lag behind login.
	tpm:UpdateAvailableHearthstones()
	tpm:UpdateAvailableWormholes()
	tpm:UpdateAvailableSeasonalTeleports()
	tpm:UpdateAvailableItemTeleports()
	if tpm.AvailableHearthstones and #tpm.AvailableHearthstones > 0 then
		toyCollectionInitialized = true
	end

	if db["Button:Size"] then
		globalWidth = db["Button:Size"]
		globalHeight = db["Button:Size"]
	end

	tpm.TEXTURE_SCALE = 0

	RecycleDisplayedButtons()

	local sections = BuildTeleportSections(showWarnings == true)
	for _, sectionData in ipairs(sections) do
		local sectionFrame = AcquireSectionFrame()
		local renderedSection = {
			key = sectionData.key,
			title = sectionData.title,
			frame = sectionFrame,
			buttons = {},
		}

		for _, spec in ipairs(sectionData.entries) do
			local button
			if spec.buttonType == "housing" then
				button = tpm.Housing:CreateSecureHousingButton({ faction = spec.faction })
				if button then
					button:SetParent(sectionFrame)
				end
			else
				button = CreateSecureButton(sectionFrame, spec.buttonType, spec.text, spec.id, spec.hearthstone)
			end

			if button then
				table.insert(renderedSection.buttons, button)
			end
		end

		if #renderedSection.buttons > 0 then
			table.insert(displayedSections, renderedSection)
		else
			sectionFrame:Hide()
			sectionFrame:ClearAllPoints()
			sectionFrame:SetParent(nil)
			table.insert(sectionFramePool, sectionFrame)
			table.remove(activeSectionFrames)
		end
	end

	LayoutDisplayedButtons()
	tpm:RefreshSettingsWidgets()
end

function tpm:CloseMainMenu()
	if not db["General:AutoClose"] then
		return
	end

	if WorldMapFrame and WorldMapFrame:IsShown() then
		HideUIPanel(WorldMapFrame)
	end

	if GameMenuFrame and GameMenuFrame:IsShown() then
		HideUIPanel(GameMenuFrame)
	end
end

-- Slash Commands
SLASH_EIKLASTELEPORTINGTAB1 = "/ett"
SLASH_EIKLASTELEPORTINGTAB2 = "/eiklatp"
SlashCmdList["EIKLASTELEPORTINGTAB"] = function()
	tpm:OpenMapTab()
end

--------------------------------------
-- Loading
--------------------------------------

local function checkItemsLoaded(self)
	if self.continuableContainer then
		self.continuableContainer:Cancel()
	end

	self.continuableContainer = ContinuableContainer:Create()

	local function LoadItems(itemTable)
		for id, _ in pairs(itemTable) do
			self.continuableContainer:AddContinuable(Item:CreateFromItemID(id))
		end
	end

	LoadItems(tpm.Wormholes)
	LoadItems(tpm.Hearthstones)
	LoadItems(tpm.ItemTeleports)

	local allLoaded = true
	local function OnItemsLoaded()
		if allLoaded then
			tpm:Setup()
			tpm:LoadOptions()
			self:UnregisterEvent("ADDON_LOADED")
		else
			checkItemsLoaded(self)
		end
	end

	allLoaded = self.continuableContainer:ContinueOnLoad(OnItemsLoaded)
end

function tpm:Setup()
	if db["Button:Size"] then
		globalWidth = db["Button:Size"]
		globalHeight = db["Button:Size"]
	end

	tpm:UpdateAvailableHearthstones()
	tpm:UpdateAvailableWormholes()
	tpm:UpdateAvailableSeasonalTeleports()
	tpm:UpdateAvailableItemTeleports()
	tpm:LoadHouses()

	-- Migration: old "none" behavior is now explicit "normal".
	if db["Teleports:Hearthstone"] == nil or db["Teleports:Hearthstone"] == "none" then
		db["Teleports:Hearthstone"] = "normal"
	end

	if
		db["Teleports:Hearthstone"]
		and db["Teleports:Hearthstone"] ~= "rng"
		and db["Teleports:Hearthstone"] ~= "normal"
		and db["Teleports:Hearthstone"] ~= "disabled"
		and not PlayerHasToy(tonumber(db["Teleports:Hearthstone"]) or 0)
	then
		print(APPEND .. L["Hearthone Reset Error"]:format(db["Teleports:Hearthstone"]))
		db["Teleports:Hearthstone"] = "normal"
	end

	tpm:InitializeMapTab()
	tpm:ReloadFrames()
end

-- Event Handlers
local events = {}
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("SPELLS_CHANGED")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("TOYS_UPDATED")
f:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...)
end)

function events:ADDON_LOADED(...)
	local addOnName = ...

	if addOnName == "EiklasTeleportingTab" then
		db = tpm:GetOptions()
		tpm.settings.current_season = 1

		db.debug = false
	end
end

function events:PLAYER_LOGIN()
	checkItemsLoaded(f)
	f:UnregisterEvent("PLAYER_LOGIN")
end

function events:BAG_UPDATE_DELAYED()
	--- @type Item[]
	local items_in_possession = CopyTable(tpm.player.items_in_possession)

	--- @type Item[]
	local items_to_be_obtained = CopyTable(tpm.player.items_to_be_obtained)

	for _, item in pairs(items_in_possession) do
		if GetItemCount(item.id) == 0 then
			tpm:RemoveItemFromPossession(item.id)
		end
	end

	for _, item in pairs(items_to_be_obtained) do
		if GetItemCount(item.id) > 0 then
			tpm:AddItemToPossession(item.id)
		end
	end

	tpm:ReloadFrames()
end

function events:PLAYER_REGEN_ENABLED()
	if pendingReload then
		tpm:ReloadFrames()
	end
end

function events:SPELLS_CHANGED()
	tpm:ReloadFrames()
end

function events:PLAYER_TALENT_UPDATE()
	tpm:ReloadFrames()
end

function events:TOYS_UPDATED()
	toyCollectionInitialized = true
	tpm:ReloadFrames()
end

-- Debug Functions
function tpm:DebugPrint(...)
	if not db.debug then
		return
	end
	print(APPEND, ...)
end
