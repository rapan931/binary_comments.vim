if has('nvim') || exists('g:loaded_binary_comments')
  finish
endif
let g:loaded_binary_comments = 1

xnoremap <expr> <Plug>(binary-comments-draw) <Cmd>call binary_comments#draw()<CR><Esc>
