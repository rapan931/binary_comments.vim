if !has('vim9script')
  if has('nvim')
    finish
  endif

  let g:binary_comments#vert = get(g:, 'binary_comments#vert', strdisplaywidth('│') == 1 ? '│' : '|')
  let g:binary_comments#hori = get(g:, 'binary_comments#hori', strdisplaywidth('─') == 1 ? '─' : '-')
  let g:binary_comments#draw_bottom = get(g:, 'binary_comments#draw_bottom', 1)
  let g:binary_comments#draw_below = get(g:, 'binary_comments#draw_below', v:true)
  let g:binary_comments#corner = get(g:, 'binary_comments#corner', #{
        \   top_left: strdisplaywidth('┌') == 1 ? '┌' : '+',
        \   bottom_left: strdisplaywidth('└') == 1 ? '└' : '+',
        \ })

  function! s:sort_pos(pos1, pos2) abort
    if a:pos1[0] == a:pos2[0]
      if a:pos1[1] > a:pos2[1]
        return [a:pos2, a:pos1]
      endif
      return [a:pos1, a:pos2]
    else
      if a:pos1[0] > a:pos2[0]
        return [a:pos2, a:pos1]
      endif
      return [a:pos1, a:pos2]
    endif
  endfunction

  function! s:get_pos(mode) abort
    let dot_pos = getcharpos('.')[1:2]
    let v_pos = getcharpos('v')[1:2]
    let [start_pos, end_pos] = s:sort_pos(dot_pos, v_pos)

    if a:mode ==# 'V'
      let start_pos[1] = 1
      let end_pos[1] = strchars(getline(end_pos[0]))
    endif

    return [start_pos, end_pos]
  endfunction

  function! s:valid(start_pos, end_pos, mode) abort
    if a:mode !=# 'v' && a:mode !=# 'V'
      echohl ErrorMsg | echo 'flag_comments.nvim: support only visual mode!' | echohl none
      return v:false
    endif

    if a:start_pos[0] != a:end_pos[0]
      echohl ErrorMsg | echo 'flag_comments.nvim: not support multi line!' | echohl none
      return v:false
    endif

    let corner = g:binary_comments#corner
    if strdisplaywidth(corner.top_left) != 1 || strdisplaywidth(corner.bottom_left) != 1
      echohl ErrorMsg | echo 'flag_comments.nvim: Only use a character with a display width of 1 for the ruled line!' | echohl none
      return v:false
    endif

    return v:true
  endfunction

  function! s:get_binary_length(str, start_pos) abort
    let margin_len = strdisplaywidth(strcharpart(getline(a:start_pos[0]), 0, a:start_pos[1] - 1))

    if match(a:str, '^[01]*$') != -1
      let binary_len = len(a:str)
    elseif match(a:str, '^0b[01]\+$') != -1
      let margin_len = margin_len + 2
      let binary_len = len(a:str) - 2
    else
      echohl ErrorMsg | echo $"flag_comments.nvim: not binary! [{a:str}]" | echohl none
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
    let [binary_len, margin_len] = s:get_binary_length(a:str, a:start_pos)
    if binary_len == v:null || margin_len == v:null
      return [v:null, v:null]
    endif

    let header = repeat(' ', margin_len) ..  repeat(g:binary_comments#vert, binary_len)

    let corner = s:get_corner()
    let body = []
    for s:i in range(binary_len)
      let body += [repeat(' ', margin_len) .. repeat(g:binary_comments#vert, binary_len - s:i - 1) .. corner .. repeat(g:binary_comments#hori, s:i + 1) .. ' ']
    endfor

    if g:binary_comments#draw_below == v:false
      let body = reverse(body)
    endif

    return [header, body]
  endfunction

  function! s:draw() abort
    let mode = mode()
    let [start_pos, end_pos] = s:get_pos(mode)

    if !s:valid(start_pos, end_pos, mode)
      return
    endif

    let target = strcharpart(getline(start_pos[0]), start_pos[1] - 1, end_pos[1] - start_pos[1] + 1)
    let [header, body] = s:create_ruled_line(target, start_pos)

    if header == v:null || body == v:null
      return
    endif

    let line_nr = start_pos[0]
    if g:binary_comments#draw_below == v:true
      call append(line_nr, header)
      call append(line_nr + 1, body)
    else
      call append(line_nr - 1, body)
      call append(line_nr, header)
    endif

    return
  endfunction

  function! binary_comments#draw() abort
    call s:draw()
    call feedkeys("\<Esc>")
  endfunction

  finish
endif

vim9script

g:binary_comments#vert = get(g:, 'binary_comments#vert', strdisplaywidth('│') == 1 ? '│' : '|')
g:binary_comments#hori = get(g:, 'binary_comments#hori', strdisplaywidth('─') == 1 ? '─' : '-')
g:binary_comments#draw_bottom = get(g:, 'binary_comments#draw_bottom', 1)
g:binary_comments#draw_below = get(g:, 'binary_comments#draw_below', true)
g:binary_comments#corner = get(g:, 'binary_comments#corner', {
  \   top_left: strdisplaywidth('┌') == 1 ? '┌' : '+',
  \   bottom_left: strdisplaywidth('└') == 1 ? '└' : '+',
  \ })


def SortPos(pos1: list<number>, pos2: list<number>): list<list<number>>
  if pos1[0] == pos2[0]
    if pos1[1] > pos2[1]
      return [pos2, pos1]
    endif
    return [pos1, pos2]
  else
    if pos1[0] > pos2[0]
      return [pos2, pos1]
    endif
    return [pos1, pos2]
  endif
enddef
  
def GetPos(mode: string): list<list<number>>
  var dot_pos = getcharpos('.')[1 : 2]
  var v_pos = getcharpos('v')[1 : 2]
  var [start_pos, end_pos] = SortPos(dot_pos, v_pos)

  if mode == 'V'
    start_pos[1] = 1
    end_pos[1] = strchars(getline(end_pos[0]))
  endif

  return [start_pos, end_pos]
enddef

def Valid(start_pos: list<number>, end_pos: list<number>, mode: string): bool
  if mode != 'v' && mode != 'V'
    echohl ErrorMsg | echo 'flag_comments.nvim: support only visual mode!' | echohl none
    return false
  endif

  if start_pos[0] != end_pos[0]
    echohl ErrorMsg | echo 'flag_comments.nvim: not support multi line!' | echohl none
    return false
  endif

  var corner = g:binary_comments#corner
  if strdisplaywidth(corner.top_left) != 1 || strdisplaywidth(corner.bottom_left) != 1
    echohl ErrorMsg | echo 'flag_comments.nvim: Only use a character with a display width of 1 for the ruled line!' | echohl none
    return false
  endif

  return true
enddef

def GetBinaryLength(str: string, start_pos: list<number>): list<any>
  var margin_len = strdisplaywidth(strcharpart(getline(start_pos[0]), 0, start_pos[1] - 1))
  var binary_len: number

  if match(str, '^[01]*$') != -1
    binary_len = len(str)
  elseif match(str, '^0b[01]\+$') != -1
    margin_len = margin_len + 2
    binary_len = len(str) - 2
  else
    echohl ErrorMsg | echo $"flag_comments.nvim: not binary! [{str}]" | echohl none
    return [null, null]
  endif

  return [binary_len, margin_len]
enddef

def GetCorner(): string
  if g:binary_comments#draw_below
    return g:binary_comments#corner.bottom_left
  else
    return g:binary_comments#corner.top_left
  endif
enddef

def CreateRuledLine(str: string, start_pos: list<number>): list<any>
  var [binary_len, margin_len] = GetBinaryLength(str, start_pos)
  if binary_len == null || margin_len == null
    return [null, null]
  endif

  var header = repeat(' ', margin_len) ..  repeat(g:binary_comments#vert, binary_len)

  var corner = GetCorner()
  var body = []

  for i in range(binary_len)
    body += [repeat(' ', margin_len) .. repeat(g:binary_comments#vert, binary_len - i - 1) .. corner .. repeat(g:binary_comments#hori, i + 1) .. ' ']
  endfor

  if g:binary_comments#draw_below == false
    body = reverse(body)
  endif

  return [header, body]
enddef

def Draw(): void
  var mode = mode()
  var [start_pos, end_pos] = GetPos(mode)

  if !Valid(start_pos, end_pos, mode)
    return
  endif

  var target = strcharpart(getline(start_pos[0]), start_pos[1] - 1, end_pos[1] - start_pos[1] + 1)
  var [header, body] = CreateRuledLine(target, start_pos)

  if header == null || body == null
    return
  endif

  var line_nr = start_pos[0]
  if g:binary_comments#draw_below == true
    call append(line_nr, header)
    call append(line_nr + 1, body)
  else
    call append(line_nr - 1, body)
    call append(line_nr, header)
  endif

  return
enddef

export def BinaryCommentsDraw(): void
  Draw()
  feedkeys("\<Esc>")
enddef
