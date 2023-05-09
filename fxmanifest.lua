fx_version 'adamant'

game 'gta5'

description 'Simple Garage System'
lua54 'yes'
version 'v1.0.0'

author 'VRS'

shared_scripts { 
	'@ox_lib/init.lua',
	'shared/config.lua'
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua'
}

files {
	'locales/*.json'
}