-- =============================================================================
-- INPUT & TOUCHPAD CONFIGURATION
-- =============================================================================
hl.config({
    input = {
        kb_layout = "us",
        repeat_delay = 60,
        repeat_rate = 200,
        follow_mouse = 1,
        scroll_factor = 3,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 3,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})