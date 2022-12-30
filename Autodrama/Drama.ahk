#Include ToGrayScale.ahk

class Drama
{
    ; Return value is an array that is: [dramaTitle, dramaAirDate, dramaStatus, totalEpisodes, rawEpsFound?, urlDramaImage, oDownloadLinks]
    getPageInfo(url)
    {
        Log.Add("Drama.getPageInfo(): Getting the drama info for: " . url)
        ;=============== static Variables =================
        static rgxPageNotFound := "<title>\s+Error!\s+<\/title>"
        , rgxBaseDomain   := "https:\/\/kissasian\.\w+"
        , rgxDramaImage   := "sUO)class=""col cover"">.+src=""(.+)"""
        , rgxDramaTitle   := "UO)<title>\s+\t(.+)\sEnglish Sub"
        , rgxAirDate      := "O)Date aired:<\/span>&nbsp;.+,\s(\d{4})"
        , rgxDramaStatus  := "O)Status:<\/span>&nbsp;(.+)\s+<\/p>"
        , rgxEpisodeSub   := "class=""episodeSub"""
        , rgxEpisodeRaw   := "sUO)class=""episodeRaw"".+(Episode\s\b\d+\b).+<\/li>"
        ;==================================================
        ; Local variables
        oRawEpisodes      := []
        , rawEpsFound     := 0
        , oDramaInfo      := []
        , oDownloadLinks  := []
        

        ; Check the UrlDownloadToFile in documentation for this code
        ; Basically downloads a URL to a variable
        oWinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        oWinHttpReq.Open("GET", url, true)
        oWinHttpReq.Send()
        ; Using 'true' above and the call below allows the script to remain responsive.
        try {
            oWinHttpReq.WaitForResponse()
            webPage := oWinHttpReq.ResponseText
        }
        catch {
            networkError := 1
        }
        
        
        if RegExMatch(webPage, rgxPageNotFound)                 ; Check if the page does not exist on the domain
            return "pageNotFound"

        RegExMatch(url, rgxBaseDomain, baseDomain)              ; Assign https://kissasian.* to baseDomain
        RegExMatch(webPage, rgxDramaImage, oDramaImage)         ; Assign the path of the drama image relative to the base domain to oDramaImage.Value(1)
            urlDramaImage := baseDomain . oDramaImage.Value(1)
        RegExMatch(webPage, rgxDramaTitle, oDramaTitle)         ; Assign the drama title to oDramaTitle.Value(1)
            dramaTitle := oDramaTitle.Value(1)
        RegExMatch(webPage, rgxAirDate, oDramaDate)             ; Assign the drama air date range to oDramaDate.Value(1)
            dramaAirDate := oDramaDate.Value(1)
        RegExMatch(webPage, rgxDramaStatus, oDramaStatus)       ; Assign the drama status (i.e., Ongoing or Completed) to oDramaStatus.Value(1)
            dramaStatus := oDramaStatus.Value(1)
        StrReplace(webPage, rgxEpisodeSub,, subbedEpisodes)     ; Assign the total number of subbed episodes to subbedEpisodes

        if (!dramaAirDate || !dramaStatus)
            networkError := 1

        ; The drama is a movie, not a show (series)
        if (subbedEpisodes = 1) {
            RegExMatch(webPage, "sUO)class=""episodeSub"".+href=""(\/.+\d)""", oMatchedLink)
            oDownloadLinks.Push(baseDomain . oMatchedLink.Value(1) . "?LaunchedByAutodrama")
        }
        else {
            Loop % subbedEpisodes
            {
                RegExMatch(webPage, "O)rel=""noreferrer noopener""\shref=""(\/[^<>]+Episode-" A_Index "\?id=\d+)""", oMatchedLink)
                oDownloadLinks.Push(baseDomain . oMatchedLink.Value(1) . "?LaunchedByAutodrama")
            }
        }

        ; Assigns the total number of raw episodes to rawEpisodes
        ; and also assigns the list of raw episodes in the array oRawEpisodes[]
        rawEpisodes := 0
        if RegExMatch(webPage, rgxEpisodeRaw)
        {
            rawEpsFound := 1

            while( RegExMatch(webPage, rgxEpisodeRaw, oFoundRawEpisode) )
            {
                oRawEpisodes.Push(oFoundRawEpisode.Value(1))
                webPage := StrReplace(webpage, oFoundRawEpisode.Value(0)) ; Deletes the found string from the drama page
                rawEpisodes++
            }
        }
        
        totalEpisodes := rawEpisodes + subbedEpisodes
        if (networkError) {
            Log.Add("ERROR: Drama.getPageInfo() could not retrieve variable webPage due to a network-related error.")
            return "networkError"
        }

        ; return value array is [dramaTitle, dramaAirDate, dramaStatus, totalEpisodes, rawEpsFound?, urlDramaImage, oDownloadLinks]
        oDramaInfo := [dramaTitle, dramaAirDate, dramaStatus, totalEpisodes, rawEpsFound, urlDramaImage, oDownloadLinks]
        return oDramaInfo
    }
    
