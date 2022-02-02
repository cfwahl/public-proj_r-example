
# setup -------------------------------------------------------------------

pacman::p_load(tidyverse,
               sf,
               raster,
               mapview)


# data --------------------------------------------------------------------

## sampling sites
utm_sf_outlet <- st_read(dsn = "data_raw/watersheds/watershed1",
                         layer = "epsg3722_sites_ws1",
                         drivers = "ESRI Shapefile")

## stream channel
utm_sf_channel <- st_read(dsn = "data_raw/watersheds/watershed1",
                          layer = "epsg3722_StrNet_ws1",
                          drivers = "ESRI Shapefile")

## extract coordinates in a matrix format
m_coord <- utm_sf_outlet %>% 
  mutate(X = st_coordinates(.)[,1],
         Y = st_coordinates(.)[,2]) %>% 
  as_tibble() %>% 
  dplyr::select(X, Y) %>% 
  data.matrix()

## check map
mapview(utm_sf_channel) + mapview(utm_sf_outlet)


# distance matrix ---------------------------------------------------------

# create rasterized stream network
# extent from utm_channel
utm_rs_channel <- rasterize(utm_sf_channel,
                            raster(res = 10, ex = extent(utm_sf_channel)))

## change non-NA raster values
utm_rs_channel[!is.na(utm_rs_channel)] <- 1

## distance matrix object
m_distance <- NULL

for(i in seq_len(nrow(m_coord))) {
  
  ## reset the raster values
  channel <- utm_rs_channel
  
  ## replace the value of the origin cell with 2
  channel[cellFromXY(channel, m_coord[i,])] <- 2
  
  ## set origin value, omit value, for distance calculation
  utm_rs_dist <- gridDistance(channel,
                              origin = 2,
                              omit = NA)
  
  ## calculate distance from origin to all the other destinations
  grid_distance <- extract(utm_rs_dist, m_coord)
  
  ## column bind to form a distance matrix
  ## unit: m
  m_distance <- cbind(m_distance, grid_distance)
  
}
