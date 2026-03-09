local _, tpm = ...
local Housing = {}
tpm.Housing = Housing

--------------------------------------
-- Libraries
--------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("EiklasTeleportingTab")
local MSQ = LibStub("Masque", true)
local MasqueGroup = MSQ and MSQ:Group(L["ADDON_NAME"])

--------------------------------------
-- Locales
--------------------------------------


local housingButtonsPool = {}
local activeHousingButtons = {}
local houseData = {}
local housingApiRetries = 0
local housingApiRetryScheduled = false
local housingReloadScheduled = false
local isRefreshingHouseData = false
local HOUSING_API_MAX_RETRIES = 0 -- 0 = unlimited retries while API is unavailable
local HOUSING_API_RETRY_DELAY_SECONDS = 1
local HOUSING_UI_ADDONS = {
	"Blizzard_HousingUI",
	"Blizzard_PlayerHousingUI",
	"Blizzard_Housing",
	"Blizzard_PlayerHousing",
	"Blizzard_HousingDashboard",
	"Blizzard_PlayerHousingDashboard",
}
local ALLIANCE_HOUSING_MAP_ID = 2352 -- Founder's Point
local HORDE_HOUSING_MAP_ID = 2351 -- Razorwind Shores

local function DebugPrint(...)
	if tpm and tpm.DebugPrint then
		tpm:DebugPrint(...)
	end
end

local function GetHouseFaction(houseInfo)
	if not (houseInfo and houseInfo.neighborhoodGUID and C_Housing and C_Housing.GetUIMapIDForNeighborhood) then
		return nil
	end
	local mapID = C_Housing.GetUIMapIDForNeighborhood(houseInfo.neighborhoodGUID)
	if mapID == ALLIANCE_HOUSING_MAP_ID then
		return "alliance"
	end
	if mapID == HORDE_HOUSING_MAP_ID then
		return "horde"
	end
	return nil
end

local function GetFactionSortRank(faction)
	if faction == "alliance" then
		return 1
	end
	if faction == "horde" then
		return 2
	end
	return 3
end

local function BuildHouseList()
	local list = {}
	if type(houseData) ~= "table" then
		return list
	end

	for _, info in pairs(houseData) do
		if type(info) == "table" then
			table.insert(list, info)
		end
	end

	table.sort(list, function(a, b)
		local factionA = GetHouseFaction(a) or ""
		local factionB = GetHouseFaction(b) or ""
		local rankA = GetFactionSortRank(factionA)
		local rankB = GetFactionSortRank(factionB)
		if rankA ~= rankB then
			return rankA < rankB
		end

		local neighborhoodA = tostring(a.neighborhoodGUID or "")
		local neighborhoodB = tostring(b.neighborhoodGUID or "")
		if neighborhoodA ~= neighborhoodB then
			return neighborhoodA < neighborhoodB
		end

		local houseGuidA = tostring(a.houseGUID or "")
		local houseGuidB = tostring(b.houseGUID or "")
		if houseGuidA ~= houseGuidB then
			return houseGuidA < houseGuidB
		end

		return tonumber(a.plotID or 0) < tonumber(b.plotID or 0)
	end)

	return list
end

local function IsHousingApiReady()
	return C_Housing and type(C_Housing.GetPlayerOwnedHouses) == "function"
end

local function TryLoadHousingUiAddons()
	if IsHousingApiReady() then
		return true
	end

	local loadAddOn = (C_AddOns and C_AddOns.LoadAddOn) or _G.LoadAddOn
	local isAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or _G.IsAddOnLoaded
	if type(loadAddOn) ~= "function" then
		return false
	end

	for _, addonName in ipairs(HOUSING_UI_ADDONS) do
		local loaded = type(isAddOnLoaded) == "function" and isAddOnLoaded(addonName)
		if not loaded then
			local ok, result = pcall(loadAddOn, addonName)
			DebugPrint("Housing: LoadAddOn", addonName, ok, result)
		end
		if IsHousingApiReady() then
			return true
		end
	end

	return IsHousingApiReady()
end

