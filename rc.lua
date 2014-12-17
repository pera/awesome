-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- User libraries
vicious = require("vicious")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local wibox = require("wibox")

local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell
local scount = screen.count()


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/zenburn.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = "gvim"
editor_cmd = editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "www" , "dev", "term", "chat", "mail", "free" }, s, {layouts[5], layouts[2], layouts[4], layouts[1], layouts[5], layouts[1]})
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "xcompmgr", "xcompmgr -C -c" },
   { "compton", "compton -C -c" },
   { "ifs", "xwinwrap -b -fs -sp -fs -nf -ov  -- /usr/lib/xscreensaver/ifs -visual GL -recurse -iterate -delay 40000 -root -window-id WID" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

editorsmenu = {
	{ "Gummi", "gummi" },
	{ "LyX", "lyx" },
	{ "Gaphor", "graphor" }
}

gamesmenu = {
	{ "GNU Go", "gogui" },
	{ "Nethack", "nethack" },
	{ "Angband", "angband" },
	{ "MAngband", "mangclient --width 800 --height 600" },
	{ "Crawl", "xterm crawl" },
	{ "ADOM", "xterm adom" },
	{ "Slash'EM", "xterm slashem" },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon }, { "editors", editorsmenu, beautiful.awesome_icon }, { "games", gamesmenu, beautiful.awesome_icon }, { "open terminal", terminal }, { "chromium", "chromium --enable-webgl --user-data-dir"}, { "lock screen", "xlock -mode demon -neighbors 8" }, { "suspend", "pm-suspend" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- ====================================
-- BEGIN OF AWESOMPD WIDGET DECLARATION
-- ====================================

local awesompd = require('awesompd/awesompd')

musicicon = wibox.widget.imagebox()
musicicon:set_image(beautiful.widget_music)
musicwidget = awesompd:create() -- Create awesompd widget
musicwidget.font = "nu 8" -- Set widget font
--musicwidget.font_color = "#FFFFFF" --Set widget font color
--musicwidget.background = "#000000" --Set widget background color
musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
--musicwidget.output_size = 20 -- Set the size of widget in symbols
musicwidget.update_interval = 10 -- Set the update interval in seconds

-- Set the folder where icons are located (change username to your login name)
musicwidget.path_to_icons = "/root/.config/awesome/icons"

-- If true, song notifications for Jamendo tracks and local tracks
-- will also contain album cover image.
musicwidget.show_album_cover = true

-- terrible hack
musicwidget.show_status = false

-- Specify how big in pixels should an album cover be. Maximum value
-- is 100.
musicwidget.album_cover_size = 50

-- This option is necessary if you want the album covers to be shown
-- for your local tracks.
musicwidget.mpd_config = "/etc/mpd.conf"

-- Specify decorators on the left and the right side of the
-- widget. Or just leave empty strings if you decorate the widget
-- from outside.
musicwidget.ldecorator = ""
musicwidget.rdecorator = ""

-- Set all the servers to work with (here can be any servers you use)
musicwidget.servers = {
	{ server = "localhost",
	port = 6600 }
}

-- Set the buttons of the widget. Keyboard keys are working in the
-- entire Awesome environment. Also look at the line 352.
musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_playpause() },
{ "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
{ "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
{ "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
{ "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
{ "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
--{ "", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
--{ "", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
{ modkey, "Pause", musicwidget:command_playpause() } })

musicwidget:run() -- After all configuration is done, run the widget

-- ==================================
-- END OF AWESOMPD WIDGET DECLARATION
-- ==================================

-- {{{ Wibox

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
--space = widget({ type = "textbox" })
local space = wibox.widget.base.make_widget()
space.fit = function() return 4,0 end
space.draw = function() end
--separator = widget({ type = "imagebox" })
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)
-- }}}

-- {{{ CPU usage and temperature
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
-- Initialize widgets
cpuwidget = wibox.widget.textbox()
cpufreqwidget = wibox.widget.textbox()
tzswidget = wibox.widget.textbox()
-- Register widgets
vicious.register(cpuwidget,  vicious.widgets.cpu, "$1%", 7)
vicious.register(cpufreqwidget,  vicious.widgets.cpufreq, "$1MHz", 23, "cpu0")
vicious.register(tzswidget, vicious.widgets.thermal, "$1C", 19, "thermal_zone0")
-- }}}

-- {{{ Battery state
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
-- Initialize widget
batwidget = wibox.widget.textbox()
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, function (widget, args)
													if args[2] < 10 then
														return "<span color='red'>" .. args[1] .. args[2] .. "%</span>"
													else
														return args[1] .. args[2] .. "%"
													end
												 end , 11, "BAT1")
-- }}}

-- {{{ Memory usage
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
-- Initialize widget
memwidget = wibox.widget.textbox()
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1%", 13)
-- }}}

-- {{{ Wireless
wlanicon = wibox.widget.imagebox()
wlanicon:set_image(beautiful.widget_wifi)
-- Initialize widgets
wlanwidget = wibox.widget.textbox()
-- Enable caching
vicious.cache(vicious.widgets.wifi)
-- Register widgets
vicious.register(wlanwidget, vicious.widgets.wifi, "${ssid} ${sign} dBm", 17, "wlan0")
-- Register buttons
wlanwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("xterm -e wicd-curses") end)
)) -- Register assigned buttons
-- }}}

-- {{{ Volume level
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
-- Initialize widgets
volwidget = wibox.widget.textbox()
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "PCM")
-- Register buttons
volwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("xterm -e alsamixer") end),
   awful.button({ }, 4, function () exec("amixer -q set PCM 2dB+", false) end),
   awful.button({ }, 5, function () exec("amixer -q set PCM 2dB-", false) end)
)) -- Register assigned buttons
-- }}}

