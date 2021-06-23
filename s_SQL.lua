if ( tostring ( get ( "CONNECTION_TYPE" ) ):lower() == "mysql" ) then 
	outputConsole ( "Attempting to connect as MySQL... Please wait")
	db = dbConnect( "mysql", "dbname="..tostring(get("DATABASE_NAME"))..";host="..tostring(get("MYSQL_HOST"))..";port="..tostring(get("MYSQL_PORT"))..";unix_socket=/opt/lampp/var/mysql/mysql.sock", tostring(get("MYSQL_USER")), tostring(get("MYSQL_PASS")), "share=1;autoreconnect=1" );
elseif ( tostring ( get ( "CONNECTION_TYPE" ) ):lower() == "sqlite" ) then 
	db = dbConnect ( "sqlite", tostring(get("DATABASE_NAME")) .. ".sql" );
else 
	error ( tostring(get("CONNECTION_TYPE")) .. " is an invalid SQL connection -- valid: mysql, sqlite" );
end 

if not db then
	print ( "The database has failed to connect")
	return 
else
	print ( "Database has been connected")
end

function db_query ( ... ) 
	local data = { ... }
	return dbPoll ( dbQuery ( db, ... ), - 1 )
end

function db_exec ( ... )
	return dbExec ( db, ... );
end
