struct MySession {
    session: Session,
    windows: Vec<MyWindow>,
    browsers: Vec<Browser>,
    app_sender: IpcSender<AppMsg>,
}

struct ClosedTab {
    entries: Vec<LoadData>,
    current: u32,
}

struct MyWindow {
    compositor_sender: IpcSender<CompositorMsg>,
    browsers: Vec<BrowserID>,
    fg_browser_index: u32,
    closed_tabs: Vec<ClosedTab>,
}

struct BrowserHelper { }
impl BrowserHelper {
    fn can_go_back(browser) {
        let i = browser.get_current_entry_index();
        i.is_some() && i != Some(0)
    },
    fn can_go_fwd(browser) {
        let i = browser.get_current_entry_index();
        let max = browser.get_entry_count() - 1;
        i.is_some() && i != Some(max)
    }
    fn go_back(browser) {
        if BrowserHelper::can_go_back(browser) {
            let i = browser.get_current_entry_index().unwrap();
            browser.set_current_entry_index(i - 1);
        }
    }
    fn go_fwd(browser) {
        if BrowserHelper::can_go_fwd(browser) {
            let i = browser.get_current_entry_index().unwrap();
            browser.set_current_entry_index(i + 1);
        }
    }
}

impl MyWindow { // One per native window
    fn handle_compositor_message(&self, msg) {
        match msg {

            BrowserMsg::NewViewport(viewport, browser) => {
                // Manage a hashmap of viewport/browser
            }

            BrowserMsg::MouseEvent(event, browserid) => {
                let browser = GetBrowserFromID(browseid);
                browserid.handle_event(event).and_then(|consumed| {
                    if event_is_scroll_event && !consumed {

                        // strategy 1: all scroll events that are not consumed
                        // are sent back to compositor
                        let msg = CompositorMsg::UnconsumedScrollEvent(event, browserid);

                        // strategy 2: all scroll events stay in compositor until
                        // the use remove his fingers from touchpad
                        let msg = CompositorMsg::ScrollViewportUntilRelease(browserid);

                        self.compositor_sender.send(msg);
                    }
                });
            }

            BrowserMsg::KeyboardEvent(event) => {

                match event.key {

                    CMD_LEFT => { // go back
                        let browser = self.browsers[self.fg_browser_index];
                        BrowserHelper::go_back(browser);
                    },

                    ESC => { // stop loading
                        let browser = self.browsers[self.fg_browser_index];
                        if browser.has_pending_pipeline() {
                            // there is a page to be loaded
                            browser.cancel_pending_pipeline();
                        }
                        // get the current pipeline
                        let pipeline = browser.get_entries().find(|e| e.current).unwrap().pipeline_id;
                        if let Some(pipeline) = pipeline {
                            PipelineProxy::stop_loading(pipeline).expect("failed to reach pipeline");
                        }
                    },

                    CMD_R => { // reload
                        let browser = self.browsers[self.fg_browser_index];
                        let pipeline = browser.get_entries().find(|e| e.current).unwrap().pipeline_id;
                        if let Some(pipeline) = pipeline {
                            PipelineProxy::reload(pipeline).expect("failed to reach pipeline");
                        }
                    },

                    CMD_L => { // focus url bar
                        let browser = self.browsers[self.fg_browser_index];
                        browser.handle_event(event).and_then(|consumed| {
                            if !consumed {
                                // […] focus urlbar
                            }
                        });
                    }

                    CMD_Q => { // quit
                        let msg = AppMsg::Quit();
                        // not sure how to reach the session
                        session.app_sender(msg);
                    }

                    CMD_W => { // close tab
                        let browser = …; // Tab to close
                        let viewport = …; // get viewport from hashmap
                        let msg = CompositorMsg::KillViewport(viewport);
                        self.compositor_sender.send(msg);
                        let load_data = browser.get_entries().map(|e| e.load_data);
                        let idx = browser.get_current_entry_index();
                        let closed_tab = ClosedTab {
                            entries: load_data,
                            current: idx,
                        }
                        self.closed_tabs.push(closed_tab);
                        // Destroy browser
                    }

                    CMD_SHIT_T => {
                        let closed_tab = match self.closed_tabs.pop() {
                            Some(closed_tab) => { closed_tab },
                            None => return,
                        }
                        let browser = Browser::new(&self.session, handlers/*FIXME:see create_new_browser*/);
                        browser.restore_entries(closed_tab.entries, closed_tab.current);
                        self.browsers.push(browser);
                        let msg = CompositorMsg::CreateViewport(browser.get_id(), true);
                        self.compositor_sender.send(msg);
                        self.fg_browser_index = self.browsers.size - 1;
                    }

                }
            }
        }
    }

