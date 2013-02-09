Estructura utilizada en Redis
=============================

## Proyectos

+ **key:**  "projects:1"  # Donde el 1 representa el ID del proyecto en la BBDD de Redmine
+ **value:**  Hash con la información del proyecto serializada a JSON. Ej. del hash: { name: 'Projecto 1', identifier: 'proj_01', description: 'Este es el projecto N° 1' }

## Tipos de ejes

+ **key:** "axis_types"
+ **value:** Hash con la información te todos los tipos de ejes (Funcionalidad por ejemplo).  Para ejemplos de la estructura ver el método add_axis_types de models/stats.rb

## Relación entre proyectos y ejes

+ **key**: "axis:12"
+ **value**: Bits donde 1 representa que el proyecto está en dicho eje y 0 que no lo está.  El ID de un proyecto se representa por su posición dentro de los bits.  

Ej.:

    Posición    98 7654 3210 
              ----+----+----
    bits:     0000 0010 0010
                     ^    ^
                     |    |
                     |    Project 1
                     |
                     Projecto 5


