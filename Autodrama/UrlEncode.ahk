; https://www.autohotkey.com/boards/viewtopic.php?p=372134&sid=6ccacfcfd2eb820d173a4a1abc6e9238#p372134
UrlEncode(str, encode := true, component := true) {
    static Doc, JS
    if !Doc {
        Doc := ComObjCreate("htmlfile")
        Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
        JS := Doc.parentWindow
        ( Doc.documentMode < 9 && JS.execScript() )
    }
    Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}