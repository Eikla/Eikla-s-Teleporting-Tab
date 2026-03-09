local _, tpm = ...

local push, sort = table.insert, sort

--- @alias Item { id: integer, name: string, icon: integer }
--- @class Player
--- @field items_in_possession Item[]
--- @field items_to_be_obtained Item[]
tpm.player = {
	items_in_possession = {},
	items_to_be_obtained = {},
}

--- @param item_id integer
function tpm:AddItemToPossession(item_id, suppressReload)
	for key, item in pairs(tpm.player.items_to_be_obtained) do
		if item.id == item_id then
			push(tpm.player.items_in_possession, item)
			if #tpm.player.items_in_possession > 1 then
				sort(tpm.player.items_in_possession, function(a, b)
					if not a or not b or not a.name or not b.name then
						return false
					end
					return a.name < b.name
				end)
			end

			tpm.player.items_to_be_obtained[key] = nil
			local missingView = tpm.settings.scroll_box_views["items_to_be_obtained"]
			if missingView and missingView.SetDataProvider then
				missingView:SetDataProvider(CreateDataProvider(tpm.player.items_to_be_obtained))
			end
			local possessionView = tpm.settings.scroll_box_views["items_in_possession"]
			if possessionView and possessionView.SetDataProvider then
				possessionView:SetDataProvider(CreateDataProvider(tpm.player.items_in_possession))
			end
			if suppressReload then
				if tpm.MarkAvailabilityDirty then
					tpm:MarkAvailabilityDirty("itemTeleports")
				end
			else
				tpm:UpdateAvailableItemTeleports()
				if tpm.RequestReload then
					tpm:RequestReload(false, 0)
				else
					tpm:ReloadFrames()
				end
			end
			return true
		end
	end
	return false
end

--- @param item_id integer
function tpm:RemoveItemFromPossession(item_id, suppressReload)
	for key, item in pairs(tpm.player.items_in_possession) do
		if item.id == item_id then
			push(tpm.player.items_to_be_obtained, item)
			if #tpm.player.items_to_be_obtained > 1 then
				sort(tpm.player.items_to_be_obtained, function(a, b)
					if not a or not b or not a.name or not b.name then
						return false
					end
					return a.name < b.name
				end)
			end

			tpm.player.items_in_possession[key] = nil
			local missingView = tpm.settings.scroll_box_views["items_to_be_obtained"]
			if missingView and missingView.SetDataProvider then
				missingView:SetDataProvider(CreateDataProvider(tpm.player.items_to_be_obtained))
			end
			local possessionView = tpm.settings.scroll_box_views["items_in_possession"]
			if possessionView and possessionView.SetDataProvider then
				possessionView:SetDataProvider(CreateDataProvider(tpm.player.items_in_possession))
			end
			if suppressReload then
				if tpm.MarkAvailabilityDirty then
					tpm:MarkAvailabilityDirty("itemTeleports")
				end
			else
				tpm:UpdateAvailableItemTeleports()
				if tpm.RequestReload then
					tpm:RequestReload(false, 0)
				else
					tpm:ReloadFrames()
				end
			end
			return true
		end
	end
	return false
end
