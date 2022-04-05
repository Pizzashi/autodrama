   /*    This file contains the following (usable) functions:
	*    * GdiPlus("Startup") OR GdiPlus("Shutdown")
	*       - Use when adding pictures (only) to GUI from buffer
	*    * GDIPlus_hBitmapFromBuffer(Buffer, nSize)
	*       - Use with GdiPlus("Startup") and DllRead(params*)
	*    * fontHandle := GDI_ModifyFont(0, "FontFace=Product Sans, Height=24" ))
	*          ; Step 1 : Load the data from DLL
	*          nSize := DllRead(Buffer, "AHK.dll", "Fonts", "ProductSans.TTF" )
	*          ; Step 2 : Load the font for private use. ( No other application can get an handle to it )
	*          DllCall( "AddFontMemResourceEx", UInt,&Buffer, UInt,nSize, Int,0, UIntP,n )
	*          ; Step 3 : Obtain handle to the above loaded font. ( You need to know the Font name )
	*
	*/


class GDI
{
	LoadFont(hWnd, hFont)
	{
		/*
		*  WM_SETFONT = 0x30
		*/
		SendMessage, 0x30, hFont, ,, ahk_id %hWnd%
	}

	LoadPicture(hWnd, hBitMap)
	{
		/*
		*  STM_SETIMAGE = 0x172
		*  IMAGE_BITMAP = 0x0
		*/
		SendMessage, 0x172, 0x0, hBitMap,, ahk_id %hWnd%
	}

	Commence( Comm="Startup" )
	{
		Static pToken, hMod
		hMod := hMod ? hMod : DllCall( "LoadLibrary", Str,"gdiplus.dll" )
		If ( Comm="Startup" )
		VarSetCapacity( si,16,0 ), si := Chr(1)
		, Res := DllCall( "gdiplus\GdiplusStartup", UIntP,pToken, UInt,&si, UInt,0 )
		Else Res := DllCall( "gdiplus\GdiplusShutdown", UInt,pToken )
		, hMod := DllCall( "FreeLibrary", UInt,hMod ) >> 64
		Return ! Res
	}

	; GDIP
	;  Last Modifed : 21-Jun-2011
	; Adapted version by SKAN www.autohotkey.com/forum/viewtopic.php?p=383863#383863
	; Original code by   Sean www.autohotkey.com/forum/viewtopic.php?p=147029#147029
	hBitmapFromBuffer( ByRef Buffer, nSize )
	{
		hData := DllCall("GlobalAlloc", UInt,2, UInt,nSize )
		pData := DllCall("GlobalLock",  UInt,hData )
		DllCall( "RtlMoveMemory", UInt,pData, UInt,&Buffer, UInt,nSize )
		DllCall( "GlobalUnlock" , UInt,hData )
		DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
		DllCall( "gdiplus\GdipCreateBitmapFromStream",  UInt,pStream, UIntP,pBitmap )
		DllCall( "gdiplus\GdipCreateHBITMAPFromBitmap", UInt,pBitmap, UIntP,hBitmap, UInt
		,DllCall( "ntdll\RtlUlongByteSwap",UInt
		,DllCall( "GetSysColor", Int,15 ) <<8 ) | 0xFF000000 )
		DllCall( "gdiplus\GdipDisposeImage", UInt,pBitmap )
		DllCall( NumGet( NumGet(1*pStream)+8 ), UInt,pStream ) ; IStream::Release
		Return hBitmap
	}

