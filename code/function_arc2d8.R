
arc2d8 <- function(x) {
  z <- 0:7
  fdir_d8 <- 2^z
  fdir_arc <- fdir_d8[c(8, 1:7)] * 3
  
  # unique pointer values for ArcGIS flow direction
  x <- x * 3
  
  for(i in seq_len(length(fdir_d8))) {
    x[x == fdir_arc[i]] <- fdir_d8[i]
  }
  
  # remove unassigned cells
  us <- c(247, 255) * 3
  x[x %in% us] <- NA
  
  return(x)  
}