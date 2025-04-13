fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'rivickys | discord.gg/BSjPSbChN3'
description 'EASY ESX JOB CREATOR'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}