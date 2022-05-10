;====================Compiler directives====================;
;@Ahk2Exe-SetName Autodrama
;@Ahk2Exe-SetMainIcon Main.ico
;@Ahk2Exe-SetCopyright Copyright © 2022 Baconfry
;@Ahk2Exe-SetCompanyName Furaico
;@Ahk2Exe-SetVersion 0.3.2
;===========================================================;
global AUTODRAMA_VERSION := "0.3.2"

#NoEnv
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
#SingleInstance, force
; This code appears only in the compiled script
/*@Ahk2Exe-Keep
#NoTrayIcon
ListLines Off
#KeyHistory 0
*/

#Include aria2\aria2.ahk
#Include aria2\httpPost.ahk
#Include aria2\Jxon.ahk
#Include Lib\Dll.ahk
#Include Lib\GDI.ahk
#Include Cleanup.ahk
#Include ComboBox.ahk
#Include Download.ahk
#Include Drama.ahk
#Include ErrorHandling.ahk
#Include ExitFunction.ahk
#Include GetDownloadFolders.ahk
#Include Helper.ahk
#Include Log.ahk
#Include OnMouseMove.ahk
#Include PlaySound.ahk
#Include Remark.ahk
#Include Window.ahk

Log.Init()

if !FileExist("resources.dll")
    FatalError("resources.dll not found! Try redownloading the app.")
if !FileExist("aria2c.exe")
    FatalError("aria2c.exe not found! Try redownloading the app.")
; Check for necessary files (aria2c, YA AINT NUFFIN LIKE A HOUND DOG)


Process, Exist ; Retrieve the script's PID
global AUTODRAMA_PID := ErrorLevel                              ; The script's PID is in ErrorLevel
     , FIREFOX_DOWNLOAD_PATH := GetFirefoxDownloadFolder()
     , USER_DOWNLOAD_PATH    := GetUserDownloadFolder()
     , MOVIE_DOWNLOAD_PATH   := USER_DOWNLOAD_PATH . "\Video\"
     , COMBO_BOX_HISTORY     := ""                              ; Used in ComboBoxHistory.ahk
     , REMARK_TEXT_ONCLICK   := ""                              ; Used as a flag for determining what action is done when the remark text is clicked
     , ENABLE_SEARCH_DRAMA   := 1                               ; Used as a way to disable the search button

; Deletes all unnecessary files from last session
Cleanup()
; Read previous search history for DramaLink
ComboBox.readPrevHistory()

/*
 *      LOAD RESOURCES FROM THE DLL FOR THE GUI
 */
;================= FONTS =================
nSize := Dll.Read(Buffer, "resources.dll", "Fonts", "ProductSans.ttf")
DllCall("AddFontMemResourceEx", UInt,&Buffer, UInt,nSize, Int,0, UIntP,n)
HeaderFont := GDI.ModifyFont(0, "FontFace=Product Sans, Height=13") ; needs h20, h25 for best effects
, TitleFont := GDI.ModifyFont(0, "FontFace=Product Sans, Height=16") ; h30 is good
, h3Font := GDI.ModifyFont(0, "FontFace=Product Sans, Height=12") ; h20 for best effects
;=============== PICTURES ================
GDI.Commence("Startup")
szSearch := Dll.Read(Search, "resources.dll", "Images", "search.png")
, hBitmapSearch := GDI.hBitmapFromBuffer(Search, szSearch)
, szMiku := Dll.Read(Miku, "resources.dll", "Images", "miku.png")
, hBitmapMiku := GDI.hBitmapFromBuffer(Miku, szMiku)

, szDramaPlacehldr := Dll.Read(DramaPlaceHldr, "resources.dll", "Images", "drama_placeholder.png")
, hBitmapDramaPlacehldr := GDI.hBitmapFromBuffer(DramaPlaceHldr, szDramaPlacehldr)
GDI.Commence("Shutdown")
;========== End Load resources from dll for the gui ============

