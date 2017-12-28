;~ SetWorkingDir %A_MyDocuments%\..\Dropbox\Apps\Day One\Journal.dayone\entries
;~ MsgBox %A_WorkingDir%

FileRead, f, iTunes Music Library.xml
f := RegExReplace(f,"<!DOCTYPE.*>[\r\n]+")
f := RegExReplace(f,"<plist version.*>","<root>")
f := RegExReplace(f,"</plist>","</root>")
y := new XML(f)

plib := y.selectSingleNode("/root/dict")
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
