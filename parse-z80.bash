#!/bin/bash

function get-tokens() {
    cat <<SUPER_EOF
EX!EXX!LD!LDD!LDDR!LDI!LDIR!POP!PUSH!ADC!ADD!CP!CPD!CPDR!CPI!CPIR!CPL!DAA!DEC!INC!NEG!SBC!SUB!AND!BIT!CCF!OR!RES!SCF!SET!XOR!CALL!DJNZ!JP!JR!NOP!RET!RETI!RETN!RST!DI!EI!HALT!IM!IN!IND!INDR!INI!INIR!OTDR!OTIR!OUT!OUTD!OUTI!SRL!RLC!RRA!RRCA
SUPER_EOF
}

function get-registers() {
    cat <<SUPER_EOF
A!F!B!C!D!E!H!L!I!R!AF!DE!HL!BC!IX!IY!SP!Z!NZ!C!NC!P!PO!M
SUPER_EOF
}

function get-registers-non-ambiguous() {
    cat <<SUPER_EOF
(DE)!(HL)!($(_whitespace)*I[XY]$(_whitespace)*\([-+]$(_expr)$(_whitespace)*\)$(_optional))!($(_number))!AF'!'.'
SUPER_EOF
}

function get-literals() {
    cat <<SUPER_EOF
($(_expr))!$(_expr)
SUPER_EOF
}

function to-regex() {
    sed -e 's/!/\\|/g'
}

function to-lower() {
    tr "[A-Z]" "[a-z]"
}

function function-exists() {
    local search_for
    search_for=$1
    declare -F | grep "declare -f $search_for" &>/dev/null
}

function _whitespace() { echo "[ \\t]"; }
function _one-or-more() { echo "\\{1,\\}"; }
function _binary_number() { echo "-$(_optional)%[01]$(_one-or-more)"; }
function _hex_number_base() { echo "[0-9a-f]$(_one-or-more)"; }
function _hex_number_prefix() { echo "-$(_optional)$(_or '\$' 0x)$(_hex_number_base)"; }
function _hex_number_postfix() { echo "-$(_hex_number_base)h"; }
function _hex_number() { echo "$(_or _hex_number_prefix _hex_number_postfix)"; }
function _decimal_number() { echo "-$(_optional)[0-9]$(_one-or-more)"; }
function _number() { echo "$(_or _binary_number _hex_number _decimal_number)"; }
function _identifier() { echo "[a-z_][a-z_0-9]*"; }
function _immediate() { echo "$(_or _number _identifier)"; }
function _expr() { echo "$(_immediate)$(_optional)\\($(_whitespace)*[-+*\\/]$(_whitespace)*($(_optional)$(_whitespace)*$(_immediate)$(_optional))$(_optional)\\)*"; }
function _optional() { echo "\\{0,1\\}"; }
function _or() { 
    local cur first
    first=1
    echo -n "\\("
    for cur; do
	if function-exists "$cur"; then
	    cur=$($cur)
	fi
	if [[ $first != 1 ]]; then
	    echo -n "\\|"
	fi
	echo -n "$cur"
	first=0
    done
    echo "\\)"
}
function _tokens() {
    get-tokens | to-lower | to-regex
}
function _registers() {
    get-registers | to-lower | to-regex
}
function _registers-non-ambig() {
    get-registers-non-ambiguous | to-lower | to-regex
}
function _literals() {
    get-literals | to-lower | to-regex
}

