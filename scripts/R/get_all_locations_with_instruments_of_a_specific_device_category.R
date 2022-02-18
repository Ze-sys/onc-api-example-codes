
library(httr)


getChildLocation <- function(location,level){
  sTab = ""
  for (t in 1:level){
    sTab = sprintf("  %s",sTab)
  }
  
  cat(sprintf("%s%s - %s\n",sTab, location$locationCode,location$locationName))
  
  children=location$children
  newLevel=level+1
  for (child in children) {
    getChildLocation(child,newLevel)
  }
  return()
}


r <- GET("https://data.oceannetworks.ca/api/locations", 
         query = list(method="getTree", 
                      token="b6ede000-1865-4ac3-94ad-e87d8bdfd307", #>replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.can/Profile when logged in.
                      locationCode="MOBP"))
if (http_error(r)) {
  if (r$status_code == 400){
    error = content(r)
    str(error)
  } else {
    str(http_status(r)$message)
  }
} else {
  locations = content(r)
  for (location in locations){
    cat(sprintf("%s - %s\n",location$locationCode,location$locationName))
    children = location$children
    for (child in children) {
      getChildLocation(child,1)
    }
  }
}
