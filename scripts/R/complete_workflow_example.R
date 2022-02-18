
library(httr)

main <- function(){
  baseUrl <- "https://data.oceannetworks.ca/api/dataProductDelivery"
  token <- "YOUR_REQUEST_ID_HERE		# replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
  outPath <- 'c:/temp'
  
  requestInfo <- requestDataProduct(baseUrl,token)
  if (is.null(requestInfo)){
    return()
  }
  cat(sprintf("Request Id: %s\n",requestInfo$dpRequestId))
  
  if (('numfiles' %in% names(requestInfo)) & 
      (suppressWarnings(all(!is.na(as.numeric(requestInfo$numFiles)))))){
    fileCount <- as.numeric(requestInfo$numFiles)
  }
  else {
    fileCount <- 1
  }
  
  if (('estimatedProcessingTime' %in% names(requestInfo)) 
      & (suppressWarnings(all(!is.na(as.numeric(requestInfo$estimatedProcessingTime)))))){
    estimatedProcessingTime <- as.numeric(requestInfo$estimatedProcessingTime)
  }
  else {
    estimatedProcessingTime <- 2
  }
  
  
  
  runs = runDataProduct(baseUrl,token,requestInfo$dpRequestId)
  if (is.null(runs)){
    return()
  }
  
  for (run in runs){
    cat(sprintf("Run Id: %s, Queue Position: %s",run$dpRunId,run$queuePosition))
    indx <- 1
    while (TRUE) {
      runId = run$dpRunId
      
      downloadResult <- downloadDataProductIndex(baseUrl, token, run$dpRunId, indx, outPath, fileCount, estimatedProcessingTime)
      if (length(downloadResult) >= 1){
        indx <- indx + 1;
      }
      else {
        break;
      }
    }
  }
}

requestDataProduct <- function(baseUrl,token) {
  response <- GET(baseUrl, 
                   query = list(method="request", 
                                token=token,
                                locationCode="BACAX",				      # Barkley Canyon / Axis (POD 1)
                                deviceCategoryCode="ADCP2MHZ",	  # 150 kHz Acoustic Doppler Current Profiler
                                dataProductCode="TSSD",			      # Time Series Scalar Data
                                extension="csv",					        # Comma Separated spreadsheet file
                                dateFrom="2016-07-27T00:00:00.000Z",
                                dateTo="2016-08-01T00:00:00.000Z",
                                dpo_qualityControl=1,
                                dpo_resample="none",
                                dpo_dataGaps=0)) 
  requestInfo <- NULL
  if (http_error(response)) {
    if (response$status_code == 400){
      error <- content(response)
      cat(error,'\n')
    } else {
      cat(http_status(response)$message,'\n')
    }
  } else {
    requestInfo = content(response)
  }
  return(requestInfo)
}

