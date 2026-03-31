#' Download occurrence data from BNDB Ecuador
#'
#' @aliases rbndb
#' @param scientific_name Scientific name of the species (e.g., "Cedrela odorata", "Alnus acuminata", "Vismia baccifera")
#' @param max_pages Maximum number of pages to download (default 10, range: 1-100)
#' @param delay Delay between requests in seconds (default 0.5)
#' @param polygon SpatialPolygonsDataFrame, sf object, or file path to shapefile/GeoJSON.
#'   If provided, filters occurrences to within the polygon.
#' @param filt If TRUE, filters records to valid Ecuador coordinates, removes duplicates and NA (default FALSE).
#' @param filetype Output format: "csv" (default) or "excel".
#' @param out_file Output filename without extension (if NULL, returns object in R)
#' @return Data frame with occurrence data
#' @export
#' @importFrom rvest read_html html_text html_nodes html_attr
#' @importFrom sf st_as_sf st_transform st_intersection st_read st_crs
#' @examples
#' \dontrun{
#' # Download all records for a species (all Ecuador)
#' occ <- download_bndb("Cedrela odorata")
#'
#' # Download with filtering (Ecuador boundaries, no duplicates, no NA)
#' occ <- download_bndb("Alnus acuminata", filt = TRUE)
#'
#' # Download filtered by a shapefile
#' occ <- download_bndb("Alnus acuminata", polygon = "path/to/polygon.shp")
#'
#' # Save as CSV
#' download_bndb("Cedrela odorata", filetype = "csv", out_file = "data")
#'
#' # Save as Excel
#' download_bndb("Cedrela odorata", filetype = "excel", out_file = "data")
#' }

download_bndb <- function(scientific_name,
                         max_pages = 10,
                         delay = 0.5,
                         polygon = NULL,
                         filt = FALSE,
                         filetype = "csv",
                         out_file = NULL) {

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

  message("Download complete. Total records with coordinates: ", nrow(all_occurrences))

  if (nrow(all_occurrences) == 0) {
    message("No records found.")
    return(NULL)
  }

  if (filt) {
    message("Applying filter: Ecuador bounds, removing duplicates and NA...")
    
    all_occurrences <- all_occurrences[!is.na(all_occurrences$decimalLatitude), ]
    all_occurrences <- all_occurrences[!is.na(all_occurrences$decimalLongitude), ]
    
    all_occurrences <- all_occurrences[all_occurrences$decimalLatitude != 0 & 
                                        all_occurrences$decimalLongitude != 0, ]
    
    all_occurrences <- all_occurrences[all_occurrences$decimalLatitude >= -5 & 
                                        all_occurrences$decimalLatitude <= 2, ]
    all_occurrences <- all_occurrences[all_occurrences$decimalLongitude >= -82 & 
                                        all_occurrences$decimalLongitude <= -75, ]
    
    all_occurrences <- all_occurrences[!duplicated(
      paste(all_occurrences$decimalLatitude, all_occurrences$decimalLongitude)
    ), ]
    
    message("Filtered to ", nrow(all_occurrences), " valid records")
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

    filter_region <- sf::st_transform(filter_region, crs = 4326)

    message("Filtering points by polygon...")

    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = 4326)

    occ_filtered <- sf::st_intersection(occ_sf, filter_region)

    if (nrow(occ_filtered) == 0) {
      message("No records found within the specified polygon")
      return(NULL)
    }

    all_occurrences <- as.data.frame(occ_filtered)
    all_occurrences <- all_occurrences[, !names(all_occurrences) %in% c("geometry")]

    message("Filtered to ", nrow(all_occurrences), " records within polygon")
  }

  if (!is.null(out_file)) {
    if (filetype == "csv") {
      message("Saving as CSV")
      
      if (!grepl("\\.csv$", out_file)) {
        out_file <- paste0(out_file, ".csv")
      }
      write.csv(all_occurrences, out_file, row.names = FALSE)
      message("Saved to: ", out_file)
    } else if (filetype == "excel") {
      message("Saving as Excel")
      
      if (!grepl("\\.xlsx$", out_file)) {
        out_file <- paste0(out_file, ".xlsx")
      }
      openxlsx::write.xlsx(all_occurrences, out_file)
      message("Saved to: ", out_file)
    }
  }

  message("Done!")
  return(all_occurrences)
}