-- {{{ Date and time
dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_date)
-- Initialize widget
datewidget = wibox.widget.textbox()
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%a %b %d %R %Z", 60)
-- }}}

-- {{{ System tray
--systray = widget({ type = "systray" })
-- }}}

for s = 1, scount do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    --mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create a layoutbox
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    --mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, function(c)
											  --remove tasklist icons
                                              local tmptask = { awful.widget.tasklist.filter.currenttags(c, s) }
                                              --local tmptask = { awful.widget.tasklist.label.currenttags(c, s) }
											  return tmptask[1], tmptask[2], tmptask[3], nil
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 24,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_focus,
        --border_width = beautiful.border_width
    })

    -- Add widgets to the wibox
    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(space)
	left_layout:add(mylayoutbox[s])
	left_layout:add(mytaglist[s])
	left_layout:add(separator)
	left_layout:add(space)
	left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
	local mytoolbar = {
		-- separator, s == 1 and systray or nil,
		musicwidget.widget, separator,
		cpuicon, space, cpuwidget, space, cpufreqwidget, space, tzswidget, separator,
		volicon, space, volwidget, separator, 
		memicon, space, memwidget, separator, 
		baticon, space, batwidget, separator, 
		wlanicon, space, wlanwidget, separator, 
		dateicon, space, datewidget, space
	}
	for k,v in pairs(mytoolbar) do
		right_layout:add(v)
	end

    -- Join left and right layouts
    local layout_top = wibox.layout.align.horizontal()
    layout_top:set_left(left_layout)
    layout_top:set_right(right_layout)

	-- Widgets that are in the bottom
	local layout_bottom = wibox.layout.fixed.horizontal()
	layout_bottom:add(mytasklist[s])

	-- Bring it all together
	local layout = wibox.layout.flex.vertical()
	layout:add(layout_top)
	layout:add(layout_bottom)

    mywibox[s]:set_widget(layout)
end
-- }}}
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "e", function () awful.util.spawn(editor) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

	-- Volume
	awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set PCM 2dB+", false) end),
	awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set PCM 2dB-", false) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
musicwidget:append_global_keys()
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "audacious" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
	{ rule = { class = "Firefox" },
	  properties = { tag = tags[1][1] } },
	{ rule = { class = "Thunderbird" },
	  properties = { tag = tags[1][5] } },
	{ rule = { class = "Pidgin" },
	  properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

