fx_version 'bodacious'

game 'gta5'

ui_page 'nui/dist/index.html'

client_scripts {
    '@crp-base/shared.lua',
    '@crp-base/client/modules/rpc.lua',
    'client/main.lua',
    'client/modules/character.lua',
    'client/modules/cash.lua',
    'client/modules/hud.lua'
}

server_scripts {
    '@crp-base/shared.lua',
    '@crp-base/server/modules/rpc.lua',
    '@crp-base/server/modules/utils.lua',
    '@crp-base/server/modules/database.lua',
    'server/modules/character.lua',
    'server/database.lua',
    'server/main.lua'
}

files {
    'nui/dist/index.html',
    'nui/dist/js/app.js',
    'nui/dist/js/chunk-vendors.js',
    'nui/dist/fonts/pdown.ttf',
    'nui/dist/img/compass.png',
    'nui/dist/img/seatbelt.svg',
    'nui/dist/img/speed-limiter.svg',
    'nui/dist/css/app.css',
    'nui/dist/css/chunk-vendors.css'
}