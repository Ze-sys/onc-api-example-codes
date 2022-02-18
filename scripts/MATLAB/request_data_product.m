
%% Example tested on Matlab R2018b, Ubuntu 18.04 on Dec 03, 2021.
%%
token = 'YOUR_TOKEN_HERE';                     % replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
baseUrl = 'https://data.oceannetworks.ca/api/dataProductDelivery';
[OPERATING_SYSTEM,~,~] = computer;

if strcmp(OPERATING_SYSTEM,'GLNXA64') ||  strcmp(OPERATING_SYSTEM,'MACI64')
    % 64-bit Linux® or macOS platforms  
    outPath = '~/Downloads/';
else
    % 64-bit Windows® platform
    outPath ='c:\temp';
end
 
requestId = requestDataProduct(baseUrl,token);
 
fprintf('Request Id: %i\n',requestId);
 
runs = runDataProduct(baseUrl,token,requestId);
 
if (isempty(runs))
    return
end
 
for i=1:numel(runs)
    run = runs(i);
    fprintf('Run Id: %i',run.dpRunId);
     
    indx = 1;       % Index Number of file to download.
                        %Because the number of files are not known until the process is complete,
                        % we try the next index until we get back a 404 status indicating that we are beyond the end of the array
    while 1
        downloadResult = downloadDataProductIndex(baseUrl,token,run.dpRunId,indx,outPath,0,0,100);
        if (numel(fieldnames(downloadResult)) >= 1)
            indx = indx+1;
        else
            break;
        end
    end
end
 
 
function requestId = requestDataProduct(baseUrl,token)
    url = [baseUrl, ...
            '?method=request' ...
            sprintf('&token=%s',token) ...                           
            '&locationCode=BACAX' ...                               % Barkley Canyon / Axis (POD 1)
            '&deviceCategoryCode=ADCP2MHZ' ...                      % 150 kHz Acoustic Doppler Current Profiler
            '&dataProductCode=TSSD' ...                             % Time Series Scalar Data
            '&extension=csv' ...                                    % Comma Separated spreadsheet file
            '&dateFrom=2016-07-21T00:00:00.000Z' ...                   % The datetime of the first data point (From Date)
            '&dateTo=2016-07-22T00:00:00.000Z' ... %2016-08-01T00:00:00.000Z' ...                     % The datetime of the last data point (To Date)
            '&dpo_qualityControl=1' ...                             % The Quality Control data product option - See https://wiki.oceannetworks.ca/display/DP/1
            '&dpo_resample=none' ...                                % The Resampling data product option - See https://wiki.oceannetworks.ca/display/DP/1
            '&dpo_dataGaps=0'];                                     % The Data Gaps data product option - See https://wiki.oceannetworks.ca/display/DP/1
    requestId = 0;
    request = matlab.net.http.RequestMessage;
    uri = matlab.net.URI(url);
    options = matlab.net.http.HTTPOptions('ConnectTimeout',60);
    response = send(request,uri,options);
    if (response.StatusCode == 200)    % HTTP Status - OK
        requestInfo = response.Body.Data;
        requestId = requestInfo.dpRequestId;
    elseif (response.StatusCode == 400) % HTTP Status - Bad Request
        disp(response.Body.Data.errors);
    else % all other HTTP Statuses
        disp(char(response.StatusLine));
    end
end
  
 
function runs = runDataProduct(baseUrl,token,requestId)
    url = [baseUrl, ...
            '?method=run' ...
            sprintf('&token=%s',token) ...                   
            sprintf('&dpRequestId=%i',requestId)];
    request = matlab.net.http.RequestMessage;
    uri = matlab.net.URI(url);
    options = matlab.net.http.HTTPOptions('ConnectTimeout',60);
    response = send(request,uri,options);
%     if (response.StatusCode = ~isempty(find([200,202]))) % HTTP Status is 200 - OK or 202 - Accepted
    if (response.StatusCode==200) || (response.StatusCode==202) % HTTP Status is 200 - OK or 202 - Accepted
        runs = response.Body.Data;
    elseif (response.StatusCode == 400) % HTTP Status - Bad Request
        errors = response.Body.Data.errors;
        for i=1:numel(errors)
            disp(errors(i));
        end
    else % all other HTTP Statuses
        disp(char(response.StatusLine));
    end
