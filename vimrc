call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on

set guioptions+=c
set guioptions-=T
set guioptions-=l
set guioptions-=r
set guioptions-=L
set guioptions-=R
" colorscheme vividchalk
colorscheme solarized
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40
set background=dark

if has('gui_running')
	set guifont=Monaco:h12
else
	set t_Co=256
	hi Normal ctermfg=green ctermbg=black

endif

set nocompatible
set history=100
set title
set nobackup
set backspace=indent,eol,start
set relativenumber
set ruler
set showmatch
set hlsearch
set autoindent
set incsearch
set nowrap
set list
set listchars=tab:\|\ ,trail:·,precedes:<,extends:>
set nofoldenable
set foldnestmax=1
set wildmenu
set lazyredraw
set scrolloff=1
set sidescrolloff=6
set nospell
set spelllang=es,en
set path+=/usr/local/include,**
set pastetoggle=<F10>

autocmd BufEnter README,TODO if &filetype == '' | setlocal filetype=text | endif
autocmd BufEnter *.escript   if &filetype == '' | setlocal filetype=erlang | endif
autocmd BufEnter *.md        if &filetype == '' | setlocal filetype=markdown | endif

autocmd FileType c,cpp                  setlocal foldmethod=syntax foldnestmax=2 cinoptions=(0,g0,N-s,:0
autocmd FileType erlang,haskell,ocaml   setlocal foldmethod=indent expandtab tabstop=4 shiftwidth=4 textwidth=0
autocmd FileType python                 setlocal foldmethod=indent
autocmd FileType text,markdown,tex,mail setlocal textwidth=72 formatoptions+=2l colorcolumn=+1 spell
autocmd FileType help                   setlocal nospell

" C plugin:
let c_no_curly_error = 1 " For C++11 lambdas

" Clang Complete plugin:
let clang_use_library     = 1
let clang_complete_auto   = 0
let clang_complete_macros = 1
let clang_complete_copen  = 1
autocmd FileType c,cpp setlocal completeopt=menuone
autocmd FileType c,cpp highlight clear SpellBad   | highlight SpellBad ctermfg=white ctermbg=red
autocmd FileType c,cpp highlight clear SpellLocal | highlight SpellLocal ctermfg=white ctermbg=blue
autocmd FileType c,cpp map <buffer> <silent> <Leader>e :call g:ClangUpdateQuickFix()<Enter>

" Vimerl plugin:
let erlang_folding     = 1
let erlang_show_errors = 0
let erlang_skel_header = {'author': 'Hugh Watkins <hwatkins@mergate.com>',
		       \  'owner' : 'Hugh Watkins'}

" Syntastic plugin:
let syntastic_auto_loc_list = 1
let syntastic_mode_map      = {'mode': 'passive'}

" GHC-mod plugin:
autocmd FileType haskell map <buffer> <silent> <Leader>e :GhcModCheck<Enter>
autocmd FileType haskell map <buffer> <silent> <Leader>t :GhcModType<Enter>

" Neco-GHC plugin:
autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
let $PATH = $PATH . ':' . expand('~/.cabal/bin')

match Todo /TODO\|FIXME/

map <Up>    {
map <Down>  }
map <Left>  [[
map <Right> ][

map <silent> <F1>  :NERDTreeToggle<Enter>
map <silent> <F2>  :write<Enter>
map <silent> <F3>  :nohlsearch<Enter>
map <silent> <F4>  :make<Enter>
map <silent> <F5>  :shell<Enter>
map <silent> <F6>  :if <SID>ToggleAutoHighlight()<Bar>set hlsearch<Bar>else<Bar>nohlsearch<Bar>endif<Enter>
map <silent> <F7>  :TagbarToggle<Enter>
map <silent> <F8>  :vimgrep /TODO\\|FIXME/ %<Enter>:copen<Enter>
map <silent> <F9>  :checktime<Enter>
map <silent> <F11> :w!<Enter>:!aspell check %<Enter>:w %<Enter>
map <silent> <F12> :SpellThis<Enter>

" Corrects current word spelling with the first suggestion
map <silent> <Leader>s 1z=
" Formats current paragraph
map <silent> <Leader>p gwap

" Use Tabular plugin to align variable assignments
map <silent> <Leader>t=       :Tabularize /^[^=]*\zs=<Enter>
" Use Tabular plugin to align variable declarations
map <silent> <Leader>t<Space> :Tabularize /^\s*\S*\zs\(\s\*\\|\s&\\|\s\)/l0r0<Enter>

" Adds spaces around current block of lines
map <silent> <Leader><Space> :call <SID>AddSpaces()<Enter>
" Removes spaces around current block of lines
map <silent> <Leader><BS>    :call <SID>RemoveSpaces()<Enter>
" Collapses current block of blank lines to one
map <silent> <Leader><Del>   :call <SID>CollapseSpaces()<Enter>

function s:AddSpaces() range
	let separation = 2
	let blanks     = repeat([''], separation)
	call append(a:lastline, blanks)
	call append(a:firstline - 1, blanks)
endfunction

function s:RemoveSpaces()
	if getline('.') == ''
		let fromline = prevnonblank(line('.')) + 1
		let toline   = nextnonblank(line('.')) - 1
		call s:DeleteLines(fromline, toline, 0)
		return
	endif

	let toline = search('^$', 'bnW')
	if toline != 0
		let fromline = prevnonblank(toline) + 1
		call s:DeleteLines(fromline, toline)
	endif

	let fromline = search('^$', 'nW')
	if fromline != 0
		let toline = nextnonblank(fromline) - 1
		call s:DeleteLines(fromline, toline)
	endif
endfunction

function s:CollapseSpaces()
	if getline('.') != ''
		return
	endif

	if line('.') > 1 && getline(line('.') - 1) == ''
		let toline   = line('.') - 1
		let fromline = prevnonblank(toline) + 1
		call s:DeleteLines(fromline, toline)
	endif

	if line('.') < line('$') && getline(line('.') + 1) == ''
		let fromline = line('.') + 1
		let toline   = nextnonblank(fromline) - 1
		call s:DeleteLines(fromline, toline)
	endif
endfunction

function s:DeleteLines(fromline, toline, ...)
	let toline = a:toline < 1 ? line('$') : a:toline
	silent execute a:fromline . ',' . toline . 'delete'
	if a:0 == 0 || a:0 == 1 && a:1
		normal ``
	endif
endfunction

function s:ToggleAutoHighlight()
	if exists('#auto_highlight')
		autocmd! auto_highlight
		augroup! auto_highlight
		augroup END
		set updatetime&
		return 0
	else
		augroup auto_highlight
			autocmd!
			autocmd CursorHold * let @/ = '\V\<' . escape(expand('<cword>'), '\') . '\>'
		augroup END
		set updatetime=500
		return 1
	endif
endfunction
