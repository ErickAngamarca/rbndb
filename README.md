# rbndb

Paquete de R para descargar datos de ocurrencia del Banco Nacional de Datos de Biodiversidad (BNDB) del Ecuador.

## Instalación

```r
# Install from GitHub
devtools::install_github("ErickAngamarca/rbndb")

# O desde el repositorio local
devtools::install_github("https://github.com/ErickAngamarca/rbndb")
```

## Uso

```r
library(rbndb)

# Descargar datos para una especie (todo Ecuador)
occ <- download_bndb("Vismia baccifera")

# Descargar datos para una provincia específica
occ <- download_bndb("Vismia baccifera", province = "Loja")

# Descargar datos para un cantón específico
occ <- download_bndb("Vismia baccifera", province = "Loja", canton = "Loja")

# Descargar datos para una parroquia específica
occ <- download_bndb("Vismia baccifera", province = "Loja", canton = "Loja", parish = "San Sebastian")

# Guardar en CSV
download_bndb("Vismia baccifera", province = "Loja", output = "csv", out_file = "data")

# Guardar en shapefile
download_bndb("Vismia baccifera", province = "Loja", output = "shp", out_file = "data")

# Ver en mapa interactivo
download_bndb("Vismia baccifera", map = TRUE)

# Especificar número de páginas
occ <- download_bndb("Escallonia micrantha", max_pages = 5)

# Ver datos
head(occ)

# Usar diferente CRS
occ <- download_bndb("Vismia baccifera", province = "Loja", crs = "EPSG:4326")
```

## Parámetros

- `scientific_name`: Nombre científico de la especie
- `max_pages`: Número máximo de páginas a descargar (default 10)
- `delay`: Delay entre requests en segundos (default 0.5)
- `province`: Nombre de provincia (GADM nivel 1). Si es NULL, descarga todo Ecuador
- `canton`: Nombre de cantón (GADM nivel 2). Requiere especificar province
- `parish`: Nombre de parroquia (GADM nivel 3). Requiere especificar canton
- `crs`: Sistema de coordenadas (default "EPSG:32717")
- `output`: Formato de salida: "csv" o "shp" (default "csv")
- `map`: Si TRUE, muestra mapa interactivo con leaflet (default FALSE)
- `out_file`: Nombre del archivo de salida (sin extensión). Si es NULL, retorna objeto en R

## Valor

Retorna un dataframe con las siguientes columnas (Darwin Core):

- occurrenceID
- scientificName
- taxon
- family
- catalogNumber
- recordedBy
- recordNumber
- eventDate
- verbatimEventDate
- locality
- decimalLatitude
- decimalLongitude
- verbatimCoordinates
- georeferenceRemarks
- minimumElevationInMeters
- maximumElevationInMeters
- habitat
- occurrenceRemarks
- disposition
- identifiedBy
- rightsHolder
- accessRights
- basisOfRecord

## Filtrado Espacial

El paquete permite filtrar los datos por边界 administrativas del Ecuador usando datos de GADM:

- **Provincia** (nivel 1): Ejemplo "Loja", "Pichincha", "Azuay"
- **Cantón** (nivel 2): Ejemplo "Loja", "Cuenca"
- **Parroquia** (nivel 3): Ejemplo "San Sebastian"

Si se especifica un nombre inválido, la función mostrará las opciones disponibles.

## Mapa Interactivo

Cuando `map = TRUE`, se genera un mapa interactivo con leaflet que muestra:
- Los puntos de occurrence
- El polígono del área de filtrado (si se especifica province/canton/parish)

## Notas

- El paquete utiliza web scraping para obtener los datos
- Solo descarga registros que tienen coordenadas válidas
- Elimina duplicados por coordenadas
- Respeta el delay entre requests para no sobrecargar el servidor
- Usa GADM para el filtrado espacial
