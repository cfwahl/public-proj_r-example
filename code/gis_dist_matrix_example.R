###############  DISTANCE MATRIX  ###########################


# load packages
pacman::p_load(tidyverse, sf, raster, tibble)

# read sites
utm_outlet <- st_read(dsn = "watershed1",
                        layer = "epsg3722_sites_ws1",
                        drivers = "ESRI Shapefile")

# convert to UTM 15
#utm_outlet <- st_transform(wgs84_outlet, crs = 3722)

# create dataframe 
df <- utm_outlet %>% 
  mutate(X = st_coordinates(.)[,1],
         Y = st_coordinates(.)[,2]) %>% 
  as_tibble()


# UTM X (Longitude)
# coordinates are from utm_outlet 
L1 <- df$X

L2 <- df$Y

# combine xy coordinate columns. This is the structure needed for the loop 
Ls <- cbind(L1, L2)


## read channel
wgs84_channel <- st_read(dsn = "watershed1",
                         layer = "epsg3722_StrNet_ws1",
                         drivers = "ESRI Shapefile")

#utm_channel <- st_transform(wgs84_channel, crs = 3722)


extent(wgs84_channel)

# create rasterized stream network
# extent from utm_channel
# if "NA" produced, then increase res
rml <- rasterize(wgs84_channel, raster(res=10, ex=extent(c(223380,
                                                           243180,
                                                           4886235,
                                                           4905360))))
Dist <- NULL
for (i in c(1:(nrow(Ls)))) {
  rmlW <- rml # reset
  rmlW[cellFromXY(rmlW,Ls[i,])] <-2 # set starting point
  dst <- gridDistance(rmlW, origin=2, omit=NA)/1000 # distance from the start point in km
  dists <- raster::extract(dst, Ls)
  Dist <- cbind(Dist, dists)
}

# view distance among sites
Dist

write.csv(Dist,"watershed1\\site_dist2.csv", row.names = TRUE)