function tokenize() {
    $(
	if [[ -n $DEBUG ]]; then
	    echo echo
	else
	    echo "sed -e"
	fi
    ) "
# First, clean everything up
# Comments
s/;.*//;
# Whitespace-only lines
s/$(_whitespace)$(_one-or-more)$//;
# Empty lines
/^$/d;
# #define, .db lines
/^$(_whitespace)*[.#]/d;
# labels
/^$(_whitespace)*$(_identifier):/d;
# bcalls
/b.*call/d;


# First part will be the actual instruction
s/^$(_whitespace)*\($(_tokens)\)\b$(_whitespace)*/[\1]!/;
  /!$/ b end;

# Next comes the first argument, which has a few forms:
# 1. register: a, b, (hl), (ix + 3)
# NOTE: _expr will take up one extra group, so we have to account for that
# First, we do ambigous ones (like fe, which could be part of "feature_check"
t reset1; :reset1
s/!$(_whitespace)*\($(_registers)\)\b/[\1]!/;
  t finish_2;

# Then, non-ambigous ones (like (hl) which can't be part of another identifier)
s/!$(_whitespace)*\($(_registers-non-ambig)\)/[\1]!/;
  t finish_2;

# 2. literals (LOCATION), EXPR
s/!$(_whitespace)*\($(_literals)\)/<\1>!/;

:finish_2
s/!$(_whitespace)$(_optional),$(_optional)$(_whitespace)*/!/;
  /!$/ b end;

# Finally, we have the last argument which is basically the previous part
t reset2; :reset2
s/!$(_whitespace)*\($(_registers)\)\b/[\1]!/;
  t finish_3;
s/!$(_whitespace)*\($(_registers-non-ambig)\)/[\1]!/;
  t finish_3;
s/!$(_whitespace)*\($(_literals)\)/<\1>!/;
:finish_3

:end
# The end!
s/!$//;

"
}

function filter-literals() {
    sed -e "
# Remove anything inside [brackets]
:filter_asm_loop
s/\[[^]]$(_one-or-more)\]//;
t filter_asm_loop;

/^$/d

# Now remove the <> part of <literal>
:filter_literals_loop
s/<\([^>]$(_one-or-more)\)>/\1/;
/</ { 
  s/[^<]$(_one-or-more)/&\n/;
  b filter_literals_loop
};

# Remove the parentheses around some expressions
s/^(\(.*\))/\1/;

# The last parts leaves empty lines, delete them
/^$(_whitespace)$(_one-or-more)$/ d;

# Make sure there's an empty line at the end
$ { 
  /^$/ ! {
    s/.*/&\n/;
  };
}
"
}

function filter-variables() {
    sed -e "
# Remove numbers because they screw us over.
s/$(_number)//g;

# Put brackets around identifiers
s/$(_identifier)/<&>/g;

# Remove everything but the things within brackets
# Either, there's no identifiers
/</ ! {
  d;
}

# Or there's some identifiers
t reset; :reset;
:filter_identifiers_loop
s/.*<\([^>]$(_one-or-more)\)>[^<]*/\1/g;
/</ {
  s/[^<]$(_one-or-more)/&\n/;
}
t filter_identifiers_loop

# Now clean up the empty lines
/^$(_whitespace)*$/ {
  d;
}
"
}

function main {
    sed $0 -ne '/[S]TART/,$ { /[S]TART/ n; p; }' \
	| to-lower \
	| tokenize \
	#| filter-literals \
	#| filter-variables \
	#| sort \
	#| uniq -c \
	#| sort -n
}

main "$@"
exit

START
; robotfindskitten
; 3 September 2009
; http://robotfindskitten.org/
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; Ideas:
; - Allow the game to read the data from both RAM and the archive, or even
;   store the data in the program itself.
; - Add support for more than 254 objects.  The RFKDATA file already uses a 16-
;   number for object count field.  If you add more than 254 objects, older
;   versions of the game won't crash, but they'll only use 254 objects.
; - You can the responses in the RFKDATA file.  See rfkdata.asm for details. 


; ===== ========================================================================
.nolist
#include "ti83plus.txt"
.list
#include "equates.asm"


; ===== Header =================================================================
	.org	$9D93
	.db	t2ByteTok, tAsmCmp

	xor	a
	jr	nc, startOfTheProgram
gameNameMsg:
	.db	"robotfindskitten v1.0",0
startOfTheProgram:

; ===== Init ===================================================================
	set	appAutoScroll, (iy + appFlags)

	; Clear out memory
	ld	hl, appBackUpScreen
	ld	(hl), 0
	ld	de, appBackUpScreen+1
	ld	bc, 750
	ldir

	; Data file
	ld	hl, rfkDataName
	b_call(_Mov9ToOP1)
	b_call(_ChkFindSym)
	jr	nc, dataFound
