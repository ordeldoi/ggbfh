# Schrift ----------------------------------------------------------------------
# Lucida Sans hat statt "Bold" den Schnitt "Demibold". Damit fontface = "bold"
# zuverlässig auf Demibold zeigt, registrieren wir die vier Schnitte unter einem
# eigenen Familiennamen bei systemfonts (wirkt für ragg- und svglite-Geräte).

font_env <- new.env(parent = emptyenv())
font_env$family <- "sans"

bfh_family_name <- "Lucida Sans BFH"

register_bfh_font <- function() {
  fonts <- systemfonts::system_fonts()
  lucida <- fonts[fonts$family == "Lucida Sans", ]
  path <- function(style) {
    p <- lucida$path[lucida$style == style]
    if (length(p)) p[[1]] else NULL
  }
  plain <- path("Regular")

  if (!is.null(plain)) {
    bold <- path("Demibold Roman") %||% plain
    italic <- path("Italic") %||% plain
    bolditalic <- path("Demibold Italic") %||% bold
    systemfonts::register_font(bfh_family_name, plain = plain, bold = bold,
                               italic = italic, bolditalic = bolditalic)
    # Windows-Bildschirmgerät (RGui, RStudio mit Grafik-Backend "Default")
    if (.Platform$OS.type == "windows") {
      args <- list(grDevices::windowsFont("Lucida Sans"))
      names(args) <- bfh_family_name
      do.call(grDevices::windowsFonts, args)
    }
    # pdf() und postscript() können keine TrueType-Schriften verwenden und
    # brechen bei unbekannten Familien ab; dort auf Helvetica ausweichen.
    args <- list(grDevices::pdfFonts()$Helvetica)
    names(args) <- bfh_family_name
    do.call(grDevices::pdfFonts, args)
    args[[1]] <- grDevices::postscriptFonts()$Helvetica
    do.call(grDevices::postscriptFonts, args)
    font_env$family <- bfh_family_name
  } else if ("Lucida Grande" %in% fonts$family) {
    # macOS
    font_env$family <- "Lucida Grande"
  } else {
    font_env$family <- "sans"
  }
  invisible(font_env$family)
}

#' Schriftfamilie des BFH-Themes
#'
#' Gibt den Familiennamen zurück, unter dem Lucida Sans beim Laden des Pakets
#' registriert wurde. Ist Lucida Sans nicht installiert, wird auf
#' `"Lucida Grande"` (macOS) bzw. `"sans"` ausgewichen.
#'
#' Für eine korrekte Darstellung sollte ein ragg-Gerät verwendet werden
#' (RStudio: Tools > Global Options > General > Graphics > Backend: AGG;
#' Export mit [bfh_save()]).
#'
#' @export
bfh_font <- function() font_env$family

`%||%` <- function(x, y) if (is.null(x)) y else x
