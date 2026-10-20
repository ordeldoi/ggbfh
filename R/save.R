#' Grafik im BFH-Stil speichern
#'
#' Wrapper um [ggplot2::ggsave()] mit Masseinheit cm und einem Gerät, das die
#' registrierte Schrift korrekt einbettet: ragg für PNG/JPEG/TIFF, Cairo für PDF.
#'
#' @param filename Dateiname; das Format ergibt sich aus der Endung.
#' @param plot Die Grafik, standardmässig die zuletzt angezeigte.
#' @param width,height Grösse in cm.
#' @param dpi Auflösung für Rastergrafiken.
#' @param ... Weitere Argumente für [ggplot2::ggsave()].
#' @examples
#' \dontrun{
#' bfh_save("grafik.png", p, width = 16, height = 10)
#' }
#' @export
bfh_save <- function(filename, plot = ggplot2::last_plot(), width = 16,
                     height = 10, dpi = 300, ...) {
  ext <- tolower(tools::file_ext(filename))
  device <- switch(ext,
    png = ragg_device("agg_png"),
    jpg = , jpeg = ragg_device("agg_jpeg"),
    tif = , tiff = ragg_device("agg_tiff"),
    pdf = function(...) grDevices::cairo_pdf(..., family = "Lucida Sans"),
    NULL
  )
  if (ext == "pdf") plot <- with_family(plot, "Lucida Sans")
  ggplot2::ggsave(filename, plot, device = device, width = width,
                  height = height, units = "cm", dpi = dpi, bg = NULL, ...)
}

ragg_device <- function(fun) {
  if (!requireNamespace("ragg", quietly = TRUE)) {
    warning("Paket 'ragg' ist nicht installiert; die Schrift wird evtl. ",
            "nicht korrekt dargestellt.", call. = FALSE)
    return(NULL)
  }
  getExportedValue("ragg", fun)
}

# Cairo kennt die bei systemfonts registrierte Familie nicht, daher wird sie
# für PDF durch den Systemnamen ersetzt.
with_family <- function(plot, family) {
  if (bfh_font() != bfh_family_name) return(plot)
  plot + ggplot2::theme(
    text = ggplot2::element_text(family = family),
    geom = ggplot2::element_geom(family = family)
  )
}
