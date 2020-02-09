" fauxClip - Clipboard support without +clipboard
" Maintainer:  Jorengarenar <https://joren.ga>

if has("clipboard") || exists('g:loaded_fauxClip') || !exists('##CmdlineLeave')
  finish
endif

let s:cpo_save = &cpo | set cpo&vim

let s:is_pbcopy     = executable('pbcopy')
let s:is_clipExe    = executable('clip.exe')
let s:fall_to_xclip = !(s:is_pbcopy || s:is_clipExe)

if s:is_pbcopy
  let s:copy_alt  = "pbcopy"
  let s:paste_alt = "pbpaste"
elseif s:is_clipExe
  let s:copy_alt  = "clip.exe"
  let s:paste_alt = "paste.exe"
endif

if !exists('g:fauxClip_copy_cmd')
  let g:fauxClip_copy_cmd = s:fall_to_xclip ? 'xclip -f -i -selection clipboard' : s:copy_alt
endif

if !exists('g:fauxClip_paste_cmd')
  let g:fauxClip_paste_cmd = s:fall_to_xclip ? 'xclip -o -selection clipboard 2> /dev/null' : s:paste_alt
endif

if !exists('g:fauxClip_copy_primary_cmd')
  let g:fauxClip_copy_primary_cmd = s:fall_to_xclip ? 'xclip -f -i' : s:copy_alt
endif

if !exists('g:fauxClip_paste_primary_cmd')
  let g:fauxClip_paste_primary_cmd = s:fall_to_xclip ? 'xclip -o 2> /dev/null' : s:paste_alt
endif

augroup fauxClipCmdWrapper
  autocmd!
  autocmd CmdlineChanged : if getcmdline() =~# '\(y\%[ank]\|d\%[elete]\|pu\%[t]!\?\)\s*[+*]'
        \| let g:CR_old = maparg('<CR>', 'c', '', 1)
        \| cnoremap <expr> <silent> <CR> getcmdline() =~# '[dyp]\w*!\?\s*[+*]' ? '<C-u>'.fauxClip#CR().'<CR>' : '<CR>'
        \| elseif exists('g:CR_old') | call fauxClip#restore_CR() | endif
  autocmd CmdlineLeave : if exists('g:CR_old') | call fauxClip#restore_CR() | endif
augroup END

nnoremap <expr> "* fauxClip#start("*")
nnoremap <expr> "+ fauxClip#start("+")

vnoremap <expr> "* fauxClip#start("*")
vnoremap <expr> "+ fauxClip#start("+")

noremap! <C-r>+       <C-r>=fauxClip#paste("+")<CR>
noremap! <C-r><C-r>+  <C-r><C-r>=fauxClip#paste("+")<CR>
noremap! <C-r><C-o>+  <C-r><C-o>=fauxClip#paste("+")<CR>
inoremap <C-r><C-p>+  <C-r><C-p>=fauxClip#paste("+")<CR>

noremap! <C-r>*       <C-r>=fauxClip#paste("*")<CR>
noremap! <C-r><C-r>*  <C-r><C-r>=fauxClip#paste("*")<CR>
noremap! <C-r><C-o>*  <C-r><C-o>=fauxClip#paste("*")<CR>
inoremap <C-r><C-p>*  <C-r><C-p>=fauxClip#paste("*")<CR>

let g:loaded_fauxClip = 1

let &cpo = s:cpo_save | unlet s:cpo_save
