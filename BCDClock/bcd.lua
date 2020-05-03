-------------------------------------------
-- BCD Clock
--
-- Binary Coded Decimal Clock for Conky
-- 
-------------------------------------------

require 'cairo'

led_colours = {
    on = {1, 1, 1, 0.75},
    off = {0, 0, 0, 0.75},
}

leds = {
    { 140, 100, 60, 20, },
    { 140, 100, 60, },
    { 140, 100, 60, 20, },
    { 140, 100, 60, },
    { 140, 100, 60, 20, },
    { 140, 100, },
}

last_update = 0

---------------------------------------------
-- Draws an LED using Cairo
--
function draw_led(display, position, state)

    local x, y = position['x'], position['y']
    local led_radius = 15
    local stroke_width = 2

    cairo_rectangle(display, x-15, y-15, 30, 30)

    cairo_set_source_rgba(display, unpack(led_colours[state]))
    cairo_set_line_width(display, stroke_width)
    cairo_fill_preserve(display)
    cairo_stroke(display)
end

---------------------------------------------
-- Creates a table of time data which is used
-- as a lookup for each LED that needs drawing
--
function create_time_table ()

    local t = {}
    local time_str = string.format('${%s %s}', 'time', '%T')
    time_str = string.reverse(conky_parse(time_str))
    for num in string.gmatch(time_str, '%d') do
        table.insert(t, num)
    end
    return t
end

---------------------------------------------
-- Creates a binary table for a given number
--
function dec_to_bin_table (num)

    local t={}
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end

---------------------------------------------
-- Calculates the state of a given LED from
-- a given item segment
--
function get_state (bit, num)

    local bin_table = dec_to_bin_table(tonumber(num))
    return (bin_table[bit] == 1 and 'on' or 'off')
end

---------------------------------------------
-- Render method
-- Gets current time, creates lookup tables
-- and iterates through to draw LEDs
--
function render(display)

    local time_str = ''
    local position = { x = 250, y = nil, }
    local led_state = 'off'
    local current_time = create_time_table()

    for i = 1, #leds do
        for idx, ypos in ipairs(leds[i]) do
            position['y'] = ypos
            draw_led(display, position, get_state(idx, current_time[i]))
        end
        position['x'] = position['x'] - 40
        if (i % 2 == 0) then
            position['x'] = position['x'] - 15
        end
    end

end

-------------------------------------------
-- Main
-- Entry point for Conky via lua_load in config
--
function conky_main()

    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local display = cairo_create(cs)
    local updates = conky_parse('${updates}');
    update = tonumber(updates)

    -- updates sometimes come through twice
    -- causing double rendering which affects
    -- display when using opacity as leds get
    -- drawon top of each other. double_buffer
    -- in conky config seems to solve this but
    -- leaving this here as safety net.
    if (update > last_update) then
        render(display)
        last_update = update
    end

    cairo_surface_destroy(cs)
    cairo_destroy(display)
    cs = nil
end 