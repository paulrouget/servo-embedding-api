
interface Browser {
  can_go_back
  go_back
  can_go_forward
  go_forward
  is_loading
  reload
  reload_ignore_cache
  get_identifier
  is_popup
  has_document
  get_main_frame
  get_focused_frame
  get_frame_byident
  get_frame // by name
  get_frame_count
  get_frame_identifiers
  get_frame_names

  send_process_message
}

// constructor
cef_browser_host_create_browser(
    cef_window_info_t,
    _cef_client_t,
    cef_string_t* url,
    _cef_browser_settings_t* settings,
    _cef_request_context_t* request_context);

interface BrowerHost {
  get_browser
  parent_window_will_close
  close_browser
  set_focus
  get_window_handle
  get_opener_window_handle
  get_client
  get_request_context
  get_zoom_level
  set_zoom_level
  start_download
  print
  find
  stop_finding
  show_dev_tools
  close_dev_tools

  set_mouse_cursor_change_disabled
  is_mouse_cursor_change_disabled

  is_window_rendering_disabled

  was_resized
  was_hidden
  notify_screen_info_changed

  invalidate
  send_key_event
  send_mouse_click_event
  send_mouse_move_event
  send_mouse_wheel_event
  send_focus_event
  send_capture_lost_event

  get_nstext_input_context

  handle_key_event_before_text_input_client
  handle_key_event_after_text_input_client
}

