local function RefreshHouseDataFromApi()
	if not IsHousingApiReady() or isRefreshingHouseData then
		return false
	end

	isRefreshingHouseData = true
	local ok, ownedHouses = pcall(C_Housing.GetPlayerOwnedHouses)
	isRefreshingHouseData = false
	if not ok then
		DebugPrint("Housing: GetPlayerOwnedHouses failed", tostring(ownedHouses))
		return false
	end

	if type(ownedHouses) == "table" then
		houseData = ownedHouses
		return true
	end

	return false
end

local function ScheduleHousingReload()
	if housingReloadScheduled then
		return
	end
	if not (tpm and (tpm.RequestReload or tpm.ReloadFrames)) then
		return
	end

	if C_Timer and C_Timer.After then
		housingReloadScheduled = true
		C_Timer.After(0, function()
			housingReloadScheduled = false
			if tpm and tpm.RequestReload then
				tpm:RequestReload(false, 0)
			elseif tpm and tpm.ReloadFrames then
				tpm:ReloadFrames()
			end
		end)
	else
		if tpm and tpm.RequestReload then
			tpm:RequestReload(false, 0)
		else
			tpm:ReloadFrames()
		end
	end
end

local function ScheduleHousingApiRetry()
	if housingApiRetryScheduled then
		return
	end
	if HOUSING_API_MAX_RETRIES > 0 and housingApiRetries >= HOUSING_API_MAX_RETRIES then
		return
	end
	if not (C_Timer and C_Timer.After) then
		return
	end

	housingApiRetryScheduled = true
	C_Timer.After(HOUSING_API_RETRY_DELAY_SECONDS, function()
		housingApiRetryScheduled = false
		housingApiRetries = housingApiRetries + 1
		DebugPrint("Housing: retrying API init", housingApiRetries)
		if tpm and tpm.LoadHouses then
			tpm:LoadHouses()
		end
	end)
end

local function SelectHouseForFaction(houseList, faction)
	if #houseList == 0 then
		return nil
	end

	if #houseList == 1 or faction == nil then
		return houseList[1]
	end

	for _, info in ipairs(houseList) do
		if GetHouseFaction(info) == faction then
			return info
		end
	end

	DebugPrint("Housing: faction match not found, using first house entry", faction)
	return houseList[1]
end

--------------------------------------
-- Functions
--------------------------------------

function Housing:CanReturn()
	return C_HousingNeighborhood and C_HousingNeighborhood.CanReturnAfterVisitingHouse()
end

local function setToolTip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local text = Housing:CanReturn() and _G.HOUSING_DASHBOARD_RETURN or _G.HOUSING_DASHBOARD_TELEPORT_TO_PLOT
	GameTooltip:SetText(text, 1, 1, 1)

	GameTooltip:Show()
end

local function createCooldownFrame(frame)
	if frame.cooldownFrame then
		return frame.cooldownFrame
	end
	local cooldownFrame = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	cooldownFrame:SetAllPoints()

	function cooldownFrame:CheckCooldown()
		if Housing:CanReturn() then
			self:Clear() -- this has no CD
			return
		end

		local cdInfo = C_Housing.GetVisitCooldownInfo()
		local start = cdInfo.startTime
		local duration = cdInfo.duration
		local enabled = cdInfo.isEnabled
		if enabled and not tpm:IsSecret(duration) and duration > 0 then
			self:SetCooldown(start, duration)
		else
			self:Clear()
		end
	end

	return cooldownFrame
end

