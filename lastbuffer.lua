-- Toggle between two buffers with a key shortcut.
local M = {}

-- ## Commands

-- Save the buffer index before switching.
events.connect(events.BUFFER_BEFORE_SWITCH, function()
	view.common_last_buffer = _G.buffer
end)

-- Switch to last buffer.
function M.last_buffer()
	if view.common_last_buffer then
		bufnum = _BUFFERS[view.common_last_buffer]
		if bufnum then
			view:goto_buffer(view.common_last_buffer)
		end
	end
end

return M
