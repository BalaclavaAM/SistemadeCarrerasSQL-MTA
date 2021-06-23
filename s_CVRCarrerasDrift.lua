--[[
    Este script fue hecho para Colombian Virtual Reality. Fue realizado en su totalidad por Balaclava.

    Pueden encontrar mi GitHub acá: https://github.com/BalaclavaAM

    Asimismo, pueden acceder a nuestro servidor de Discord: https://discord.gg/EeaemXa

    Este recurso es de uso libre. Si usted desea republicar este recurso deberá ponerme créditos como el autor original.

    Recuerde que antes de usarlo debe configurar la base de datos para que las consultas SQL se puedan ejecutar.
]]

local carroscreadores={}
local participantes={}
local playerinfo={}
local cars={}
local races={}

local timers={}
local starttimers={}

local endtimers={}

local timersconteo={}

local race=""

local playersthatloaded={}

local commands={}

local prefix="#5A5959[#FFC900CVRCa#002BFFrre#FF0000ras#5A5959]#FFFFFF"

function getCarrera(nombre)
    local data = db_query ( "SELECT * FROM carrerascvr WHERE NombreCarrera=?", nombre )
    if #data>0 then
        return data
    else
        return false
    end
end


function getCarreras()
    local data = db_query ( "SELECT * FROM carrerascvr WHERE 1" )
    return data
end


function getCarrerasBy(nombre)
    local data = db_query ( "SELECT * FROM `carrerascvr` WHERE `NombreCarrera` LIKE '%"..nombre.."%'")
    return data
end

function delCarrera(nombre)
    if getCarrera(nombre)~=false then
        db_query ( "DELETE FROM `carrerascvr` WHERE `NombreCarrera`=?",nombre )
    end
end

function commandDelRace(p,_,race)
    --if exports['NGAdministration']:isPlayerStaff(p) then En este condicional se revisaba si el usuario era administrador...
        local datoscarrera= getCarrera(race)
        if race then
            if #datoscarrera>0 then
                delCarrera(race)
            else
                local carreras={}
                local data = getCarrerasBy(nombrecarrera)
                for k,v in ipairs(data) do
                    table.insert(carreras,v['NombreCarrera'])
                end
                outputChatBox(prefix.."Las carreras que empiezan con "..nombrecarrera.." son: #FF0000"..table.concat(carreras,","),p,255,0,0,true)
            end
        --else
            local carreras={}
            local data = getCarreras()
            for k,v in ipairs(data) do
                table.insert(carreras,v['NombreCarrera'])
            end
            outputChatBox(prefix.."Las carreras disponibles son: #FF0000"..table.concat(carreras,","),p,255,0,0,true)
        --end
    end
end
addCommandHandler("eliminarcarrera",commandDelRace)


function exitHandler(thePed)
    if participantes[thePed] then
        exitRace(thePed)
    end
end


function crearCarrera(nombre,checkpoints,startcoords,vehiculo)
    if nombre and checkpoints and startcoords and vehiculo then
        if not(getCarrera(nombre)) then
            tabla={}
            table.insert(tabla,{persona="Nadie",tiempo=90000})    
            table.insert(tabla,{persona="Nadien",tiempo=90001})
            table.insert(tabla,{persona="Nadienn",tiempo=90002})
            db_exec ( "INSERT INTO carrerascvr ( `NombreCarrera`, `Creador`, `Vehiculo`, `Checkpoints`, `Startcoords`, `MejoresTiempos`) VALUES ( ?,?,?,?,?,? );", nombre, getAccountName(getPlayerAccount(source))..": "..getPlayerName(source),tonumber(vehiculo),toJSON(checkpoints),toJSON(startcoords),toJSON(tabla))
            outputChatBox(prefix.."Has creado la carrera satisfactoriamente",source,255,0,0,true)
        else
            outputChatBox(prefix.."Ya existe una carrera con ese #FF0000nombre",source,255,0,0,true)
        end
    else
        outputChatBox(prefix.."Tuvimos un error obteniendo todos los datos",source,255,0,0,true)
    end