dataNotFound:
	ld	hl, dataNotFoundMsg
	b_call(_PutS)
	b_call(_NewLine)
	ret
dataFound:
	ld	a, b
	or	a
	jr	z, dataNotFound
	ld	(dataFilePage), a
	ld	(dataFileLoc), de
	ld	a, b
	ex	de, hl
	ld	de, appData
	ld	bc, 100
	b_call(_FlashToRAM)
	ld	hl, appData+21
	ld	de, rfkDataVerifyString
	ld	b, 10
	ld	c, 100
verifyDataLoop:
	ld	a, (de)
	inc	de
	cpi
	jr	nz, dataNotFound
	djnz	verifyDataLoop
	ld	a, (appData+31)
	ld	(maxObjects), a	; Check to make sure we haven't gotten a 16-bit
	ld	a, (appData+32)	; data file.
	or	a
	jr	z, dataVerified
	ld	a, 254
	ld	(maxObjects), a
dataVerified:
	ld	hl, (dataFileLoc)
	ld	de, 22
	add	hl, de
	ld	a, (dataFilePage)
	call	adjustForNextPage
	ld	(dataFilePage), a
	ld	(dataFileLoc), hl
	
	;b_call(_ClrScrn)
	b_call(_ClrLCDFull)
	
	res	indicRun, (iy+indicFlags)
	res	textWrite, (iy+sGrFlags)
	set	FullScrnDraw, (iy+ApiFlg4) ; apparently has no effect
	b_call(_APDSetup)
	b_call(_EnableAPD)

; Help screen.
; I'm too lazy for a loop here.
	ld	hl, 0
	ld	(PenCol), hl
	ld	hl, titleText
	b_call(_VPutS)
	ld	de, 1*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 2*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 3*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 4*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 5*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 6*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 7*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	ld	de, 8*7*256
	ld	(PenCol), de
	b_call(_VPutS)
	b_call(_GetKey)
	cp	kCapV
	jr	nz, doneWithTitle
	b_call(_ClrLCDFull)
	ld	hl, 0
	ld	(PenCol), hl
	ld	hl, gameNameMsg
	b_call(_VPutS)
	b_call(_GetKey)
doneWithTitle:
	;b_call(_ClrScrn)
	b_call(_ClrLCDFull)

	; Random number generator
	b_call(_Random)
	ld	hl, seed1+2
	ld	de, LFSRSeed
	ld	bc, 8
	ldir


; ----- Random playfield -------------------------------------------------------
; The play field is a grid, eight lines high by fifteen columns wide.
; The ninth line is for the responses.  We could make it ten lines total, but
; that would mess up random number generation.  Not that it's not already messed
; up.
	ld	a, 17
	ld	(OP1+1), a
populateFieldLoop:
	; Location on screen
	call	RandLFSR
	and	%00001111
	cp	15
	jr	z, populateFieldLoop
	ld	(currentX), a
	call	CalcCol
	call	RandLFSR
	and	%00000111
	ld	(currentY), a
	call	calcRow
makeRandomCharLoop:
	call	RandLFSR
	ld	(OP1), a
	srl	a
	srl	a
	srl	a
	ld	hl, goodCharsMap
	ld	d, 0
	ld	e, a
	add	hl, de
	ld	c, (hl)
	ld	a, (OP1)
	and	%00000111
	inc	a
	ld	b, a
makeRandomCharLoopLoop:
	sla	c
	djnz	makeRandomCharLoopLoop
	jr	nc, makeRandomCharLoop
	ld	a, (OP1)
	b_call(_VPutMap)
makeRandomCharLoopLoopLoop:
	call	RandLFSR
	or	a
	jr	z, makeRandomCharLoopLoopLoop
	ld	c, a
	ld	a, (maxObjects)
	cp	c
	jr	c, makeRandomCharLoopLoopLoop
	; ?
	call	calcLoc
	ld	(hl), c
	ld	a, (OP1)
	ld	de, playFieldSize
	add	hl, de
	ld	(hl), a
	ld	a, (OP1+1)
	dec	a
	ld	(OP1+1), a
	jr	nz, populateFieldLoop
	or	a
	sbc	hl, de
	ld	(hl), kitten


