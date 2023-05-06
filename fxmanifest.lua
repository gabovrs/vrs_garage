fx_version 'adamant'

game 'gta5'

description 'Garage system by VRS'
lua54 'yes'
version '1.0'

author 'VRS'

shared_scripts { 
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/config.lua'
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

files {
	'locales/*.json'
}