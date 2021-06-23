local editando="None"

local inicio={}
local iniciomarkers={}
local iniciocarros={}
local haciendoinicio=false

local checkpoints={}
local checkpointsmarkers={}
local checkpointsblips={}
local haciendochecks=false

local markerfinal=false
local creandofinal=false

local namerace=false

local vehicle=false

local prefix="#5A5959[#FFC900CVRCa#002BFFrre#FF0000ras#5A5959]#FFFFFF" --Acá pueden configurar el prefijo de su servidor, o en sí de lo que requieran.

function crearCarrera()
    if #inicio>0 then
        if #checkpoints>0 then
            if vehicle then
                if namerace then
                    triggerServerEvent("CVRCarreras:CrearCarrera",localPlayer,namerace,checkpoints,inicio,vehicle)
                    abrirPanel()
                    reset()
                else
                    outputChatBox(prefix.."No le pusiste nombre a la carrera",255,0,0,true)
                end
            else
                outputChatBox(prefix.."No hay vehículo seleccionado",255,0,0,true)
            end
        else
            outputChatBox(prefix.."No has puesto los #FF0000checkpoints #FFFFFFde la carrera",255,0,0,true)
        end
    else
        outputChatBox(prefix.."Faltan las #13FF00coordenadas de inicio#FFFFFF, parcero.",255,0,0,true)
    end
end

function reset()
    editando="None"

    inicio={}
    for k,v in ipairs(iniciomarkers) do
        destroyElement(v)
    end
    iniciomarkers={}
    iniciocarros={}
    haciendoinicio=false

    checkpoints={}
    for k,v in ipairs(checkpointsmarkers) do
        destroyElement(v)
    end
    for k,v in ipairs(checkpointsblips) do
        destroyElement(v)
    end
    checkpointsblips={}
    checkpointsmarkers={}
    haciendochecks=false

    markerfinal=false
    creandofinal=false

    vehicle=false

    namerace=false
end