    fn user_hit_enter_in_urlbar(&self, url: String, user_value: String) {
        let browser = self.browsers[self.fg_browser_index];
        if browser.has_prerendering_pipeline() {
            // We assumed that the prerendering pipeline would
            // have been dismissed if the user entered a different
            // url
            browser.navigate_to_prerendering_pipeline(None);
        } else {
            let load_data = LoadData {
                url: url.clone(),
                user_typed_value: user_value.clone(),
                transition_type: TransitionType::Typed,
                http_method: HTTPMethod::GET,
                scroll_restoration_mode: ScrollRestoration::Auto,
                title: None,
                http_headers: None,
                body: None,
                referrer_url: None,
                scroll_position: None,
                js_state_object: None,
                form_data: None,
            }
            browser.navigate(load_data, None);
        }
    }

    fn user_about_to_hit_enter_in_urlbar(&self, url: String, user_value: String) {
        let browser = self.browsers[self.fg_browser_index];
        if browser.has_prerendering_pipeline() {
            browser.cancel_prerendering_pipeline();
        }
        browser.build_prerendering_pipeline(LoadData {
            url: url.clone(),
            user_typed_value: user_value.clone(),
            transition_type: TransitionType::Typed,
            http_method: HTTPMethod::GET,
            scroll_restoration_mode: ScrollRestoration::Auto,
            title: None,
            http_headers: None,
            body: None,
            referrer_url: None,
            scroll_position: None,
            js_state_object: None,
            form_data: None,
        });
    }

    fn invalidate_prerendering_pipeline() {
        // Called if the preloading pipeline makes
        let browser = self.browsers[self.fg_browser_index];
        if browser.has_prerendering_pipeline() {
            browser.cancel_prerendering_pipeline();
        }
    },

    fn create_new_browser(&self,
                          load_data: LoadData,
                          opener: Option<PipelineID>
                          disposition: WindowDisposition) {
        let browser = Browser::new(&self.session,
                                  "".to_owned(),
                                  // FIXME: not sure if that's valid rust,
                                  // can we pass self as BrowserHandler, a trait?
                                  &self, // browser handler
                                  &self, // pipeline handler
                                  &self, // http handler
                                  );

        browser.navigate(load_data, opener);

        if disposition == WindowDisposition::NewWindow {
            // Error
        }

        self.browsers.push(browser);
        let msg = CompositorMsg::CreateViewport(browser.get_id(), true);
        self.compositor_sender.send(msg);
        if disposition == WindowDisposition::ForegroundTab {
            self.fg_browser_index = self.browsers.size - 1;
            // […] more stuff
        }
    }

    fn preview_browser_history(&self, browser) {
        let pipelines = browser.get_entries().iter().filter_map(|e| {
            e.pipeline_id
        });
        let msg = CompositorMsg::PreviewManyPipelines(pipelines);
        self.compositor_sender.send(msg);
    }
}

impl MySession {
    fn find_window_for_browser(&self, browser: BrowserID) -> &MyWindow {
        // […]
    },
    fn find_browser_for_pipeline(&self, pipeline: PipelineProxy) -> BrowserID {
        // This is not really handy. It's probably better to have a
        // pipeline <-> browser hashmap, built with
        // BrowserHandler::current_entry_index_changed
        self.browsers.find(|b| {
            b.get_current_entry().unwrap().pipeline_id == pipeline
        });
    }
    fn create_new_native_window(&self) {
        let (sender, receiver) = ipc::channel().unwrap();
        let msg = AppMsg::CreateNewNativeWindow(sender);
        self.app_sender.send(msg);
        let chan = receiver.recv().unwrap();
        let window = MyWindow {
            compositor_sender: chan,
            browsers: [],
            fg_browser_index: 0
        };
        self.windows.push(window);
        window
    }
}

