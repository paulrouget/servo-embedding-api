enum PrintMarginsType {
  "default",
  "no-margin",
  "minimum-margin",
}

enum PrintPageSizePreset {
  "A3",
  "A4",
  "A5",
  "Legal",
  "Letter",
  "Tabloid",
}

enum PrintOrientation {
  "landscape",
  "portrait",
}

dictionary PrintPageSize {
  unsigned long width, // microns
  unsigned long height,
}

dictionary PrintOptions {
  MarginsType marginsType;
  (PrintPageSize or PrintPageSizePreset) pageSize;
  PrintOrientation orientation;
  boolean doPrintBackground; // Whether to print CSS backgrounds.
  boolean doPrintSelectionOnly; // Whether to print selection only.
}

interface Printable {
  Promise<void> printPage(PrintOptions options);
  Promise<void> printPageToPDF(PrintOptions options);
}
