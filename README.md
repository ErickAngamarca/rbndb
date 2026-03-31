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
occ <- download_bndb("Vismia baccifera")

# Descargar datos filtrados por un archivo shapefile
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp")

# Descargar datos filtrados por un archivo GeoJSON
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.geojson")

# Descargar datos usando un objeto sf
library(sf)
poly <- st_read("ruta/al/poligono.shp")
occ <- download_bndb("Vismia baccifera", polygon = poly)

# Guardar como CSV
download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
              output = "csv", out_file = "datos")

# Guardar como Shapefile
download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
              output = "shp", out_file = "datos")

# Ver en mapa interactivo
download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", map = TRUE)

# Especificar sistema de coordenadas diferente
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
                     crs = "EPSG:4326")

# Especificar número de páginas
occ <- download_bndb("Escallonia micrantha", max_pages = 5)
```

## Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `scientific_name` | character | Nombre científico de la especie (ej. "Vismia baccifera") |
| `max_pages` | numeric | Número máximo de páginas a descargar (default 10, máx 1000 registros) |
| `delay` | numeric | Delay entre requests en segundos (default 0.5) |
| `polygon` | character/sf | Ruta a archivo (shp/geojson) u objeto sf/SpatialPolygons para filtrado espacial |
| `crs` | character | Sistema de coordenadas de salida |
| `output` | character | Formato de salida: "csv" o "shp" (default "csv") |
| `map` | logical | Si TRUE, muestra mapa interactivo con leaflet (default FALSE) |
| `out_file` | character | Nombre del archivo de salida (sin extensión). Si NULL, retorna objeto en R |

### Sistema de Coordenadas (crs)

El parámetro `crs` acepta cualquier código EPSG válido. Los más comunes para Ecuador son:

| CRS | Nombre | Uso recomendado |
|-----|--------|-----------------|
| `EPSG:32717` | WGS 84 / UTM zone 17S | **Default** - apropiado para Ecuador continental |
| `EPSG:32716` | WGS 84 / UTM zone 16S | Ecuador occidental |
| `EPSG:32718` | WGS 84 / UTM zone 18S | Ecuador oriental |
| `EPSG:4326` | WGS 84 | Sistema geográfico (latitud/longitud) - estándar GPS |
| `EPSG:32617` | WGS 84 / UTM zone 17N | UTM norte |
| `EPSG:32618` | WGS 84 / UTM zone 18N | UTM norte |
| `EPSG:32714` | WGS 84 / UTM zone 14S | Costa norte |
| `EPSG:32715` | WGS 84 / UTM zone 15S | Costa central |
| `EPSG:32713` | WGS 84 / UTM zone 13S | Sur de Ecuador |
| `EPSG:6248` | SIRGAS 2000 / UTM zone 17S | Sistema de referencia moderno Latinoamérica |
| `EPSG:24877` | PSAD 56 / UTM zone 17S | Sistema histórico usado en Ecuador |
| `EPSG:24878` | PSAD 56 / UTM zone 18S | Sistema histórico |
| `EPSG:24876` | PSAD 56 / UTM zone 16S | Sistema histórico |
| `EPSG:4248` | PSAD 56 | Sistema geográfico histórico |
| `EPSG:4269` | NAD 27 | Sistema norteamericano (poco usado) |
| `EPSG:26717` | NAD 27 / UTM zone 17N | Sistema histórico |

**Nota**: Ecuador ha usado varios sistemas de coordenadas históricamente. PSAD 56 es común en datos antiguos, mientras que WGS84/SIRGAS 2000 es el estándar actual.

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
- El polígono debe estar en WGS84 (EPSG:4326) o en un sistema proyectado
- Los datos originales del BNDB vienen en WGS84 (EPSG:4326)

## Dependencias

El paquete requiere las siguientes librerías:
- httr
- rvest
- sf
- leaflet

## Autor

Erick Angamarca (erick.angamarca97@gmail.com)

## Referencias

- Banco Nacional de Datos de Biodiversidad (BNDB): https://bndb.sisbioecuador.bio
- GADM: https://gadm.org
- EPSG: https://epsg.org
