
library(httr)
r <- GET("https://data.oceannetworks.ca/api/deviceCategories", 
         query = list(method="get", 
                      token="YOUR_TOKEN_HERE", #>replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
                      propertyCode="differentialtemperature"))

if (http_error(r)) {
  if (r$status_code == 400){
    error = content(r)
    str(error)
  } else {
    str(http_status(r)$message)
  }
} else {
  deviceCategories = content(r)
  for (deviceCategory in deviceCategories){
    str(deviceCategory)
  }
}
