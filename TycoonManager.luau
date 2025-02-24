local templateplot = workspace:WaitForChild("TemplatePlot")
local plots = workspace.Plots

local function GetPlot(player)
	for _, plot in plots:GetChildren() do
		local owner = plot:GetAttribute('owner')
		if not owner then continue end
		if owner ~= player.UserId then continue end
		return plot
	end
end


local function getItemfromTemplatePlot(ItemId)
	for _, item in templateplot.Items:GetChildren() do
		if item:GetAttribute('ID') == ItemId then
			return item
		end
	end
end
local function getButtonfromTemplatePlot(ItemId)
	for _, item in templateplot.Buttons:GetChildren() do
		if item:GetAttribute('ID') == ItemId then
			return item
		end
	end
end

local function getButtonbyIdofItemtoUnlock(player, ItemId)
	local plot = GetPlot(player)
	print(plot)
	if not plot then return end

	for _, button in plot.Buttons:GetChildren() do
		local idofitemtounlock = button:GetAttribute('ID')
		if not idofitemtounlock then continue end

		if ItemId == idofitemtounlock then
			return button
		end	
	end
end

local function loadItems(player, ItemsIdsTable)

	local plot = GetPlot(player)
	for _, itemId in ItemsIdsTable do
		local item = getItemfromTemplatePlot(itemId)
		if not item then continue end

		local itemclone = item:Clone()
		local ItemCframe

		if itemclone:IsA('Model') then
			ItemCframe = itemclone:GetPivot()
		elseif itemclone:IsA('BasePart') then
			ItemCframe = itemclone.CFrame;
		end


		local Itemrelative = templateplot.CFrame:ToObjectSpace(ItemCframe)
		local worldcframeofNewPlot = plot.CFrame:ToWorldSpace(Itemrelative)

		if itemclone:IsA('Model') then
			itemclone:PivotTo(worldcframeofNewPlot)
		elseif itemclone:IsA('BasePart') then
			itemclone.CFrame = worldcframeofNewPlot;
		end;

		itemclone.Parent = plot.itemsfolder;

		for _, scriptObject in itemclone:GetDescendants() do
			if scriptObject:IsA('BaseScript') then
				scriptObject.Enabled = true
			end
		end
	end
end

script:WaitForChild('CreatePlot').Event:Connect(function(player, ItemsIdsTable)
	for _, plot in plots:GetChildren() do
		if plot:GetAttribute("taken") then continue end
		plot:SetAttribute('taken', true)
		plot:SetAttribute('owner', player.UserId)

		print('plot has been given to '..player.Name..'!')

		local itemsfolder = Instance.new("Folder")
		itemsfolder.Name = "itemsfolder"
		itemsfolder.Parent = plot

		local templatebuttons = templateplot.Buttons:Clone()
		local templateitems = templateplot.Items

		loadItems(player, ItemsIdsTable)

		for _, button in templatebuttons:GetChildren() do
			if table.find(ItemsIdsTable, button:GetAttribute("idofItemToUnlock")) then continue end

			local relativeCframe = templateplot.CFrame:ToObjectSpace(button.CFrame)	
			button.CFrame = plot.CFrame:toWorldSpace(relativeCframe)

			if button:GetAttribute("Hidden", true) then
				button.Transparency = 1
				button.CanCollide = false
				button.BillboardGui.Enabled = false
			end

			button.Touched:Connect(function(Hit)
				if button:GetAttribute("Hidden", true) then return end
				local player = game.Players:GetPlayerFromCharacter(Hit.Parent)
				if not player then return end

				if plot:GetAttribute('owner') ~= player.UserId then 
					print("identityfraud") return end

				local itemtoUnlock = button:GetAttribute('ID')
				local destroyed = false
				for _, v in pairs(itemsfolder:GetChildren()) do
					if v:GetAttribute('ID') == itemtoUnlock then
						button:Destroy()
						destroyed = true
					end
				end
				if destroyed then return end
				print(itemtoUnlock)
				if not itemtoUnlock then print('you retard forgot to add a id attribute') return end

				local price = button:GetAttribute('price')
				if price then
					if player.leaderstats.Cash.Value < price then
						warn('you cant afford this monkey')
						return
					end


					player.leaderstats.Cash.Value -= price
				end

				local ButtonIdstoAppearOnceBought = button:GetAttribute("ButtonIdstoAppearOnceBought")
				print(ButtonIdstoAppearOnceBought)

				if ButtonIdstoAppearOnceBought then
					local ItemIds = string.split(ButtonIdstoAppearOnceBought, ",")
					print(ButtonIdstoAppearOnceBought)

					for _, ItemId in ItemIds do
						ItemId = tonumber(ItemId)
						print(ItemId)
						local button = getButtonbyIdofItemtoUnlock(player, ItemId)
						print(button)
						if not button then print("sadsa") continue end

						button.Transparency = 0
						button.CanCollide = true
						button:SetAttribute("Hidden", nil)
						button.BillboardGui.Enabled = true
					end
				end
				for _, item in templateitems:GetChildren() do

					if item:GetAttribute('ID') ~= itemtoUnlock or item:GetAttribute('ID') == 0 then continue end

					local ItemCframe
					local itemclone = item:Clone()

					if itemclone:IsA('Model') then
						ItemCframe = itemclone:GetPivot()
					elseif itemclone:IsA('BasePart') then
						ItemCframe = itemclone.CFrame
					end

					local Itemrelative = templateplot.CFrame:ToObjectSpace(ItemCframe)
					local worldcframeofNewPlot = plot.CFrame:ToWorldSpace(Itemrelative)
					if itemclone:IsA('Model') then
						itemclone:PivotTo(worldcframeofNewPlot)
					elseif itemclone:IsA('BasePart') then
						itemclone.CFrame = worldcframeofNewPlot
					end

					for _, scriptObject in itemclone:GetDescendants() do
						if scriptObject:IsA('BaseScript') then
							scriptObject.Enabled = true
						end
					end

					itemclone.Parent = itemsfolder
					game.ServerScriptService.Data.ItemUnlocked:Fire(player, itemtoUnlock)
				end
			end)
			button:Destroy()
		end

		templatebuttons.Parent = plot

		break
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	for _, plot in plots:GetChildren() do
		if not plot:GetAttribute('owner') then continue end
		if plot:GetAttribute('owner') ~= player.UserId then continue end
		plot:SetAttribute('taken', nil)
		plot:SetAttribute('owner', nil)
		break
	end
end)
