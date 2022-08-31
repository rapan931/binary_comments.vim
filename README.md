# binary_comments.vim
Add comments to the binary

## Install

[vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'rapan931/binary_comments.vim'
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)  
[vim-jetpack](https://github.com/tani/vim-jetpack)
```lua
use 'rapan931/binary_comments.vim'
```

## Demo

![binary_comments](https://user-images.githubusercontent.com/24415677/187362359-887c6fea-1802-4d46-a815-3075a4413d7d.gif)

## Usage

neovim
```lua
vim.keymap.set('x', 'ge', require('binary_comments').draw)
```

vim
```vim
xnoremap ge <Plug>(binary-comments-draw)
```

## Setup

neovim
```lua
-- This sample is default value. 
-- If you do not need to change the set values, there is no need to call setup
require('binary_comments').setup({
  corner = {
    top_left = fn.strdisplaywidth('┌') == 1 and '┌' or '+',
    bottom_left = fn.strdisplaywidth('└') == 1 and '└' or '+',
  },
  vert = fn.strdisplaywidth('│') == 1 and '│' or '|',
  hori = fn.strdisplaywidth('─') == 1 and '─' or '-',
  draw_below = true,  -- draw position, if false, ruled lines on top of binary
})
```

vim
```vim
" This sample is default value.
" If you do not need to change the set values, there is no need to call setup
let g:binary_comments#vert = get(g:, 'binary_comments#vert', strdisplaywidth('│') == 1 ? '│' : '|')
let g:binary_comments#hori = get(g:, 'binary_comments#hori', strdisplaywidth('─') == 1 ? '─' : '-')
let g:binary_comments#draw_bottom = get(g:, 'binary_comments#draw_bottom', 1)
let g:binary_comments#draw_below = get(g:, 'binary_comments#draw_below', v:true)
let g:binary_comments#corner = get(g:, 'binary_comments#corner', #{
      \   top_left: strdisplaywidth('┌') == 1 ? '┌' : '+',
      \   bottom_left: strdisplaywidth('└') == 1 ? '└' : '+',
      \ })
```