enum MarginsType {
  "default",
  "no-margin",
  "minimum-margin",
}

enum PageSizePreset {
  "A3",
  "A4",
  "A5",
  "Legal",
  "Letter",
  "Tabloid",
}

dictionary PageSize {
  unsigned long width, // microns
  unsigned long height,
}

dictionary PrintOptions {
  MarginsType marginsType;
  (PageSize or PageSizePreset) pageSize;
  boolean printBackground; // Whether to print CSS backgrounds.
  boolean printSelectionOnly; // Whether to print selection only.
  boolean landscape; // true for landscape, false for portrait. 
}

interface Printable {
  Promise<void> print(PrintOptions options);
  Promise<void> printToPDF(PrintOptions options);
}

