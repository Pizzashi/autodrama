#Include Lib\Dll.ahk
#Include Lib\GDI.ahk
#Include AdvancedSettings.ahk
#Include ComboBox.ahk
#Include OnMouseMove.ahk
#Include Remark.ahk
#Include Window.ahk

class MainWindow
{
    Launch()
    {
        Global

        /*
        *      START OF LOAD RESOURCES FROM THE DLL FOR THE GUI
        */
        ;================= FONTS =================
        nSize := Dll.Read(Buffer, "resources.dll", "Fonts", "ProductSans.ttf")
        DllCall("AddFontMemResourceEx", UInt,&Buffer, UInt,nSize, Int,0, UIntP,n)
        ScreamFont := GDI.ModifyFont(0, "FontFace=Product Sans, Height=25")
        , HeaderFont := GDI.ModifyFont(0, "FontFace=Product Sans, Height=13") ; needs h20, h25 for best effects
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
        /*
        *      END OF LOAD RESOURCES FROM THE DLL FOR THE GUI
        */


        /*
        *      START OF INITIALIZING MAIN GUI
        */
        Gui, Main:New, HwndhMainGui +OwnDialogs, % "Autodrama v" . AUTODRAMA_VERSION
        ;===================== Left side of the GUI =====================
        ;================= Drama Link ===================
        Gui, Main:Add, Text, x20 y10 w200 h30 HwndhDramaLinkText c287882, % "Drama Link"
        Gui, Main:Font, s10, Segoe UI
        Gui, Main:Add, ComboBox, x20 y+5 w315 vDramaLink HwndhDramaLink, % COMBO_BOX_HISTORY
        Gui, Main:Add, Picture, x+10 yp-5 w35 h35 HwndhSearchIcon vSearchIcon gSearchDrama 0x20E
        GDI.LoadFont(hDramaLinkText, TitleFont)
        GDI.LoadPicture(hSearchIcon, hBitmapSearch)
        ;================= Start Guide ===================
        Gui, Main:Add, Text, c287882 center w300 h160 x45 y180 vStartGuide HwndhStartGuide, % "To begin, search a drama."
        GDI.LoadFont(hStartGuide, ScreamFont)
        ;=============== Download Options ===============
        Gui, MainO:New, ParentMain -Caption
        Gui, MainO:Font, s10, Segoe UI
        Gui, MainO:Add, Text, x20 y+0 w200 h40 HwndhOptionsText c287882, % "Download Options"
        Gui, MainO:Font, Norm
        Gui, MainO:Add, Text, x20 y+10 w75, % "Mode"
        Gui, MainO:Add, DDL, x+20 yp-3 w220 vDownloadType gChangeDownloadType, % "Download all episodes||Download chosen episodes"
        Gui, MainO:Add, Text, x20 y+15 w75, % "On finish"
        Gui, MainO:Add, DDL, x+20 yp-3 w220 vOnFinish, % "THE KING|Notify Daisy|Do nothing||"
        GDI.LoadFont(hOptionsText, TitleFont)
        ;=== Child GUI to hide it in one go ======
        Gui, MainO2:New, ParentMainO -Caption
        Gui, MainO2:Font, s10, Segoe UI
        Gui, MainO2:Add, Text, x20 y+10, % "Download episodes:"
        Gui, MainO2:Add, Text, x+10 yp+0, % "from"
        Gui, MainO2:Add, Edit, x+10 yp-3 w40 vDownloadStart number,
        Gui, MainO2:Add, Text, x+10 yp+3, % "to"
        Gui, MainO2:Add, Edit, x+10 yp-3 w40 vDownloadEnd number,
        Gui, MainO2:Show, x0 y150 hide
        ;=== END Child GUI  ======================
        ;=================  Download ===================
        Gui, MainO:Add, Button, x20 y182 w360 h40 disabled gDownloadDrama vDownloadBtn HwndhDownloadBtn, % "Download"
        Gui, MainO:Add, Button, x20 y+10 w113 h40 disabled gResumeDownloads vResumeDownloadBtn HwndhResumeDownloadBtn, % "Resume"
        Gui, MainO:Add, Button, x+10 yp+0 w114 h40 disabled gPauseDownloads vPauseDownloadBtn HwndhPauseDownloadBtn, % "Pause"
        Gui, MainO:Add, Button, x+10 yp+0 w113 h40 disabled gCancelDownloads vCancelDownloadBtn HwndhCancelDownloadBtn, % "Cancel"
        Gui, MainO:Show, x0 y110 hide
        GDI.LoadFont(hDownloadBtn, TitleFont)
        GDI.LoadFont(hResumeDownloadBtn, HeaderFont)
        GDI.LoadFont(hPauseDownloadBtn, HeaderFont)
        GDI.LoadFont(hCancelDownloadBtn, HeaderFont)
        ;===================== Right side of the GUI =====================
        Gui, Main:Add, Text, x420 y10 w200 h30 HwndhInformationText c287882, % "Drama Information"
        Gui, Main:Add, Button, x420 y320 w360 h40 gOpenDownloadFolder HwndhOpenDwnldDirBtn, % "Open Downloads Folder"
        GDI.LoadFont(hInformationText, TitleFont)
        GDI.LoadFont(hOpenDwnldDirBtn, HeaderFont)
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
        Gui, Main:Add, Picture, w130 h117 x20 y395 HwndhMikuIcon 0x20E gLaunchAdvancedSettings
        Gui, Main:Add, Progress, x+0 y380 w610 h100 BackgroundWhite
        Gui, MainR:Font, s12, Segoe UI
        Gui, Main:Add, Text, xp+10 yp+10 w590 h20 BackgroundTrans vRemarkTitle HwndhRemarkTitle cGreen, % "Everything looks good for now!"
        Gui, Main:Add, Text, xp+0 y+5 w590 h55 BackgroundTrans vRemarkText, % "To begin, copy and paste a drama link and click that shiny search button."
        GDI.LoadFont(hRemarkTitle, h3Font)
        GDI.LoadPicture(hMikuIcon, hBitmapMiku)

        OnMessage(0x200, "OnMouseMove") ; For changing the cursor to "HAND" when it is over the search icon
        Gui, Main:Show, h500 w800
        /*
        *      END OF INITIALIZING MAIN GUI
        */
    }
}