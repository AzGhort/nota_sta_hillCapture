local sensorInfo = {
	name = "HillPoints",
	desc = "Conquers all hill-points.",
	author = "AzGhort",
	date = "2018-05-13",
	license = "notAlicense",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

-- @description return current wind statistics
return function()
	local points = {}
	local counter = 1
	local height = 191

	-- find all points higher than 191
	for i=1,Game.mapSizeX,50 do
		for j=1,Game.mapSizeZ,50 do
			if (Spring.GetGroundHeight(i,j) > height - 1) then
				points[counter] = {i,j}
				counter = counter + 1
			end
		end
	end

	local pruned = { }
	counter = 1
	-- prune points from same hills (euclidean distance less than 300)
	for i,point in ipairs(points) do
		local unique = 1
		for j,point2 in ipairs(pruned) do
			local dist = math.sqrt((point[1]-point2[1])*(point[1]-point2[1]) + (point[2]-point2[2])*(point[2]-point2[2]))
			if (dist < 300) then
				unique = 0
			end
		end
		if (unique == 1) then
			pruned[counter] = points[i]
			local y = Spring.GetGroundHeight(points[i][1], points[i][2])
			Spring.GiveOrderToUnit(units[counter], CMD.MOVE, {points[i][1], y, points[i][2]}, {})
			counter = counter + 1
		end
  end

	return pruned
end