; ----- Play loop --------------------------------------------------------------
	; Location on screen
play:
	res	foundObject, (iy+asm_Flag1)
	call	RandLFSR
	and	%00001111
	cp	15
	jr	z, play
	ld	(currentX), a
	call	calcCol
	call	RandLFSR
	and	%00000111
	ld	(currentY), a
	call	calcRow
	call	calcLoc
	ld	a, (hl)
	or	a
	jr	nz, play
playLoop:
	ld	a, (currentX)
	call	calcCol
	ld	a, (currentY)
	call	calcRow
	ld	a, '#'
	b_call(_VPutMap)
	
	
getKeyLoop:
	bit	foundObject, (iy+asm_Flag1)
	jp	z, getKeyLoopKeyGet
	ld	hl, (scrollTimer)
	dec	hl
	ld	(scrollTimer), hl
	ld	a, (stringStage)
	cp	1
	jp	z, stringPause1
	cp	2
	jr	z, stringScroll
	cp	3
	jp	z, stringPause2
stringRestart:
	ld	a, 1
	ld	(stringStage), a
	ld	hl, 7h
	ld	(CurRow), hl
	ld	a, ' '
	ld	b, 15
stringEraseLoop:
	b_call(_PutC)
	djnz	stringEraseLoop
	b_call(_PutMap)
	ld	hl, 56*256
	ld	(PenCol), hl
	ld	hl, appData
	res	foundObject, (iy+asm_Flag1)
	call	VPutS
	jp	nc, getKeyLoopKeyGet
	set	foundObject, (iy+asm_Flag1)
	ld	hl, mediumWait
	ld	(scrollTimer), hl
	ld	hl, appData
	ld	(stringOffset), hl
	jp	getKeyLoopKeyGet
stringScroll:
	ld	hl, (scrollTimer)
	ld	de, 0FFFFh
	add	hl, de	; This way flags aren't an issue.
	jr	c, getKeyLoopKeyGet
	ld	hl, (stringOffset)
	inc	hl
	ld	(stringOffset), hl
	ld	hl, 56*256
	ld	(PenCol), hl
	ld	hl, (stringOffset)
	call	VPutS
	push	af
	ld	a, ' '
	b_call(_VPutMap)
	ld	a, ' '
	b_call(_VPutMap)
	pop	af
	jr	nc, stringScrollDispStringDoneScroll
	ld	hl, shortWait
	ld	(scrollTimer), hl
	jr	getKeyLoopKeyGet
stringScrollDispStringDoneScroll:
	ld	hl, longWait
	ld	(scrollTimer), hl
	ld	a, (stringStage)
	inc	a
	ld	(stringStage), a
	jr	getKeyLoopKeyGet
stringPause1:
stringPause2:
	ld	hl, (scrollTimer)
	ld	de, 0FFFFh
	add	hl, de
	jr	c, getKeyLoopKeyGet
	ld	hl, shortWait
	ld	(scrollTimer), hl
	ld	a, (stringStage)
	inc	a
	ld	(stringStage), a
	
	
getKeyLoopKeyGet:
	b_call(_GetCSC)
	or	a
	jp	z, getKeyLoop

	push	af
; Location off screen
	ld	a, (currentX)
	call	calcCol
	ld	a, (currentY)
	call	calcRow
	ld	hl, spaceText
	b_call(_VPutS)
	pop	af

	cp	skUp
	jr	z, goUp
	cp	skDown
	jr	z, goDown
	cp	skLeft
	jr	z, goLeft
	cp	skRight
	jr	z, goRight
	cp	skMode
	jr	z, quit
	cp	skClear
	jp	nz, getKeyLoop
quit:	b_call(_ClrScrnFull)
	b_call(_HomeUp)
	res	DonePrgm, (iy+DoneFlags)
	res	OnInterrupt, (iy+OnFlags)
	ret

