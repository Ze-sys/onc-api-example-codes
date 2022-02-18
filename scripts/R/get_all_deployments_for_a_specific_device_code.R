
library(httr)
r <- GET("https://data.oceannetworks.ca/api/deployments", 
         query = list(method="get", 
                      token="YOUR_TOKEN_HERE", #>replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
                      locationCode="BACAX",
                      propertyCode="seawatertemperature",
                      dateFrom="2010-07-01T00:00:00.000Z",
                      dateTo="2011-06-30T23:59:59.999Z"))

if (http_error(r)) {
  if (r$status_code == 400){
    error = content(r)
    str(error)
  } else {
    str(http_status(r)$message)
  }
} else {
  deployments = content(r)
  for (deployment in deployments){
    str(deployment)
  }
}
