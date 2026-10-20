.onLoad <- function(libname, pkgname) {
  try(register_bfh_font(), silent = TRUE)

  # Geordnete Faktoren nutzen in ggplot2 nicht die Theme-Palette, sondern die
  # Optionen ggplot2.ordinal.*. Sofern nicht bereits gesetzt, wird dort die
  # Farbfamilie Blau (dunkel bis hell) hinterlegt.
  if (is.null(getOption("ggplot2.ordinal.colour"))) {
    options(ggplot2.ordinal.colour = function(...) {
      ggplot2::discrete_scale("colour", palette = function(n) bfh_pal("blau", n), ...)
    })
  }
  if (is.null(getOption("ggplot2.ordinal.fill"))) {
    options(ggplot2.ordinal.fill = function(...) {
      ggplot2::discrete_scale("fill", palette = function(n) bfh_pal("blau", n), ...)
    })
  }
}