Gui, Main:New, HwndhMainGui +OwnDialogs, % "Autodrama v" . AUTODRAMA_VERSION
;===================== Left side of the GUI =====================
;================= Drama Link ===================
Gui, Main:Add, Text, x20 y10 w200 h30 HwndhDramaLinkText c287882, % "Drama Link"
Gui, Main:Font, s10, Segoe UI
Gui, Main:Add, ComboBox, x20 y+5 w315 vDramaLink HwndhDramaLink, % COMBO_BOX_HISTORY
Gui, Main:Add, Picture, x+10 yp-5 w35 h35 HwndhSearchIcon vSearchIcon gSearchDrama 0x20E
GDI.LoadFont(hDramaLinkText, TitleFont)
GDI.LoadPicture(hSearchIcon, hBitmapSearch)
;================== Options =====================
Gui, Main:Add, Text, x20 y+20 w200 h40 HwndhOptionsText c287882, % "Download Options"
Gui, Main:Font, Norm
Gui, Main:Add, Text, x20 y+10 w75, % "Mode"
Gui, Main:Add, DDL, x+20 yp-3 w220 vDownloadType gChangeDownloadType, % "Download all episodes||Download chosen episodes"
Gui, Main:Add, Text, x20 y+15 w75, % "On finish"
Gui, Main:Add, DDL, x+20 yp-3 w220 vOnFinish, % "THE KING|Notify Daisy|Do nothing||"
;=== Child GUI to hide it in one go ======
Gui, Main2:New, ParentMain -Caption
Gui, Main2:Font, s10, Segoe UI
Gui, Main2:Add, Text, x20 y+10, % "Download episodes:"
Gui, Main2:Add, Text, x+10 yp+0, % "from"
Gui, Main2:Add, Edit, x+10 yp-3 w40 vDownloadStart number,
Gui, Main2:Add, Text, x+10 yp+3, % "to"
Gui, Main2:Add, Edit, x+10 yp-3 w40 vDownloadEnd number,
Gui, Main2:Show, x0 y260 hide
;=== END Child GUI  ======================
GDI.LoadFont(hOptionsText, TitleFont)
;=================  Download ===================
Gui, Main:Add, Button, x20 y260 w360 h40 disabled gDownloadDrama vDownloadBtn HwndhDownloadBtn, % "Download"
Gui, Main:Add, Button, x20 y+10 w113 h40 disabled gResumeDownloads vResumeDownloadBtn HwndhResumeDownloadBtn, % "Resume"
Gui, Main:Add, Button, x+10 yp+0 w114 h40 disabled gPauseDownloads vPauseDownloadBtn HwndhPauseDownloadBtn, % "Pause"
Gui, Main:Add, Button, x+10 yp+0 w113 h40 disabled gCancelDownloads vCancelDownloadBtn HwndhCancelDownloadBtn, % "Cancel"
Gui, Main:Add, Button, x420 yp+0 w360 h40 gOpenDownloadFolder HwndhOpenDwnldDirBtn, % "Open Downloads Folder"
GDI.LoadFont(hDownloadBtn, TitleFont)
GDI.LoadFont(hResumeDownloadBtn, HeaderFont)
GDI.LoadFont(hPauseDownloadBtn, HeaderFont)
GDI.LoadFont(hCancelDownloadBtn, HeaderFont)
GDI.LoadFont(hOpenDwnldDirBtn, HeaderFont)
;===================== Right side of the GUI =====================
Gui, Main:Add, Text, x420 y10 w200 h30 HwndhInformationText c287882, % "Drama Information"
;Gui, Main:Add, Text, x420 y250 h25 w360 HwndhDlListText c287882, % "Ongoing downloads"
GDI.LoadFont(hInformationText, TitleFont)

;================ Placeholder Right side of the GUI ===============
Gui, MainR:New, ParentMain -Caption
Gui, MainR:Add, Picture, x20 y0 w150 h195 border vDramaImage HwndhDramaImage 0x20E
Gui, MainR:Font, s14, Segoe UI
Gui, MainR:Add, Text, x+10 yp+0 w200, % "Search a drama to see its details"
Gui, MainR:Font, s11, Segoe UI
Gui, MainR:Add, Text, xp+0 y+10, % "Year aired"
Gui, MainR:Add, Text, xp+0 y+5, % "Episodes"
Gui, MainR:Add, Text, xp+0 y+5, % "Status"
Gui, MainR:Add, Text, xp+0 y+5, % "Raw episodes"
Gui, MainR:Show, x500 y55 w400 h250
GDI.LoadPicture(hDramaImage, hBitmapDramaPlacehldr)
;===================== Bottom of the GUI =====================
Gui, Main:Add, Picture, w130 h117 x20 y395 HwndhMikuIcon 0x20E
Gui, Main:Add, Progress, x+0 y380 w610 h100 BackgroundWhite
Gui, MainR:Font, s12, Segoe UI
Gui, Main:Add, Text, xp+10 yp+10 w590 h20 BackgroundTrans vRemarkTitle HwndhRemarkTitle cGreen, % "Everything looks good for now!"
Gui, Main:Add, Text, xp+0 y+5 w590 h55 BackgroundTrans vRemarkText, % "To begin, copy and paste a drama link and click that shiny search button."
GDI.LoadFont(hRemarkTitle, h3Font)
GDI.LoadPicture(hMikuIcon, hBitmapMiku)



