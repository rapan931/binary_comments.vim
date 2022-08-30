local api = vim.api
local fn = vim.fn
local blank = ' '

---@class BinaryCommentsCorner
---@field top_left string
---@field bottom_left string

---config
---Use a character with a display width of 2 for the ruled line.
---@class BinaryCommentsConfig
---@field corner BinaryCommentsCorner
---@field vert string
---@field hori string
---@field draw_bottom boolean draw_position
local config = {
  corner = {
    top_left = fn.strdisplaywidth('┌') == 1 and '┌' or '+',
    bottom_left = fn.strdisplaywidth('└') == 1 and '└' or '+',
  },
  vert = fn.strdisplaywidth('│') == 1 and '│' or '|',
  hori = fn.strdisplaywidth('─') == 1 and '─' or '-',
  draw_bottom = true,
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

---reverse list
---@param list table
---@return table reverse list
local function reverse(list)
  local ret = {}
  for i = #list, 1, -1 do
    ret[#list - i + 1] = list[i]
  end
  return ret
end

---Check
---@param pos1 table [line, col]
---@param pos2 table [line, col]
---@return boolean valid
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

  local corner = config.corner

  if fn.strdisplaywidth(corner.top_left) ~= 1 or fn.strdisplaywidth(corner.bottom_left) ~= 1 then
    api.nvim_echo({ { 'flag_comments.nvim: Only use a character with a display width of 1 for the ruled line!',
      'ErrorMsg' } }, true, {})
    return false
  end

  return true
end

local function get_corner()
  if config.draw_bottom then
    return config.corner.bottom_left
  else
    return config.corner.top_left
  end
end

---get binary length
---@param str string binary("0b1111" or "1111")
---@param start_pos string binary head position
---@return number | nil binary_length(if str is "0b1111", return 4)
---@return number | nil margin length(length of head of line to binary. if line is "      0b1111", return 8)
local function binary_length(str, start_pos)
  local margin_len = fn.strdisplaywidth(fn.strcharpart(fn.getline(start_pos[1]), 0, start_pos[2] - 1))

  local binary_len
  if str:match('^[01]*$') then
    binary_len = #str
  elseif (str:sub(1, 2) == '0b') and #str:sub(3) > 0 and str:sub(3):match('[01]') then
    margin_len = margin_len + 2
    binary_len = #str - 2
  else
    api.nvim_echo({ { 'flag_comments.nvim: not binary!', 'ErrorMsg' } }, true, {})
    api.nvim_feedkeys(api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
    return nil, nil
  end

  return binary_len, margin_len
end

---create ruled line
---@param str string binary("0b1111" or "1111")
---@param start_pos string binary head position
---@return string | nil header. if str "0b11111", return "│││││"
---@return string[] | nil rows list. if config.draw_bottom is false, reverse body in this function
local function create_ruled_line(str, start_pos)

  local binary_len, margin_len = binary_length(str, start_pos)
  if binary_len == nil or margin_len == nil then
    return nil, nil
  end

  local vert = config.vert
  local hori = config.hori
  local corner = get_corner()

  local header = blank:rep(margin_len) .. vert:rep(binary_len)
  local body = {}
  for i = 1, binary_len do
    local s = blank:rep(margin_len) .. vert:rep(binary_len - i) .. corner .. hori:rep(i) .. blank
    table.insert(body, s)
  end

  if config.draw_bottom == false then
    body = reverse(body)
  end

  return header, body
end

---@return string[] [line, col] start_pos
---@return string[] [line, col] end_pos
local function get_pos()
  local dot_pos = vim.list_slice(fn.getcharpos("."), 2, 3)
  local v_pos = vim.list_slice(fn.getcharpos("v"), 2, 3)
  return sort_pos(dot_pos, v_pos)
end

local M = {}

---@param override_config BinaryCommentsConfig
M.setup = function(override_config)
  config = vim.tbl_extend('force', config, override_config)
end

M.draw = function()

  local start_pos, end_pos = get_pos()

  if not valid(start_pos, end_pos) then
    return
  end

  local target = fn.strcharpart(fn.getline(start_pos[1]), start_pos[2] - 1, end_pos[2] - start_pos[2] + 1)
  local header, body = create_ruled_line(target, start_pos)

  if header == nil or body == nil then
    return
  end

  local line_nr = start_pos[1]

  if config.draw_bottom then
    api.nvim_buf_set_lines(0, line_nr, line_nr, false, { header })
    api.nvim_buf_set_lines(0, line_nr + 1, line_nr + 1, false, body)
  else
    api.nvim_buf_set_lines(0, line_nr - 1, line_nr - 1, false, body)
    api.nvim_buf_set_lines(0, line_nr - 1 + #body, line_nr - 1 + #body, false, { header })
  end

  api.nvim_feedkeys(api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
end

return M
