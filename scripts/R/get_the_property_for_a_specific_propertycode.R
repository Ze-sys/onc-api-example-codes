
library(httr)
r <- GET("https://data.oceannetworks.ca/api/properties", 
         query = list(method="get", 
                      token="YOUR_TOKEN_HERE", #>replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
                      deviceCategoryCode="ADCP150KHZ"))

if (http_error(r)) {
  if (r$status_code == 400){
    error = content(r)
    str(error)
  } else {
    str(http_status(r)$message)
  }
} else {
  properties= content(r)
  for (property in properties){
    str(property)
  }
}
