script_name("DixelMod Loader")
script_version("1.0")

local moonloader = require 'moonloader'
local encoding = require 'encoding'
local lfs = require 'lfs'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local http = require 'requests'
local download_url = "https://dreakrek.github.io/dixelmod/" -- URL base de GitHub Pages
local version_url = download_url .. "version.txt" -- URL del archivo de versión
local mod_folder = getGameDirectory() .. "\\moonloader\\mods\\dixelmod"

function main()
    repeat wait(100) until isSampAvailable()
    sampAddChatMessage(u8"DixelMod Loader iniciado.", 0x73b461) -- Mensaje de depuración
    
    if not doesDirectoryExist(mod_folder) then
        createDirectory(mod_folder)
        sampAddChatMessage(u8"Directorio de DixelMod creado.", 0x73b461) -- Mensaje de depuración
    else
        sampAddChatMessage(u8"Directorio de DixelMod ya existe.", 0x73b461) -- Mensaje de depuración
    end

    checkVersion()

    while true do
        wait(0)
    end
end

function checkVersion()
    sampAddChatMessage(u8"Verificando la versión del mod...", 0x73b461) -- Mensaje de depuración
    local response = http.get(version_url)

    if response and response.status_code == 200 then
        sampAddChatMessage(u8"Conexión establecida, verificando versión...", 0x73b461) -- Mensaje de depuración
        
        local version_info = response.text
        local remote_version = version_info:match("version=(%S+)")
        local file_list = version_info:match("files=(.*)")

        if remote_version and file_list then
            sampAddChatMessage(u8"Versión remota: " .. remote_version, 0x73b461) -- Mensaje de depuración

            local local_version_file = mod_folder .. "\\version.txt"
            local local_version = "0.0"

            if doesFileExist(local_version_file) then
                local file = io.open(local_version_file, "r")
                local_version = file:read("*line")
                file:close()
                sampAddChatMessage(u8"Versión local encontrada: " .. local_version, 0x73b461) -- Mensaje de depuración
            else
                sampAddChatMessage(u8"No se encontró la versión local, descargando archivos.", 0x73b461) -- Mensaje de depuración
            end

            if local_version ~= remote_version then
                sampAddChatMessage(u8"Actualizando DixelMod a la versión " .. remote_version, 0x73b461) -- Mensaje de depuración

                local files = {}
                for file in file_list:gmatch("([^,]+)") do
                    file = file:gsub("^%s*(.-)%s*$", "%1") -- Elimina espacios en blanco alrededor
                    if #file > 0 then
                        table.insert(files, file)
                    end
                end

                -- Descargamos todos los archivos independientemente
                for _, file in ipairs(files) do
                    downloadFile(download_url .. file, mod_folder .. "\\" .. file)
                end
                
                -- Actualizamos el archivo de versión local
                local file = io.open(local_version_file, "w")
                file:write(remote_version)
                file:close()
            else
                sampAddChatMessage(u8"DixelMod ya está actualizado.", 0x73b461)
            end
        else
            sampAddChatMessage(u8"Error al procesar la versión remota o la lista de archivos.", 0x73b461)
        end
    else
        sampAddChatMessage(u8"Error al verificar la versión del mod o no se pudo conectar al servidor.", 0x73b461)
    end
end

function downloadFile(url, save_path)
    local response = http.get(url)
    if response and response.status_code == 200 then
        createDirectoryRecursively(save_path) -- Crea directorios si es necesario
        local file = io.open(save_path, "wb")
        file:write(response.body)
        file:close()
        sampAddChatMessage(u8"Descargado: " .. url, 0x73b461)
    else
        sampAddChatMessage(u8"Error al descargar: " .. url, 0x73b461)
    end
end

function createDirectoryRecursively(filePath)
    local path = filePath:match("(.+)[/\\].-$") -- Obtiene el directorio base
    local current_path = ""
    for folder in path:gmatch("[^\\/]+") do
        current_path = current_path .. folder .. "\\"
        if not doesDirectoryExist(current_path) then
            createDirectory(current_path)
            sampAddChatMessage(u8"Directorio creado: " .. current_path, 0x73b461) -- Mensaje de depuración
        end
    end
end