end
addEvent("CVRCarreras:CrearCarrera",true)
addEventHandler("CVRCarreras:CrearCarrera",root,crearCarrera)

function crearCarroCreador(car,x,y,z)
    carroscreadores[source]=createVehicle(car,x,y,z)
    warpPedIntoVehicle(source,carroscreadores[source])
end
addEvent("CVRCarreras:CrearCarroCreador",true)
addEventHandler("CVRCarreras:CrearCarroCreador",root,crearCarroCreador)

function BorrarCarroCreador()
    if isElement(carroscreadores[source]) then
        destroyElement(carroscreadores[source])
    end
    carroscreadores[source]=nil
end
addEvent("CVRCarreras:BorrarCarroCreador",true)
addEventHandler("CVRCarreras:BorrarCarroCreador",root,BorrarCarroCreador)


function cargarCarrera(p,nombrecarrera)
    if not(playersthatloaded[p]) then
        local datoscarrera = getCarrera(nombrecarrera)
        if nombrecarrera then
            if datoscarrera~=false then
                if races[nombrecarrera]==nil then
                    races[nombrecarrera]={creador=datoscarrera[1]['Creador'],
                                            vehiculo=datoscarrera[1]['Vehiculo'],
                                            inicio=fromJSON(datoscarrera[1]['Startcoords']),
                                            trazada=fromJSON(datoscarrera[1]['Checkpoints']),
                                            mejores=fromJSON(datoscarrera[1]['MejoresTiempos']),
                                            players={},
                                            started=false,
                                            loadedby=p,
                                            cars={}}
                    local number=math.random(0,25)
                    while commands[number] do
                        number=math.random(0,25)
                    end
                    playersthatloaded[p]=nombrecarrera
                    commands[number]=nombrecarrera
                    outputChatBox(prefix.."El jugador "..getPlayerName(p).." ha empezado la carrera "..nombrecarrera.." creada por #FF0000"..datoscarrera[1]['Creador'].." #FFFFFFusa #3AFF00/entrarcarrera "..tostring(number).." #FFFFFFpara participar.",player,255,0,0,true)
                    timers[nombrecarrera]=setTimer( function(nombrecarrera)
                                                    if #races[nombrecarrera]['players']<1 then
                                                        races[nombrecarrera]=nil
                                                        outputChatBox(prefix.."La carrera #FF0000"..nombrecarrera.." #FFFFFFha sido terminada porque nadie entró a ella!",root,255,0,0,true)
                                                    end
                                                    end,60000,1,nombrecarrera)
                else
                    outputChatBox(prefix.."Esta carrera ya está cargada",p,255,0,0,true)
                end
            else
                local carreras={}
                local data = getCarrerasBy(nombrecarrera)
                for k,v in ipairs(data) do
                    table.insert(carreras,v['NombreCarrera'])
                end
                outputChatBox(prefix.."Las carreras que empiezan con "..nombrecarrera.." son: #FF0000"..table.concat(carreras,","),p,255,0,0,true)
            end
        else
            local carreras={}
            local data = getCarreras()
            for k,v in ipairs(data) do
                table.insert(carreras,v['NombreCarrera'])
            end
            outputChatBox(prefix.."Las carreras disponibles son: #FF0000"..table.concat(carreras,","),p,255,0,0,true)
        end
    end
end
addEvent("CVRCarreras:CargarCarrera",true)
addEventHandler("CVRCarreras:CargarCarrera",root,cargarCarrera)


function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = ( seconds %60 )
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )
		
		if day > 0 then table.insert( results, day .. ( day == 1 and " dia" or " días" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hora" or " horas" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minuto" or " minutos" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " segundo" or " segundos" ) ) end
		
		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " y ", 1 ) )
	end
	return ""
end

function table.removeValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            table.remove(tab, index)
            return index
        end
    end
    return false
end

