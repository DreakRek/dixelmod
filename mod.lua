-- Importa las bibliotecas necesarias
local moonloader = require("moonloader")
local http = require("socket.http")
local lfs = require("lfs")

-- Configura la URL del repositorio y el archivo que deseas actualizar
local repoURL = "https://raw.githubusercontent.com/DreakRek/dixelmod/refs/heads/main/mod.lua"  -- Cambia esta URL por la tuya
local modloaderPath = getGameDirectory() .. "\\modloader\\mods\\"
local modFile = modloaderPath .. "mod.lua"

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8


-- Función para descargar el archivo
function downloadFile(url, destination)
    local response, status = http.request(url)
    if status == 200 then
        local file = io.open(destination, "w+")
        file:write(response)
        file:close()
        return true
    else
        return false
    end
end

-- Función que se ejecuta al iniciar el script
function main()
    sampAddChatMessage(u8"MOD Dixel RP", 0x73b461)
    
    if not lfs.attributes(modloaderPath, "mode") then
        lfs.mkdir(modloaderPath)
    end

    -- Verificar si el archivo ya existe
    if not lfs.attributes(modFile) then
        sampAddChatMessage(u8"No se encontró el mod, descargando en la carpeta modloader...", 0x73b461)
        if downloadFile(repoURL, modFile) then
            sampAddChatMessage(u8"Descarga completada con éxito.", 0x73b461)
        else
            sampAddChatMessage(u8"Error al descargar el archivo.", 0x73b461)
        end
    else
        -- Si el archivo existe, verificamos si hay una actualización disponible
        sampAddChatMessage(u8"Verificando actualizaciones...", 0x73b461)
        local response, status = http.request(repoURL)
        if status == 200 then
            local localFileContent = io.open(modFile, "r"):read("*all")
            if localFileContent ~= response then
                sampAddChatMessage(u8"Se encontró una actualización, descargando...", 0x73b461)
                if downloadFile(repoURL, modFile) then
                    sampAddChatMessage(u8"Actualización completada con éxito.", 0x73b461)
                else
                    sampAddChatMessage(u8"Error al descargar la actualización.", 0x73b461)
                end
            else
                sampAddChatMessage(u8"El mod ya está actualizado.", 0x73b461)
            end
        else
            sampAddChatMessage(u8"Error al verificar actualizaciones.", 0x73b461)
        end
    end
    
    -- Esperar indefinidamente para que el script no termine
    while true do
        wait(1000)
    end
end