impl PipelineHandler for MySession {

    fn will_navigate(&self, pipeline: PipelineID, load_data: LoadData) {
        match load_data.transition_type {
            LinkClicked(MiddleButton, _) |
            LinkClicked(_, CMD_KEY) |
            LinkClicked(_, CTRL_KEY) => {
                let browser = self.find_browser_for_pipeline(pipeline);
                let window = self.find_window_for_browser(browser);
                window.create_new_browser(load_data, WindowDisposition::BackgroundTab);
                // Will cancel navigation
                false
            },
            JavaScript => {
                let browser = self.find_browser_for_pipeline(pipeline);
                let window = self.find_window_for_browser(browser);
                window.create_new_browser(load_data, WindowDisposition::BackgroundTab);
                false
            }
            Reload => {
                // Reload is about to happen
            },
            _ => {
                // Will let navigation happen
                let browser = self.find_browser_for_pipeline(pipeline);
                if is_pin_tab(browser) { // the pin tab notion is an embedder thing
                    let old_domain = Url::parse(PipelineProxy::get_url(pipeline)).unwrap();
                    let new_domain = Url::parse(load_data.url).unwrap();
                    if old_domain != new_domain {
                        let window = self.find_window_for_browser(browser);
                        window.create_new_browser(load_data, WindowDisposition::ForegroundTab);
                        // Will cancel navigation
                        false
                    } else {
                        true
                    }
                } else {
                    true
                }
            }
        }
    }

    fn title_changed(&self, pipeline: PipelineID) {
        let title = PipelineProxy::get_title(pipeline).expect("error");
        let browser = self.find_browser_for_pipeline(pipeline);
        // […] Update title in tab
    }

    fn icons_changed(&self, pipeline: PipelineId) {
        let icons = PipelineProxy::get_icons(pipeline).expect("error");
        let best_fit = icons.fold(/*[…]*/);
        let browser = self.find_browser_for_pipeline(pipeline);
        // […] Update icon in tab
    }

    fn metas_changed(&self, pipeline, PipelineID) {
        let metas = PipelineProxy::get_metas(pipeline).expect("error");
        if let Some(meta) = metas.find(|m| m.name == "theme-color") {
            let color = meta.content;
            let browser = self.find_browser_for_pipeline(pipeline);
            // […] Update color for tab
        }

    }

    fn close(&self, pipeline: PipelineID) {
        let browser = self.find_browser_for_pipeline(pipeline);
        // […] show dialog, then destroy browser
    }

    fn new_window(&self, pipeline: PipelineID, mut disposition: WindowDisposition, load_data: LoadData) {
        let window = if disposition == WindowDisposition::NewWindow {
            disposition = WindowDisposition::ForegroundTab
            self.create_new_native_window()
        } else {
            let browser = self.find_browser_for_pipeline(pipeline);
            self.find_window_for_browser(browser)
        }
        window.create_new_browser(load_data, disposition);
    }

    fn confirm(&self, pipeline: PipelineID, title: String, message: String, resp_chan: IpcSender<bool>) {
        let browser = self.find_browser_for_pipeline(pipeline);
        let window = self.find_window_for_browser(browser);
        let msg = CompositorMsg::ShowConfirmDialog(
            browser.get_id(),
            title,
            message,
            resp_chan);
        window.compositor_sender.send(msg);
    }

    fn state_changed(&self, pipeline: PipelineID) {
        let state = PipelineProxy::get_pipeline_state(pipeline).expect("error");
        match state {
            PipelineState::Error(_) => {
                // Connection error
                // Do something
            },
            PipelineState::Complete => {
                let http_response = PipelineProxy::get_http_response(pipeline).expect("error").unwrap();
                let status = http_method.raw_status;
                if status == 404 {
                    // Do something
                }
            }
            _ => {},
        }
    }
}

impl BrowserHandler for MySession {
    fn current_entry_index_changed(&self, browser, pipeline, index) {
        // Update a map of browser <-> pipeline
    }
}
