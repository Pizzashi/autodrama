Join.testKey() ; Test if there's a proper authentication key

class Join
{
    ; In the AuthKey.lic file, do:
    /*  
     *  static keyApi := [key for api]
     *  e.g. static keyApi := 0123456789101112131415
     */    
    #Include AuthKey.lic

    testKey()
    {
        ; Check if AuthKey was properly set up
            if (this.keyApi = "INSERT_KEY_HERE" || this.keyApi = "") {
                Msgbox, 0, % "Fatal Error", % "Please set the authentication key correctly."
                ExitApp
            } else {
                return
            }
    }

    ; Returns 1 if it's a success, and returns 0 otherwise
    Notify(deviceName, pushMessage, urlType := 0)
    {
        ; Refer to https://joinjoaomgcd.appspot.com to view the device Ids
        devicePairs         := {"Daisy": "aa2c0e33a64446d99d2e857ba7983b4c", "Baconfry": "221904fe00b244d0987a684e92856f21"}
        receivingDevice     := devicePairs[deviceName]
        notifSmallIcon      := "https://i.ibb.co/Ph8mV21/helper-48.png"
        notifTitle          := "Autodrama"
        notifMessage        := pushMessage
        sendText            := urlType ? "&url=" . UrlEncode(notifMessage) : "&text=" . UrlEncode(notifMessage)
        notificationCode    := "https://joinjoaomgcd.appspot.com/_ah/api/messaging/v1/sendPush?"
                            . "apikey=" . this.keyApi
                            . "&deviceId=" . receivingDevice
                            . sendText
                            . "&title=" . UrlEncode(notifTitle)
                            . "&smallicon=" . UrlEncode(notifSmallIcon)

        try
        {
            oPushRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            oPushRequest.open("GET", notificationCode)
            oPushRequest.send()
        }
        catch errorCode
        {
            Msgbox, 0, % " Error", % "There was an error on notifying " deviceName ". The application could not seem to reach the server to send push notifications. Please make sure the application can access the Internet."
            Log.Add("ERROR: Join.Notify() cannot send push notification due to error. Error code is " errorCode)
            return 0
        }
        return 1
    }
}