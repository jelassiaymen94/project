fx_version 'cerulean'

game 'gta5'

dependecies {
	'crp-lib', 'crp-ui', 'crp-binds'
}

client_scripts {
	'@crp-lib/client/main.lua',
	'client/util.lua',
    'client/main.lua'
}

shared_script '@crp-lib/shared/util.lua'