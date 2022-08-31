if !has('vim9script')
  if has('nvim') || exists('g:loaded_binary_comments')
    finish
  endif
  let g:loaded_binary_comments = 1
  xnoremap <Plug>(binary-comments-draw) <Cmd>call binary_comments#draw()<CR>

  finish
endif

vim9script

import autoload 'binary_comments.vim'
" xnoremap <Plug>(binary-comments-draw) <Cmd>call binary_comments.BinaryCommentsDraw()<CR> not work
xnoremap <Plug>(binary-comments-draw) <Cmd>call binary_comments#BinaryCommentsDraw()<CR>
