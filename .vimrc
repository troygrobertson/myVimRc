autocmd!
call pathogen#infect()
set nocompatible
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch

" keep more context when scrolling off the end of a buffer
set scrolloff=3


" make tab completion for files/buffers act like bash
set wildmenu
let mapleader=","

set backspace =indent,eol,start
set showcmd
" makes RVM work inside Vim. I have no idea why.
set shell=bash
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
set cmdheight=1
set switchbuf=useopen
set showtabline=2
set winwidth=79

" Turn folding off for real, hopefully
 set foldmethod=manual
 set nofoldenable
" Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
set nojoinspaces
" If a file is changed outside of vim, automatically reload it without asking
set autoread
set noswapfile


syntax on
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCMDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup vimrcEx
      " Clear all autocmds in the group
    autocmd!
    autocmd FileType text setlocal textwidth=78
    " Jump to last cursor position unless it's invalid or in an event handler
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
          \   exe "normal g`\"" |
          \ endif

        "for ruby, autoindent with two spaces, always expand tabs
    autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass,cucumber
    set ai sw=2 sts=2 et
    autocmd FileType python set sw=4 sts=4 et

    autocmd! BufRead,BufNewFile *.sass setfiletype sass 

    autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

    " Indent p tags
    " autocmd FileType html,eruby if g:html_indent_tags !~'\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd'| endif

    " Don't syntax highlight markdown because it's often wrong
    autocmd! FileType mkd setlocal syn=off

    " Leave the return key alone when in command line windows, since it's used
    " to run commands there.
    autocmd! CmdwinEnter * :unmap <cr>
    autocmd! CmdwinLeave * :call MapCR()

    " *.md is markdown
    autocmd! BufNewFile,BufRead *.md
    setlocal ft=

    " indent slim two spaces, not four
    autocmd! FileType *.slim set sw=2 sts=2 et
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set t_Co=256 " 256 colors
:set background=dark

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>


imap<c-c> <esc>
imap<c-l> <space>=><space>
:nnoremap <CR> :nohlsearch<cr>
map <leader>vm :vert new ~/.vimrc<cr>
map <leader>nw :vert new ./<cr>
map <leader>rf :w<cr>\|:!cucumber -p wip<cr>
map <leader>rd :!rake db:drop<cr>\|:!rake db:create<cr>\|:!rake db:migrate<cr>\|:!rake db:populate<cr>

map <leader>gv :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>gc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
map <leader>gm :CommandTFlush<cr>\|:CommandT app/models<cr>
map <leader>gh :CommandTFlush<cr>\|:CommandT app/helpers<cr>
map <leader>gl :CommandTFlush<cr>\|:CommandT lib<cr>
map <leader>gp :CommandTFlush<cr>\|:CommandT public<cr>
map <leader>gs :CommandTFlush<cr>\|:CommandT public/stylesheets<cr>
" Open files with <leader>f
map <leader>ff :CommandTFlush<cr>\|:CommandT ./<cr>

" Open files, limited to the directory of the current file, with <leader>gf
" This requires the %% mapping found below.
map <leader>gf :CommandTFlush<cr>\|:CommandT ./features/<cr>

cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>
function! ShowRoutes()
	" Requires 'scratch' plugin
	:topleft 100 :split __Routes__
	" Make sure Vim doesn't write __Routes__ as a file
	:set buftype=nofile
	" Delete everything
	:normal 1GdG
	"Put routes output in buffer
	:0r! rake -s routes
	" Size window to number of lines (1 plus rake
	" output length)
	:exec ":normal " . line("$") . _ "
	" Move cursor to bottom
	:normal 1GG
	" Delete empty trailing line
	:normal dd
 endfunction
map <leader>gR :call ShowRoutes()<cr>
function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo
    exec ":!bundle exec rspec " . a:filename
    endfunction
    
   function! SetTestFile()
    " Set the spec file that tests will be run for.
    	let t:grb_test_file=@%
    endfunction
    
    function! RunTestFile(...)
    if a:0
    	let command_suffix = a:1
    else
    	let command_suffix = ""
  endif

" Run the tests for the previously-marked file.
	let in_spec_file = match(expand("%"), '_spec.rb$') != -1
	if in_spec_file
		call SetTestFile()
	elseif !exists("t:grb_test_file")
		return
	end
call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
	let spec_line_number = line('.')
	call RunTestFile(":" . spec_line_number)
endfunction

" Run this file
map <leader>t :call RunTestFile()<cr>
" Run only the example under the cursor
map <leader>T :call RunNearestTest()<cr>
" Run all test files
map <leader>a :call RunTests('spec')<cr>
