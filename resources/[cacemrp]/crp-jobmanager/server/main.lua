local inService = {}

AddEventHandler('crp-jobmanager:activateService', function(name)
	inService[name] = {}
end)

RegisterServerEvent('crp-jobmanager:disableService')
AddEventHandler('crp-jobmanager:disableService', function(name)
    inService[name][source] = false
    
    Citizen.Wait(1000)

    if name == 'medic' then
    	for k, v in pairs(inService['police']) do
			TriggerClientEvent('esx-policejob:updateMedicBlip', k)
		end
    end

    for k, v in pairs(inService[name]) do
        TriggerClientEvent('esx-' .. name .. 'job:updateBlip', k)
    end
end)

RegisterServerEvent('crp-jobmanager:enableService')
AddEventHandler('crp-jobmanager:enableService', function(name)
    inService[name][source] = true
    
    Citizen.Wait(1000)

    if name == 'medic' then
    	for k, v in pairs(inService['police']) do
			TriggerClientEvent('esx-policejob:updateMedicBlip', k)
		end
    end

    for k, v in pairs(inService[name]) do
        TriggerClientEvent('esx-' .. name .. 'job:updateBlip', k)
    end
end)

TriggerEvent('crp-base:addCommand', 'recrutar', function(source, args, user)
    if source == tonumber(args[1]) then 
        return 
    end

    local user = exports['crp-base']:GetCharacter(source)
    local userJob = user.getJob()

    if not exports['crp-base']:CheckIfHigherRank(userJob.name, userJob.grade) then
        print('doesnt have permision')
        return
    end

    args[1] = tonumber(args[1])
    args[2] = tonumber(args[2])

    if args[1] and args[2] then
        if args[2] >= userJob.grade then 
            print('trying to set null rank or leader rank')
            return 
        end

        local target = exports['crp-base']:GetCharacter(args[1])

        if target then
            target.setJob(userJob.name, args[2])

            print('job setted')
        else
            print('player not online')
        end
    else
        print('invalid usage')
    end
end, { help = 'Recrute uma pessoa para a sua organização.', params = {{ name = 'id do jogador' }, { name = 'cargo' }}})