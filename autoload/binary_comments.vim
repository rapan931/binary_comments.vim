if has('nvim')
  finish
endif

let g:binary_comments#vert = get(g:, 'binary_comments#vert', strdisplaywidth('│') == 1 ? '│' : '|')
let g:binary_comments#hori = get(g:, 'binary_comments#hori', strdisplaywidth('─') == 1 ? '─' : '-')
let g:binary_comments#draw_bottom = get(g:, 'binary_comments#draw_bottom', 1)
let g:binary_comments#draw_below = get(g:, 'binary_comments#draw_below', v:true)
let g:binary_comments#corner = get(g:, 'binary_comments#corner', #{
      \   topleft: strdisplaywidth('┌') == 1 ? '┌' : '+',
      \   bottom_left: strdisplaywidth('└') == 1 ? '└' : '+',
      \ })

function! s:sort_pos(pos1, pos2) abort
  if pos1[1] > pos2[1]
    return [pos2, pos1]
  end
  return [pos1, pos2]
endfunction

function! s:get_pos() abort
  let dot_pos = getcharpos(".")[1:2]
  let v_pos = getcharpos("v")[1:2]
  return sort_pos(dot_pos, v_pos)
endfunction

function! s:valid(start_pos, end_pos) abort
  let mode = mode()
  if mode !=# 'v' || mode !=# 'V'
    echohl ErrorMsg | echo 'flag_comments.nvim: support only visual mode!' | echohl none
    return v:false
  endif

  if pos1[0] != pos2[0]
    echohl ErrorMsg | echo 'flag_comments.nvim: not support multi line!' | echohl none
    return v:false
  endif

  let corner = binary_comments#corner
  if strdisplaywidth(corner.top_left) != 1 || strdisplaywidth(corner.bottom_left) != 1
    echohl ErrorMsg | echo 'flag_comments.nvim: not support multi line!' | echohl none
    return v:false
  endif

  return v:true
endfunction

function! s:binary_length(str, start_pos) abort
  let margin_len = strdisplaywidth(strcharpart(getline(start_pos[0]), 0, start_pos[1] - 1))

  if match(str, '^[01]*$') != -1
    let binary_len = len(str)
  elseif match(str, '^0b[01]+$') != -1
    let margin_len = margin_len + 2
    let binary_len = len(str) - 2
  else
    echohl ErrorMsg | echo 'flag_comments.nvim: not binary!' | echohl none
    return [v:null, v:null]
  endif

  return [binary_len, margin_len]
endfunction

function! s:get_corner() abort
  if g:binary_comments#draw_below
    return g:binary_comments#corner.bottom_left
  else
    return g:binary_comments#corner.top_left
  endif
endfunction

function! s:create_ruled_line(str, start_pos) abort
  let [binary_len, margin_len] = s:binary_length(str, start_pos)
  if binary_len == v:null || margin_len == v:null
    return [v:null, v:null]
  endif

  let header = repeat(' ', margin_len) ..  repeat(g:binary_comments#vert, binary_len)

  let corner = s:get_corner()
  let body = []
  for s:i in range(4)
    let body[i] = repeat(' ', margin_len) .. repeat(g:binary_comments#vert, binary_len) .. corner .. repeat(g:binary_comments#hori, i + 1) .. ' '
  endfor

  if g:binary_comments#draw_below == v:false
    let body = reverse(body)
  endif

  return [header, body]
endfunction

function! s:draw() abort
  let [start_pos, end_pos] = s:get_pos()

  if !s:valid(start_pos, end_pos)
    return
  endif

  let target = strcharpart(getline(start_pos[0]), start_pos[1] - 1, end_pos[1] - start_pos[1] + 1)
  let [header, body] = s:create_ruled_line(target, start_pos)

  if header == v:null || body == v:null
    return
  endif

  let line_nr = start_pos[0]
  if g:binary_comments#draw_below == v:true
    append(line_nr, header)
    append(line_nr, body)
  else
    append(line_nr, body)
    append(line_nr, header)
  endif

  return
endfunction

function! binary_comments#ddraw() abort
  s:draw()
  return "\<Esc>"
endfunction
