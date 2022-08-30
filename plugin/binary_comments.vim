if has('nvim') || exists('g:loaded_binary_comments')
  finish
endif
let g:loaded_binary_comments = 1

xnoremap <Plug>(binary-comments-draw) <Cmd>call binary_comments#draw()<CR>
