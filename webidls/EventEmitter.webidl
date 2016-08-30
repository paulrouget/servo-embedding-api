typedef EventListenerCallback = void (Event);

interface EventEmitter {
  void on(String eventName, EventListenerCallback callback);
  void off (String eventName, EventListenerCallback callback);
  Promise<Event> once(String eventName, EventListenerCallback callback);
  void removeAllListeners(Sequence<String> eventNames);
}

interface Event {
  const String type;
  const boolean cancellable;
  void cancel();
}
