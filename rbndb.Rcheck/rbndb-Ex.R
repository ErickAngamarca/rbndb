pkgname <- "rbndb"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('rbndb')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("download_bndb")
### * download_bndb

flush(stderr()); flush(stdout())

### Name: download_bndb
### Title: Download occurrence data from BNDB Ecuador
### Aliases: download_bndb rbndb

### ** Examples

## Not run: 
##D # Download all records for a species (all Ecuador)
##D occ <- download_bndb("Cedrela odorata")
##D 
##D # Download with filtering (Ecuador bounds, no duplicates, no NA)
##D occ <- download_bndb("Alnus acuminata", filt = TRUE)
##D 
##D # Download filtered by a shapefile
##D occ <- download_bndb("Alnus acuminata", polygon = "path/to/polygon.shp")
##D 
##D # Save as CSV
##D download_bndb("Cedrela odorata", filetype = "csv", out_file = "data")
##D 
##D # Save as Excel
##D download_bndb("Cedrela odorata", filetype = "excel", out_file = "data")
## End(Not run)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
