class Log
{
	Init()
	{
		FileDelete, %LOG_FILEDIR%.old

		; Delete log files from last month
		Loop, Files, *.*
		{
			if (A_LoopFileExt = "log" || A_LoopFileExt = "old")
				if !InStr(A_LoopFileName, A_MMM)
					FileDelete, % A_LoopFileLongPath
		}

		if FileExist(LOG_FILEDIR)
			FileMove, %LOG_FILEDIR%, %LOG_FILEDIR%.old

		titleText := "Autodrama v" AUTODRAMA_VERSION " log for " A_MMMM " " A_DD ", " A_YYYY "`r`n"
		FileAppend, %titleText%, %LOG_FILEDIR%
	}

	Add(addText)
	{
		appendText := "[" . A_Hour . ":" . A_Min . ":" . A_Sec . "]" . " " . addText . "`r`n"
		FileAppend, %appendText%, %LOG_FILEDIR%
	}
}