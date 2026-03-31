# rbndb

Paquete de R para descargar datos de ocurrencia del Banco Nacional de Datos de Biodiversidad (BNDB) del Ecuador mediante web scraping.

## Instalación

```r
# Install from GitHub
devtools::install_github("ErickAngamarca/rbndb")

library(rbndb)
```

## Uso

```r
library(rbndb)

# Descargar datos para una especie (todo Ecuador)
occ <- download_bndb("Cedrela odorata")

# Descargar datos filtrados por un archivo shapefile (CRS 32717)
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", crs = "EPSG:32717")

# Descargar datos filtrados por un archivo GeoJSON
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.geojson", crs = "EPSG:4326")

# Descargar datos usando un objeto sf
library(sf)
poly <- st_read("ruta/al/poligono.shp")
occ <- download_bndb("Cedrela odorata", polygon = poly, crs = "EPSG:32717")

# Guardar como CSV
download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", 
              output = "csv", out_file = "datos")

# Guardar como Shapefile (requiere especificar CRS)
download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", 
              output = "shp", out_file = "datos", crs = "EPSG:32717")

# Ver en mapa interactivo (requiere especificar CRS)
download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", map = TRUE, crs = "EPSG:4326")

# Especificar sistema de coordenadas WGS84
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", crs = "EPSG:4326")

# Especificar número de páginas
occ <- download_bndb("Cedrela odorata", max_pages = 5)
```

## Parámetros

| Parámetro | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `scientific_name` | character | Nombre científico de la especie (ej. "Cedrela odorata") | Sí |
| `max_pages` | numeric | Número máximo de páginas a descargar (default 10) | No |
| `delay` | numeric | Delay entre requests en segundos (default 0.5) | No |
| `polygon` | character/sf | Ruta a archivo (shp/geojson) u objeto sf/SpatialPolygons | No |
| `crs` | character | Sistema de coordenadas de salida (default "EPSG:32717") | Sí para output="shp" o map=TRUE |
| `output` | character | Formato de salida: "csv" o "shp" (default "csv") | No |
| `map` | logical | Si TRUE, muestra mapa interactivo con leaflet (default FALSE) | No |
| `out_file` | character | Nombre del archivo de salida (sin extensión) | No |

### Sistema de Coordenadas (crs)

El parámetro `crs` acepta cualquier código EPSG válido. Los más comunes para Ecuador son:

| CRS | Nombre | Uso recomendado |
|-----|--------|-----------------|
| `EPSG:32717` | WGS 84 / UTM zone 17S | **Default** - apropiado para Ecuador continental |
| `EPSG:4326` | WGS 84 | Sistema geográfico (latitud/longitud) |
| `EPSG:32617` | WGS 84 / UTM zone 17N | UTM norte |
| `EPSG:24877` | PSAD 56 / UTM zone 17S | Sistema histórico |

### Requisitos

- **Si `output = "shp"`**: Debe especificar `crs`
- **Si `map = TRUE`**: Debe especificar `crs`

### Formato de Polígono

El parámetro `polygon` acepta:
- Ruta a archivo shapefile: `"ruta/poligono.shp"`
- Ruta a archivo GeoJSON: `"ruta/poligono.geojson"`
- Objeto sf cargado en R
- Objeto SpatialPolygons del paquete sp

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

Para filtrar los datos por un área específica, proporciona un polígono mediante el parámetro `polygon`. El polígono puede ser:

1. **Archivo shapefile**: Archivos .shp con extensión
2. **Archivo GeoJSON**: Archivos .geojson o .json
3. **Objeto sf**: Un objeto sf cargado en R
4. **Objeto SpatialPolygons**: Del paquete sp

El paquete usa `sf::st_intersection` para recortar los puntos dentro del polígono.

## Mapa Interactivo

Cuando `map = TRUE`, se genera un mapa interactivo con leaflet que muestra:
- Los puntos de ocurrencia con popup conteniendo información de la especie
- El polígono del área de filtrado (si se especifica)

## Notas

- El paquete utiliza web scraping para obtener los datos del BNDB
- Solo descarga registros que tienen coordenadas válidas
- Elimina duplicados basándose en coordenadas
- Respeta el delay entre requests para no sobrecargar el servidor

## Dependencias

El paquete requiere las siguientes librerías:
- httr
- rvest
- sf
- leaflet
- magrittr

## Autor

Erick Angamarca (erick.angamarca97@gmail.com)

## Referencias

- Banco Nacional de Datos de Biodiversidad (BNDB): https://bndb.sisbioecuador.bio
- GADM: https://gadm.org
- EPSG: https://epsg.org
