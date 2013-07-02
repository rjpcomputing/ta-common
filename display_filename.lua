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
  gui.title = string.format('%s %s Textadept (%s)', filename:match('[^/\\]+$'),
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
  local columns, items = { _L['Name'], _L['File'] }, {}
  for _, buffer in ipairs(_BUFFERS) do
    local filename = buffer.filename or buffer._type or _L['Untitled']
    items[#items + 1] = (buffer.dirty and '*' or '')..filename:match('[^/\\]+$')
    items[#items + 1] = filename:gsub(pattern, replacement)
  end
  local width = CURSES and {'--width', gui.size[1] - 2} or {'--width', gui.size[1] - 100}
  local i = gui.filteredlist(_L['Switch Buffers'], columns, items, true, width)
  if i then view:goto_buffer(i + 1) end
end

function M.snapopen(utf8_paths, title, filter, exclude_FILTER, ...)
  local list = {}
  for utf8_path in utf8_paths:gmatch('[^\n]+') do
    lfs.dir_foreach(utf8_path, function(file)
      if #list >= io.SNAPOPEN_MAX then return false end
      list[#list + 1] = file:gsub('^%.[/\\]', '')		-- Remove the ./ prefix from files
                            :gsub(pattern, replacement)	-- Added path substitution
    end, filter, exclude_FILTER)
  end
  local width = CURSES and {'--width', gui.size[1] - 2} or {'--width', gui.size[1] - 100}
  local file = gui.filteredlist(title and title or _L['Open'], _L['File'], list, false,
                                '--select-multiple', width, ...) or ''
  file = file:gsub(replacement, pattern:gsub('^%^', ''))	-- Removed path substitution
  io.open_file(file)
end

-- Prompts the user to open a recently opened file.
function M.open_recent_file()
	local shortRecentFileList = {}
	for _, name in ipairs(io.recent_files) do
		shortRecentFileList[#shortRecentFileList + 1] = name:gsub(pattern, replacement)
	end
	local width = CURSES and {'--width', gui.size[1] - 2} or {'--width', gui.size[1] - 100}
	local i = gui.filteredlist('Open Recent', _L['File'], shortRecentFileList, true, width)
	if i then io.open_file(io.recent_files[i + 1]:gsub(replacement, pattern:gsub('%^', ''))) end
end

return M
