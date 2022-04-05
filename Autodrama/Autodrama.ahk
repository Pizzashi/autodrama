;====================Compiler directives====================;
;@Ahk2Exe-SetName Autodrama
;@Ahk2Exe-SetMainIcon Main.ico
;@Ahk2Exe-SetCopyright Copyright © 2022 Baconfry
;@Ahk2Exe-SetCompanyName Furaico
;@Ahk2Exe-SetVersion 0.1
;===========================================================;

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

#Include Lib\Dll.ahk
#Include Lib\GDI.ahk
#Include Drama.ahk
#Include GetDownloadFolders.ahk
#Include Remark.ahk
#Include Log.ahk
#Include ErrorHandling.ahk

Log.Init()

if !FileExist("resources.dll")
    FatalError("resources.dll not found! Try redownloading the app.")
; Check for necessary files (aria2c, YA AINT NUFFIN LIKE A HOUND DOG)


global FIREFOX_DOWNLOAD_PATH := GetFirefoxDownloadFolder()
     , USER_DOWNLOAD_PATH    := GetUserDownloadFolder()
     , MOVIE_DOWNLOAD_PATH   := USER_DOWNLOAD_PATH . "\Video\"

; Delete old .autodramatext files
FileDelete, %FIREFOX_DOWNLOAD_PATH%\*.autodramatext
; Delete the app's AppData folder

; Wait for firefox to close before resetting the CredentialsReady flag

;========== Start Load resources from dll for the gui ==========
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

Gui, Main:New, HwndhMainGui, Autodrama
;Gui, Main:Add, Progress, h500 w1 x400 BackgroundBlack
;===================== Left side of the GUI =====================
;================= Drama Link ===================
Gui, Main:Add, Text, x20 y10 w200 h30 HwndhDramaLinkText c287882, % "Drama Link"
Gui, Main:Font, s10, Segoe UI
Gui, Main:Add, ComboBox, x20 y+5 w315 vDramaLink, % "https://kissasian.li/Drama/Kamen-Rider-Saber-Transformation-Secret-of-Seven-Riders-Special-Issue|one|two|three|four|five"
Gui, Main:Add, Picture, x+10 yp-5 w35 h35 HwndhSearchIcon gSearchDrama 0x20E
GDI.LoadFont(hDramaLinkText, TitleFont)
GDI.LoadPicture(hSearchIcon, hBitmapSearch)
;================== Options =====================
Gui, Main:Add, Text, x20 y+20 w200 h40 HwndhOptionsText c287882, % "Options"
Gui, Main:Font, Norm
Gui, Main:Add, Text, x20 y+10 w75, % "Mode"
Gui, Main:Add, DDL, x+20 yp-3 w220 vDownloadType gChangeDownloadType, % "Download all episodes||Download chosen episodes|Download new episodes"
Gui, Main:Add, Text, x20 y+15 w75, % "On finish"
Gui, Main:Add, DDL, x+20 yp-3 w220 vOnFinish, % "YOU AINT NOTHING BUT A HOUND DOG|Notify Daisy|Do nothing||"
;=== Child GUI to hide it in one go ======
Gui, Main2:New, ParentMain -Caption
Gui, Main2:Font, s10, Segoe UI
Gui, Main2:Add, Text, x20 y+10, % "Download episodes:"
Gui, Main2:Add, Text, x+10 yp+0, % "from"
Gui, Main2:Add, Edit, x+10 yp-3 w40 vDownloadStart number,
Gui, Main2:Add, Text, x+10 yp+3, % "to"
Gui, Main2:Add, Edit, x+10 yp-3 w40 vDownloadEnd number,
Gui, Main2:Show, x0 y240 hide
;=== END Child GUI  ======================
GDI.LoadFont(hOptionsText, TitleFont)
;=================  Download ===================
Gui, Main:Add, Button, x20 y250 w360 h40 disabled HwndhDownloadText, % "Download"
GDI.LoadFont(hDownloadText, TitleFont)

;===================== Right side of the GUI =====================
Gui, Main:Add, Text, x420 y10 w200 h30 HwndhInformationText c287882, % "Information"
;Gui, Main:Add, Text, x420 y250 h25 w360 HwndhDlListText c287882, % "Ongoing downloads"
GDI.LoadFont(hInformationText, TitleFont)

;================ Placeholder Right side of the GUI ===============
Gui, MainR:New, ParentMain -Caption
Gui, MainR:Add, Picture, x20 y0 w150 h195 vDramaImage HwndhDramaImage 0x20E
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

