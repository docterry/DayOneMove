;~ SetWorkingDir %A_MyDocuments%\..\Dropbox\Apps\Day One\Journal.dayone\entries
;~ MsgBox %A_WorkingDir%

loop, files, *.doentry
{
	plib := readFile(A_LoopFileName).selectSingleNode("/root/dict")
	cdate := getKey(plib,"Creation Date")
	entry := getKey(plib,"Entry Text")
	ploc := getKey(plib,"Location")
	lat := getKey(ploc,"Latitude")
	lon := getKey(ploc,"Longitude")
	MsgBox % lon
}
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

trNode := getKey(plib,"Tracks")
plNode := getKey(plib,"Playlists")

Loop, % (tot := (pl := plNode.selectNodes("dict")).Length) {
	k := pl.item(A_Index-1)
	v := readKeys(k)
	if (v.Name="Library") {
		continue
	}
	if (v["Distinguished Kind"]) {
		continue
	}
	pl_Name := v.Name
	
	pli := getKey(k,"Playlist Items")
	Loop, % (li := pli.selectNodes("dict")).Length {
		k := li.item(A_Index-1)
		id := getKey(k,"Track ID")
		tra := getTrack(id)
		fname := tra.Location
		fname := RegExReplace(fname,"file://.*music/","#EXTURL:file:///media/Music/")
		MsgBox,,% pl_Name, % fname
	}
}

ExitApp

getTrack(id) {
	global trNode
	v := getKey(trNode,id)
	res := readKeys(v)
	return res
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
