class Log
{
	Init()
	{
		static logFile := A_ScriptDir . "\" . "Autodrama" "_" A_MMM "_" A_DD "_" A_YYYY ".log"
		
		FileDelete, %logFile%.old

		if FileExist(logFile)
			FileMove, %logFile%, %logFile%.old

		titleText := "Autodrama Log for " A_MMMM " " A_DD ", " A_YYYY "`r`n"
		FileAppend, %titleText%, %logFile%
	}

	Add(addText)
	{
		static logFile := A_ScriptDir . "\" . "Autodrama" "_" A_MMM "_" A_DD "_" A_YYYY ".log"
		appendText := "[" . A_Hour . ":" . A_Min . ":" . A_Sec . "]" . " " . addText . "`r`n"
		FileAppend, %appendText%, %logFile%
	}
}