/*
==================== Log ======================
Gui, Main:Font, s10
Gui, Main:Font, Bold
Gui, Main:Add, Text, x20 y+10, % "Log"
Gui, Main:Font, Norm s9, Consolas 
Gui, Main:Add, Edit, x20 y+5 w360 h80 -wrap number readonly vGuiLog HwndhGuiLog, [Autodrama: %A_MMM% %A_DD%, %A_YYYY%]`n[%A_Hour%:%A_Min%:%A_Sec%] Ready`r`n
Gui, Main:Add, Button, x75 y+5 w250, % "Upload log to Baconfry-sama"
*/


OnMessage(0x200, "OnMouseMove") ; For changing the cursor to "HAND" when it is over the search icon
Gui, Main:Show, h500 w800
OnExit("ExitFunction")
return

#Include HelperLabels.ahk
#Include DownloadLabels.ahk

OpenDownloadFolder:
    Run, % MOVIE_DOWNLOAD_PATH
return

ResumeDownloads:
    SetTimer, UpdateStatus, 1000
    if (aria2.unpauseAll().result = "OK") {
        Window.downloadControls("Enable", "Disable", "Enable")
        Log.Add("ResumeDownloads: Successfully resumed Aria2c downloads.")
        Remark.Update("Successfully resumed downloads."
                    , "Your downloads were paused with no problems."
                    , "Green")
    }
    else {
        Log.Add("ERROR: ResumeDownloads: Error in resuming Aria2c downloads.")
        Remark.Update("There's an error in resuming your downloads!"
                    , "Your downloads could not be resumed successfully. Please close the app and try again."
                    , "Red"
                    , 1)
    }
    Gosub, UpdateStatus ; Start updating GUI immediately
return

PauseDownloads:
    SetTimer, UpdateStatus, Off
    if (aria2.pauseAll().result = "OK") {
        Window.downloadControls("Disable", "Enable", "Enable")
        Log.Add("PauseDownloads: Successfully paused Aria2c downloads.")
        Remark.Update("Successfully paused downloads."
                    , "Your downloads were paused with no problems."
                    , "Green")
    }
    else {
        Log.Add("ERROR: PauseDownloads: Error in pausing Aria2c downloads.")
        Remark.Update("An error occured while pausing your downloads!"
                    , "Your downloads could not be paused successfully. Please close the app and try again."
                    , "Red"
                    , 1)
    }    
return

CancelDownloads:
    SetTimer, UpdateStatus, Off

    Log.Add("CancelDownloads: Attempting to shutdown aria2c.")
    if (aria2.shutdown().result = "OK") {
		Window.resetAll()
        Remark.Update("Successfully cancelled downloads."
                    , "Your downloads have been successfully cancelled. You may try searching another drama again."
                    , "Green")
    }
    else {
        Log.Add("ERROR: CancelDownloads: Error in shutting down aria.")
        Remark.Update("There was an error in cancelling your downloads."
                    , "Your downloads could not be cancelled. Close and restart the app instead."
                    , "Red"
                    , 1)
    }
return

