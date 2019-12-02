local Inventories = {}

AddEventHandler('crp-inventory:moveItem', function(source, data, callback)
    if string.find(data.currentInventory, 'drop') then
        CheckIfInventoryExists(data.currentInventory, data.coords)
    end

    exports.ghmattimysql:scalar('SELECT count FROM inventory WHERE name = @name AND item = @item AND slot = @slot;', {
        ['@name'] = data.lastInventory, ['@item'] = data.id, ['@slot'] = data.lastSlot
    }, function(count)
        if count and count >= data.quantity then
            if (count - data.quantity) > 0 then
                exports.ghmattimysql:execute('UPDATE inventory SET count = count - @quantity WHERE name = @name AND item = @item AND slot = @slot;', 
                { ['@quantity'] = data.quantity, ['@name'] = data.lastInventory, ['@item'] = data.id, ['@slot'] = data.lastSlot })

                exports.ghmattimysql:execute('INSERT INTO inventory (count, item, slot, name) VALUES (@quantity, @item, @slot, @name);', 
                { ['@quantity'] = data.quantity, ['@name'] = data.currentInventory, ['@item'] = data.id, ['@slot'] = data.currentSlot })

                callback({ status = true, splitItem = true })
            else
                exports.ghmattimysql:execute('UPDATE inventory SET name = @name, slot = @slot WHERE name = @lastname AND item = @item AND slot = @lastslot;', { ['@quantity'] = data.quantity, 
                ['@name'] = data.currentInventory, ['@lastname'] = data.lastInventory, ['@item'] = data.id, ['@slot'] = data.currentSlot, ['@lastslot'] = data.lastSlot }, function(done)
                    if done then
                        if string.find(data.lastInventory, 'drop') then
                            exports.ghmattimysql:execute('SELECT * FROM inventory WHERE name = @lastname;', { ['@lastname'] = data.lastInventory }, function(result)
                                if not result[1] then
                                    DeleteEmptyInventory(data.lastInventory)
                                end
                                
                                callback({ status = true, splitItem = false })
                            end)
                        else
                            callback({ status = true, splitItem = false })
                        end
                    end
                end)
            end
        else
            print('item not found')
            callback({ status = false })
        end
	end)
end)

AddEventHandler('crp-inventory:swapItems', function(source, data, callback)
    exports.ghmattimysql:scalar('SELECT count FROM inventory WHERE name = @name AND item = @item AND slot = @slot;', {
        ['@name'] = data.lastInventory, ['@item'] = data.item, ['@slot'] = data.lastSlot
    }, function(count)
        if count and count >= data.quantity then
            exports.ghmattimysql:scalar('SELECT count FROM inventory WHERE name = @name AND item = @item AND slot = @slot;', {
                ['@name'] = data.currentInventory, ['@item'] = data._item, ['@slot'] = data.currentSlot
            }, function(_count)
                if _count then
                    if data.canStack and (count - data.quantity) > 0 then
                        exports.ghmattimysql:execute('UPDATE inventory SET count = count - @quantity WHERE name = @name AND item = @item AND slot = @slot;', 
                        { ['@quantity'] = data.quantity, ['@name'] = data.lastInventory, ['@item'] = data.item, ['@slot'] = data.lastSlot })
            
                        exports.ghmattimysql:execute('UPDATE inventory SET count = count + @quantity WHERE name = @name AND item = @item AND slot = @slot;', 
                        { ['@quantity'] = data.quantity, ['@name'] = data.currentInventory, ['@item'] = data._item, ['@slot'] = data.currentSlot })

                        callback({ status = true, stackItems = true, delete = false })
                    else
                        local status = { status = false }

                        if data.canStack then
                            exports.ghmattimysql:execute('DELETE FROM inventory WHERE name = @name AND item = @item AND slot = @slot;', 
                            { ['@name'] = data.lastInventory, ['@item'] = data.item, ['@slot'] = data.lastSlot })
            
                            exports.ghmattimysql:execute('UPDATE inventory SET count = count + @quantity WHERE name = @name AND item = @item AND slot = @slot;', 
                            { ['@quantity'] = data.quantity, ['@name'] = data.currentInventory, ['@item'] = data._item, ['@slot'] = data.currentSlot })

                            status = { status = true, stackItems = true, delete = true }
                        elseif (count - data.quantity) == 0 then
                            exports.ghmattimysql:execute('UPDATE inventory SET name = @_name, slot = @_slot  WHERE name = @name AND item = @item AND slot = @slot;', 
                            { ['@_name'] = data.lastInventory, ['@_slot'] = data.lastSlot, ['@name'] = data.currentInventory, ['@item'] = data._item, ['@slot'] = data.currentSlot })

                            exports.ghmattimysql:execute('UPDATE inventory SET name = @_name, slot = @_slot  WHERE name = @name AND item = @item AND slot = @slot;', 
                            { ['@_name'] = data.currentInventory, ['@_slot'] = data.currentSlot, ['@name'] = data.lastInventory, ['@item'] = data.item, ['@slot'] = data.lastSlot })

                            status = { status = true, swapItems = true }
                        end
                        
                        callback(status)
                    end
                else
                    callback({ status = false })
                    print('not found crl')
                end
            end)
        else
            print('item not found')
            callback({ status = false })
        end
	end)
end)

AddEventHandler('crp-inventory:getInventory', function(source, id, callback)
    local character = exports['crp-base']:GetCharacter(source)

    if character.getCharacterID() == id then 
        exports.ghmattimysql:execute('SELECT * FROM inventory WHERE name = @name;', {
            ['@name'] = 'character-' .. id
        }, function(result)
            callback(result)
        end)
    else
        print('player tried to acess another player inventory')
    end
end)

AddEventHandler('crp-inventory:getInventories', function(source, data, callback)
    local character = exports['crp-base']:GetCharacter(source)

    if character.getCharacterID() == data.id then 
        exports.ghmattimysql:execute('SELECT * FROM inventory WHERE name = @name;', { ['@name'] = 'character-' .. data.id }, function(result)
            exports.ghmattimysql:execute('SELECT * FROM inventory WHERE name = @name;', { ['@name'] = data.inventory }, function(_result)
                callback({ player = result, secondary = _result})
            end)
        end)
    else
        print('player tried to acess another player inventory')
    end
end)

function CheckIfInventoryExists(inventory, coords)
    if next(Inventories) == nil then
        table.insert(Inventories, { name = inventory, coords = coords })

        TriggerClientEvent('crp-inventory:updateInventories', -1, Inventories)
        return
    end

    local found = false

    for i = 1, #Inventories, 1 do
        if CompareCoords(Inventories[i].coords, coords) or Inventories[i].name == inventory then
            found = true
            return
        end
    end

    if not found then
        table.insert(Inventories, { name = inventory, coords = coords })

        TriggerClientEvent('crp-inventory:updateInventories', -1, Inventories)
    end
end

function DeleteEmptyInventory(name)
    for i = 1, #Inventories, 1 do
        if Inventories[i].name == name then
            table.remove(Inventories, i)

            TriggerClientEvent('crp-inventory:updateInventories', -1, Inventories)
        end
    end
end

function CompareCoords(coords, newcoords)
    if (coords.x == newcoords.x and coords.y == newcoords.y and coords.z == newcoords.z) then
        return true
    end
    return false
end