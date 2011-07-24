:set previewheight=3
:map <F4> :cn
:map <F5> :silent !c:\pp\algovis\algovis\compile.bat<CR>:cfile c:\temp\makeoutput.txt<CR>
:cd c:\pp\algovis\algovis
:set path+=./visualize/*.coffee,*.bat,*.py,*.yaml,./visualize/*.coffee,./Templates/*.html,./visualize/*.css

set errorformat=%f:Error:%m\ on\ line\ %l,
				    \%f:Error:\ %s\ on\ line\ %l%m

:set foldcolumn=2 fdn=1 
:highlight FoldColumn gui=bold guibg=NONE guifg=green
:highlight Folded gui=NONE guibg=NONE guifg=white


