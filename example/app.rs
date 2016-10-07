/// See GLContext from Glutin

fn main() {
    let win1 = BuildGlutinWindowAsDrawable();
    let win2 = BuildGlutinWindowAsDrawable();

    let t1 = thread::spawn(move || { run(win1); });
    let t2 = thread::spawn(move || { run(win2); });

    t1.join();
    t2.join();
}

fn run(drawable: &Drawable) {

    let compositor = Servo::newCompositor(&Drawable);

    let pixel_ratio = drawable.get_hidpi_factor();

    let window_rect = drawable.get_frame();
    let sidebar_width = 200;

    // the browser is full window
    let browser_rect = window_rect.clone();

    // sidebar is outside of the window for now
    let mut sidebar_rect = window_rect.clone();
    sidebar_rect.size.width = sidebar_width;
    sidebar_rect.origin.x = window_rect.size.width;
    let mut sidebar_content_rect = sidebar_rect.clone();
    sidebar_content_rect.coordinates.x = 0;
    sidebar_content_rect.coordinates.y = 0;

    let browser_view = compositor.new_browser_view(
        ViewFrame { coordinates: browser_rect, z_index: 0 },
        ContentFrame { coordinates: browser_rect, pixel_ratio: pixel_ratio },
        PageOverscrollOptions {
            top: OverscrollOptions::Disabled,
            bottom: OverscrollOptions::Disabled,
            right: OverscrollOptions::Disabled,
            left: OverscrollOptions::Disabled,
        });

    let sidebar_view = compositor.new_browser_view(
        ViewFrame { coordinates: sidebar_rect, z_index: 1 },
        ContentFrame { coordinates: sidebar_content_rect, pixel_ratio: pixel_ratio },
        PageOverscrollOptions {
            top: OverscrollOptions::Disabled,
            bottom: OverscrollOptions::Disabled,
            right: OverscrollOptions::Disabled,
            left: OverscrollOptions::Disabled,
        });

    let preview = compositor.new_pipeline_view();
}

fn BuildGlutinWindowAsDrawable () -> Drawable {
    // Platform specific code
}