goLeft:
	ld	a, (currentX)
	or	a
	jp	z, playLoop
	dec	a
	ld	(currentX), a
	call	calcLoc
	ld	a, (hl)
	or	a
	jp	z, playLoop
	ld	b, a
	ld	a, (currentX)
	inc	a
	ld	(currentX), a
	jr	robotFoundObject
goRight:
	ld	a, (currentX)
	cp	14
	jp	nc, playLoop
	inc	a
	ld	(currentX), a
	call	calcLoc
	ld	a, (hl)
	or	a
	jp	z, playLoop
	ld	b, a
	ld	a, (currentX)
	dec	a
	ld	(currentX), a
	jr	robotFoundObject
goUp:
	ld	a, (currentY)
	or	a
	jp	z, playLoop
	dec	a
	ld	(currentY), a
	call	calcLoc
	ld	a, (hl)
	or	a
	jp	z, playLoop
	ld	b, a
	ld	a, (currentY)
	inc	a
	ld	(currentY), a
	jr	robotFoundObject
goDown:	
	ld	a, (currentY)
	cp	7
	jp	nc, playLoop
	inc	a
	ld	(currentY), a
	call	calcLoc
	ld	a, (hl)
	or	a
	jp	z, playLoop
	ld	b, a
	ld	a, (currentY)
	dec	a
	ld	(currentY), a
robotFoundObject:
	ld	a, b
	cp	kitten
	jr	z, robotfindskitten
	set	foundObject, (iy+asm_Flag1)
	ld	h, 0
	ld	l, a
	add	hl, hl
	ld	de, (dataFileLoc)
	add	hl, de
	ld	de, 9
	add	hl, de
	ld	a, (dataFilePage)
	call	adjustForNextPage
	ld	de, appData
	ld	bc, 4
	b_call(_FlashToRAM)
	ld	hl, (dataFileLoc)
	ld	de, (appData)
	add	hl, de
	dec	hl	; I don't know.
	dec	hl
	dec	hl
	ld	a, (dataFilePage)
	call	adjustForNextPage
	ld	bc, 256
	ld	de, appData
	b_call(_FlashToRAM)
	xor	a
	ld	(stringStage), a
	jp	playLoop

robotfindskitten:
	ld	de, playFieldSize
	add	hl, de
	push	hl
	pop	ix
	b_call(_ClrScrnFull)
	ld	hl, 400h
	ld	(CurRow), hl
	ld	a, (ix)
	b_call(_PutC)
	ld	a, ' '
	b_call(_PutC)
	b_call(_PutC)
	b_call(_PutC)
	b_call(_PutC)
	b_call(_PutC)
	b_call(_PutC)
	ld	a, '#'
	b_call(_PutC)
	call	wait

	ld	a, 4
	ld	(CurCol), a
	ld	a, ' '
	b_call(_PutC)
	ld	a, (ix)
	b_call(_PutC)
	ld	a, ' '
	b_call(_PutC)
	b_call(_PutC)
	b_call(_PutC)
	b_call(_PutC)
	ld	a, '#'
	b_call(_PutC)
	ld	a, ' '
	b_call(_PutC)
	call	wait

	ld	a, 5
	ld	(CurCol), a
	ld	a, ' '
	b_call(_PutC)
	ld	a, (ix)
	b_call(_PutC)
	ld	a, ' '
	b_call(_PutC)
	b_call(_PutC)
	ld	a, '#'
	b_call(_PutC)
	ld	a, ' '
	b_call(_PutC)
	call	wait

	ld	a, 6
	ld	(CurCol), a
	ld	a, ' '
	b_call(_PutC)
	ld	a, (ix)
	b_call(_PutC)
	ld	a, '#'
	b_call(_PutC)
	ld	a, ' '
	b_call(_PutC)
	call	wait


	b_call(_HomeUp)
	ld	hl, robotfindskittenMsg
	b_call(_PutS)
	call	wait
;	call	wait
	ld	hl, goodJobMsg
	b_call(_PutS)
	b_call(_NewLine)
	res	DonePrgm, (iy+DoneFlags)
	res	OnInterrupt, (iy+OnFlags)
	ret


; ===== Data ===================================================================

#include "routines.asm"
#include "data.asm"

.end
.end
ld a, 5h
