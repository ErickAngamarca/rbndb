#' Download occurrence data from BNDB Ecuador
#'
#' @aliases rbndb
#' @param scientific_name Scientific name of the species (e.g., "Cedrela odorata", "Alnus acuminata", "Vismia baccifera")
#' @param max_pages Maximum number of pages to download (default 10, range: 1-100)
#' @param delay Delay between requests in seconds (default 0.5)
#' @param polygon SpatialPolygonsDataFrame, sf object, or file path to shapefile/GeoJSON.
#'   If NULL, downloads all Ecuador. Can be a file path (e.g., "path/to/polygon.shp" or 
#'   "path/to/polygon.geojson") or an R object (sf/SpatialPolygons).
#' @param crs Coordinate reference system for output. Required if output = "shp" or map = TRUE.
#'   Supported CRS codes:
#'   - "EPSG:32717" - WGS 84 / UTM zone 17S (DEFAULT, for Ecuador)
#'   - "EPSG:32716" - WGS 84 / UTM zone 16S
#'   - "EPSG:32718" - WGS 84 / UTM zone 18S
#'   - "EPSG:4326" - WGS 84 (latitude/longitude)
#'   - "EPSG:32617" - WGS 84 / UTM zone 17N
#'   - "EPSG:32618" - WGS 84 / UTM zone 18N
#'   - "EPSG:32714" - WGS 84 / UTM zone 14S
#'   - "EPSG:32715" - WGS 84 / UTM zone 15S
#'   - "EPSG:32713" - WGS 84 / UTM zone 13S
#'   - "EPSG:6248" - SIRGAS 2000 / UTM zone 17S
#'   - "EPSG:6247" - SIRGAS 2000 / UTM zone 16S
#'   - "EPSG:24877" - PSAD 56 / UTM zone 17S (historical)
#'   - "EPSG:24878" - PSAD 56 / UTM zone 18S
#'   - "EPSG:24876" - PSAD 56 / UTM zone 16S
#'   - "EPSG:4248" - PSAD 56 (geographic)
#'   - "EPSG:4269" - NAD 27 (geographic)
#' @param output Output format: "csv" (default) or "shp". If "shp", crs must be specified.
#' @param map If TRUE, display simple plot map (default FALSE).
#'   Requires crs to be specified.
#' @param out_file Output filename without extension (if NULL, returns object in R)
#' @return Data frame with occurrence data
#' @export
#' @importFrom httr GET
#' @importFrom rvest read_html html_text html_nodes html_attr
#' @importFrom sf st_as_sf st_transform st_intersection st_read st_write st_crs
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' # Download all records for a species (all Ecuador)
#' occ <- download_bndb("Cedrela odorata")
#'
#' # Download records filtered by a shapefile
#' occ <- download_bndb("Alnus acuminata", polygon = "path/to/polygon.shp", crs = "EPSG:4326")
#'
#' # Save as CSV
#' download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", 
#'               output = "csv", out_file = "data")
#'
#' # Save as shapefile in UTM (crs required)
#' download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", 
#'               output = "shp", out_file = "data", crs = "EPSG:32717")
#'
#' # Display interactive map (crs required)
#' download_bndb("Alnus acuminata", polygon = "path/to/polygon.shp", 
#'               map = TRUE, crs = "EPSG:4326")
#' }

