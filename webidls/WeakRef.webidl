// An object that references weakly a Servo components.

interface WeakRef {
  readonly attribute boolean isDestroyed;
}

// Fires following events:

interface WeakRefDestroyedEvent : Event {
  // Time to remove all references.
  const DOMString name = "destroyed"; 
}
