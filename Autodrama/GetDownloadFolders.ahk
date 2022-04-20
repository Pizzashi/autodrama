; https://www.autohotkey.com/boards/viewtopic.php?p=286094#p286094
GetUserDownloadFolder()
{
    FOLDERID_Downloads := "{374DE290-123F-4565-9164-39C4925E467B}"
    VarSetCapacity(CLSID, 16)
    DllCall("ole32\CLSIDFromString", "Str", FOLDERID_Downloads, "Ptr", &CLSID)
    DllCall("shell32\SHGetKnownFolderPath", "Ptr", &CLSID, "UInt", 0, "Ptr", 0, "Ptr*", ppath)
    dir := StrGet(ppath, "UTF-16")
    DllCall("ole32\CoTaskMemFree", "ptr", ppath)
    VarSetCapacity(downloads, (261 + !A_IsUnicode) << !!A_IsUnicode)
    DllCall("ExpandEnvironmentStrings", "Str", dir, "Str", downloads, "UInt", 260)
    return LTrim(RTrim(downloads, """"),"""") ; Trims the " from the leftmost and rightmost
}

GetFirefoxDownloadFolder()
{
    /*
    *   This function returns either of the three values:
    *       When no Firefox installation is detected:           "no_firefox_detected"
    *       When no custom download path is set by the user:    GetUserDownloadFolder() -> returns the user's download folder
    *       When a custom download path is detected:            dwnldPath
    *
    *   Note that this function will retrieve the first download path it can find,
    *   it does not provide support for multiple profiles.
    */

    firefoxDirectory := FileExist(A_AppData . "\Mozilla\Firefox\")
                        ? A_AppData . "\Mozilla\Firefox\"
                        : FileExist("C:\Program Files\Mozilla Firefox\")
                        ? "C:\Program Files\Mozilla Firefox\"
                        : FileExist("C:\Program Files\Mozilla Firefox\")
                        ? "C:\Program Files (x86)\Mozilla Firefox\"
                        : 0

    if !(firefoxDirectory)
        return "no_firefox_detected"

    dwnldPathRegex = user_pref\("browser\.download\.dir",\s(.*)\);
    dwnldPath := 0

    ; Pull the first Download location found
    Loop, Files, %firefoxDirectory%\prefs.js, R
    {
        FileRead, foundPref, %A_LoopFileLongPath%
        if RegExMatch(foundPref, "O)" . dwnldPathRegex, oMatch)
        {
            dwnldPath := StrReplace(oMatch.Value(1), "\\", "\")
            dwnldPath := LTrim(RTrim(dwnldPath, """"),"""") ; Trims the " from the leftmost and rightmost
        }
    }

    return (dwnldPath) ? dwnldPath : GetUserDownloadFolder()
}
