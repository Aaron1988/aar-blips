fx_version 'cerulean'
game 'gta5'

author 'Aaron'
description 'Blip Manager for ESX and QBCore'
version '1.0.0'

shared_scripts {
    'framework.lua',
    'config.lua',
    'blips.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    '/server:5848',
    '/onesync',
}

lua54 'yes'