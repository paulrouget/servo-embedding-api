struct MyCompositor {
    compositor: Compositor,
    browser_sender: IpcSender<BrowserMsg>,
    translate_browserview: bool,
    translate_toolbar: bool,
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
                // Get browserviews under cursor
                let iter = self.compositor.get_browserviews_from_point(current_cursor);
                // Get highest browserview 
                let browserview = iter.max_by_key(|v| {v.get_frame().z_index});
                if Some(browserview) = browserview {

                    let browser = browserview.get_attached_browser().unwrap();

                    if !event_is_scroll {
                        let msg = BrowserMsg::MouseEvent(event, browser);
                        self.browser_sender.send(msg);
                        return
                    }

                    if self.translate_browserview {
                        // Scroll event and translate_browserview is true
                        if event.phase == release {
                            self.translate_browserview = false;
                        } else {
                            self.move_browserview_from_scrollevent(browserview, event);
                        }
                        return;
                    }

                    // Check if the toolbar should be moved or not. If scroll up and toolbar
                    // is not collapse for example.
                    let translate_toolbar = …;

                    if translate_toolbar {
                        let y = event.delta_y;

                        // 1. Move toolbar
                        // let's assume the toolbar is a DOM element in another browserview,
                        // and that DOM element is linked to a StackingContextID
                        let toolbar_browserview = …;
                        let toolbar_id = …;
                        let mut composite_and_transform = toolbar_browserview.get_composite_and_transform(toolbar_id).unwrap();
                        let transform = composite_and_transform.transform.post_translated(0,y,0);
                        composite_and_transform.transform = transform;
                        toolbar_browserview.set_composite_and_transform(toolbar_id, composite_and_transform);

                        // 2. resize and move content
                        let mut frame = browserview.get_content_frame();
                        frame.coordinates.size.height += y;
                        frame.coordinates.origin.y -= y;
                        browserview.set_content_frame(frame, None);

                        // Warning! When translate_toolbar is back to false, or the user release the touch pad,
                        // call browserview.resize_and_scroll_browsers
                    }

                    let msg = BrowserMsg::MouseEvent(event, browser);
                    self.browser_sender.send(msg);
                }
            }
        }
    }

    fn move_browserview_from_scrollevent(&self, browserview, event) {
        // Only handle vertical scroll
        let delta_y = event.delta.y;
        let mut new_frame = browserview.get_frame();
        new_frame.coordinates.origin.y += delta_y;
        browserview.set_frame(new_frame, None);
    }

    fn handle_browser_message(&self, message: CompositorMsg) {
        match message {
            CompositorMsg::CreateBrowserView(sender) => {
                let framebuffer_size = …; // Size of the GL region
                let w = framebuffer_size.width;
                let h = framebuffer_size.height;
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
                let browserview = self.compositor.new_browserview(frame, content_frame, browser);
                sender.send(browserview.get_id());
            },
            CompositorMsg::KillBrowserView(viewpo) {
                // Destroy browserview
            },
            CompositorMsg::ShowConfirmDialog(browser, title, message) => {
                // build a popup, draw it somewhere, wait for keyboard or
                // mouse events to see if the user clicks cancel or ok.
                // then send boolean back to browser
            },
            CompositorMsg::PreviewManyDocuments(documents) {
                // Maybe get all views first and hide them

                let framebuffer_size = …; // Size of the GL region

                let w = framebuffer_size.width;
                let h = framebuffer_size.height;
                let ratio = documents.len();
                let rect = Rect::new(0,0,w,h).scale(ratio,ratio);

                let mut offset = 0;

                documents.iter().map(|p| {
                    let mut view_rect = rect.clone();
                    view_rect.origin.x = offset;
                    offset += rect.size.width;
                    let frame = ViewFrame {
                        coordinates: view_rect,
                        z_index: 0,
                        background_color: Color::White,
                        opacity: 1,
                    }
                    self.compositor.new_documentview(frame, p);
                });
                

            }
            CompositorMsg::UnconsumedScrollEvent(event, browserid) {
                let browserview = …; // Get browserview from browserid
                self.move_browserview_from_scrollevent(browserview, event);
            }
            CompositorMsg::ScrollBrowserViewUntilRelease(_) {
                self.translate_browserview = false;
            }
        }
    }
}