function Housing:CreateSecureHousingButton(tpInfo)
	local button, houseInfo = nil, nil
	local faction = tpInfo and tpInfo.faction and string.lower(tpInfo.faction)
	local houseList = BuildHouseList()
	houseInfo = SelectHouseForFaction(houseList, faction)
	local canReturn = self:CanReturn()

	if not canReturn and not houseInfo then
		DebugPrint(
			"Housing: no house payload available",
			"faction=" .. tostring(faction),
			"hasHouseInfo=" .. tostring(houseInfo ~= nil),
			"neighborhoodGUID=" .. tostring(houseInfo and houseInfo.neighborhoodGUID),
			"houseGUID=" .. tostring(houseInfo and houseInfo.houseGUID),
			"plotID=" .. tostring(houseInfo and houseInfo.plotID)
		)
		return nil
	end

	if next(housingButtonsPool) then
		button = table.remove(housingButtonsPool)
	else
		button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")

		button.text = button:CreateFontString(nil, "OVERLAY")
		button.text:SetPoint("BOTTOM", button, "BOTTOM", 0, 5)
		button.cooldownFrame = createCooldownFrame(button)

		function button:Recycle()
			self:SetParent(nil)
			self:ClearAllPoints()
			self:Hide()
			table.insert(housingButtonsPool, self)

			if MasqueGroup then
				MasqueGroup:RemoveButton(self)
			end
		end

		button:EnableMouse(true)
		button:RegisterForClicks("AnyDown", "AnyUp")
		button:SetAttribute("useOnKeyDown", true)
		button:SetScript("PostClick", function()
			tpm:CloseMainMenu()
		end)

		button:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		button:SetScript("OnEnter", function(self)
			setToolTip(self)
		end)

		button:SetScript("OnShow", function(self)
			if not Housing:CanReturn() then
				self.cooldownFrame:CheckCooldown()
			end
		end)

		-- Icon
		button.icon = button:CreateTexture(nil, "BACKGROUND")
		button.icon:SetAllPoints()
	end

	-- Textures
	if self:CanReturn() then
		button.icon:SetAtlas("dashboard-panel-homestone-teleport-out-button")
	else
		local spellTexture =  C_Spell.GetSpellTexture(1263273)
		button.icon:SetTexture(spellTexture)
	end

	local zoomFactor = tpm.TEXTURE_SCALE
	local offset = zoomFactor / 2
	button.icon:SetTexCoord(offset, 1-offset, offset, 1-offset)

	-- Attributes
	button:SetAttribute("macrotext", nil)
	if canReturn then
		button:SetAttribute("type", "returnhome")
		button:SetAttribute("house-neighborhood-guid", nil)
		button:SetAttribute("house-guid", nil)
		button:SetAttribute("house-plot-id", nil)
	else
		button:SetAttribute("type", "teleporthome")
		button:SetAttribute("house-neighborhood-guid", houseInfo.neighborhoodGUID)
		button:SetAttribute("house-guid", houseInfo.houseGUID)
		button:SetAttribute("house-plot-id", houseInfo.plotID)
	end

	button.cooldownFrame:CheckCooldown()
	table.insert(activeHousingButtons, button)

	local db = tpm:GetOptions()
	local size = db["Button:Size"] or 40
	button:SetSize(size, size)
	button:Show()

	if MasqueGroup then
		MasqueGroup:AddButton(button, { Icon = button.icon })
	end
	return button
end

function Housing:RecycleHousingButtons()
	for _, secureButton in ipairs(activeHousingButtons) do
		secureButton:Recycle()
	end
	activeHousingButtons = {}
end

function Housing:GetActiveHousingButtons()
	return #activeHousingButtons
end

function Housing:HasAPlot()
	return self:GetHouseCount() > 0
end

function Housing:GetHouseCount()
	local count = #BuildHouseList()
	if count == 0 and not IsHousingApiReady() then
		TryLoadHousingUiAddons()
		if not IsHousingApiReady() then
			ScheduleHousingApiRetry()
		end
	end
	return count
end

--------------------------------------
-- Event Handlers
--------------------------------------

local events = {}
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...)
end)

function events:PLAYER_HOUSE_LIST_UPDATED(housingInfo)
	housingApiRetries = 0
	if type(housingInfo) == "table" then
		houseData = housingInfo
	else
		-- Keep this guarded: GetPlayerOwnedHouses can synchronously re-fire this event.
		RefreshHouseDataFromApi()
	end
	ScheduleHousingReload()
end

function tpm:LoadHouses()
	f:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")

	if not IsHousingApiReady() then
		TryLoadHousingUiAddons()
	end
	if not IsHousingApiReady() then
		DebugPrint("Housing: API not ready yet, scheduling retry")
		ScheduleHousingApiRetry()
		return
	end

	housingApiRetries = 0
	if RefreshHouseDataFromApi() then
		ScheduleHousingReload()
	end
end

