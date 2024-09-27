local http = require("socket.http")
local lfs = require("lfs")

-- URL de prueba (debería funcionar siempre)
local testURL = "http://www.example.com"
local downloadPath = getGameDirectory() .. "\\modloader\\downloads\\"
local destinationFile = downloadPath .. "example.html"

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

-- Función principal
function main()

    repeat wait(500) until isSampAvailable()
     
    sampAddChatMessage("Intentando descargar archivo de prueba...", 0x73b461)


    if not lfs.attributes(downloadPath, "mode") then
        lfs.mkdir(downloadPath) -- Crear la carpeta si no existe
    end


    if downloadFile(testURL, destinationFile) then
        sampAddChatMessage("Archivo de prueba descargado correctamente.", 0x73b461)
    else
        sampAddChatMessage("Error al descargar el archivo de prueba.", 0xFF0000)
    end

    while true do
        wait(1000)
    end
end
