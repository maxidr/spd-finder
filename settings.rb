module Settings
  
  REDIS_URL   = ENV["REDIS_URL"]    || "redis://127.0.0.1:6379/0"
  
  REDMINE_URL = ENV["REDMINE_URL"]  || "http://cluster.softwarepublico.gob.ar/redmine"

  # Conexión de ejemplo 
  #   "mysql2://user:password@server_host:/database"
  REDMINE_DATABASE_URL = ENV["REDMINE_DATABASE_URL"]
end
