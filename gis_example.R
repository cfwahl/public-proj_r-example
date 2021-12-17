
# setup -------------------------------------------------------------------

pacman::p_load(tidyverse,
               sf,
               raster)


# read data ---------------------------------------------------------------

## raster - upstream catchment area
wgs84_upa <- raster("data_raw/n35w090_upa.tif")

## extract stream grids (>= 1 sq-km)
stream_grid_1sqkm <- calc(wgs84_upa,
                          fun = function(x) ifelse(x >= 1, 1, NA))

## save the raster file
writeRaster(stream_grid_1sqkm,
            filename = "data_fmt/epsg4326_stream_grid_1sqkm",
            format = "GTiff",
            overwrite = TRUE)  


