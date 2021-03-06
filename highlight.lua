-- Highlight the active buffer/view.

local line_number_back = buffer.style_back[_SCINTILLA.constants.STYLE_LINENUMBER]
local current_line_back = buffer.caret_line_back

local function active()
  local buffer = buffer
  buffer.style_back[33] = current_line_back
  buffer:set_fold_margin_colour(1, current_line_back)
  buffer:set_fold_margin_hi_colour(1, current_line_back)
end

local function inactive()
  local buffer = buffer
  buffer.style_back[33] = line_number_back
  buffer:set_fold_margin_colour(true, line_number_back)
  buffer:set_fold_margin_hi_colour(true, line_number_back)
end

events.connect(events.VIEW_BEFORE_SWITCH, function() inactive() end)
events.connect(events.VIEW_AFTER_SWITCH, function() active() end)
events.connect(events.BUFFER_AFTER_SWITCH, function() active() end)
events.connect(events.BUFFER_NEW, function() active() end)
events.connect(events.FILE_OPENED, function() active() end)
events.connect(events.RESET_AFTER, function() active() end)

events.connect(events.BUFFER_AFTER_SWITCH, function()
  local buffer = buffer
  if buffer._textredux then
    buffer.style_fore[33] = current_line_back
    buffer:set_fold_margin_colour(1, line_number_back)
    buffer:set_fold_margin_hi_colour(1, line_number_back)
  end
end)
