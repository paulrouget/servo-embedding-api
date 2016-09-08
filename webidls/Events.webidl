// STATUS: draft

interface Event {
  const DOMString name;
}

interface CancelableEvent : Event {
  const boolean cancelable;
  readonly attribute boolean canceled;
  void cancel();
}

typedef EventListenerCallback = void (Event);

interface EventEmitter {
  void on(DOMString eventName, EventListenerCallback callback);
  void off (DOMString eventName, EventListenerCallback callback);
  Promise<Event> once(DOMString eventName, EventListenerCallback callback);
  void removeAllListeners();
}
