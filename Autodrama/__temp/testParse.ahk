#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


TestFunc()
{
    FileRead, webpage, hasRaw.txt

    samplelink := "https://kissasian.li/Drama/Twenty-Five-Twenty-One"

    rgxBaseDomain  = https:\/\/kissasian\.\w+
    rgxDramaImage  = sUO)class="col cover">.+src="(.+)"
    rgxDramaTitle  = UO)<title>\s+\t(.+)\sEnglish Sub
    rgxAirDate     = O)Date aired:<\/span>&nbsp;(.+)\s+<\/p>
    rgxDramaStatus = O)Status:<\/span>&nbsp;(.+)\s+<\/p>
    rgxEpisodeSub  = class="episodeSub"
    rgxEpisodeRaw  = sUO)class="episodeRaw".+(Episode\s\b\d+\b).+<\/li>
    oRawEpisodes  := []

    RegExMatch(samplelink, rgxBaseDomain, baseDomain)   ; Assign https://kissasian.* to baseDomain
    RegExMatch(webpage, rgxDramaImage, oDramaImage)     ; Assign the path of the drama image relative to the base domain to oDramaImage.Value(1)
    RegExMatch(webpage, rgxDramaTitle, oDramaTitle)     ; Assign the drama title to oDramaTitle.Value(1)
    RegExMatch(webpage, rgxAirDate, oDramaDate)         ; Assign the drama air date range to oDramaDate.Value(1)
    RegExMatch(webpage, rgcDramaStatus, oDramaStatus)   ; Assign the drama status (i.e., Ongoing or Completed) to oDramaStatus.Value(1)
    StrReplace(webpage, rgxEpisodeSub,, subbedEpisodes) ; Assign the total number of subbed episodes to subbedEpisodes

    ; Assigns the total number of raw episodes to rawEpisodes
    ; and also assigns the list of raw episodes in the array oRawEpisodes[]
    while( RegExMatch(webpage, rgxEpisodeRaw, oFoundRawEpisode) )
    {
        oRawEpisodes.Push(oFoundRawEpisode.Value(1))
        webpage := StrReplace(webpage, oFoundRawEpisode.Value(0)) ; Deletes the found string from the drama page
        rawEpisodes++
    }
    /*
    Msgbox % rawEpisodes
    Loop % oRawEpisodes.Length()
        tempList .= oRawEpisodes[A_Index] . "`n"
    Msgbox % tempList
    */

    ;Msgbox % subbedEpisodes
    urlDramaImage := baseDomain . oDramaImage.Value(1)
    totalEpisodes := rawEpisodes + subbedEpisodes
    Msgbox % oDramaDate.Value(1)
    returnArray := ["supp", oRawEpisodes]
    return returnArray

}

yoop := TestFunc()
;Msgbox % yoop[1]