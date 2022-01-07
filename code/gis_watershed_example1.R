
# setup -------------------------------------------------------------------

pacman::p_load(tidyverse,
               sf,
               raster,
               stars,
               whitebox,
               foreach)


# extract stream grid -----------------------------------------------------

## read raster - upstream catchment area
wgs84_upa <- raster("data_raw/n35w090_upa.tif")

## extract stream grids (>= 1 sq-km)
stream_grid_1sqkm <- calc(wgs84_upa,
                          fun = function(x) ifelse(x >= 1, 1, NA))

## save the raster file
writeRaster(stream_grid_1sqkm,
            filename = "data_fmt/epsg4326_stream_grid_1sqkm",
            format = "GTiff",
            overwrite = TRUE)  


# snapping ----------------------------------------------------------------

## read channel
wgs84_channel <- st_read(dsn = "data_fmt",
                         layer = "epsg4326_str_net",
                         drivers = "ESRI Shapefile")
utm_channel <- st_transform(wgs84_channel, crs = 32616)

## read outlet points
wgs84_outlet <- st_read(dsn = "data_raw/epsg4326_outlet_sample.gpkg")
utm_outlet <- st_transform(wgs84_outlet, crs = 32616)

## snap points to the nearest polyline
source("code/function_st_snap_points.R")
utm_outlet_snap <- st_snap_points(x = utm_outlet,
                                  y = utm_channel) %>% 
  st_as_sf()

wgs84_outlet_snap <- st_transform(utm_outlet_snap,
                                  crs = 4326)

## export to check snapped file in QGIS
st_write(wgs84_outlet_snap,
         dsn = "data_fmt/epsg4326_outlet_sample_snap.gpkg",
         append = FALSE)


# watershed delineation ---------------------------------------------------
# whitebox functions cannot take path including whitespace
# gis files for whitebox is saved in temporary directory

## read flow direction raster
wgs84_dir_arc <- raster("data_raw/n35w090_dir.tif")

## convered arc format to d8 format
source("code/function_arc2d8.R")
wgs84_dir_d8 <- arc2d8(wgs84_dir_arc)
temp_d8 <- paste(tempdir(), "epsg4326_dir_d8.tif", sep = "\\") # temporary file name

## save gis files to temporary directory
st_write(wgs84_outlet_snap,
         dsn = tempdir(),
         "outlet",
         driver = "ESRI Shapefile",
         append = FALSE)

writeRaster(wgs84_dir_d8,
            temp_d8,
            overwrite = TRUE)

## watershed raster file name
wsd <- paste(tempdir(), "epsg4326_watershed.tif", sep = "\\")

wbt_watershed(d8_pntr = temp_d8,
              pour_pts = paste(tempdir(), "outlet.shp", sep = "\\"), 
              output = wsd)

## watershed raster to watershed polygon
wgs84_wsd_shape <- NULL
wgs84_wsd_shape <- raster(wsd) %>% 
  st_as_stars() %>% 
  st_as_sf(merge = TRUE,
           as_points = FALSE)

st_write(wgs84_wsd_shape,
         dsn = "data_fmt/wgs84_watershed.gpkg",
         append = FALSE)

