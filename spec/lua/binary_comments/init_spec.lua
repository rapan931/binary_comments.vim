local plugin_name = 'binary_comments'
local helper = require('vusted.helper')
helper.root = helper.find_plugin_root(plugin_name)
local binary_comments = helper.require('binary_comments')

local vassert = require('vusted.assert')
local asserts = vassert.asserts

local api = vim.api

function helper.setup()
  vim.keymap.set('x', 'ge', function() binary_comments.draw() end)
end

function helper.after_each()
  helper.cleanup({ keymap = { enabled = false }})
  helper.cleanup_loaded_modules(plugin_name)
end

asserts.create('all_lines'):register_same(function()
  return api.nvim_buf_get_lines(0, 0, -1, false)
end)

describe('binary_comments.draw()', function()
  setup(helper.setup)
  before_each(helper.before_each)
  after_each(helper.after_each)
  describe('[0b111]', function()
    describe('only binary', function()

      local str = '0b111'

      it('output below', function()
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggviWge')

        -- vim.pretty_print(fn.getbufline())
        -- assert.cursor_line('0b111')
        assert.all_lines({
          str,
          '  │││',
          '  ││└─ ',
          '  │└── ',
          '  └─── ',
          ''
        })
      end)

      it('output above', function()
        binary_comments.setup({
          draw_below = false
        })
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggviWge')

        -- vim.pretty_print(fn.getbufline())
        -- assert.cursor_line('0b111')
        assert.all_lines({
          '  ┌─── ',
          '  │┌── ',
          '  ││┌─ ',
          '  │││',
          str,
          ''
        })
      end)
    end)

    describe('whitespace at the beginning of the ruled line', function()
      before_each(helper.before_each)

      local str = '	  0b111'

      it('output below', function()
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal gg5lviWge')

        -- vim.pretty_print(fn.getbufline())
        -- assert.cursor_line('0b111')
        assert.all_lines({
          str,
          '            │││',
          '            ││└─ ',
          '            │└── ',
          '            └─── ',
          ''
        })
      end)

      it('output above', function()
        binary_comments.setup({
          draw_below = false
        })
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal gg5lviWge')

        -- vim.pretty_print(fn.getbufline())
        -- assert.cursor_line('0b111')
        assert.all_lines({
          '            ┌─── ',
          '            │┌── ',
          '            ││┌─ ',
          '            │││',
          str,
          ''
        })
      end)
    end)
    describe('multibyte char at the beginning of the ruled line', function()
      before_each(helper.before_each)

      local str = 'abcあいうdef 0b111'

      it('output below', function()
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggf0viWge')

        -- vim.pretty_print(fn.getbufline())
        -- assert.cursor_line('0b111')
        assert.all_lines({
          str,
          '               │││',
          '               ││└─ ',
          '               │└── ',
          '               └─── ',
          ''
        })
      end)

      it('output above', function()
        binary_comments.setup({
          draw_below = false
        })
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggf0viWge')

        -- vim.pretty_print(fn.getbufline())
        -- assert.cursor_line('0b111')
        assert.all_lines({
          '               ┌─── ',
          '               │┌── ',
          '               ││┌─ ',
          '               │││',
          str,
          ''
        })
      end)
    end)
  end)

  describe('[111]', function()
    describe('only binary', function()
      before_each(helper.before_each)

      local str = '111'

      it('output below', function()
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggviWge')

        assert.all_lines({
          str,
          '│││',
          '││└─ ',
          '│└── ',
          '└─── ',
          ''
        })
      end)

      it('output above', function()
        binary_comments.setup({
          draw_below = false
        })
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggviWge')

        assert.all_lines({
          '┌─── ',
          '│┌── ',
          '││┌─ ',
          '│││',
          str,
          ''
        })
      end)
    end)

    describe('whitespace at the beginning of the ruled line', function()
      before_each(helper.before_each)

      local str = '	  111'

      it('output below', function()
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal gg5lviWge')

        assert.all_lines({
          str,
          '          │││',
          '          ││└─ ',
          '          │└── ',
          '          └─── ',
          ''
        })
      end)

      it('output above', function()
        binary_comments.setup({
          draw_below = false
        })
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal gg5lviWge')

        assert.all_lines({
          '          ┌─── ',
          '          │┌── ',
          '          ││┌─ ',
          '          │││',
          str,
          ''
        })
      end)
    end)
    describe('multibyte char at the beginning of the ruled line', function()
      before_each(helper.before_each)

      local str = 'abcあいうdef 111'

      it('output below', function()
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggf1viWge')

        assert.all_lines({
          str,
          '             │││',
          '             ││└─ ',
          '             │└── ',
          '             └─── ',
          ''
        })
      end)

      it('output above', function()
        binary_comments.setup({
          draw_below = false
        })
        api.nvim_buf_set_lines(0, 0, 0, false, { str })
        vim.cmd('normal ggf1viWge')

        assert.all_lines({
          '             ┌─── ',
          '             │┌── ',
          '             ││┌─ ',
          '             │││',
          str,
          ''
        })
      end)
    end)
  end)
end)
