--[[

Description:
A Universal Parallax Module that can be used across many games
handles all the Parallax work for you. Only Vertical

Variables:
- parallaxManager.layers = {} | Holds all the parallax layers created

Functions:
- parallaxManager.createNewLayer(options) | options = {depth, {assets}, layerType(screen, left, right, or random), randomizeOrder, minimumSpacing, maximumSpacing, xOffset and yOffset} | Creates a new Parallax Layer based on the parameters inputed.

- parallaxManager.setPosition(value) | Value is the x position | Moves all the layers and assets according to the value given.

- parallaxManager.checkObjects(difference) | Automatic Function (Do Not Call It Manually) | Object Pooling, Once the object is off the screen it moves it to the other side again and if randomize is wanted it will be placed according to minimum spacing and maximum spacing.

- parallaxManager.shuffleTable(t) | t is a table | shuffles the contents of the tables randomly.

--]]

local parallaxManager = {}

--Holds all the layers to parallax
parallaxManager.layers = {}

--Create New Layer Function
function parallaxManager.createNewLayer(options)
	local layer = display.newGroup()

	--Sets Layer Depth to the value inputed or default 0
	layer.depth = options.depth or 0
	--Sets Layer Assets to Asset list inputed
	layer.assets = options.assets
	--Sets Type of Asset (Screen, Left, Right, or Random)
	layer.layerType = options.layerType
	--Sets Layer Offsets to the value inputed or default 0
	layer.xOffset = options.xOffset or 0
	layer.yOffset = options.yOffset or 0
	--Sets Layer Randomize order to the value inputed or default false
	layer.randomizeOrder = options.randomizeOrder or false
	--Set Layer Spacing Values or default 0
	layer.minimumSpacing = options.minimumSpacing or 0
	layer.maximumSpacing = options.maximumSpacing or 0

	--Objects
	layer.objects = {}

	--Randomize Assets if randomize order
	if layer.randomizeOrder then
		parallaxManager.shuffleTable(layer.assets)
	end

	--Go Through all the assets
	for k in pairs(layer.assets) do
		--Randomize Spacing
		local spacing = math.random(layer.minimumSpacing, layer.maximumSpacing)
		--Spawn the asset
		local object = display.newImage(layer.assets[k])
		--Set the spacing
		object.y = (object.height * k) + spacing
		--Apply settings according to type
		if layer.layerType == "screen" then object.x = display.contentCenterX end
		if layer.layerType == "left" then object.x = object.contentWidth * 0.5 end
		if layer.layerType == "right" then object.x = display.contentWidth - (object.contentWidth * 0.5) end
		if layer.layerType == "random" then 
			local xValue = math.random(object.contentWidth * 0.5, display.contentWidth - (object.contentWidth * 0.5))
			object.x = xValue
		end
		--Add it to the objects
		layer.objects[#layer.objects + 1] = object
		--Insert it into the layer
		layer:insert(object)
	end

	--Apply xOffset and yOffset to the layer
	layer.y = layer.y + layer.yOffset

	--Add Layer into Layers Table
	parallaxManager.layers[#parallaxManager.layers+1] = layer

	return layer
end

--Previous value
local prevValue = 0

--Set Position for Parallax
function parallaxManager.setPosition(value)

	--Difference of the value passed and previous value
	local difference = value - prevValue

	--Goes through all the assets within the layers
	for k in pairs(parallaxManager.layers) do
		for v in pairs(parallaxManager.layers[k].objects) do
			--Update Layer Assets Position
			parallaxManager.layers[k].objects[v].y = parallaxManager.layers[k].objects[v].y-(difference * parallaxManager.layers[k].depth)
		end
	end

	--Sets Previous Value to Current Value
	prevValue = value

	--Checks if objects are off the screen
	parallaxManager.checkObjects(difference)
end

--Check if new object needed | Object Pooling
function parallaxManager.checkObjects(difference)
	for k in pairs(parallaxManager.layers) do
		for v in pairs(parallaxManager.layers[k].objects) do
			--Checks if Asset is off the screen on the bottom and is moving down
			if difference < 0 and parallaxManager.layers[k].objects[v].y > display.contentHeight - parallaxManager.layers[k].objects[v].contentHeight*0.5 then
				--Place the asset back on the left
				parallaxManager.layers[k].objects[v].y = -display.contentHeight - parallaxManager.layers[k].objects[v].contentHeight*0.5

				--Check if randomize is wanted
				if parallaxManager.layers[k].randomizeOrder then
					--Randomize Spacing
					local spacing = math.random(parallaxManager.layers[k].minimumSpacing, parallaxManager.layers[k].maximumSpacing)
					parallaxManager.layers[k].objects[v].y = parallaxManager.layers[k].objects[v].y - spacing
				end

				--If layer type is random, randomize it again
				if parallaxManager.layers[k].layerType == "random" then 
					local xValue = math.random(parallaxManager.layers[k].objects[v].contentWidth * 0.5, display.contentWidth - (parallaxManager.layers[k].objects[v].contentWidth * 0.5))
					parallaxManager.layers[k].objects[v].x = xValue
				end
				
			--Checks if Asset is off the screen on the top and is moving up
			elseif difference > 0 and parallaxManager.layers[k].objects[v].y < -display.contentHeight - parallaxManager.layers[k].objects[v].contentHeight*0.5 then
				--Place the asset back on the right
				parallaxManager.layers[k].objects[v].y = display.contentHeight + parallaxManager.layers[k].objects[v].contentHeight*0.5

				--Check if randomize is wanted
				if parallaxManager.layers[k].randomizeOrder then
					--Randomize Spacing
					local spacing = math.random(parallaxManager.layers[k].minimumSpacing, parallaxManager.layers[k].maximumSpacing)
					parallaxManager.layers[k].objects[v].y = parallaxManager.layers[k].objects[v].y + spacing
				end

				--If layer type is random, randomize it again
				if parallaxManager.layers[k].layerType == "random" then 
					local xValue = math.random(parallaxManager.layers[k].objects[v].contentWidth * 0.5, display.contentWidth - (parallaxManager.layers[k].objects[v].contentWidth * 0.5))
					parallaxManager.layers[k].objects[v].x = xValue
				end
			end
		end
	end
end

--Randomize a table
function parallaxManager.shuffleTable( t )
	--Sets rand to randomization function
    local rand = math.random
    --If the parameter passed is not a table display an error message 
    assert( t, "shuffleTable() expected a table, got nil" )
    --Get the length of the table
    local iterations = #t
    local j
    
    --Shuffle the table
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

return parallaxManager