Gui, Main:Show, h500 w800

;Sleep, 2000
;GuiControl, MainR:, DramaImage, kdrama.jpg


;Gosub, CheckFiles
return

SearchDrama:
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

    Remark.Update("Working..."
                , "Getting the drama info, please wait..."
                , "Blue")

    oDramaInfo := Drama.getPageInfo(DramaLink)

    if (oDramaInfo = "networkError") {
        Remark.Update("Error! Error! Error!"
                    , "The application cannot download the drama information due to network problems, please try again."
                    , "Red"
                    , 1)
        return
    }

    eBuildError := Drama.buildDramaInfoGUI(oDramaInfo)
    if (eBuildError) {
        Remark.Update("Got the drama information, but..."
                    , "The Drama image could not be downloaded successfully. Please try searching again."
                    , "808000")
    }
    else {
        Remark.Update("Got the drama information!"
                    , "Look at the drama details. If this is the drama that you intend to download, then modify the Options and hit download!"
                    , "Green")
    }

    


    /*
            MOVE THIS BLOCK TO DOWNLOAD GOSUB
            if (DownloadType = "Download chosen episodes" && DownloadStart > DownloadEnd) {
                invalidInput := 1
                Remark.updText("Badet you so USELESSSSSS. The starting episode is greater than the end episode! MAS DAKO ANG DOWNLOAD START KAYSA DOWNLOAD END. TRY AGAIN.")
                Log.Add("ERROR: Badet set has set a greater starting episode than ending episode")
                return
            }
            if ( DownloadType = "Download chosen episodes" && (!(DownloadStart) || !(DownloadEnd)) ) {
                invalidInput := 1
                Remark.updText("Useless silly Badet. You haven't chosen episodes yet.")
                Log.Add("ERROR: Badet set has set a greater starting episode than ending episode")
                ;RecordToLog("USELESS BADET. PAGPILI UG EPISODES KUNG ASA TAMAN.`r`nTRY AGAIN.", 0, 1)
                return
            }
    */
    ;===============================================
    
    ;RecordToLog("Downloading: " . DramaLink, 0)
    ;DownloadType := (DownloadType = "Download chosen episodes") ? "Download from episode " . DownloadStart . " to " . DownloadEnd : DownloadType
    ;RecordToLog("Download type: " . DownloadType, 0)
    ;RecordToLog("On download finish: " . OnFinish, 0)
return

ChangeDownloadType:
    Gui, Main:Submit, NoHide
    if (DownloadType = "Download chosen episodes") {
        Gui, Main2:Show
    } else {
        Gui, Main2:Hide
    }
return

CheckFiles:
    Loop, Files, D:\Users\bacon\Downloads\*.autodramatext, R
    {
        foundSignal := A_LoopFileFullPath
        Gosub, ProcessHelperSignal
        break
    }
return

ProcessHelperSignal:
    FileRead, fileContents, %foundSignal%
    FileDelete, %foundSignal%
    ; if fileContents = creds

    ; movieFolder

    movieFolder := """" . MOVIE_DOWNLOAD_PATH . "Twenty-Five Twenty-One (2022)" . """"

    Loop, Parse, tempContents, |
    {
        if (A_Index = 1)
            episodeName := """" . A_LoopField . ".mp4" . """"
        if (A_Index = 2)
            downloadLink := """" . A_LoopField . """"
    }

    ; TO-DO: Add a folder per series
    RunWait, %ComSpec% /c title Downloading %episodeName% && "C:\Users\bacon\Desktop\Temp\AHK\Autodrama\__res\aria2-1.36.0-win-32bit-build1\aria2c.exe" --console-log-level=warn -d %movieFolder% -o %episodeName% %downloadLink%, , Min

    if FileExist(movieFolder . "\" . episodeName)
        Msgbox, yaaay
return

MainGuiClose:
ExitApp

;aria2c -o "Character Movie" "https://fvs.io/redirector?token=aUMwZitReWp3QU5wS2R3WUREVmxzS1ZySWNHd3EzMzhrM21Vblllekt1SFpSLzBrTzc3NDhCS2NRcXo0R2xMMXFvTnNXU1kyQWRxSnpiVGN0UE9sdlJ0QXl6aEpDQW5HdjZqa3dsWHpiQnJBUHYyUXhyRHJndFhPQlUzWVY5VmRZSFd3VjFUWHVscmxJZ3pUZXkxbUlIaXRKaHJzTGFTOUYzdGo6VzRuK0RoMHdsbm14OThBWWFGcEh0Zz09x6ng"