runDataProduct <- function(baseUrl,token,requestId) {
  response <- GET(baseUrl, 
                   query = list(method="run", 
                                token=token,
                                dpRequestId=requestId))	      #>replace YOUR_REQUEST_ID_HERE with a requestId number returned from the request method
  
  runs <- NULL
  if (http_error(response)) {
    if (response$status_code == 400){
      error <- content(response)
      cat(error,'\n')
    } else {
      cat(http_status(response)$message,'\n')
    }
  } else {
    runs <- content(response)
  }
  return(runs)
}
downloadDataProductIndex <- function(baseUrl, token, runId, indx=1, outPath='c:\temp', fileCount=1, estimatedProcessingTime=1, maxRetries=100){
  defaultSleepTime <- 2
  downloadResult <- list()
  tryCount <- 0
  lastMessage <- ''
  
  if (estimatedProcessingTime > 1){
    sleepTime <- estimatedProcessingTime * 0.5
  }
  else {
    sleepTime <- defaultSleepTime
  }
  
  while (TRUE) {
    tryCount <- tryCount + 1
    if (tryCount >= maxRetries) {
      cat(sprintf('Maximum number of retries (%i) exceeded',maxRetries))
      break
    }
    response <- GET(baseUrl, 
                    query = list(method="download", 
                                  token=token,
                                  dpRunId=runId,
                                  index=indx))        # for run requests that contain more than one file, change the index number to the index of the file you would like to download.
                                                        # If the index number does not exist an HTTP 410 and a message will be returned.
    if (response$status_code == 200){       # HTTP OK
      if (!dir.exists(outPath)){
        dir.create(outPath, recursive = TRUE)
      }
      
      fileName <- strsplit(response$headers$`content-disposition`,'=')[[1]][2];
      filePath <- sprintf("%s/%s",outPath,fileName)
      
      size <- response$headers$`content-length`;
      
      if (file.exists(filePath)){
        cat(sprintf("\n  Skipping, file '%s' already exists.", fileName))
      }
      else {
        if (fileCount == 0){
          cat(sprintf("\n  Downloading %s '%s' (%s)", toString(indx), fileName, convertSize(as.double(size))))
        }
        else{
          cat(sprintf("\n  Downloading %s/%i '%s' (%s)", toString(indx), fileCount, fileName, convertSize(as.double(size))))
        }
        
        fileID <- file(filePath,"wb")
        writeBin(content(response), fileID)
        close(fileID)
        
        
      }
      downloadResult[['file']] <- fileName;
      downloadResult[['url']] <- response$url;
      break
    }
    else if (response$status_code == 202){  # Accepted - Result is not complete -> Retry
      payload = content(response)
      if (!is.null(payload)){
        msg <- payload$message
        if (msg == lastMessage){
          cat('.')
        }
        else {
          cat(sprintf('\n  %s',msg))
          lastMessage <- msg
        }
      }
      else (
        cat('\n  Retrying...')
      )
    }
    else if (response$status_code == 204){  # No Content - No Data Found
      payload <- content(response)
      if (!is.null(payload)){ # 1
        msg <- sprintf('  %s [%i]',payload$message,response$StatusCode)
      }
      else {
        msg <- 'No Data Found'
      }
      cat(sprintf('\n  %s',msg))
      break
    }
    else if (response$status_code == 404){  # Not Found - Beyond End of Index - Index # > Results Count
      downloadResult <- list()
      break
    }
    else if (response$status_code == 410){  # Gone - file does not exist on the FTP server.
      payload <- content(response)
      if (!is.null(payload)){ #2
        msg <- payload$message
        if (msg == lastMessage){
          cat('.')
        }
        else {
          cat(sprintf('\n  %s',msg))
          lastMessage <- msg
        }
      }
      else (
        cat('\n  Running...Writing File.')
      )
    }
    else if (response$status_code %in% list(400,401)){  # Bad Request
      
      if (!is.null(response$content) & !is.null(content(response)$errors)) {
        cat(sprintf('\n  %s',http_status(response)$message))
        for (error in content(response)$errors){
          cat(sprintf("\n    Parameter: %s, Message: %s",error$parameter,error$errorMessage))
        }
      } else {
        cat(sprintf('\n  %s',http_status(response)$message))
      }
      break
    }
    else {                           # All other HTTP Statuses
      cat(sprintf("\n%s: %s\n",http_status(response)$message,content(response)$message))
      break
    }
    if ((tryCount <= 5) & (sleepTime > defaultSleepTime)) {
      sleepTime <- sleepTime * 0.5  
    }
    Sys.sleep(sleepTime)
  }
  
  return(downloadResult)
}
convertSize <- function(size) {
  if (size == 0){
    sizeString <- '0 KB'
  }
  else{
    sizeName <- list('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
    i <- as.integer(floor(log(size,1024)))
    p <- 1024^i
    s <- round(size/p,2)
    sizeString <- sprintf('%g %s', s, sizeName[[i+1]])
  }
  return(sizeString)
}
main()
