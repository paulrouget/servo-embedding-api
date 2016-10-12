struct MyCompositor {
    compositor: Compositor,
    browser_sender: IpcSender<BrowserMsg>,
}

struct App {
    compositors: Vec<CompositorMsg>,
}

impl App {
    fn handle_message {
        match message {
            AppMsg::CreateNewNativeWindow(resp_chan) => {
                let drawable = NewGlutinWindowAsDrawable();
                let new_compositor = MyCompositor {
                    compositor: Compositor::new(drawable),
                    browser_sender: …,
                }
                self.compositors.push(new_compositor);
                // create chan
                resp_chan.send(chan);
            }
        }
    }
}

/// Event loop
impl MyCompositor {
    fn handle_window_event(&self, native_event: NativeEvent) {
        let event = NativeEventToServoEvent(native_event);
        match event {
            KeyboardEvent => {
                let msg = BrowserMsg::KeyboardEvent(event);
                self.browser_sender.send(msg);
            },
            MouseEvent => {
                let current_cursor = …;
                // Get viewports under cursor
                let iter = self.compositor.get_viewports_from_point(current_cursor);
                // Get highest viewport
                let viewport = iter.max_by_key(|v| {v.get_frame().z_index});
                if Some(viewport) = viewport {
                    if Some(browser) = viewport.get_attached_browser() {
                        let msg = BrowserMsg::MouseEvent(event, browser);
                        self.browser_sender.send(msg);
                    }
                }
            }
        }
    }

    fn handle_browser_message(&self, message: CompositorMsg) {
        match message {
            CompositorMsg::CreateViewport(browser, visible) => {
                let framebuffer_size = …; // Size of the GL region
                let w = framebuffer_size.width;
                let h = framebuffer_size.width;
                let toolbar_height = 20;
                let outer_frame = ViewFrame {
                    coordinates: Rect::new(0,0,w,h),
                    z_index: 0,
                    background_color: Color::White,
                    opacity: 1,
                }
                let mut content_frame = frame.clone();
                content_frame.coordinates.origin.x = toolbar_height;
                content_frame.coordinates.size.height -= toolbar_height;
                self.compositor.new_viewport(frame, content_frame, overscroll_options)
                               .attach_browser(browser)
                               .set_visible(visible);
            }
        }
    }
}