function exitRace(p)
    if participantes[p] then
            if playerinfo[p] then
            local info = playerinfo[p]
            if cars[p] then
                if isElement(cars[p]) then
                    destroyElement(cars[p])
                    cars[p]=false
                end
            end
            if isElement(p) then
                removeEventHandler("onPlayerQuit",p,exitRaceF)
                setElementFrozen(p,true)
                setTimer(function(p,info)
                    setElementPosition(p,info.x,info.y,info.z,true)
                    setElementDimension(p,info.dimension)
                    setElementInterior(p,info.interior)
                end,1500,1,p,info)
                triggerClientEvent(p,"CVRCarreras:ResetMarkers",p)
                removeElementData(p,"inRace")
                if not (carro~=581 and carro~=509 and carro~=481 and carro~=462 and carro~=521 and carro~=463 and carro~=510 and carro~=522 and carro~=461 and carro~=448 and carro~=468 and carro~=586) then
                    triggerClientEvent(p,"CVRCarreras:ActivarCaida",p)
                end
            end
            local carrera=participantes[p]
            table.removeValue(races[participantes[p]]['players'],p)
            participantes[p]=nil
            playerinfo[p]=nil
            setElementFrozen(p,false)
            if #races[carrera]['players']<=0 then
                endRaceGeneral(carrera)
            end
        end
    end
end
addCommandHandler("salircarrera",exitRace)

function exitRaceF()
    p=source
    if participantes[p] then
            if playerinfo[p] then
            local info = playerinfo[p]
            if cars[p] then
                if isElement(cars[p]) then
                    destroyElement(cars[p])
                    cars[p]=false
                end
            end
            if isElement(p) then
                setElementFrozen(p,true)
                setElementPosition(p,info.x,info.y,info.z,true)
                setElementDimension(p,info.dimension)
                setElementInterior(p,info.interior)
            end
            table.removeValue(races[participantes[p]]['players'],p)
            participantes[p]=nil
            playerinfo[p]=nil
            setElementFrozen(p,false)
        end
    end
end

function endRaceGeneral(race)
    if endtimers[race] and isTimer(endtimers[race]) then
        killTimer(endtimers[race])
    end
    local jugadores = races[race]['players']
    for k,player in ipairs(jugadores) do
        exitRace(player)
    end
    local number=0
    for k,v in pairs(commands) do
        if v==race then
            number=k
        end
    end
    local clave=races[race]['loadedby']
    if clave then
        playersthatloaded[clave]=nil
    end
    commands[number]=nil
    outputChatBox(prefix.."La carrera #FF0000"..race.." #FFFFFFha sido terminada!",root,255,0,0,true)
    races[race]=nil
end

function onPlayerWin()
    if getPedOccupiedVehicle(source) and getPedOccupiedVehicle(source)==cars[source]  then
        local carrera=participantes[source]
        local llegada = getTickCount()
        local jugadores = races[carrera]['players']
        local tiempotardado = (llegada-races[carrera]['timestarted'])/1000
        local puesto = #races[carrera]['playersllegada']+1
        table.insert(races[carrera]['playersllegada'],source)
        outputChatBox(prefix.."El jugador #3AFF00"..getPlayerName(source).." #FFFFFFllegó en #FF0000"..tostring(puesto).." #FFFFFFpuesto en la carrera #FF0000"..carrera.." #FFFFFFmarcando un tiempo de: #3AFF00"..secondsToTimeDesc(tiempotardado),root,255,0,0,true)
        checkTime(source,carrera,tiempotardado)
        exitRace(source)
        if puesto==1 and races[carrera] then 
            endtimers[carrera]=setTimer(function(carrera)
                endRaceGeneral(carrera)
            end,30000,1,carrera)
            outputChatBox(prefix.."La carrera #3AFF00"..carrera.." #FFFFFFterminará en 30 sg",root,255,0,0,true)
        end
        if races[carrera] and #races[carrera]['players']<=0 then
            endRaceGeneral(carrera)
        end
    else
        outputChatBox(prefix.."Ese no es el carro con el que empezaste! :(",source,255,0,0,true)
        exitRace(source)
    end
end
addEvent("CVRCarreras:OnPlayerWin",true)
addEventHandler("CVRCarreras:OnPlayerWin",root,onPlayerWin)

