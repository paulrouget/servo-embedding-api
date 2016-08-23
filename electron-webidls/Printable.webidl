dictionary PrintOptions {
  Number marginsType; // - Specifies the type of margins to use. Uses 0 for default margin, 1 for no margin, and 2 for minimum margin.
  String pageSize; // - Specify page size of the generated PDF. Can be A3, A4, A5, Legal, Letter, Tabloid or an Object containing height and width in microns.
  boolean printBackground; // - Whether to print CSS backgrounds.
  boolean printSelectionOnly; // - Whether to print selection only.
  boolean landscape; // - true for landscape, false for portrait. 
}

interface Printable {
  void print(PrintOptions options);
  void printToPDF(PrintOptions options, callback);
}
