
# setup -------------------------------------------------------------------

pacman::p_load(riverdist,
               dplyr,
               sf)

# set working directory 

# data --------------------------------------------------------------------

# read sites
utm_sf_outlet <- st_read(dsn = "data_raw/watersheds/watershed1",
                         layer = "epsg3722_sites_ws1",
                         drivers = "ESRI Shapefile")

# create dataframe 
df <- utm_sf_outlet %>% 
  mutate(X = st_coordinates(.)[,1],
         Y = st_coordinates(.)[,2]) %>% 
  as_tibble()

# coordinates  from utm_sf_outlet 
df_coord <- df %>% 
  distinct(segment, X, Y)

# read in the network
strnet <- line2network(path="data_raw/watersheds/watershed1", 
                       layer="epsg3722_StrNet_ws1")


# prep stream netowrk and sites --------------------------------------------------

# plot of all the segments
plot(strnet)  

# check topology (nodes)
topologydots(strnet)

# do a clean up: dissolve - y, insert vertices - y, distance - 1, 
#     examine figure for mouth questions, remove additional segments - n, 
#     build segment routes - y
strnet_fixed <- cleanup(rivers = strnet)

# snap sites to stream network
site_snap <- xy2segvert(x=X, y=Y, rivers=strnet_fixed)

# add vertices
site_strnet <- bind_cols(utm_sf_outlet, site_snap)

# map
plot(x=strnet_fixed, color = FALSE)
points(X, Y, pch=16, col="red") # raw coords
riverpoints(seg=site_snap$seg, vert=site_snap$vert, rivers=strnet_fixed, 
            pch=16, cex=0.5, bg="forestgreen") # snapped coords
text(X, Y, labels=site_strnet$segment, pos = 4)


# distance matrix  --------------------------------------------------------

# create matrix of distances
dmat <- riverdistancemat(site_strnet$seg, site_strnet$vert, strnet_fixed, 
                         ID = site_strnet$segment ) %>% as.matrix
dmat <- dmat/1000 # convert to km

# write the data out
site_dists <- as.data.frame(dmat)
write.csv(site_dists,"data_raw/watersheds/watershed1\\siteXdist_ws1.csv", row.names = TRUE)

# flow direction ----------------------------------------------------------

# Mouth of network must be specified, get seg and vert from cleanup() above
setmouth(seg=213, vert=992, rivers=strnet_fixed)

# net = TRUE subtarcts downstream movement from upstream 
updmat <- upstreammat(seg = site_strnet$seg, vert = site_strnet$vert, 
                      rivers = strnet_fixed, 
                      ID = site_strnet$segment, net = TRUE) %>% as.matrix

updmat <- updmat/1000 # convert to km

# write the data out
site_dists <- as.data.frame(updmat)
write.csv(site_dists,"watershed1\\siteXdownstdist_ws1.csv", row.names = TRUE)

