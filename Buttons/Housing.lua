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
houseData = houseData or {}

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

	return list
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
	local houseCount = self:GetHouseCount()
	local houseList = BuildHouseList()

	if houseCount == 1 or faction == "alliance" then
		houseInfo = houseList[1]
	else -- horde if 2
		houseInfo = houseList[2]
	end

	if not self:CanReturn() and not houseInfo then
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
	if self:CanReturn() then
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
	if count == 0 and C_Housing and C_Housing.GetPlayerOwnedHouses then
		local ownedHouses = C_Housing.GetPlayerOwnedHouses()
		if type(ownedHouses) == "table" then
			houseData = ownedHouses
			count = #BuildHouseList()
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
	if type(housingInfo) == "table" then
		houseData = housingInfo
	elseif C_Housing and C_Housing.GetPlayerOwnedHouses then
		local ownedHouses = C_Housing.GetPlayerOwnedHouses()
		if type(ownedHouses) == "table" then
			houseData = ownedHouses
		end
	end
	tpm:ReloadFrames()
end

function tpm:LoadHouses()
	if not (C_Housing and C_Housing.GetPlayerOwnedHouses) then
		return
	end
	local ownedHouses = C_Housing.GetPlayerOwnedHouses()
	if type(ownedHouses) == "table" then
		houseData = ownedHouses
	end
	f:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
	C_Housing.GetPlayerOwnedHouses()
end

