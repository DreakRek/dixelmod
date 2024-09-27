local http = require("socket.http")
local lfs = require("lfs")

-- URLs del repositorio de GitHub
local versionURL = "https://raw.githubusercontent.com/DreakRek/dixelmod/main/version.txt"  -- URL del archivo de versión
local modURL = "https://raw.githubusercontent.com/DreakRek/dixelmod/main/mod.lua" -- URL del archivo mod
local extraFiles = { -- Lista de otros archivos que se encuentran en el repositorio (agrega más si tienes otros archivos)
    ["config.txt"] = "https://raw.githubusercontent.com/DreakRek/dixelmod/main/config.txt",
}

-- Rutas locales
local modloaderPath = getGameDirectory() .. "\\modloader\\mods\\"
local moonloaderPath = getGameDirectory() .. "\\moonloader\\"
local localVersionFile = modloaderPath .. "version.txt"
local localModFile = moonloaderPath .. "mod.lua"

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

-- Función para verificar la existencia de archivos y descargarlos si no existen
function checkAndDownloadFiles()
    -- Verificar si el archivo de versión existe
    if not lfs.attributes(localVersionFile) then
        sampAddChatMessage("No se encontró el archivo de versión, descargándolo...", 0x73b461)
        if not downloadFile(versionURL, localVersionFile) then
            sampAddChatMessage("Error al descargar el archivo de versión.", 0xFF0000)
            return false
        end
    end

    -- Leer la versión remota
    local remoteVersion = readVersion(localVersionFile)

    -- Verificar si el archivo del mod existe
    if not lfs.attributes(localModFile) then
        sampAddChatMessage("No se encontró el archivo mod.lua, descargándolo...", 0x73b461)
        if not downloadFile(modURL, localModFile) then
            sampAddChatMessage("Error al descargar el archivo mod.lua.", 0xFF0000)
            return false
        end
    end

    -- Verificar y descargar los archivos adicionales
    for fileName, fileURL in pairs(extraFiles) do
        local destinationFile = modloaderPath .. fileName
        if not lfs.attributes(destinationFile) then
            sampAddChatMessage("Descargando archivo adicional: " .. fileName, 0x73b461)
            if not downloadFile(fileURL, destinationFile) then
                sampAddChatMessage("Error al descargar el archivo: " .. fileName, 0xFF0000)
                return false
            end
        end
    end

    sampAddChatMessage("Todos los archivos están en su lugar y actualizados.", 0x73b461)
    return true
end

-- Función principal
function main()
    repeat wait(500) until isSampAvailable()

    sampAddChatMessage("Verificando archivos del mod...", 0x73b461)

    -- Verifica si la carpeta de modloader existe, de lo contrario, la crea
    if not lfs.attributes(modloaderPath, "mode") then
        lfs.mkdir(modloaderPath)
    end

    -- Verifica si la carpeta de moonloader existe, de lo contrario, la crea
    if not lfs.attributes(moonloaderPath, "mode") then
        lfs.mkdir(moonloaderPath)
    end

    -- Verificar y descargar archivos si es necesario
    checkAndDownloadFiles()

    while true do
        wait(1000)
    end
end
