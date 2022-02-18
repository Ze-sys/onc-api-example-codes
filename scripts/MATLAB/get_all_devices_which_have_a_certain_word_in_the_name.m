
url = ['https://data.oceannetworks.ca/api/devices' ...
        '?method=get' ...
        '&token=YOUR_TOKEN_HERE' ...           %replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
        '&locationCode=BACAX' ...
        '&propertyCode=seawatertemperature' ...
        '&dateFrom=2010-07-01T00:00:00.000Z' ...
        '&dateTo=2011-06-30T23:59:59.999Z'];

request = matlab.net.http.RequestMessage;
uri = matlab.net.URI(url);
options = matlab.net.http.HTTPOptions('ConnectTimeout',60);
 
response = send(request,uri,options);
 
if (response.StatusCode == 200)    % HTTP Status - OK
    devices = response.Body.Data;
    for i=1:numel(devices)
        device = devices(i);
        disp(device);
    end
elseif (response.StatusCode == 400) % HTTP Status - Bad Request
    disp(response.Body.Data.errors);
else % all other HTTP Statuses
    disp(char(response.StatusLine));
end
