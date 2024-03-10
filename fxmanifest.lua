fx_version "cerulean"

description "siren"
version '1.0.0'

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

ui_page 'web/build/index.html'

client_scripts {
  "client/utils.lua",
  "client/client.lua",
  "shared/main.lua"
}

server_script "server/**/*"

files {
  'web/build/index.html',
  'web/build/**/*',
}

dependencies {
  '/server:5104',
  '/onesync',
}
