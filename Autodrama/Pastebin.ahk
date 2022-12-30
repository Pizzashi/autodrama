class Pastebin
{
    /*
        This is how to get the userKey, just copy the below code in a new .ahk file

        postCode := "api_dev_key=7EducOi-el95UzQZxkPuqeMoMnbk7OGF"
        . "&api_user_name=autodrama_logs"
        . "&api_user_password=Rx1Hte0Z^axiy@@DGKALfdJ95!p*gkcomu^nd$GQly3Cp6c%MyD%Vu0OcL9D%@Mr"
        link := "https://pastebin.com/api/api_login.php"

        msgbox % clipboard := url_tovar(link, postCode)

        url_tovar(URL, param) { 
            WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            WebRequest.Open("POST", URL)
            WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
            WebRequest.Send(param)
            res := WebRequest.ResponseText
            return res
        }
    */

    ; Returns 1 if it's a success, and returns 0 otherwise
    Upload(logFile)
    {
        ; Pastebin API documentation: https://pastebin.com/doc_api

        ; This account is disposable, no need to hide these credentials
        static devKey   := "7EducOi-el95UzQZxkPuqeMoMnbk7OGF"
        , userKey       := "0f16986f762e0d3f479aa413693515ea"
        , userName      := "autodrama_logs"
        , passCode      := "Rx1Hte0Z^axiy@@DGKALfdJ95!p*gkcomu^nd$GQly3Cp6c%MyD%Vu0OcL9D%@Mr"
        , postLink      := "https://pastebin.com/api/api_post.php"
        FileRead, logText, % A_ScriptDir "\" logFile
        FileRead, oldLogText, % A_ScriptDir "\" logFile ".old"

        finalLog := oldLogText ? logText . "`n`n==================Previous log==================`n`n" . oldLogText : logText

        postCode := "api_dev_key=" . devKey
            . "&api_paste_code=" . UrlEncode(finalLog)
            . "&api_paste_private=1"                            ; 0=public 1=unlisted 2=private
            . "&api_paste_name=" . UrlEncode(logFile)
            . "&api_paste_expire_date=1D"                       ; Expires after a day
            . "&api_option=paste"
            . "&api_user_name=" . userName
            . "&api_user_password=" . passCode
            . "&api_user_key=" . userKey
        
        try
        {
            oWebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            oWebRequest.Open("POST", postLink)
            oWebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
            oWebRequest.Send(postCode)
            oWebRequest.WaitForResponse()
            pasteLink := oWebRequest.ResponseText
        }

        if !(pasteLink)
        {
            Msgbox, 0, % " Error", % "The server did not return anything to the application. Maybe check your internet?"
            return 0
        }

        if InStr(pasteLink, "Bad API request")
        {
            Msgbox, 0, % " Error", % "The API request to Pastebin failed. Please notify Baconfry-sama at once. Response: " webResponse
            return 0
        }

        ; Send the paste link to Baconfry
        Ntfy.sendMessage("Baconfry", "Autodrama has a PasteBin link for you!", "Press the button below to open the paste.", pasteLink)
        return 1
    }
}