download_bndb <- function(scientific_name,
                          max_pages = 10,
                          delay = 0.5,
                          polygon = NULL,
                          crs = NULL,
                          output = "csv",
                          map = FALSE,
                          out_file = NULL) {

  if (output == "shp" && is.null(crs)) {
    stop("CRS must be specified when output = 'shp'. Use crs = 'EPSG:32717' or crs = 'EPSG:4326'")
  }
  
  if (map && is.null(crs)) {
    stop("CRS must be specified when map = TRUE. Use crs = 'EPSG:32717' or crs = 'EPSG:4326'")
  }
  
  if (is.null(crs)) {
    crs <- "EPSG:4326"
  }

  message("Starting BNDB download for: ", scientific_name)

  all_occurrences <- data.frame()

  base_url <- "https://bndb.sisbioecuador.bio/bndb/collections/list.php"

  for (page in 1:max_pages) {
    url <- paste0(base_url, "?taxa=", utils::URLencode(scientific_name),
                  "&taxontype=2&page=", page)

    tryCatch({
      pg <- rvest::read_html(url)

      occ_ids <- rvest::html_attr(rvest::html_nodes(pg, 'input[name="occid[]"]'), 'value')

      if (length(occ_ids) == 0) {
        message("No more records on page ", page)
        break
      }

      message("Page ", page, ": ", length(occ_ids), " records")

      for (i in seq_along(occ_ids)) {
        occ_id <- occ_ids[i]
        Sys.sleep(delay)

        occ_url <- paste0("https://bndb.sisbioecuador.bio/bndb/collections/individual/index.php?occid=", occ_id)

        tryCatch({
          occ_pg <- rvest::read_html(occ_url)
          body_text <- rvest::html_text(rvest::html_node(occ_pg, 'body'))

          extractor_simple <- function(inicio, fin) {
            pattern <- paste0(inicio, ".*?", fin)
            match <- regmatches(body_text, regexec(pattern, body_text))[[1]]
            if (length(match) == 0) return(NA)
            valor <- sub(inicio, "", match[1])
            gsub("^[[:space:]]+|[[:space:]]+$", "", valor)
          }

          lat <- NA
          lon <- NA

          coord_line <- NA
          if (grepl("Coordinates:", body_text)) {
            coord_start <- regexpr("Coordinates:", body_text)[1]
            coord_end <- regexpr("\n", substring(body_text, coord_start + 1))[1] + coord_start
            coord_line <- substring(body_text, coord_start + 12, coord_end - 1)
          }
          
          if (!is.na(coord_line) && coord_line != "") {
            coord_line_clean <- gsub("\u00b0", " ", coord_line)
            coord_line_clean <- gsub("\u00b4|\u0027|\u2032|\u2033", " ", coord_line_clean)
            coord_line_clean <- gsub("[''']", " ", coord_line_clean)
            coord_line_clean <- gsub("\\s+", " ", coord_line_clean)
            coord_line_clean <- gsub(";", " ", coord_line_clean)
            coord_line_clean <- trimws(coord_line_clean)
            
            nums <- as.numeric(unlist(regmatches(coord_line_clean, gregexpr("[0-9]+", coord_line_clean))))
            
            dirs <- unlist(regmatches(coord_line_clean, gregexpr("[NSnsEWew]", coord_line_clean)))
            dirs <- toupper(dirs)
            
            lat <- NA
            lon <- NA
            
            if (length(nums) >= 4) {
              lat_deg <- nums[1]
              lat_min <- nums[2]
              lat_sec <- ifelse(length(nums) >= 6, nums[3], 0)
              lat_dir <- ifelse(dirs[1] == "S", "S", "N")
              lat <- lat_deg + lat_min/60 + lat_sec/3600
              if (lat_dir == "S") lat <- -lat
              
              lon_deg <- nums[ifelse(length(nums) >= 6, 4, 3)]
              lon_min <- nums[ifelse(length(nums) >= 6, 5, 4)]
              lon_sec <- ifelse(length(nums) >= 6, nums[6], 0)
              lon_dir <- ifelse(dirs[2] == "W", "W", "E")
              lon <- lon_deg + lon_min/60 + lon_sec/3600
              if (lon_dir == "W") lon <- -lon
            } else if (length(nums) >= 2) {
              lat <- nums[1]
              lon <- nums[2]
              if (any(dirs == "S")) lat <- -abs(lat)
              if (any(dirs == "W")) lon <- -abs(lon)
            }
            
            if (is.na(lat) || is.na(lon)) {
              nums <- strsplit(coord_line, '[^0-9.-]')[[1]]
              nums <- nums[nchar(nums) > 0]
              nums <- nums[!is.na(suppressWarnings(as.numeric(nums)))]
              if (length(nums) >= 2) {
                lat <- as.numeric(nums[1])
                lon <- as.numeric(nums[2])
              }
            }
          }
          
          if (is.na(lat) || is.na(lon)) {
            coord_pattern <- "([0-9]+\\.[0-9]+)[\\u00b0]?\\s*[NS]?.*?\\s*([0-9]+\\.[0-9]+)[\\u00b0]?\\s*[EW]?"
            matches <- gregexpr(coord_pattern, body_text, perl = TRUE)
            regm <- matches[[1]]
            if (regm[1] > 0) {
              txt <- substr(body_text, regm[1], attr(regm, "match.length")[1] + regm[1] - 1)
              nums <- strsplit(txt, '[^0-9.-]')[[1]]
              nums <- nums[nchar(nums) > 0]
              nums <- nums[!is.na(suppressWarnings(as.numeric(nums)))]
              if (length(nums) >= 2) {
                lat_val <- as.numeric(nums[1])
                lon_val <- as.numeric(nums[2])
                if (lat_val > -5 && lat_val < 2 && lon_val > -82 && lon_val < -75) {
                  lat <- lat_val
                  lon <- lon_val
                } else if (lon_val > -5 && lon_val < 2 && lat_val > -82 && lat_val < -75) {
                  lat <- lon_val
                  lon <- lat_val
                }
              }
            }
          }

          elev <- NA
          elev_pattern <- "Elevation:([0-9]+)"
          elev_match <- regmatches(body_text, regexec(elev_pattern, body_text))[[1]]
          if (length(elev_match) > 1) {
            elev <- as.numeric(elev_match[2])
          }

          registro <- data.frame(
            occurrenceID = occ_id,
            scientificName = scientific_name,
            taxon = extractor_simple("Taxon:", "\n"),
            family = extractor_simple("Family:", "\n"),
            catalogNumber = extractor_simple("Catalog #:", "\n"),
            recordedBy = extractor_simple("Collector:", "\n"),
            recordNumber = extractor_simple("Number:", "\n"),
            eventDate = extractor_simple("Date:", "Verbatim"),
            verbatimEventDate = extractor_simple("Verbatim Date:", "\n"),
            locality = extractor_simple("Locality:", "\n"),
            decimalLatitude = lat,
            decimalLongitude = lon,
            verbatimCoordinates = extractor_simple("Verbatim Coordinates:", "\n"),
            georeferenceRemarks = extractor_simple("Location Remarks:", "\n"),
            minimumElevationInMeters = elev,
            maximumElevationInMeters = elev,
            habitat = extractor_simple("Habitat:", "\n"),
            occurrenceRemarks = extractor_simple("Description:", "\n"),
            disposition = extractor_simple("Disposition:", "\n"),
            identifiedBy = extractor_simple("Determiner:", "\n"),
            rightsHolder = extractor_simple("Rights Holder:", "\n"),
            accessRights = extractor_simple("Access Rights:", "\n"),
            basisOfRecord = "HumanObservation",
            stringsAsFactors = FALSE
          )

          if (!is.na(registro$decimalLatitude) && !is.na(registro$decimalLongitude)) {
            all_occurrences <- rbind(all_occurrences, registro)
          }

        }, error = function(e) { })

        if (i %% 10 == 0) message("  Processed ", i, "/", length(occ_ids))
      }

    }, error = function(e) {
      message("Error on page ", page, ": ", e$message)
      return(all_occurrences)
    })
  }

  if (nrow(all_occurrences) > 0) {
    all_occurrences <- all_occurrences[!duplicated(
      paste(all_occurrences$decimalLatitude, all_occurrences$decimalLongitude)
    ), ]
  }

  message("Download complete. Total records with coordinates: ", nrow(all_occurrences))

  if (nrow(all_occurrences) == 0) {
    message("No records found.")
    return(NULL)
  }

  if (!is.null(polygon)) {
    message("Applying spatial filter...")

    if (is.character(polygon)) {
      message("Reading polygon from file: ", polygon)
      filter_region <- sf::st_read(polygon, quiet = TRUE)
    } else {
      filter_region <- polygon
    }

    if (inherits(filter_region, "SpatialPolygons")) {
      filter_region <- sf::st_as_sf(filter_region)
    }

    polygon_crs <- sf::st_crs(filter_region)
    
    if (is.null(crs)) {
      crs <- "EPSG:4326"
    }
    
    filter_region <- sf::st_transform(filter_region, crs = crs)

    message("Filtering points by polygon...")

    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = 4326)

    occ_sf_transformed <- sf::st_transform(occ_sf, crs = crs)

    occ_filtered <- sf::st_intersection(occ_sf_transformed, filter_region)

    if (nrow(occ_filtered) == 0) {
      message("No records found within the specified polygon")
      return(NULL)
    }

    all_occurrences <- as.data.frame(occ_filtered)
    all_occurrences <- all_occurrences[, !names(all_occurrences) %in% c("geometry")]
    
    if (crs != "EPSG:4326" && crs != 4326) {
      all_occurrences$decimalLatitude <- sf::st_coordinates(occ_filtered)[, 2]
      all_occurrences$decimalLongitude <- sf::st_coordinates(occ_filtered)[, 1]
    }

    message("Filtered to ", nrow(all_occurrences), " records within polygon")
  }

  if (map) {
    message("Generating map...")

    occ_for_map <- all_occurrences[!is.na(all_occurrences$decimalLatitude) & 
                                    !is.na(all_occurrences$decimalLongitude), ]
    
    if (nrow(occ_for_map) == 0) {
      message("No records with valid coordinates to display on map")
    } else {
      if (!is.null(polygon)) {
        if (exists("filter_region")) {
          polygon_map <- filter_region
        } else {
          if (is.character(polygon)) {
            polygon_map <- sf::st_read(polygon, quiet = TRUE)
          } else {
            polygon_map <- polygon
          }
          if (inherits(polygon_map, "SpatialPolygons")) {
            polygon_map <- sf::st_as_sf(polygon_map)
          }
        }
        polygon_map <- sf::st_transform(polygon_map, crs = 4326)
        
        plot(sf::st_geometry(polygon_map), col = "lightblue", border = "blue", 
             main = paste("Occurrences of", scientific_name))
      } else {
        plot(occ_for_map$decimalLongitude, occ_for_map$decimalLatitude, 
             type = "p", main = paste("Occurrences of", scientific_name),
             xlab = "Longitude", ylab = "Latitude")
      }

      points(occ_for_map$decimalLongitude, occ_for_map$decimalLatitude, 
             pch = 20, col = "red")
      
      message("Displaying map...")
    }
  }

  if (!is.null(out_file)) {
    if (output == "shp") {
      message("Saving as shapefile in CRS: ", crs)
      
      occ_sf <- sf::st_as_sf(all_occurrences,
                            coords = c("decimalLongitude", "decimalLatitude"),
                            crs = 4326)
      
      if (!is.null(crs) && crs != "EPSG:4326" && crs != 4326) {
        occ_sf <- sf::st_transform(occ_sf, crs = crs)
      }
      
      if (!grepl("\\.shp$", out_file)) {
        out_file <- paste0(out_file, ".shp")
      }
      sf::st_write(occ_sf, out_file, delete_dsn = TRUE)
      message("Saved to: ", out_file)
    } else if (output == "csv") {
      message("Saving as CSV (WGS84 coordinates)")
      
      if (!grepl("\\.csv$", out_file)) {
        out_file <- paste0(out_file, ".csv")
      }
      write.csv(all_occurrences, out_file, row.names = FALSE)
      message("Saved to: ", out_file)
    }
  }

  message("Done!")
  return(all_occurrences)
}