    buildDramaInfoGUI(oDramaInfo)
    {
        Global

        local dramaTitle := oDramaInfo[1]
        , airDate := oDramaInfo[2]
        , dramaStatus := oDramaInfo[3]
        , totalEpisodes := oDramaInfo[4]
        , rawEpisodesFound := oDramaInfo[5]
        , urlDramaImage := oDramaInfo[6]
        
        FileDelete, DownloadedImages\kdrama_banner.jpg
        FileCreateDir, DownloadedImages ; Creates the folder if necessary
        try {
            UrlDownloadToFile, %urlDramaImage%, DownloadedImages\kdrama_banner.jpg
        } catch {
            Log.Add("ERROR: Drama.buildDramaInfoGUI() could not download the drama's banner for some reason.")
            downloadError := 1
        }

        Gui, MainK:New, ParentMain -Caption
        Gui, MainK:Add, Picture, x20 y0 w150 h195 border vDramaInfoImage, % "DownloadedImages\kdrama_banner.jpg"
        Gui, MainK:Font, s14, Segoe UI
        Gui, MainK:Add, Text, x180 yp+0 w200, % dramaTitle
        Gui, MainK:Font, s11, Segoe UI
        Gui, MainK:Add, Text, x180 y+10 c287882, % "Year aired: "
        Gui, MainK:Add, Text, x+0 yp+0, % airDate
        Gui, MainK:Add, Text, x180 y+5 c287882, % "Episodes: "
        Gui, MainK:Add, Text, x+0 yp+0, % totalEpisodes
        Gui, MainK:Add, Text, x180 y+5 c287882, % "Status: "
        Gui, MainK:Add, Text, x+0 yp+0, % dramaStatus
        
        ; Highlight if there are raw episodes
        if (rawEpisodesFound) {
            Gui, MainK:Add, Text, x180 y+10 w200 cRed, % "CAUTION: There are raw episodes."
        } else {
            Gui, MainK:Add, Text, x180 y+10 w200, % "All episodes are subbed."
        }

        Gui, MainR:Destroy
        Gui, MainK:Show, x500 y55 w400 h250

        return (downloadError) ? 1 : 0
    }

    infoImageToGrayScale()
    {
        Global

        SetBatchLines, -1   ; Recommended because ToGrayscale() has a heavy 255-iteration loop
        local hBitMapDramaInfo := LoadPicture("DownloadedImages\kdrama_banner.jpg")
        , hBitMapGrayScl := ToGrayscale(hBitMapDramaInfo)
        SetBatchLines, 10ms

        GuiControl, MainK:, DramaInfoImage, % "HBITMAP:" . hBitMapGrayScl
        return
    }


    allLinksUp(oDownloadLinks)
    {
        Loop % oDownloadLinks.Length()
        {
            if !(oDownloadLinks[A_Index]) {
                Log.Add("ERROR: allLinksUp() found an empty download link.")
                return 0
            }
        }

        return 1
    }
}