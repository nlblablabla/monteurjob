fx_version 'cerulean'
game 'gta5'

version '1.0.0'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

client_script {
    'client/*.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'
