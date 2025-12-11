local mod_data = assert(prototypes.mod_data["gift-boxes"].data, "ERROR: mod-data for gift boxes not found")

local total_category_weight = 0
local int_max_category = {}
local int_max_per_category = {}
local total_weight = {}
local results = {}
for c_name, category in pairs(mod_data) do
  total_category_weight = total_category_weight + 1 --(category.weight or 1)
  int_max_category[c_name] = total_category_weight
  int_max_per_category[c_name] = {}
  results[c_name] = category.results
  total_weight[c_name] = 0
  for index, result in pairs(category.results) do
    total_weight[c_name] = total_weight[c_name] + 1--(result.weight or 1)
    int_max_per_category[c_name][index] = total_weight[c_name]
  end
end

local function get_category(int)
  for category, max_int in pairs(int_max_category) do
    if int <= max_int then
      return category
    end
  end
end

local function get_result(results, int)
  for index, max_int in pairs(results) do
    if int <= max_int then
      return index
    end
  end
end

script.on_event(defines.events.on_player_crafted_item, function(event)
  if event.recipe.name ~= "open-gift-box" then return end
  event.item_stack.clear()
  local player = game.get_player(event.player_index)
  local rand1 = math.random(1, total_category_weight)
  local category = get_category(rand1)
  local rand2 = math.random(1, total_weight[category])
  local result_index = get_result(int_max_per_category[category], rand2)
  local result = results[category][result_index]
  player.print(result.message or {"gift-box-category-notice." .. category})
  if result.type == "item" then
    player.print({"gift-box-messages.inserted", result.amount or 1, "[item=" .. result.name .. "]"})
    player.insert{
      name = result.name,
      quality = result.quality,
      count = result.amount or 1
    }
  elseif result.type == "create-entity" then
    -- player.print({"gift-box-messages.created", result.amount or 1, "[entity=" .. result.name .. "]"})
    local params = result.parameters or {}
    params.name = result.name
    params.position = {
      player.position.x + (result.position_offset and (result.position_offset.x or result.position_offset[1]) or 0),
      player.position.y + (result.position_offset and (result.position_offset.y or result.position_offset[2]) or 0)
    }
    params.force = result.force or nil
    params.target = player.character or nil
    for _ = 1, result.amount or 1 do
      player.surface.create_entity(params)
    end
  end
end)