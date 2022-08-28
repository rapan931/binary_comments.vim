local api = vim.api
local fn = vim.fn

---config
---Use a character with a display width of 2 for the ruled line.
---@class BinaryCommentsConfig
---@field top_left_corner string
---@field top_light_corner string
---@field bottom_left_corner string
---@field bottom_light_corner string
---@field vert string
---@field hori string
local config = {
  top_left_corner = fn.strdisplaywidth('┌') and '┌' or '+',
  top_light_corner = fn.strdisplaywidth('┐') and '┐' or '+',
  bottom_left_corner = fn.strdisplaywidth('└') and '└' or '+',
  bottom_light_corner = fn.strdisplaywidth('┐') and '┐' or '+',
  vert = '|',
  hori = '-',
}

---Sort pos1 and pos2 (**line is same. compare col only**)
---@param pos1 string[] [line, col]
---@param pos2 string[] [line, col]
---@return string[] [line, col] start_pos
---@return string[] [line, col] end_pos
local function sort_pos(pos1, pos2)
  if pos1[2] > pos2[2] then
    return pos2, pos1
  end
  return pos1, pos2
end

local function valid(pos1, pos2)
  local mode = fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    api.nvim_echo({ { 'flag_comments.nvim: support only visual mode!', 'ErrorMsg' } }, true, {})
    return false
  end

  if pos1[0] ~= pos2[0] then
    api.nvim_echo({ { 'flag_comments.nvim: not support multi line!', 'ErrorMsg' } }, true, {})
    return false
  end

  return true
end

local M = {}

---@param override bistahieversorConfig
M.setup = function(override)
  config = vim.tbl_extend('force', config, override)
end

M.draw = function()

  local dot_pos = vim.list_slice(fn.getcharpos("."), 2, 3)
  local v_pos = vim.list_slice(fn.getcharpos("v"), 2, 3)

  if not valid(dot_pos, v_pos) then
    return
  end

  local start_pos, end_pos = sort_pos(dot_pos, v_pos)
  local str = fn.strcharpart(fn.getline(start_pos[1]), start_pos[2] - 1, end_pos[2] - start_pos[2] + 1)
  local margin_length = fn.strdisplaywidth(fn.strcharpart(fn.getline(start_pos[1]), 0, start_pos[2] - 1))

  local line_nr = start_pos[1]

  local binary_len
  if str:match('^[01]*$') then
    binary_len = #str
  elseif (str:sub(1, 2) == '0b') and #str:sub(3) > 0 and str:sub(3):match('[01]') then
    margin_length = margin_length + 2
    binary_len = #str - 2
  else
    api.nvim_echo({ { 'flag_comments.nvim: not binary!', 'ErrorMsg' } }, true, {})
    api.nvim_feedkeys(api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
    return
  end

  local blank = ' '
  local blanks = blank:rep(margin_length)

  local vert = config.vert
  local hori = config.hori
  local corner = config.bottom_left_corner

  local header = blanks .. vert:rep(binary_len)
  api.nvim_buf_set_lines(0, line_nr, line_nr, false, { header })

  for i = 1, binary_len do
    local s = blank:rep(margin_length) .. vert:rep(binary_len - i) .. corner .. hori:rep(i) .. blank
    api.nvim_buf_set_lines(0, line_nr + i, line_nr + i, false, { s })
  end

  api.nvim_feedkeys(api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
end

return M