end
  
 
function downloadResult = downloadDataProductIndex(baseUrl, ...
                                                    token, ...
                                                    runId, ...
                                                    indx, ...
                                                    outPath, ...
                                                    fileCount, ...
                                                    estimatedProcessingTime, ...
                                                    maxRetries)
    url = [baseUrl ...
           '?method=download' ...
           sprintf('&token=%s',token) ...
           sprintf('&dpRunId=%i',runId) ...
           sprintf('&index=%i',indx)];
     
    defaultSleepTime = 2;
    downloadResult = struct();
    tryCount = 0;
    lastMessage = '';
     
    if (estimatedProcessingTime > 1)
        sleepTime = estimatedProcessingTime * 0.5;
    else
        sleepTime = defaultSleepTime;
    end
     
    while 1
        tryCount = tryCount + 1;
        if (tryCount >= maxRetries)
            msg = sprintf('Maximum number of retries (%i) exceeded',maxRetries);
            fprintf(msg); % this fails sometimes. Won't fix it for now
            break;
        end
         
        request = matlab.net.http.RequestMessage;
        uri = matlab.net.URI(url);
        options = matlab.net.http.HTTPOptions('ConnectTimeout',60);
        response = send(request,uri,options);
        if (response.StatusCode == 200)        % HTTP OK
            fileName = '';
            size = 0;
            for i=1:numel(response.Header)
                fld = response.Header(i);
                if (fld.Name == "Content-Disposition")
                        S = strsplit(fld.Value,'=');
                        fileName = S(2);
                end
                if (fld.Name == "Content-Length")
                    size = fld.Value;
                end
            end
            fprintf('\n');
            file = sprintf('%s\\%s',outPath,fileName);
            if (fileCount == 0)
             fprintf("  Downloading %i '%s' (%s)", indx, fileName, convertSize(double(size)));
            else
                fprintf("  Downloading %i/%i '%s' (%s)", indx, fileCount, fileName, convertSize(double(size)));
            end
            
            matlabVersion = version('-release');
            year = str2double(matlabVersion(1:end-1));
            if year >= 2021
                fileID = fopen(file, 'w','n','ISO-8859-1');
            else
                fileID = fopen(file, 'w','n');
            end
        
            cleanID = onCleanup(@() fclose(fileID));
            fwrite(fileID,response.Body.Data);
             
            [downloadResult(:).url] = url;
             
            break;
        elseif (response.StatusCode == 202)     % Accepted - Result is not complete -> Retry
            payload = response.Body.Data;
            if (numel(payload) >=1)
                msg = payload.message;
                if ~(strcmp(msg,lastMessage))
                    fprintf('\n  %s',msg);
                    lastMessage = msg;
                else
                    fprintf('.');
                end
            else
                disp('Retrying');
            end
        elseif (response.StatusCode == 204)     % No Content - No Data Found
            payload = response.Body.Data;
            if (numel(payload) >=1)
                msg = sprintf('  %s [%i]',payload.message,response.StatusCode);
            else
                msg = 'No Data Found';
            end
            disp(msg)
            break;
        elseif (response.StatusCode == 404)     % Not Found - Beyond End of Index - Index # > Results Count
            downloadResult = struct();
            break;
        elseif (response.StatusCode == 410)     % Gone - file does not exist on the FTP server. It may not hae been transferred to the FTP server yet
            payload = response.Body.Data;
            if (numel(payload) >=1)
                msg = payload.message;
                if ~(strcmp(msg,lastMessage))
                    fprintf('\n  %s',msg);
                    lastMessage = msg;
                else
                    fprintf('.');
                end
            else
                disp('Running... Writing File.');
            end
        elseif (response.StatusCode == 400) % HTTP BadRequest
            fprintf('\n');
            errors = response.Body.Data.errors;
            for i=1:numel(errors)
                disp(errors(i));
            end
            break;
        else % all other HTTP Statuses
            fprintf('\n');
            disp(response.Body.Data);
            break;
        end
         
        if (tryCount <= 5) && (sleepTime > defaultSleepTime)
           sleepTime = sleepTime * 0.5;
        end
        pause(sleepTime);
         
    end
end
  
 
function sizeString = convertSize(size)
    if (size == 0)
        sizeString = '0 KB';
    else
        sizeName = {'B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'};
        i = int64(floor(log(size)/ log(1024)));
        p = power(1024,i);
        s = round(size/double(p),2);
        sizeString = sprintf('%g %s', s, string(sizeName(i+1)));
    end
end
