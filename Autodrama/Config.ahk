class Config
{
    Read(sectionName, key)
    {
        IniRead, tempRead, configuration.ini, % sectionName, % key, % "Autodrama.Config.Read.ErrorMessage"
        return (tempRead = "Autodrama.Config.Read.ErrorMessage") ? "" : tempRead
    }

    Write(sectionName, key, value)
    {
        try {
            IniWrite, % value, configuration.ini, % sectionName, % key
        }
        if (ErrorLevel) {
            Log.Add("ERROR: Config.Write(): The app could not write " value " into " sectionName "\" key " in configuration.ini")
            return ""
        } else {
            return value
        }
    }

    Init()
    {
        if !FileExist("configuration.ini") {
            try FileAppend,, configuration.ini
            catch
            {
                Log.Add("ERROR: Config.Init(): There was a problem in setting up configuration.ini")
                FatalError("There was an error with setting up the configuration file. Please restart the app.")
            }
        }
    }
}