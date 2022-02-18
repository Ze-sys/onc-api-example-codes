
url = ['https://data.oceannetworks.ca/api/deviceCategories' ...
        '?method=get' ...
        '&token=YOUR_TOKEN_HERE' ...                          %replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
        '&propertyCode=differentialtemperature'];

request = matlab.net.http.RequestMessage;
uri = matlab.net.URI(url);
options = matlab.net.http.HTTPOptions('ConnectTimeout',60);
  
response = send(request,uri,options);
  
if (response.StatusCode == 200)    % HTTP Status - OK
    deviceCategories = response.Body.Data;
    for i=1:numel(deviceCategories)
        deviceCategory = deviceCategories(i);
        disp(deviceCategory);
    end
elseif (response.StatusCode == 400) % HTTP Status - Bad Request
    disp(response.Body.Data.errors);
else % all other HTTP Statuses
    disp(char(response.StatusLine));
end
