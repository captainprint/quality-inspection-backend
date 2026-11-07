--app window configuration, https://www.love2d.org/wiki/Config_Files
function love.conf(t)
	t.window.version = "12.0" --version of love2d this was made for
	t.window.console = true
	t.window.width = 1600
	t.window.height = 900
	t.window.title = "QC software"
	t.window.resizable = true
	t.window.minwidth = 768
	t.window.minheight = t.window.minwidth * (t.window.height / t.window.width)
	t.window.vsync = 1
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.borderless = false
	--[[t.window.x = 0
	t.window.y = 0]]
end