function crearPanel()
    local screenW, screenH = guiGetScreenSize()
        mainWindowCarreras = guiCreateWindow((screenW - 325) / 2, (screenH - 366) / 2, 325, 366, "Creador de Carreras/Challenge", false)
        guiWindowSetSizable(mainWindowCarreras, false)

        lblChallenge = guiCreateLabel(0.06, 0.08, 0.23, 0.05, "ChallengeDrift", true, mainWindowCarreras)
        lblCarrera = guiCreateLabel(0.79, 0.08, 0.13, 0.05, "Carrera", true, mainWindowCarreras)
        buttonSelect = guiCreateButton(0.42, 0.08, 0.20, 0.05, "Seleccionar", true, mainWindowCarreras)
        lblCarro = guiCreateLabel(0.08, 0.16, 0.22, 0.04, "Id Vehiculo", true, mainWindowCarreras)
        editBoxIdVehiculos = guiCreateEdit(0.07, 0.21, 0.23, 0.05, "", true, mainWindowCarreras)
        buttonSelectMarkers = guiCreateButton(114, 68, 105, 33, "Seleccionar Markers de Inicio", false, mainWindowCarreras)
        lblMarkersSelected = guiCreateLabel(0.70, 0.19, 0.25, 0.13, "Markers \nSeleccionados", true, mainWindowCarreras)
        buttonRestart = guiCreateButton(0.78, 0.90, 0.19, 0.07, "Reiniciar", true, mainWindowCarreras)
        buttonExit = guiCreateButton(0.04, 0.92, 0.07, 0.06, "x", true, mainWindowCarreras)
        buttonTrazada = guiCreateButton(0.36, 0.33, 0.32, 0.09, "Seleccionar Markers Trazada", true, mainWindowCarreras)
        lblTrazadaSelected = guiCreateLabel(0.70, 0.33, 0.25, 0.13, "Markers \nSeleccionados", true, mainWindowCarreras)
        btnSelectVehicle = guiCreateButton(0.07, 0.28, 0.23, 0.05, "Seleccionar", true, mainWindowCarreras)
        btnSelectFinalMarker = guiCreateButton(0.36, 0.47, 0.32, 0.09, "Seleccionar Marker Final", true, mainWindowCarreras)
        btnCreate = guiCreateButton(0.41, 0.78, 0.23, 0.07, "Crear", true, mainWindowCarreras)
        lblFinalSelected = guiCreateLabel(0.70, 0.47, 0.25, 0.13, "Marker \nFinal \nSeleccionado", true, mainWindowCarreras)  
        if editando=="None" then
            guiLabelSetColor(lblChallenge,255,255,255)
            guiLabelSetColor(lblCarrera,255,255,255)
            guiSetEnabled(buttonSelectMarkers,false)
            guiSetEnabled(buttonTrazada,false)
            guiSetEnabled(btnSelectVehicle,false)
            guiSetEnabled(btnSelectFinalMarker,false)
            guiSetEnabled(btnCreate,false)
            guiSetEnabled(editBoxIdVehiculos,false)
        elseif editando=="Challenge" then
            guiLabelSetColor(lblChallenge,0,255,0)
            guiLabelSetColor(lblCarrera,255,0,0)
            guiSetEnabled(editBoxIdVehiculos,true)
            guiSetEnabled(btnSelectVehicle,true)
        elseif editando=="Carrera" then
            guiLabelSetColor(lblChallenge,255,0,0)
            guiLabelSetColor(lblCarrera,0,255,0)
            guiSetEnabled(editBoxIdVehiculos,true)
            guiSetEnabled(btnSelectVehicle,true)
        end
        if vehicle then
            guiSetText(editBoxIdVehiculos,vehicle)
        end
        if #inicio<1 then
            guiSetEnabled(buttonSelectMarkers,false)
            guiSetEnabled(buttonTrazada,false)
            guiSetEnabled(btnSelectFinalMarker,false)
            guiSetEnabled(btnCreate,false)
            guiSetEnabled(btnSelectFinalMarker,false)
        end
        if #inicio>1 and not(haciendoinicio) then
            guiSetEnabled(buttonSelect,false)
            guiSetEnabled(buttonSelectMarkers,false)
            guiSetEnabled(buttonTrazada,true)
            guiSetEnabled(btnSelectFinalMarker,false)
            guiSetText(lblMarkersSelected,"Markers \nSeleccionados: "..tostring(#inicio))
        end
        if #checkpoints>1 then
            guiSetEnabled(buttonSelect,false)
            guiSetEnabled(buttonSelectMarkers,false)
            guiSetEnabled(buttonTrazada,false)
            guiSetEnabled(btnSelectFinalMarker,true)
        end
        if markerfinal then
            guiSetEnabled(btnSelectFinalMarker,false)
            guiSetEnabled(buttonSelectMarkers,false)
            guiSetEnabled(btnCreate,true)
        else
            guiSetEnabled(btnCreate,false)
        end
        showCursor(true)
end

function obtenerActualEditando()
    retorno=false
    local r,g,b = guiLabelGetColor(lblChallenge)
    local r1,g1,b1 = guiLabelGetColor(lblCarrera)
    if r==255 and g==0 and b==0 and r1==0 and g1==255 and b1==0 then
        retorno="Carrera"
    elseif r==0 and g==255 and b==0 and r1==255 and g1==0 and b1==0 then
        retorno="Challenge"
    end
    return retorno
end

function updateEdition(edition)
    if #checkpoints<1 then
        if edition=="Carrera" then
            guiLabelSetColor(lblChallenge,255,0,0)
            guiLabelSetColor(lblCarrera,0,255,0)
            editando="Carrera"
            outputChatBox(prefix.."Ahora estás creando una #13FF00carrera",255,0,0,true)
        elseif edition=="Challenge" then
            guiLabelSetColor(lblChallenge,0,255,0)
            guiLabelSetColor(lblCarrera,255,0,0)
            editando="Challenge"
            outputChatBox(prefix.."Ahora estás creando un #FF0000challenge",255,0,0,true)
        end
        if not vehicle then
            outputChatBox(prefix.."Selecciona la #FF0000id #FFFFFFdel vehículo que quieres que usen",255,0,0,true)
            outputChatBox(prefix.."Si no sabes cual puedes consultarlos en #FF0000https://wiki.multitheftauto.com/wiki/Vehicle_IDs",255,0,0,true)
            guiSetEnabled(btnSelectVehicle,true)
            guiSetEnabled(editBoxIdVehiculos,true)
        end
    else
        outputChatBox(prefix.."Ya tienes unos checkpoints seleccionados, por favor reinicia la creación de la carrera!",255,0,0)
    end
end

function terminarInicio()
    if haciendoinicio then
        if #inicio>1 then
            haciendoinicio=false
            unbindKey("h","down",anhadirInicio)
            unbindKey("backspace","down",borrarInicio)
            outputChatBox(prefix.."Has terminado de hacer las #32FF00coordenadas de inicio#FFFFFF!",255,0,0,true)
            for k,v in ipairs(iniciocarros) do
                destroyElement(v)
            end
            iniciocarros={}
            abrirPanel()
            triggerServerEvent("CVRCarreras:BorrarCarroCreador",localPlayer)
        else
            outputChatBox(prefix.."Error, no has puesto al menos dos marcadores. Usa #32FF00h #FFFFFFy #FF0000backspace.",255,0,0,true)
        end
    end
end
addCommandHandler("terminarinicio",terminarInicio)


function anhadirInicio()
    if isPedInVehicle(localPlayer) and getElementModel(getPedOccupiedVehicle(localPlayer))==tonumber(vehicle) then
        local carro=getPedOccupiedVehicle(localPlayer)
        local x1,y1,z1 = getElementPosition(carro)
        table.insert(iniciomarkers,createMarker(x1,y1,z1,"cylinder", 1.5, 255, 255, 0, 170))
        local rx1,ry1,rz1=getElementRotation(getPedOccupiedVehicle(localPlayer))
        local tabla={x=x1,y=y1,z=z1,rx=rx1,ry=ry1,rz=rz1}
        table.insert(inicio,tabla)
        setElementPosition(getPedOccupiedVehicle(localPlayer),x1,y1,z1)
        table.insert(iniciocarros,createVehicle(vehicle,x1,y1,z1,rx1,ry1,rz1))
        setVehicleLocked(iniciocarros[#iniciocarros],true)
        
        outputChatBox(prefix.."#55FF00Añadido!",255,0,0,true)

        outputChatBox(prefix.."Si has terminado pon el comando #FF0000/terminarinicio",255,0,0,true)
    else
        outputChatBox(prefix.."Tienes que estar dentro del vehículo que te dimos para crear los #74FF00checkpoints de inicio",255,0,0,true)
    end
end

function borrarInicio()
    if #iniciomarkers>0 and #iniciocarros>0 and #inicio>0 then
        destroyElement(iniciomarkers[#iniciomarkers])
        iniciomarkers[#iniciomarkers]=nil
        destroyElement(iniciocarros[#iniciocarros])
        iniciocarros[#iniciocarros]=nil
        inicio[#inicio]=nil
        outputChatBox(prefix.."#FF0000Borrado!",255,0,0,true)
    end
end

function activarModoCreacionMarkersInicio()
    outputChatBox(prefix.."Has activado el modo creación de puntos de inicio!",255,0,0,true)
    outputChatBox(prefix.."Presiona #59FF00h #FFFFFFpara crear un punto de inicio, y #FF0000backspace #FFFFFFpara borrarlo!",255,0,0,true)
    outputChatBox(prefix.."Sé muy cuidadoso con los puntos de inicio, ya que tienen en cuenta incluso la #FF0000rotación del vehículo!",255,0,0,true)
    local x,y,z = getElementPosition(localPlayer)
    triggerServerEvent("CVRCarreras:CrearCarroCreador",localPlayer,vehicle,x,y,z)
    bindKey("h","down",anhadirInicio)
    bindKey("backspace","down",borrarInicio)
    haciendoinicio=true
    abrirPanel()
end

function terminarCheckpoint()
    if haciendocheck then
        if #checkpoints>0 then
            haciendocheck=false
            unbindKey("h","down",anhadirCheckpoint)
            unbindKey("backspace","down",borrarCheckpoint)
            outputChatBox(prefix.."Has terminado de hacer los #FF0000checkpoints!",255,0,0,true)
            abrirPanel()
        else
            outputChatBox(prefix.."Error, no has puesto ningún checkpoint. Usa #1FFF00h #FFFFFFy #FF0000backspace.",255,0,0,true)
        end
    end
end
addCommandHandler("terminarcheckpoint",terminarCheckpoint)

function anhadirCheckpoint()
    local x1,y1,z1 = getElementPosition(localPlayer)
    table.insert(checkpointsmarkers,createMarker(x1,y1,z1,"checkpoint",6,255,0,0,150))
    table.insert(checkpointsblips,createBlip(x1,y1,z1,0))
    local tabla={x=x1,y=y1,z=z1}
    table.insert(checkpoints,tabla)
    
    outputChatBox(prefix.."#1FFF00Añadido!",255,0,0,true)

    outputChatBox(prefix.."Si has terminado pon el comando #FF0000/terminarcheckpoint",255,0,0,true)
end

function borrarCheckpoint()
    if #checkpoints>0 and #checkpointsmarkers>0 then
        destroyElement(checkpointsmarkers[#checkpointsmarkers])
        destroyElement(checkpointsblips[#checkpointsblips])
        checkpointsblips[#checkpointsblips]=nil
        checkpointsmarkers[#checkpointsmarkers]=nil
        checkpoints[#checkpoints]=nil
        outputChatBox(prefix.."#FF0000Borrado!",255,0,0,true)
    end
end

function activarModoCreacionMarkersTrazada()
    outputChatBox(prefix.."Has activado el modo creación de checkpoints!",255,0,0,true)
    outputChatBox(prefix.."Presiona #4DFF00h #FFFFFFpara crear un checkpoint, y #FF0000backspace #FFFFFFpara borrarlo!",255,0,0,true)
    bindKey("h","down",anhadirCheckpoint)
    bindKey("backspace","down",borrarCheckpoint)
    haciendocheck=true
    abrirPanel()
end

function anhadirCheckpointFinal()
    if not(markerfinal) then
        local x1,y1,z1 = getElementPosition(localPlayer)
        table.insert(checkpointsmarkers,createMarker(x1,y1,z1,"checkpoint",6,0,255,0,150))
        local tabla={x=x1,y=y1,z=z1}
        table.insert(checkpoints,tabla)
        markerfinal=true
        
        outputChatBox(prefix.."#3AFF00Añadido!",255,0,0,true)

        outputChatBox(prefix.."Si has terminado pon el comando #3AFF00/terminarfinal",255,0,0,true)
    else
        outputChatBox(prefix.."Presiona #FF0000backspace #FFFFFFpara borrar el marcador final",255,0,0,true)
    end
end

function borrarCheckpointFinal()
    if markerfinal then
        destroyElement(checkpointsmarkers[#checkpointsmarkers])
        checkpointsmarkers[#checkpointsmarkers]=nil
        checkpoints[#checkpoints]=nil
        outputChatBox(prefix.."#FF0000Borrado!",255,0,0,true)
        markerfinal=false
    end
end


function terminarCheckpoint()
    if creandofinal then
        if markerfinal then
            creandofinal=false
            unbindKey("h","down",anhadirCheckpointFinal)
            unbindKey("backspace","down",borrarCheckpointFinal)
            outputChatBox(prefix.."#3AFF00Has terminado de hacer la carrera!",255,0,0,true)
            abrirPanel()
        else
            outputChatBox(prefix.."Error, no has puesto ningún checkpoint. Usa #FF0000h #FFFFFFy #FF0000backspace.",255,0,0,true)
        end
    end
end
addCommandHandler("terminarfinal",terminarCheckpoint)


function activarModoCreacionMarkerFinal()
    outputChatBox(prefix.."Has activado el modo creación de checkpoint final!",255,0,0,true)
    outputChatBox(prefix.."Presiona #3AFF00h #FFFFFFpara crear el checkpoint final, y #FF0000backspace #FFFFFFpara borrarlo!",255,0,0,true)
    bindKey("h","down",anhadirCheckpointFinal)
    bindKey("backspace","down",borrarCheckpointFinal)
    creandofinal=true
    abrirPanel()
end




function handleClick()
    if source==buttonSelect then
        local r,g,b = guiLabelGetColor(lblChallenge)
        local r1,g1,b1 = guiLabelGetColor(lblCarrera)
        if not(obtenerActualEditando()) then
            updateEdition("Carrera")
        elseif obtenerActualEditando()=="Carrera" then
            updateEdition("Challenge")
        elseif obtenerActualEditando()=="Challenge" then
            updateEdition("Carrera")
        end
    elseif source==btnSelectVehicle then
        local texto= guiGetText(editBoxIdVehiculos) or false
        if texto then
            local carro=getVehicleNameFromModel(texto) or false
            if carro and carro~="432" and carro~="425" and carro~="447" and carro~="520" then
                vehicle=texto
                outputChatBox(prefix.."Has seleccionado el siguiente carro #3AFF00"..carro,255,0,0,true)
                guiSetEnabled(buttonSelectMarkers,true)
                outputChatBox(prefix.."El siguiente paso es que selecciones los #3AFF00marcadores de inicio!",255,0,0,true)
            else
                outputChatBox(prefix.."Ese id es inválido. Si no sabes que poner, consulta acá:",255,0,0,true)
                outputChatBox(prefix.."#FF0000https://wiki.multitheftauto.com/wiki/Vehicle_IDs",255,0,0,true)
            end
        else
            outputChatBox(prefix.."Tienes que colocar el id. Si no sabes cual, consulta acá:",255,0,0,true)
            outputChatBox(prefix.."#FF0000https://wiki.multitheftauto.com/wiki/Vehicle_IDs",255,0,0,true)
        end
    elseif source==buttonSelectMarkers then
        activarModoCreacionMarkersInicio()
    elseif source==buttonTrazada then
        activarModoCreacionMarkersTrazada()
    elseif source==btnSelectFinalMarker then
        activarModoCreacionMarkerFinal()
    elseif source==btnCreate then
        crearCarrera()
    elseif source==buttonRestart then
        reset()
        abrirPanel()
    elseif source==buttonExit then
        abrirPanel()
    end
end

function abrirPanel()
    if isElement(mainWindowCarreras) then
        removeEventHandler("onClientGUIClick",root,handleClick)
        destroyElement(mainWindowCarreras)
        showCursor(false)
    else
        if haciendoinicio or haciendochecks or creandofinal then
            return
        end
        crearPanel()
        addEventHandler("onClientGUIClick",root,handleClick)
    end
end

function abrirpanelcomando(_,nombre)
    nombre = nombre or namerace
    if nombre then
        namerace = nombre
        abrirPanel()
    else
        outputChatBox(prefix.."Usa la siguiente sintáxis: #3AFF00/crearcarrera nombre",255,0,0,true)
    end
end
addCommandHandler("crearcarrera",abrirpanelcomando)

--[[ Esta parte de acá es donde se hacen los checkpoints y eso :D]]--
local screenX,screenY = guiGetScreenSize()
local guiX,guiY = screenX/1280,screenY/720


addEvent(getResourceName(getThisResource())..":sendTimerToClient",true)
addEventHandler(getResourceName(getThisResource())..":sendTimerToClient",root,
    function(remaining)
        local remaining = remaining/1000
        if remaining then
            c_Remaining = remaining
            c_raceTimer = setTimer(function()
                remaining = remaining-1
                c_Remaining = remaining
                if remaining <= 0 then
                    if isTimer(c_raceTimer) then
                        killTimer(c_raceTimer)
                    end
                end
            end,1000,0)
        end
    end
)

addEventHandler("onClientRender", root,
    function()
        if c_raceTimer and isTimer(c_raceTimer) then
            local remaining = c_Remaining
            if remaining then
                setWorldSpecialPropertyEnabled( "aircars", false )
                local newTime = math.ceil(remaining)
                dxDrawText("La carrera comienza en..", guiX*494, guiY*332, guiX*786, guiY*390, tocolor(255, 255, 255, 255), 1.50, "default-bold", "center", "center", false, false, false, false, false)
                dxDrawText(remaining, guiX*494, guiY*389, guiX*786, guiY*419, tocolor(255, 255, 255, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
            end
        end
    end
)




local inraceMarkers={}
local inraceBlips={}
local markers={}
local index=0

function resetMarkers()
    for k,v in ipairs(inraceMarkers) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    inraceMarkers={}
    for k,v in ipairs(inraceBlips) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    inraceBlips={}
    markers={}
    index=0
end
addEvent("CVRCarreras:ResetMarkers",true)
addEventHandler("CVRCarreras:ResetMarkers",root,resetMarkers)

function onClientRaceEnded()
    triggerServerEvent("CVRCarreras:OnPlayerWin",localPlayer)
end

function markerHit(hitPlayer,matchingDimension)
    if hitPlayer==localPlayer and matchingDimension then
        if source==inraceMarkers[index] and index<#markers then
            removeEventHandler("onClientMarkerHit",inraceMarkers[index],markerHit)
            destroyElement(inraceBlips[index])
            destroyElement(inraceMarkers[index])
            index=index+1
            drawBlipsandMarker()
        elseif source==inraceMarkers[index] and index>=#markers then
            onClientRaceEnded()
            resetMarkers()
        end
    end
end

function drawBlipsandMarker()
    local x = markers[index]['x']
    local y = markers[index]['y']
    local z = markers[index]['z']
    if markers[index+1] then
        local x2 = markers[index+1]['x'] or false
        local y2 = markers[index+1]['y'] or false
        local z2 = markers[index+1]['z'] or false
    end
    if isElement(inraceMarkers[index]) then
        destroyElement(inraceMarkers[index])
    end
    if isElement(inraceBlips[index]) then
        destroyElement(inraceBlips[index])
    end
    inraceMarkers[index]=createMarker(x,y,z,"checkpoint",6,255,0,0,150)
    inraceBlips[index]=createBlip(x,y,z,0, 2, 255, 0, 0, 255) 
    if x2 and y2 and z2 then
        inraceMarkers[index]=createMarker(x2,y2,z2,"checkpoint", 2.5, 255, 200, 0, 150)
    end
    addEventHandler("onClientMarkerHit",inraceMarkers[index],markerHit)
end


function startLocalRace(marcadorescarrera,cars)
    resetMarkers()
    index=1
    markers=marcadorescarrera
    for k,v in ipairs(markers) do
        inraceBlips[k]=createBlip(v.x,v.y,v.z, 0, 2, 255, 200, 0, 255)
    end
    drawBlipsandMarker()
    for k,v in ipairs(cars) do
        if isElement(v) and getPedOccupiedVehicle(localPlayer) and v~=getPedOccupiedVehicle(localPlayer) then
            setElementCollidableWith(getPedOccupiedVehicle(localPlayer),v,false)
            setElementCollidableWith(v,getPedOccupiedVehicle(localPlayer),false)
        end
    end
end
addEvent("CVRCarreras:EmpezarCarreraLocal",true)
addEventHandler("CVRCarreras:EmpezarCarreraLocal",root,startLocalRace)

function disableCaida () 
	setPedCanBeKnockedOffBike ( localPlayer, false ) 
end 
addEvent("CVRCarreras:DesactivarCaida",true)
addEventHandler("CVRCarreras:DesactivarCaida",root,disableCaida)

function enableCaida () 
	setPedCanBeKnockedOffBike ( localPlayer, true ) 
end 
addEvent("CVRCarreras:ActivarCaida",true)
addEventHandler("CVRCarreras:ActivarCaida",root,enableCaida)


function crearPanel()
    local screenW, screenH = guiGetScreenSize()
    CVRCarrerasPanelMain = guiCreateWindow((screenW - 464) / 2, (screenH - 526) / 2, 464, 526, "Carrera CVR", false)
    guiWindowSetSizable(CVRCarrerasPanelMain, false)
    guiSetAlpha(CVRCarrerasPanelMain, 0.75)

    CVRCarrerasListC = guiCreateGridList(9, 39, 165, 436, false, CVRCarrerasPanelMain)
    guiGridListAddColumn(CVRCarrerasListC, "Nombre", 0.9)
    CVRCarrerasBuscC = guiCreateEdit(9, 484, 165, 22, "", false, CVRCarrerasPanelMain)
    CVRCarrerasLabelListC = guiCreateLabel(9, 20, 164, 15, "Lista carreras", false, CVRCarrerasPanelMain)
    guiSetFont(CVRCarrerasLabelListC, "clear-normal")
    guiLabelSetHorizontalAlign(CVRCarrerasLabelListC, "center", false)
    guiLabelSetVerticalAlign(CVRCarrerasLabelListC, "center")
    CVRCarrerasBotnSalir = guiCreateButton(427, 489, 27, 27, "X", false, CVRCarrerasPanelMain)
    guiSetFont(CVRCarrerasBotnSalir, "clear-normal")
    guiSetProperty(CVRCarrerasBotnSalir, "NormalTextColour", "FFFE0005")
    CVRCarrerasNomCar = guiCreateLabel(209, 47, 88, 15, "Nombre carrera: ", false, CVRCarrerasPanelMain)
    CVRCarrerasAutorCar = guiCreateLabel(209, 72, 36, 15, "Autor: ", false, CVRCarrerasPanelMain)
    CVRCarrerasCheckp = guiCreateLabel(209, 97, 83, 15, "#Checkpoints:  ", false, CVRCarrerasPanelMain)
    CVRCarrerasCarro = guiCreateLabel(209, 122, 36, 15, "Carro:  ", false, CVRCarrerasPanelMain)
    CVRCarrerasLabelRecords = guiCreateLabel(209, 167, 218, 15, "Records", false, CVRCarrerasPanelMain)
    guiLabelSetHorizontalAlign(CVRCarrerasLabelRecords, "center", false)
    guiLabelSetVerticalAlign(CVRCarrerasLabelRecords, "center")
    CVRCarrerasNomCarR = guiCreateLabel(297, 47, 158, 15, "NombreR", false, CVRCarrerasPanelMain)
    CVRCarrerasAutorCarR = guiCreateLabel(245, 72, 158, 15, "Yoooo", false, CVRCarrerasPanelMain)
    CVRCarrerasCheckpR = guiCreateLabel(292, 97, 158, 15, "20", false, CVRCarrerasPanelMain)
    CVRCarrerasCarroR = guiCreateLabel(245, 122, 158, 15, "Infernus", false, CVRCarrerasPanelMain)
    CVRCarerrasRecord1 = guiCreateLabel(208, 200, 219, 33, "1. Balaclava: 30min 2mins 3.00sg", false, CVRCarrerasPanelMain)
    guiLabelSetHorizontalAlign(CVRCarerrasRecord1, "center", false)
    guiLabelSetVerticalAlign(CVRCarerrasRecord1, "center")
    CVRCarrerasRecord2 = guiCreateLabel(209, 254, 219, 33, "2. Balaclava: 30min 2mins 3.00sg", false, CVRCarrerasPanelMain)
    guiLabelSetHorizontalAlign(CVRCarrerasRecord2, "center", false)
    guiLabelSetVerticalAlign(CVRCarrerasRecord2, "center")
    CVRCarrerasRecord3 = guiCreateLabel(209, 307, 219, 33, "3. Balaclava: 30min 2mins 3.00sg", false, CVRCarrerasPanelMain)
    guiLabelSetHorizontalAlign(CVRCarrerasRecord3, "center", false)
    guiLabelSetVerticalAlign(CVRCarrerasRecord3, "center")
    CVRCarrerasbotnCargar = guiCreateButton(268, 393, 101, 35, "Cargar", false, CVRCarrerasPanelMain)
    guiSetProperty(CVRCarrerasbotnCargar, "NormalTextColour", "FF60D700")
    CVRCarrosParti = guiCreateLabel(209, 147, 83, 15, "#Participantes  ", false, CVRCarrerasPanelMain)
    CVRCarrerasParticiR = guiCreateLabel(292, 147, 158, 15, "10", false, CVRCarrerasPanelMain)    
    addEventHandler("onClientGUIChanged",CVRCarrerasBuscC,filtrador)
end
local tablacarreras={}
function recibirDatos(tabla)
    if isElement(CVRCarrerasPanelMain) then
        for k,v in ipairs(tabla) do
            guiGridListAddRow(CVRCarrerasListC,v['NombreCarrera'])
            tablacarreras[v['NombreCarrera']]={autor=v['Creador'],veh=v['Vehiculo'],chk=#fromJSON(v['Checkpoints']),capacidad=#fromJSON(v['Startcoords']),mtimes=fromJSON(v['MejoresTiempos'])}
        end
    end
end
addEvent("CVRCarreras:RecibirDatos",true)
addEventHandler("CVRCarreras:RecibirDatos",root,recibirDatos)

function clickPanelCarreras()
    if source==CVRCarrerasbotnCargar then
        local r,x = guiGridListGetSelectedItem(CVRCarrerasListC)
        local nombre = guiGridListGetItemText(CVRCarrerasListC,r,x)
        triggerServerEvent("CVRCarreras:CargarCarrera",localPlayer,localPlayer,nombre)
        creadorPanel()
    elseif source==CVRCarrerasListC then
        local r,x = guiGridListGetSelectedItem(CVRCarrerasListC)
        local nombre = guiGridListGetItemText(CVRCarrerasListC,r,x)
        guiSetText(CVRCarrerasNomCarR,nombre)
        guiSetText(CVRCarrerasCheckpR,tablacarreras[nombre]['chk'])
        guiSetText(CVRCarrerasAutorCarR,tablacarreras[nombre]['autor'])
        guiSetText(CVRCarrerasParticiR,tablacarreras[nombre]['capacidad'])
        guiSetText(CVRCarerrasRecord1,"1."..tablacarreras[nombre]['mtimes'][1]["persona"]..":"..tablacarreras[nombre]['mtimes'][1]["tiempo"].."sg.")
        guiSetText(CVRCarrerasRecord2,"2."..tablacarreras[nombre]['mtimes'][2]["persona"]..":"..tablacarreras[nombre]['mtimes'][2]["tiempo"].."sg.")
        guiSetText(CVRCarrerasRecord3,"3."..tablacarreras[nombre]['mtimes'][3]["persona"]..":"..tablacarreras[nombre]['mtimes'][3]["tiempo"].."sg.")
        guiSetText(CVRCarrerasCarroR,getVehicleNameFromModel(tonumber(tablacarreras[nombre]['veh'])))
    elseif source==CVRCarrerasBotnSalir then
        creadorPanel()
    end
end

function filtrador()
    local text = guiGetText ( source )
    if ( text ~= "" ) then
        guiGridListClear ( CVRCarrerasListC )
        for k, v in pairs ( tablacarreras ) do
            local name = k
            if ( string.find ( string.lower ( name ), string.lower ( text ) ) ) then
                local row = guiGridListAddRow ( CVRCarrerasListC,name )
                guiGridListSetItemText ( CVRCarrerasListC, row, 1, name, false, false )
            end
        end
    else
        guiGridListClear ( CVRCarrerasListC )
        for k,v in pairs (tablacarreras) do
            guiGridListAddRow(CVRCarrerasListC,k)
        end
    end
end

function creadorPanel()
    if isElement(CVRCarrerasPanelMain) then
        destroyElement(CVRCarrerasPanelMain)
        showCursor(false)
    else
        crearPanel()
        triggerServerEvent("CVRCarrerasRequestData",localPlayer)
        addEventHandler("onClientGUIClick",root,clickPanelCarreras)
        showCursor(true)
    end
end
addCommandHandler("cargarcarrera",creadorPanel)