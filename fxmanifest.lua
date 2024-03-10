fx_version 'cerulean'
game 'gta5'

author 'Petris Services <github.com/PetrisGR>'
description 'Taxi NPC Mission'
version '1.0.0'

lua54 'yes'

server_scripts {
    'config.lua',
    'server/main.lua'
}

server_export 'StartTaxiMission'
server_export 'StopTaxiMission'

client_scripts {
    'depedency/clm_ProgressBar/main.lua',
    'depedency/clm_ProgressBar/class.lua',
    'client/main.lua'
}