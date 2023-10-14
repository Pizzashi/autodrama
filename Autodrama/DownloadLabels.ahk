UpdateStatus:
	dlInfo := ""
	
	for i, dl in gidList
	{
		if (i > MAX_CONCURRENT_DWNL)
			break

        if !IsObject(dlInfo)
            dlInfo := []

		data := aria2.tellStatus( dl.gid ).result

		_fileName   := RegExReplace(data.files.1.path, ".*[/\\]")
		_progress   := Floor(data.completedLength / data.totalLength * 100) . "%"
		

        dlInfo[i] := "Downloading: " _fileName " (" . _progress . ")"

		if (data.status = "error") {
            Log.Add("ERROR: UpdateStatus: Error in downloading " _fileName)
            gidList.RemoveAt(i)
			FAILED_DOWNLOADS += 1
			Continue
		}

        if (data.status ~= "complete") {
            Log.Add("UpdateStatus: Successfully downloaded " _fileName)
			gidList.RemoveAt(i)
			COMPLETED_DOWNLOADS += 1
			Continue
		}
	}
    
	_speed := aria2.getGlobalStat().result.downloadSpeed
	
	; Download is complete!
    if ( (FAILED_DOWNLOADS + COMPLETED_DOWNLOADS) >= TOTAL_DOWNLOADS ) {
        Remark.Update("Download complete!"
                , "Successfully downloaded " COMPLETED_DOWNLOADS " file(s). There were " FAILED_DOWNLOADS " failed download(s).`n"
                . "You may find the downloaded episodes in " . """" . oDramaInfo[1] . " (" oDramaInfo[2] ")" . """" . "."
                , "Green")
		Log.Add("UpdateStatus: Successfully downloaded " COMPLETED_DOWNLOADS " file(s). There were " FAILED_DOWNLOADS " failed download(s).")
		
		SetTimer, UpdateStatus, Off
		Download.onFinish(1, COMPLETED_DOWNLOADS, FAILED_DOWNLOADS)	
		
		return
	}
	if !(_speed) {
		; 120 means keep trying for ~120 seconds
		if (failedRetries > 120)
		{
			Remark.Update("The download has failed!"
					, "The app cannot download the files, your internet may be slow or disconnected. Try again later."
					, "Red"
					, 1)
			Log.Add("ERROR: UpdateStatus cannot download episodes due to problems (failedRetries exceeded 120 times).")
			
			failedRetries := 0
			aria2.forceShutdown()
			Download.onFinish(0)
			SetTimer, UpdateStatus, Off
			return
		}
		failedRetries++
        Remark.Update("Trying to download files..."
                , "Please wait as the app prepares your downloads."
                , "Blue")
    }
    else {
        Remark.Update("Downloading files at " . Download.FormatByteSize(_speed) . "/s"
                , "There are " COMPLETED_DOWNLOADS " completed download(s) and " FAILED_DOWNLOADS " failed download(s) out of " TOTAL_DOWNLOADS ".`n"
                . dlInfo[1]"`n"dlInfo[2]
                , "Blue")
    }
return

RunDownloadLinks:
	; Timeout for 10 seconds every 5 episodes to avoid error messages
	if (openEpisodes >= 5) {
		Sleep, 10000
		openEpisodes := 0
	}

	Run, % oDownloadLinks[launchedEpisodeNumber]
	openEpisodes++
	launchedEpisodeNumber++

	if (launchedEpisodeNumber > oDownloadLinks.Length())
		SetTimer, RunDownloadLinks, Off
return