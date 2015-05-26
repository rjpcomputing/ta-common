-- Shorten display filenames in buffer title and switch buffer dialog.
-- On Windows
--     C:\Documents and Settings\username\Desktop\...
-- is replaced with
--     Desktop\...,
-- on Max OS X and Linux
--     /home/username/..
-- or
--     /Users/username/...
-- with
--     ~/...
--
-- Modified from Textadept's
-- [core.gui](http://code.google.com/p/textadept/source/browse/core/gui.lua) and
-- [snapopen](http://code.google.com/p/textadept/source/browse/modules/textadept/snapopen.lua)
-- module.
local M = {}

-- ## Fields

local pattern, replacement

-- Read environment variable.
if WIN32 then
  pattern = os.getenv('USERPROFILE')..'\\'
  replacement = ''
else
  pattern = '^'..os.getenv('HOME')
  replacement = '~'
end

-- ## Commands

-- Sets the title of the Textadept window to the buffer's filename.
-- Parameter:<br>
-- _buffer_: The currently focused buffer.
local function set_title(buffer)
  local buffer = buffer
  local filename = buffer.filename or buffer._type or _L['Untitled']
  local dirty = buffer.dirty and '*' or '-'
  ui.title = string.format('%s %s Textadept (%s)', filename:match('[^/\\]+$'),
                            dirty, filename:gsub(pattern, replacement))
end

-- Connect to events that change the title.
events.connect('save_point_reached',
  function() -- changes Textadept title to show 'clean' buffer
    buffer.dirty = false
    set_title(buffer)
  end)

events.connect('save_point_left',
  function() -- changes Textadept title to show 'dirty' buffer
    buffer.dirty = true
    set_title(buffer)
  end)

events.connect('buffer_after_switch',
  function() -- updates titlebar and statusbar
    set_title(buffer)
    events.emit('update_ui')
  end)

events.connect('view_after_switch',
  function() -- updates titlebar and statusbar
    set_title(buffer)
    events.emit('update_ui')
  end)

-- Displays a dialog with a list of buffers to switch to and switches to the
-- selected one, if any.
function M.switch_buffer()
  local columns, items = {_L['Name'], _L['File']}, {}
  for _, buffer in ipairs(_BUFFERS) do
    local filename = buffer.filename or buffer._type or _L['Untitled']
    filename = filename:iconv('UTF-8', _CHARSET)
    local basename = buffer.filename and filename:match('[^/\\]+$') or filename
    items[#items + 1] = (buffer.dirty and '*' or '')..basename
    items[#items + 1] = filename:gsub(pattern, replacement)
  end
  local button, i = ui.dialogs.filteredlist{
    title = _L['Switch Buffers'], columns = columns, items = items,
    width = CURSES and ui.size[1] - 2 or ui.size[1] - 100
  }
  if button == 1 and i then view:goto_buffer(i) end
end

function M.snapopen(paths, filter, exclude_FILTER, opts)
  if buffer._type or nil == buffer.filename then return end
  if not paths then paths = io.get_project_root() or buffer.filename:match('^(.+)[/\\]') end
  if type(paths) == 'string' then
    if not filter then
      filter = io.snapopen_filters[paths]
      if filter and exclude_FILTER == nil then
        exclude_FILTER = filter ~= lfs.FILTER
      end
    end
    paths = {paths}
  end
  local utf8_list = {}
  for i = 1, #paths do
    lfs.dir_foreach(paths[i], function(file)
      if #utf8_list >= io.SNAPOPEN_MAX then return false end
      file = file:gsub('^%.[/\\]', ''):gsub(pattern, replacement):iconv('UTF-8', _CHARSET)
      utf8_list[#utf8_list + 1] = file
    end, filter, exclude_FILTER)
  end
  if #utf8_list >= io.SNAPOPEN_MAX then
    local msg = string.format('%d %s %d', io.SNAPOPEN_MAX,
                              _L['files or more were found. Showing the first'],
                              io.SNAPOPEN_MAX)
    ui.dialogs.msgbox{
      title = _L['File Limit Exceeded'], text = msg, icon = 'gtk-dialog-info'
    }
  end
  local options = {
    title = _L['Open'], columns = _L['File'], items = utf8_list,
    button1 = _L['_OK'], button2 = _L['_Cancel'], select_multiple = true,
    string_output = true, width = CURSES and ui.size[1] - 2 or ui.size[1] - 100
  }
  if opts then for k, v in pairs(opts) do options[k] = v end end
  local button, files = ui.dialogs.filteredlist(options)
  if button ~= _L['_OK'] or not files then return end
  for i = 1, #files do files[i] = files[i]:gsub(replacement, pattern:gsub('^%^', '')):iconv(_CHARSET, 'UTF-8') end
  io.open_file(files)
end

--function M.snapopen(paths, filter, exclude_FILTER, opts)
--  --if type(paths) == 'string' then paths = {paths} end
--  local paths = paths or io.get_project_root()
--  if not paths then paths = buffer.filename:match('^(.+)[/\\]') end
--  if type(paths) == 'string' then
--    if not filter then
--      filter = io.snapopen_filters[paths]
--      if filter and type(exclude_FILTER) == "nil" then
--        exclude_FILTER = filter ~= lfs.FILTER
--      end
--    end
--    paths = {paths}
--  end
--  local utf8_list = {}
--  for i = 1, #paths do
--    lfs.dir_foreach(paths[i], function(file)
--      if #utf8_list >= io.SNAPOPEN_MAX then return false end
--      file = file:gsub('^%.[/\\]', ''):gsub(pattern, replacement):iconv('UTF-8', _CHARSET)
--      utf8_list[#utf8_list + 1] = file
--    end, filter, exclude_FILTER)
--  end
--  if #utf8_list >= io.SNAPOPEN_MAX then
--    local msg = string.format('%d %s %d', io.SNAPOPEN_MAX,
--                              _L['files or more were found. Showing the first'],
--                              io.SNAPOPEN_MAX)
--    ui.dialogs.msgbox{
--      title = _L['File Limit Exceeded'], text = msg, icon = 'gtk-dialog-info'
--    }
--  end
--  local options = {
--    title = _L['Open'], columns = _L['File'], items = utf8_list,
--    button1 = _L['_OK'], button2 = _L['_Cancel'], select_multiple = true,
--    string_output = true, width = CURSES and ui.size[1] - 2 or ui.size[1] - 100
--  }
--  if opts then for k, v in pairs(opts) do options[k] = v end end
--  local button, files = ui.dialogs.filteredlist(options)
--  if button ~= _L['_OK'] or not files then return end
--  for i = 1, #files do files[i] = files[i]:gsub(replacement, pattern:gsub('^%^', '')):iconv(_CHARSET, 'UTF-8') end
--  io.open_file(files)
--end

function M.open_recent_file()
  local utf8_filenames = {}
  for _, filename in ipairs(io.recent_files) do
    utf8_filenames[#utf8_filenames + 1] = filename:gsub(pattern, replacement):iconv('UTF-8', _CHARSET)
  end
  local button, i = ui.dialogs.filteredlist{
    title = 'Open Recent', columns = _L['File'], items = utf8_filenames,
    width = CURSES and ui.size[1] - 2 or ui.size[1] - 100
  }
  if button == 1 and i then io.open_file(io.recent_files[i]:gsub(replacement, pattern:gsub('%^', ''))) end
end

return M