function comenzarcarrera(carrera)
    outputChatBox(prefix.."La carrera #FF0000"..carrera.." #FFFFFFestá a punto de comenzar",root,255,0,0,true)
    if starttimers[carrera] and isTimer(starttimers[carrera]) then
        killTimer(starttimers[carrera])
        starttimers[carrera]=nil
    end
    local jugadores=races[carrera]['players']
    local trazada=races[carrera]['trazada']
    local carrosc=races[carrera]['cars']
    timersconteo[carrera]=setTimer(function(carrera, jugadores)
                            for k,player in ipairs(jugadores) do
                                if isElement(player) then
                                    toggleControl(player,"enter_exit",true)
                                    setElementFrozen(getPedOccupiedVehicle(player),false)
                                    triggerClientEvent(player,"CVRCarreras:EmpezarCarreraLocal",player,trazada,carrosc)
                                else
                                    exitRace(p)
                                end
                            end
                        end,5000,1,carrera,jugadores)
    for k,player in ipairs(jugadores) do
        local remaining = getTimerDetails(timersconteo[carrera])
        triggerClientEvent(player,getResourceName(getThisResource())..":sendTimerToClient",player,remaining)
    end

    races[carrera]['started']=true
    races[carrera]['timestarted']=getTickCount()
    races[carrera]['playersllegada']={}
end

function forzarinicio(p)
    if participantes[p] and races[participantes[p]]['loadedby']==p then
        comenzarcarrera(participantes[p])
        outputChatBox(prefix.."#3AFF00"..getPlayerName(p).."#FFFFFF ha forzado el inicio de la carrera #3AFF00 "..participantes[p],root,255,0,0,true)
    else
        outputChatBox(prefix.."Tienes que estar en una carrera y ser al menos VIP Diamond para forzar una carrera",p,255,0,0,true)
    end
end
addCommandHandler("comenzarcarrera",forzarinicio)

function checkTime(p,race,time)
    if time<races[race]['mejores'][1]['tiempo'] then
        outputChatBox(prefix.."#FF0000"..getPlayerName(p).." #FFFFFFha roto el record en la carrera #3AFF00"..race.." #FFFFFFel nuevo record es #FF0000"..secondsToTimeDesc(time),root,255,0,0,true)
        races[race]['mejores'][1]['tiempo']=time
        races[race]['mejores'][1]['persona']=getAccountName(getPlayerAccount(p))
        db_exec ( "UPDATE `carrerascvr` SET `MejoresTiempos`=? WHERE `NombreCarrera`=?",toJSON(races[race]['mejores']),race )
    elseif time<races[race]['mejores'][2]['tiempo'] then
        outputChatBox(prefix.."#FF0000"..getPlayerName(p).." #FFFFFFsuperó el segundo mejor tiempo en la carrera #3AFF00"..race.." #FFFFFFel nuevo tiempo es #FF0000"..secondsToTimeDesc(time),root,255,0,0,true)
        races[race]['mejores'][2]['tiempo']=time
        races[race]['mejores'][2]['persona']=getAccountName(getPlayerAccount(p))
        db_exec ( "UPDATE `carrerascvr` SET `MejoresTiempos`=? WHERE `NombreCarrera`=?",toJSON(races[race]['mejores']),race )
    elseif time<races[race]['mejores'][3]['tiempo'] then
        outputChatBox(prefix.."#FF0000"..getPlayerName(p).." #FFFFFFsuperó el tercer mejor tiempo en la carrera #3AFF00"..race.." #FFFFFFel nuevo tiempo es #FF0000"..secondsToTimeDesc(time),root,255,0,0,true)
        races[race]['mejores'][3]['tiempo']=time
        races[race]['mejores'][3]['persona']=getAccountName(getPlayerAccount(p))
        db_exec ( "UPDATE `carrerascvr` SET `MejoresTiempos`=? WHERE `NombreCarrera`=?",toJSON(races[race]['mejores']),race )
    end
end

