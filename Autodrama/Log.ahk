class Log
{
	Init()
	{
		FileDelete, %LOG_FILEDIR%.old

		if FileExist(LOG_FILEDIR)
			FileMove, %LOG_FILEDIR%, %LOG_FILEDIR%.old

		titleText := "Autodrama Log for " A_MMMM " " A_DD ", " A_YYYY "`r`n"
		FileAppend, %titleText%, %LOG_FILEDIR%
	}

	Add(addText)
	{
		appendText := "[" . A_Hour . ":" . A_Min . ":" . A_Sec . "]" . " " . addText . "`r`n"
		FileAppend, %appendText%, %LOG_FILEDIR%
	}
}