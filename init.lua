-- Some functions, key commands and modifications that change
-- [Textadept](http://code.google.com/p/textadept/)'s
-- default behaviour.
-- It contains modifications to Mitchell's Textadept modules, code from
-- Brian Schott and others who posted to the mailing list or the
-- [Textadept wiki](http://caladbolg.net/textadeptwiki/).
-- Otherwise it is written and maintained by
-- [Robert Gieseke](https://github.com/rgieseke).<br>
-- The source is on
-- [GitHub](https://github.com/rgieseke/ta-common),
-- released under the
-- [MIT license](http://www.opensource.org/licenses/mit-license.php).
--
-- ## Installation
-- Download a
-- [zipped](https://github.com/rgieseke/ta-common/zipball/master)
-- version and save the contained directory as `.textadept/modules/common`
-- or clone the git repository:
--     cd ~/.textadept/modules
--     git clone https://github.com/rgieseke/ta-common.git common
-- Put
--     require 'common'
-- in your `.textadept/init.lua`.<br>
-- The submodules can also be used independently:
--     require 'common.ack'

local keys = keys

local M = {}

M.ack = require 'common.ack'
M.bracematching = require 'common.bracematching'
require 'common.comments'
M.display_filename = require 'common.display_filename'
M.enclose = require 'common.enclose'
M.filename = require 'common.filename'
if not CURSES then require 'common.highlight' end
M.lastbuffer = require 'common.lastbuffer'
M.multiedit = require 'common.multiedit'
M.project = require 'common.project'
require 'common.save_strips_ws'
M.vc = require 'common.vc'


-- ## Key commands
local keys = keys

-- Snapopen.<br>
-- (Filtering out some folders and file extensions)<br>
-- Textadept home: `Alt/⌘`+`Shift`+`U`<br>
-- User home : `Alt/⌘`+`U`<br>
-- Current project `Alt/⌘`+`P`<br>
keys[OSX and 'mU' or 'aU'] = { io.snapopen, _HOME, { '.+%.luadoc',
              folders = { 'images', 'doc', 'manual', '%.hg', '%.git' } } }
keys[OSX and 'mu' or 'au'] = { io.snapopen, _USERHOME,
              { folders = { '%.hg', '%.git' } } }
keys[OSX and 'mp' or 'ap'] = function ()
  local root = _M.common.project.root()
  io.snapopen(root, { 'pyc$'})
end

-- Insert a filename: `Ctrl`+`Alt/⌘`+`Shift`+`O`
keys[OSX and 'cmO' or 'caO'] = M.filename.insert_filename

-- Save and reset Lua state: `F9`
keys['f9'] = { function()
  buffer:save()
  reset()
end }

-- Open command entry for ack/Lua search: `Ctrl`+`Alt/⌘`+`K`<br>
-- In the command entry, switch to Lua find in files, `Ctrl`+`L`,
-- or  ack search, `Ctrl`+`K`.
keys.cmk = M.ack.search_entry

-- Go to the matching brace: `Ctrl`+`M`
keys.cm = M.bracematching.match_brace

-- Add another cursor position: `Ctrl`+`Shift`+`M`<br>
-- Select all occurrences of a word: `Ctrl`+`Alt/⌘`+`Shift`+`M`
keys.cM = M.multiedit.add_position
keys[OSX and 'cmM' or 'caM'] = M.multiedit.select_all

-- Switch to last buffer: `Ctrl`+`2`
keys.c2 = M.lastbuffer.last_buffer

-- Switch buffer dialog:<br>
-- `Ctrl`+`B` or `⌘`+`B` (OS X)<br>
-- See [display_filename.lua](display_filename.html).
--keys[OSX and 'mb' or 'ab'] = M.display_filename.switch_buffer

-- Show hg status (or project folder) in snapopen dialog:<br>
-- `Ctrl`+`Alt/⌘`+`P`
keys[OSX and 'cmp' or 'cap'] = function()
  if buffer.filename then M.vc.hg_status( ) end
end

-- Enclose selection or insert chars: `'` , `"`, `(`, `[`, `{`
keys["'"] = { M.enclose.enclose_selection, "'", "'" }
keys['"'] = { M.enclose.enclose_selection, '"', '"' }
keys['('] = { M.enclose.enclose_selection, '(', ')' }
keys['['] = { M.enclose.enclose_selection, '[', ']' }
keys['{'] = { M.enclose.enclose_selection, '{', '}' }

-- Enclose selection and keep selection or insert single char
-- if nothing is selected: `Ctrl`+`Alt/⌘`+`'` or `"` or `(` or `[` or `{`
keys[OSX and "cm'" or "ca'"] = { M.enclose.paste_or_grow_enclose, "'", "'" }
keys[OSX and 'cm"' or 'ca"'] = { M.enclose.paste_or_grow_enclose, '"', '"' }
keys[OSX and 'cm(' or 'ca('] = { M.enclose.paste_or_grow_enclose, '(', ')' }
keys[OSX and 'cm[' or 'ca['] = { M.enclose.paste_or_grow_enclose, '[', ']' }
keys[OSX and 'cm{' or 'ca{'] = { M.enclose.paste_or_grow_enclose, '{', '}' }

return M
