
getLocationsHierarchy()
 
function getLocationsHierarchy()
            
    url = ['https://data.oceannetworks.ca/api/locations?' ...
            '&method=getTree' ...
            '&token=YOUR_TOKEN_HERE'];							%replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.can/Profile when logged in.
            '&locationCode=MOBP'];

    request = matlab.net.http.RequestMessage;
    uri = matlab.net.URI(url);
    options = matlab.net.http.HTTPOptions('ConnectTimeout',60);

    response = send(request,uri,options);

    if (response.StatusCode == 200)    % HTTP Status - OK
        locations = response.Body.Data;
        
        for i=1:numel(locations)
            location = locations(i);
            
            disp(sprintf('%s - %s',location.locationCode,location.locationName));
            
            if (numel(location.children) >= 1)
                for c=1:numel(location.children)
                    getLocationChild(location.children(c),1);
                end
            end
        end
    elseif (response.StatusCode == 400) % HTTP Status - Bad Request
        disp(response.Body.Data.errors);
    else % all other HTTP Statuses
        disp(char(response.StatusLine));
    end
end

function getLocationChild(location,level)
    sTab = '';
    for t=1:level
        sTab = sprintf('\t %s',sTab);
    end
    
    disp(sprintf('%s %s - %s',sTab, location.locationCode,location.locationName));
            
    if (numel(location.children) >= 1)
        for c=1:numel(location.children)
            getLocationChild(location.children(c),level + 1);
        end
    end
end