SearchDrama:
    if !(ENABLE_SEARCH_DRAMA)
        return

    Gui, Main:Submit, NoHide
    
    ; Check for invalid input
    if (!RegExMatch(DramaLink, "(https|http):\/\/kissasian\.(\w+)\/(Drama|Movie)\/.*") || RegExMatch(DramaLink, "(https|http):\/\/kissasian\.(\w+).+(https|http):\/\/kissasian\.(\w+)"))
    {
        Remark.Update("Houston, we have a problem."
                    , "Badet, you are one so very useless egg. Your drama link is invalid, check if it is correct."
                    , "Red"
                    , 1)
        Log.Add("ERROR: Badet placed invalid DramaLink: " DramaLink)
        return
    }

    Window.disableInput()
    Window.disableDownload()
    Remark.Update("Working..."
                , "Getting the drama info, please wait..."
                , "Blue")
    Log.Add("SearchDrama: Searching for drama...")

    oDramaInfo := Drama.getPageInfo(DramaLink)
    if (oDramaInfo = "networkError") {
        Remark.Update("Error! Error! Error!"
                    , "The application cannot download the drama information due to network problems, please try again."
                    , "Red"
                    , 1)
        Window.disableDownload()
        Window.enableInput()
        return
    }
    else if (oDramaInfo = "pageNotFound") {
        Remark.Update("Error! The requested link was not found on the server!"
                    , "It looks like the drama link you entered is incorrect, or does not exist on the server. Try copying the entire link again."
                    , "Red"
                    , 1)
        Log.Add("ERROR: Badet has input an invalid drama link. DramaLink: " . DramaLink)
        Window.disableDownload()
        Window.enableInput()
        return
    }

    oDownloadLinks := oDramaInfo[7]
    if !(Drama.allLinksUp(oDownloadLinks)) {
        Remark.Update("One of the episode links cannot be reached."
                    , "Looks like not all episodes have valid links. Please try searching for the drama again."
                    , "808000")
        Window.disableDownload()
        Window.enableInput()
        return   
    }

    eBuildError := Drama.buildDramaInfoGUI(oDramaInfo)
    if (eBuildError) {
        Remark.Update("Got the drama information, but..."
                    , "The Drama image could not be downloaded successfully. Please try searching again."
                    , "808000")
        Window.disableDownload()
        Window.enableInput()
        return
    }
    
    ; Everything looks good!
    Remark.Update("Got the drama information!"
                , "Look at the drama details. If this is the drama that you intend to download, then modify the Options and hit download!"
                , "Green")
    Log.Add("Successfully processed drama information and download links.")
    ComboBox.updateHistory(DramaLink) ; Record the last link to history
    Window.enableInput()
    Window.enableDownload()
return

DownloadDrama:
    Gui, Main:Submit, NoHide
    Gui, Main2:Submit, NoHide
    
    ; Check for invalid input
    if (DownloadType = "Download chosen episodes") {
        if ( (DownloadStart > DownloadEnd)
          || (!(DownloadStart) || !(DownloadEnd))
          || (DownloadStart < 1)
          || (DownloadEnd > oDownloadLinks.Length()) ) {
            Remark.Update("There's an error on the chosen download range."
                        , "You useless badet. Recheck your chosen download episodes. Dapat mas gamay ang ""from"" kaysa ""to"". Take note nga dili pwede apilon ang mga raw kay dili kabalo mag Korean si mather you useless egg."
                        , "Red"
                        , 1)
            Log.Add("ERROR: Badet has screwed up on choosing the download episodes."
                    . "`nDownloadStart: " DownloadStart
                    . "`nDownloadEnd: " DownloadEnd
                    . "`nMaximum episode: " oDownloadLinks.Length())
            return
        }
    }

    Log.Add("DownloadDrama: Downloading the selected drama...")
    Window.disableInput()
    Window.disableDownload()
    Window.disableOptions()

    ; Modify oDownloadLinks if user chose to download chosen episodes
    ; Do not append this code to the previous if-statement, this is not checking for invalid input
    if (DownloadType = "Download chosen episodes") {
        beginLen := (DownloadStart - 1)
        oDownloadLinks.RemoveAt(1, beginLen)

        endStart := (DownloadEnd - DownloadStart + 2)
        endLen := (oDownloadLinks.Length() - endStart + 1)
        oDownloadLinks.RemoveAt(endStart, endLen)
    }

    global DRAMA_FOLDER := MOVIE_DOWNLOAD_PATH . Download.makeWinFriendly(oDramaInfo[1] . " (" . oDramaInfo[2] . ")")
    ; From this point, the Remarks.Update code will be written in the Helper and Download classes
    ; Check if Aria can be started
    if !Download.startAria()
        return
    ; Start download process
    Helper.readyCredentials()
return

ChangeDownloadType:
    Gui, Main:Submit, NoHide
    if (DownloadType = "Download chosen episodes") {
        Gui, Main2:Show
    } else {
        Gui, Main2:Hide
    }
return

MainGuiClose:
ExitApp

;aria2c -o "Character Movie" "https://fvs.io/redirector?token=aUMwZitReWp3QU5wS2R3WUREVmxzS1ZySWNHd3EzMzhrM21Vblllekt1SFpSLzBrTzc3NDhCS2NRcXo0R2xMMXFvTnNXU1kyQWRxSnpiVGN0UE9sdlJ0QXl6aEpDQW5HdjZqa3dsWHpiQnJBUHYyUXhyRHJndFhPQlUzWVY5VmRZSFd3VjFUWHVscmxJZ3pUZXkxbUlIaXRKaHJzTGFTOUYzdGo6VzRuK0RoMHdsbm14OThBWWFGcEh0Zz09x6ng"