SetWorkingDir %A_MyDocuments%\..\Dropbox\Apps\Day One\Journal.dayone\entries

y := new XML("<root/>")

loop, files, *.doentry
{
	idx := A_Index
	plib := readFile(A_LoopFileName).selectSingleNode("/root/dict")
	
	pdate := getKey(plib,"Creation Date")
		pdate := RegExReplace(pdate, "[TZ\-\:]")
		pdate += -8, H
		FormatTime, cdate, % pdate, ddd, dd MMM yyyy HH:mm:ss
	
	pent := getKey(plib,"Entry Text")
		t := instr(pent, "`n")
		if (t between 1 and 80) 
		{
			title := SubStr(pent,1,t)
			body := SubStr(pent,t+1)
		} else {
			title := 
			body := pent
		}
		body := RegExReplace(body,"`n","</p><p>")
	ploc := getKey(plib,"Location")
		lat := getKey(ploc,"Latitude")
		lon := getKey(ploc,"Longitude")
	
	y.addElement("item","root",{id:idx})
		y.addElement("title","/root/item[@id='" idx "']",title)
		y.addElement("pubDate","/root/item[@id='" idx "']",cdate)
		y.addElement("content___encoded","/root/item[@id='" idx "']","<p>" body "</p>")
}
y.save("import.xml")

FileRead, yTxt, import.xml
yTxt := RegExReplace(yTxt, "<item id.*?>","<item>")
yTxt := RegExReplace(yTxt, "___",":")
yTxt := RegExReplace(yTxt, "&lt;","<")
yTxt := RegExReplace(yTxt, "&gt;",">")

yT1 =
(
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0"
	xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/"
	xmlns:content="http://purl.org/rss/1.0/modules/content/"
	xmlns:wfw="http://wellformedweb.org/CommentAPI/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:wp="http://wordpress.org/export/1.2/"
>
)

yTxt := yT1 . yTxt . "</rss>"

FileDelete, import.xml
FileAppend, % yTxt, import.xml

ExitApp

readfile(fn) {
	FileRead, txt, % fn
	txt := RegExReplace(txt,"<.xml.*?>[\r\n]+")
	txt := RegExReplace(txt,"<!DOCTYPE.*?>[\r\n]+")
	txt := RegExReplace(txt,"<plist version.*?>","<root>")
	txt := RegExReplace(txt,"</plist>","</root>")
	txt := RegExReplace(txt,"\n","`r`n")
	return new XML(txt)
}

getKey(dict,lbl) {
/*	dict = <dict> object containing <key /><$val /> pairs
	lbl  = <key> to find in <dict>
*/
	key := dict.selectSingleNode("key[text()='" lbl "']")
	val := key.nextSibling
	if (val.nodeName~="array|dict") {
		return val
	} 
	return val.text
}

readKeys(dict) {
/*	dict = <dict> object containing <key /><$val /> pairs
	returns obj res[keystr]:=valstr
*/
	res := []
	Loop, % (pairs := dict.selectNodes("*")).Length {
		k := pairs.item(i:=A_Index-1)
		if (k.nodeName="key") {
			v := pairs.item(i+1)
			keyStr := k.text
			valStr := (v.nodeName~="array|dict") ? v.nodeName : v.text
			res[keyStr]:=valStr
		}
	}
	return res
}

#Include xml.ahk
#Include strx.ahk