function entrarcarrera(p,_,carrera)
    if not(isPedDead(p)) then
        if carrera then
            if tonumber(carrera) then
                carrera=commands[tonumber(carrera)]
            end
                if races[carrera] and not(races[carrera]['started']) and #races[carrera]['players']<#races[carrera]['inicio'] then
                    if timers[carrera] and isTimer(timers[carrera]) then
                        killTimer(timers[carrera])
                        timers[carrera]=nil
                    end
                    local jugadores = #races[carrera]['players']
                    local carro = races[carrera]['vehiculo']
                    local coordenadasinicio = races[carrera]['inicio'][jugadores+1]
                    cars[p]=createVehicle(carro,coordenadasinicio['x'],coordenadasinicio['y'],coordenadasinicio['z'],coordenadasinicio['rx'],coordenadasinicio['ry'],coordenadasinicio['rz'])
                    table.insert(races[carrera]['cars'],cars[p]) 
                    if carro~=581 and carro~=509 and carro~=481 and carro~=462 and carro~=521 and carro~=463 and carro~=510 and carro~=522 and carro~=461 and carro~=448 and carro~=468 and carro~=586 then
                        addEventHandler("onVehicleExit",cars[p],exitHandler)
                    else
                        triggerClientEvent(p,"CVRCarreras:DesactivarCaida",p)
                    end
                    addEventHandler("onPlayerQuit",p,exitRaceF)
                    setElementData(p,"inRace",true)
                    participantes[p]=carrera
                    local px,py,pz = getElementPosition(p)
                    local pd = getElementDimension(p)
                    local pi = getElementInterior(p)
                    playerinfo[p]={x=px,y=py,z=pz,dimension=pd,interior=pi}
                    table.insert(races[carrera]['players'],p)
                    warpPedIntoVehicle(p,cars[p])
                    setElementFrozen(cars[p],true)
                    toggleControl(p,"enter_exit",false)
                    local records=races[carrera]['mejores']
                    outputChatBox(prefix.."Records de esta carrera:",p,255,0,0,true)
                    for k,v in ipairs(records) do
                        outputChatBox(prefix..tonumber(k).." Jugador: #3AFF00"..v['persona'].."  #FFFFFFRecord: #FF0000"..v['tiempo'].."#3AFF00 sg",p,255,0,0,true)
                    end
                    outputChatBox(prefix.."La carrera empezará en #FF0000120 segundos #FFFFFFo puedes forzarla con #3AFF00/comenzarcarrera",p,255,0,0,true)
                    if jugadores==0 then
                        starttimers[carrera]=setTimer(comenzarcarrera,120000,1,carrera)
                    end
                    if jugadores+1>=#races[carrera]['inicio'] then
                        comenzarcarrera(carrera)
                    end
                else
                    local tabla={}
                    for k,v in pairs(races) do
                        table.insert(tabla,k)
                    end
                    outputChatBox(prefix.."Las siguientes carreras están activas: #3AFF00"..table.concat(table),p,255,0,0,true)
                end
        else
            local tabla={}
            for k,v in pairs(races) do
                table.insert(tabla,k)
            end
            outputChatBox(prefix.."Las siguientes carreras están activas: #3AFF00"..table.concat(table),p,255,0,0,true)
        end
    end
end
addCommandHandler("entrarcarrera",entrarcarrera)


function alimentarTablaLocal()
    local tablita = getCarreras()
    triggerClientEvent(source,"CVRCarreras:RecibirDatos",source,tablita)
end
addEvent("CVRCarrerasRequestData",true)
addEventHandler("CVRCarrerasRequestData",root,alimentarTablaLocal)


function enviarMensajedeEntrada()
    outputChatBox(prefix.."Recurso creado por #FC1515BalaclavaAM#FFFFFF para #A400F7Colombian Virtual Reality. #51B6F5www.discord.com/mtacvr",root,255,255,0,true)
    outputChatBox(prefix.."Recurso público. Si usted desea remover los créditos no hay ningún problema siempre y cuando #FC1515no se use para fines comerciales.",root,255,255,0,true)
    
    db_exec([[CREATE TABLE IF NOT EXISTS carrerascvr ( NombreCarrera VARCHAR(200), Creador VARCHAR(50), Vehiculo INT, Checkpoints TEXT, Startcoords TEXT, MejoresTiempos TEXT )]]);
end
addEventHandler("onResourceStart",resourceRoot,enviarMensajedeEntrada)