Finder SPD
==========

El objetivo del proyecto es contar con un buscador de proyectos SPD donde se pueda filtrar por ejes.
La información es obtenida de una base de datos que utiliza un sistema [Redmine](http://redmine.org). 

El sistema cuenta con campos personalizados en los proyectos llamados ejes (ej: "Funcionalidad": donde se indican valores que identifica dicha característica del sistema).  Dichos campos son de selección múltiple, por lo que un proyecto puede tener varios valores de varios ejes. 

El proyecto depende de una base de datos [Redis](redis.io)

**IMPORTANTE**

Es necesario que los ejes, en Redmine, sean cargados con valores que correspondan al siguiente formato:

    NNNNN DESCRIPCION

Donde:

+ NNNNN es un número (puede iniciar con 0).  Ej.: 00001 ó 12 ó 00391
+ DESCRIPCION es la descripción del eje. Ej.: _Lenguaje de programación | Visual FoxPro_ ó _Software de seguridad | Biométrico_

Ejemplos:

+ 007 Gestión de la información | Portal
+ 1001 Lenguaje de programación | Ada
  

## Configuración

El sistema require de 3 variables de entorno:

+ REDIS_URL: Donde se indica el string de conexión contra la base de datos Redis.  Ej.: "redis://192.168.1.21:6379/0"
+ REDMINE_URL: Dirección del sistema Redmine al que se direccionará cuando se selecciona alguno de los proyectos encontrados. Ej.: "http://mysite.com/redmine"
+ REDMINE_DATABASE_URL = String de conexión contra la base de datos de redmine. Ej.: mysql2://user:password@server_host:/database

Para cargar las variables (en linux) se debe ejecutar:

    export REDIS_URL=redis://192.168.1.21:6379/0

Para dejar fijas dichas variables se pueden volcar los "export" en un archivo dentro de la carpeta /etc/profile.d (por ejemplo: spd_finder.sh).

Luego de cargar las variables se puede iniciar el proyecto (standalone) del siguiente modo:

    bundle install
    rackup


## Importación de datos 

Para poder utilizar el sistema se necesita importar información de la base de datos de Redmine a la base de datos Redis.  Para ello se debe ejecutar:

    rake import CUSTOM_FIELD_IDS=2,5,8

El parámetro CUSTOM_FIELD_IDS indica los ids a utilizar de la tabla custom_fields del Redmine.  Estos ids representan los campos personalizados correspondientes a los ejes que se desean cargar, evitando cargar mas campos personalizado que podría tener el sistema. 
Para mas detalles ejecute el comando sin el parámetro.

## Tests

Para correr los test se debe ejecutar:

    rake 

Se requiere tener conexión con una base de datos redis para poder correr los tests.  Por defecto tratará de utilizar una local (redis://127.0.0.1:6379) pero podría indicarse otra del siguiente modo:

    rake REDIS_URL=redis://192.168.1.29:6379/13

Ver test/helper.rb para mas detalles.


