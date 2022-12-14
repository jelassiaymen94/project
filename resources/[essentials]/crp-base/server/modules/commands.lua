CRP.Commands, CRP.CommandsList = {}, {
	{ 'ooc', 'Apenas utilize este comando em casos "extremos".', nil, function(source, args)
		local user = GetCharacter(source)

		args = table.concat(args, ' ')

		if isEmpty(args) then
				return
		end

		TriggerClientEvent('chat:addMessage', -1, { color = {255, 255, 255}, templateId = 'blue', args = { user.getFullName(), args }})
	end, {{ name = 'mensagem' }}},
	{ 'me', 'Envie uma mensagem.', nil, function(source, args)
        args = table.concat(args, ' ')

        if isEmpty(args) then
            return
        end

        TriggerClientEvent('crp-base:displayMe', -1, source, args)
    end, {{ name = 'mensagem' }}},
    { 'dinheiro', 'Utilize este comando para conseguir ver o seu dinheiro.', nil, function(source, args)
        TriggerClientEvent('crp-ui:setMoneyStatus', source, { status = true, time = 5000 })
    end, {}},
    { 'recrutar', 'Recrute uma pessoa para a sua organização.', nil, function(source, args)
        --- TODO: COMMAND
	end, {{ name = 'id do jogador' }, { name = 'cargo' }},
	{ 'darchave', '', nil, function(source, args)
		TriggerClientEvent('crp-vehicles:giveKey', source)
	end, {}}},
	{ 'lugar', '', nil, function(source, args)
		TriggerClientEvent('crp-vehicles:changeSeat', source, tonumber(args[1]))
	end, {}}
}

function CRP.Commands:RegisterCommands()
	for i = 1, #CRP.CommandsList do
		RegisterCommand(CRP.CommandsList[i][1], CRP.CommandsList[i][4], false)
	end
end

function CRP.Commands:AddSugestion(source, commandData, characterJob)
	local necessaryPerms = commandData[3]

	if necessaryPerms then
		local foundPerm = false

		for i = 1, #necessaryPerms do
			if not necessaryPerms[i] == characterJob then
				return
			end

			foundPerm = true
			break
		end

		if not foundPerm then
			return
		end
	end

	TriggerClientEvent('chat:addSuggestion', source, '/' .. commandData[1], commandData[2], commandData[5])
end

CRP.Commands:RegisterCommands()