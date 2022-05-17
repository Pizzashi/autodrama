; Converts BitMap to grayscale
ToGrayscale(sBM) {                            ; By SKAN on CR7J/D39L @ tiny.cc/tograyscale
  Local  ; Original ver. GDI_GrayscaleBitmap() @ https://autohotkey.com/board/topic/82794-

  P8:=(A_PtrSize=8),  VarSetCapacity(BM,P8? 32:24, 0)
  DllCall("GetObject", "Ptr",sBM, "Int",P8? 32:24, "Ptr",&BM)
  W := NumGet(BM,4,"Int"), H := NumGet(BM,8,"Int")
  sDC := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr")

  DllCall("DeleteObject", "Ptr",DllCall("SelectObject", "Ptr",sDC, "Ptr",sBM, "Ptr"))

  tBM := DllCall( "CopyImage", "Ptr"
       , DllCall( "CreateBitmap", "Int",1, "Int",1, "Int",0x1, "Int",8, "Ptr",0, "Ptr")
       , "Int",0, "Int",W, "Int",H, "Int",0x2008, "Ptr")

  tDC := DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  DllCall("DeleteObject", "Ptr",DllCall("SelectObject", "Ptr",tDC, "Ptr",tBM, "Ptr"))

  Loop % (255, n:=0x000000, VarSetCapacity(RGBQUAD256,256*4,0))
        Numput(n+=0x010101, RGBQUAD256, A_Index*4, "Int")
  DllCall("SetDIBColorTable", "Ptr",tDC, "Int",0, "Int",256, "Ptr",&RGBQUAD256)

  DllCall("BitBlt",   "Ptr",tDC, "Int",0, "Int",0, "Int",W, "Int",H
                    , "Ptr",sDC, "Int",0, "Int",0, "Int",0x00CC0020)

Return % (tBM, DllCall("DeleteDC", "Ptr",sDC), DllCall("DeleteDC", "Ptr",tDC))
}