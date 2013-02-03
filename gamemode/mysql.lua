require("mysqloo")

MySQLConfig = {} -- Ignore this line

MySQLConfig.Host  = "127.0.0.1" 
MySQLConfig.Username = "Username" 
MySQLConfig.Password = "Password" 
MySQLConfig.Database_name = "DB Name"
MySQLConfig.Database_port = --Port


function MySQL_Query( Query )
	DB = mysqloo.connect(MySQLConfig.Host, MySQLConfig.Username, MySQLConfig.Password, MySQLConfig.Database_name,  RP_MySQLConfig.Database_port )
	response = DB:query(Query)
end