	; https://www.autohotkey.com/board/topic/74964-gdi-modifyfont/
	; Creates a new font by modifying the template of an existing font          CD:24-Dec-2011
	; Topic: www.autohotkey.com/forum/viewtopic.php?t=80322                     LM:24-Dec-2011
	ModifyFont( hFont=0, Options="" ) 
	{
		; OBJ_FONT = 6,    DEFAULT_GUI_FONT = 17                ;     LOGFONT {
		If ! ( DllCall( "GetObjectType",  UInt,hFont ) = 6 )    ;       0 LONG  lfHeight
				hFont := DllCall( "GetStockObject", UInt,17 )    ;       4 LONG  lfWidth
																;       8 LONG  lfEscapement
																;      12 LONG  lfOrientation
																;      16 LONG  lfWeight
		VarSetCapacity( LF, 100, 0 )                            ;      20 BYTE  lfItalic
		DllCall( "GetObject", UInt,hFont, UInt,100, UInt,&LF )  ;      21 BYTE  lfUnderline
																;      22 BYTE  lfStrikeOut
																;      23 BYTE  lfCharSet
		Loop, Parse, Options, =`,, %A_Space%                    ;      24 BYTE  lfOutPrecision
		A_Index & 1                                             ;      25 BYTE  lfClipPrecision
		?  ErrorLevel  := SubStr( A_LoopField, 1, 4 )           ;      26 BYTE  lfQuality
		: %ErrorLevel% := SubStr( A_LoopField, 1                ;      27 BYTE  lfPitchAndFamily
						, ErrorLevel="Font" ? 32 : 4 )           ;      28 TCHAR lfFaceName }


		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Heig <> "" ) ;                                                                Height
		LogPixels := DllCall( "GetDeviceCaps", UInt,hDC:= DllCall( "GetDC", UInt,0 ), UInt,90 )
		, DllCall( "ReleaseDC", UInt,0, UInt,hDC )
		, NumPut( 0 - DllCall( "MulDiv", Int,Heig, Int,LogPixels, Int,72 ), LF, "Int" )


		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Widt <> "" ) ;                                                                 Width
		NumPut( Widt, LF,  4 )


		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Esca <> "" ) ;                                                            Escapement
		NumPut( Esca, LF,  8 )


		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Orie <> "" ) ;                                                           Orientation
		NumPut( Orie, LF, 12 )


		/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		NORMAL or REGULAR                                                                Weight
		BOLD
		EXTRABOLD
		HEAVY or BLACK
		MEDIUM
		THIN
		SEMIBOLD or DEMIBOLD
		ULTRALIGHT
		LIGHT
		DONTCARE
		*/
		
		If ( Weig <> "" && ( Wt := Weig ) )
		NumPut( ( Wt="Norm" || Wt="Regu" ) ? 400 : ( Wt="Bold" ) ? 700 : ( Wt="Extr" ) ? 800
				: ( Wt="Heav" || Wt="Blac" ) ? 900 : ( Wt="Medi" ) ? 500 : ( Wt="Thin" ) ? 100
				: ( Wt="Semi" || Wt="Demi" ) ? 600 : ( Wt="Ultr" ) ? 200 : ( Wt="Ligh" ) ? 300
				: 0, LF, 16 )

		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Ital <> "" ) ;                                                            Italicise?
		NumPut( !!Ital, LF, 20, "UChar" )


		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Unde <> "" ) ;                                                            Underline?
		NumPut( !!Unde, LF, 21, "UChar" )


		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		If ( Stri <> "" ) ;                                                            StrikeOut?
		NumPut( !!Stri, LF, 22, "UChar" )


		/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		DEFAULT SYMBOL ANSI MAC OEM                                                CharacterSet
		ARABIC  BALTIC  CHINESEBIG5  EASTEUROPE  GB2312  GREEK  HANGUL
		HEBREW  JOHAB  RUSSIAN  SHIFTJIS  THAI  TURKISH VIETNAMESE
		*/

		If ( Char <> "" )                                                    ;
		NumPut( ( Char="Defa" ) ?   1 : ( Char="Symb" ) ?   2 : ( Char="Ansi" ) ?   0
				: ( Char="MAC_" ) ?  77 : ( Char="Arab" ) ? 178 : ( Char="Balt" ) ? 186
				: ( Char="Chin" ) ? 136 : ( Char="East" ) ? 238 : ( Char="GB23" ) ? 134
				: ( Char="Gree" ) ? 161 : ( Char="Hang" ) ? 129 : ( Char="Hebr" ) ? 177
				: ( Char="Joha" ) ? 130 : ( Char="OEM_" ) ? 255 : ( Char="Russ" ) ? 204
				: ( Char="Shif" ) ? 128 : ( Char="Thai" ) ? 222 : ( Char="Turk" ) ? 162
				: ( Char="Viet" ) ? 163 :   Char, LF, 23, "UChar" )


		/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		DEFAULT                                                                 OutputPrecision
		DEVICE
		OUTLINE
		PS_ONLY
		RASTER
		STRING
		STROKE
		TT_ONLY
		TT
		*/

		If ( OutP <> "" )
		NumPut( ( OutP="Defa" ) ? 0 : ( OutP="Devi" ) ? 5 : ( OutP="Outl" ) ? 8
				: ( OutP="TT_O" ) ? 7 : ( OutP="TT"   ) ? 4 : ( OutP="PS_O" ) ? 10
				: ( OutP="Stri" ) ? 1 : ( OutP="Rast" ) ? 6 : ( OutP="Stro" ) ? 3
				:   OutP, LF, 24, "UChar" )

		/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		DEFAULT                                                               ClippingPrecision
		STROKE
		EMBEDDED
		LH_ANGLES
		*/

		If ( Clip <> "" )
		NumPut( ( Clip="Defa" ) ?  0 : ( Clip="Stro" ) ? 2 : ( Clip="Embe" ) ? 128
				: ( Clip="LH_A" ) ? 16 :   Clip, LF, 25, "UChar" )


		/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		CLEARTYPE                                                                       Quality
		ANTIALIASED
		NONANTIALIASED
		PROOF
		DRAFT
		DEFAULT
		*/

		If ( Qual <> "" )
		NumPut( ( Qual="Clea" ) ? 5 : ( Qual="Anti" ) ? 4 : ( Qual="NonA" ) ? 3
				: ( Qual="Proo" ) ? 2 : ( Qual="Draf" ) ? 1 : ( Qual="Defa" ) ? 0
				:   Qual, LF, 26, "UChar" )
		

		/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		DECORATIVE                                                               PitchAndFamily
		DONTCARE     
		MODERN 
		ROMAN 
		SCRIPT
		SWISS 
		*/

		If ( Pitc <> "" )
		NumPut( ( Pitc="Dont" ) ?  0 : ( Pitc="Deco" ) ? 80 : ( Pitc="Mode" ) ? 48
				: ( Pitc="Roma" ) ? 16 : ( Pitc="Scri" ) ? 64 : ( Pitc="Swis" ) ? 32
				:   Pitc, LF, 27, "UChar" )

		;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		;                                                                             FontFaceName

		If ( Font <> "" )
		DllCall( "RtlMoveMemory", UInt,&LF+28, UInt,&Font, Int,StrLen( Font )
													* ( A_IsUnicode ? 2 : 1 ) )

		Return DllCall( "CreateFontIndirect", UInt,&LF, UInt )
	}

	DeleteObject(hObj)
	{
		Return !! DllCall( "GDI32\DeleteObject", UInt,hObj )
	}
}