local http = require("socket.http")
local lfs = require("lfs")

-- URL correcta del repositorio de GitHub
local versionURL = "https://raw.githubusercontent.com/DreakRek/dixelmod/main/version.txt"  -- URL del archivo de versión
local modURL = "https://raw.githubusercontent.com/DreakRek/dixelmod/main/mod.lua" -- URL del archivo del mod

-- Rutas locales
local downloadPath = getGameDirectory() .. "\\modloader\\downloads\\"
local localVersionFile = downloadPath .. "version.txt"
local localModFile = downloadPath .. "mod.lua"

-- Función para descargar el archivo
function downloadFile(url, destination)
    local response, status = http.request(url)
    print("Estado de descarga: ", status) -- Mostrar el código de estado HTTP en la consola de MoonLoader
    if status == 200 then
        local file = io.open(destination, "wb")
        if file then
            file:write(response)
            file:close()
            print("Archivo descargado correctamente en: " .. destination)
            return true
        else
            print("Error al crear el archivo en la ruta especificada.")
            return false
        end
    else
        print("Error al descargar archivo. Código de estado: ", status) -- Mostrar el error de estado
        return false
    end
end

-- Función para leer la versión del archivo
function readVersion(filePath)
    local file = io.open(filePath, "r")
    if file then
        local version = file:read("*all")
        file:close()
        return version
    end
    return nil
end

-- Función principal
function main()
    repeat wait(500) until isSampAvailable()
     
    sampAddChatMessage("Verificando actualizaciones del mod...", 0x73b461)

    -- Verifica si la carpeta de descarga existe, de lo contrario, la crea
    if not lfs.attributes(downloadPath, "mode") then
        lfs.mkdir(downloadPath)
    end

    -- Descargar el archivo de versión del repositorio
    if downloadFile(versionURL, localVersionFile) then
        sampAddChatMessage("Archivo de versión descargado correctamente.", 0x73b461)
        
        -- Leer la versión remota descargada
        local remoteVersion = readVersion(localVersionFile)
        print("Versión remota encontrada: " .. tostring(remoteVersion))

        -- Leer la versión local (si existe)
        local localVersion = readVersion(localVersionFile)
        print("Versión local encontrada: " .. tostring(localVersion))

        if localVersion ~= remoteVersion then
            sampAddChatMessage("Nueva versión disponible (" .. remoteVersion .. "), actualizando mod...", 0x73b461)
            
            -- Descargar el archivo del mod
            if downloadFile(modURL, localModFile) then
                sampAddChatMessage("Mod actualizado a la versión " .. remoteVersion, 0x73b461)
            else
                sampAddChatMessage("Error al descargar la nueva versión del mod.", 0xFF0000)
            end
        else
            sampAddChatMessage("El mod ya está actualizado a la versión " .. localVersion, 0x73b461)
        end
    else
        sampAddChatMessage("Error al verificar la versión del mod.", 0xFF0000)
    end

    while true do
        wait(1000)
    end
end
