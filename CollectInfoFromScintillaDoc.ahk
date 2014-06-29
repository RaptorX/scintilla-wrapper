;AHK V2

global _t  ;Super global used in Callout of RegEx
_s:=FileRead("ScintillaDoc.html")
_t:="|"
Callout1(_m){
	_t.=_m[1] . "|"
	return 1
}
RegExMatch(_s,'(?:<a class="message" href="#[^"]+">(.+?)</a>)(?CCallout1)')

_s:=_t,_t:={}
Callout2(_m){
	local _msg,_pl,_pw
	_msg:=_m[1]
	if _m[2]		;F(a)
		_pl:=_m[2]
	else			;F(a,b)
		_pl:=_m[3]	,_pw:=_m[4]
	local _s:=0
	if Instr(_pl,"const char *")
		_s|=0x1
	if Instr(_pw,"const char *")
		_s|=0x2
	if(_s!=0){
		_msg:=SubStr(_msg,5)	;SCI_XXX→XXX
		_msg:=StrLower(_msg)	;XXX→xxx
		_t[_msg]:=_s
	}
	return 1
}

_x:=RegExMatch(_s,"
				(
					x)
						\| ([A-Z_8]+)	\(	(?:				# Function(Msg) Name + Param List Begin
												([^,)|]+)	# One Param
												|			# or
												([^,|]+),\ ([^)|]+)	)	# Two Param
										\)					# Param List End
						\|
						(?CCallout2)
				)")

_o:=""
for _k,_v in _t
	_o.=_k ":" _v ","

Clipboard:=_o
