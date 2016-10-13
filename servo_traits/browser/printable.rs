pub enum PrintMarginsType {
    Default,
    NoMargin,
    MinimumMargin,
}

pub enum PrintPageSize {
    Custom(Size2D<f32>),
    A3,
    A4,
    A5,
    Legal,
    Letter,
    Tabloid,
}

pub enum PrintOrientation {
    Landscape,
    Portrait,
}

pub struct PrintOptions {
    margin_type: MarginsType,
    page_size: PrintPageSize,
    orientation: PrintOrientation,
    print_background: bool,
    print_selection_only: bool,
}

// Implemented by Browser, or maybe Pipeline
pub trait Printable {
    fn printPage(&self, options: PrintOptions) -> impl Future<Item=(),Error=()>;
    fn printPageToPDF(&self, options: PrintOptions) -> impl Future<Item=(),Error=()>;
}
