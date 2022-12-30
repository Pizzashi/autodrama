class Ntfy
{
    #Include TopicKeys.lic
    ; In the TopicKeys.lic, please set the following values
    ; static daisyTopic := "INSERT_TOPIC_STRING_HERE"
    ; static baconfryTopic := "INSERT_TOPIC_STRING_HERE"

    sendMessage(receiver, title, message, link := "")
    {
        Local
        global AUTODRAMA_VERSION, Log

        messagePriority := "4"
        messageTag := "autodrama_v" . AUTODRAMA_VERSION
        devicePairs := {"Daisy": "https://ntfy.sh/" . this.daisyTopic, "Baconfry": "https://ntfy.sh/" . this.baconfryTopic}
        receivingDevice := devicePairs[receiver]

        try {
            ntfy := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            ntfy.Open("POST", receivingDevice, false)
            ntfy.SetRequestHeader("Title", title)
            ntfy.SetRequestHeader("Priority", messagePriority)
            ntfy.SetRequestHeader("Tags", messageTag)
            if (link) {
                ntfy.SetRequestHeader("Actions", "view, Open Link, " . link)
            }

            ntfy.Send(message)
            rawServerResponse := ntfy.ResponseText
        } catch, errorCode {
            Log.Add("ERROR: Ntfy.sendMessage(): Error in notifying " receiver "." . " Error code (if present): " errorCode)
            Msgbox, 0, % " Error", % "There was an error on notifying " receiver "."
                                   . " The application could not seem to reach the server to send push notifications. Please make sure Autodrama can access the Internet."
            return 0
        }

        oNtfyReponse := Jxon_Load(ntfy.ResponseText)
        cleanedResponse := "Ntfy.sendMessage(): Successfully received request on " . this.formatUnix(oNtfyReponse.time) . "."
                . "`n`t" . "The request id is " . """" oNtfyReponse.id """"
                . "`n`t" . "The notification title is " . """" oNtfyReponse.title """"
                . "`n`t" . "The notitication body is " . """" oNtfyReponse.message """"
        Log.Add(cleanedResponse)
        
        return 1
    }

    ; Formats unix time to HH:MM:SS
    formatUnix(unixTime)
    {
        utcTime := 1970
        utcTime += unixTime, s
        FormatTime, formattedTime, utcTime, HH:mm:ss
        return formattedTime
    }
}
