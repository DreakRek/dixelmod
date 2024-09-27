script_name("DixelMod Loader")
script_version("1.0")

local moonloader = require 'moonloader'
local json = require 'json'
local http = require 'requests'
local download_url = "https://dreakrek.github.io/dixelmod/" -- URL base de GitHub Pages
local version_url = download_url .. "version.json" -- URL del archivo de versión
local mod_folder = getGameDirectory() .. "\\moonloader\\mods\\dixelmod"

function main()
    if not doesDirectoryExist(mod_folder) then
        createDirectory(mod_folder)
    end

    checkVersion()

    while true do
        wait(0)
    end
end

function checkVersion()
    local response = http.get(version_url)
    if response.status_code == 200 then
        local remote_data = json.decode(response.text)
        local remote_version = remote_data.version
        local local_version_file = mod_folder .. "\\version.txt"
        local local_version = "0.0"

        if doesFileExist(local_version_file) then
            local file = io.open(local_version_file, "r")
            local_version = file:read("*all")
            file:close()
        end

        if local_version ~= remote_version then
            downloadFiles(remote_data.files)
            local file = io.open(local_version_file, "w")
            file:write(remote_version)
            file:close()
        else
            print("DixelMod está actualizado.")
        end
    else
        print("Error al verificar la versión del mod.")
    end
end

function downloadFiles(files)
    for category, file_list in pairs(files) do
        for _, file in ipairs(file_list) do
            local file_url = download_url .. file
            local save_path = mod_folder .. "\\" .. file
            downloadFile(file_url, save_path)
        end
    end
    print("Todos los archivos del mod han sido descargados y actualizados.")
end

function downloadFile(url, save_path)
    local response = http.get(url)
    if response.status_code == 200 then
        createDirectoryRecursively(save_path) -- Crea directorios si es necesario
        local file = io.open(save_path, "wb")
        file:write(response.body)
        file:close()
        print("Descargado: " .. url)
    else
        print("Error al descargar: " .. url)
    end
end

function createDirectoryRecursively(filePath)
    local path = filePath:match("(.+)[/\\].-$") -- Obtiene el directorio base
    local current_path = ""
    for folder in path:gmatch("[^\\/]+") do
        current_path = current_path .. folder .. "\\"
        if not doesDirectoryExist(current_path) then
            createDirectory(current_path)
        end
    end
end
