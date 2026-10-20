#' Übersicht der BFH-Paletten
#'
#' Zeigt alle diskreten Paletten und Verläufe als Farbstreifen.
#'
#' @param cvd Wenn `TRUE`, wird die Standardpalette zusätzlich mit simulierter
#'   Deuteranopie, Protanopie und Tritanopie gezeigt (benötigt `colorspace`).
#' @return Ein ggplot-Objekt.
#' @export
bfh_show_palettes <- function(cvd = FALSE) {
  std <- bfh_pal("standard")
  rows <- list("Standard" = std)
  if (cvd) {
    if (!requireNamespace("colorspace", quietly = TRUE)) {
      stop("F\u00fcr cvd = TRUE wird das Paket 'colorspace' ben\u00f6tigt.", call. = FALSE)
    }
    sims <- list(colorspace::deutan(std), colorspace::protan(std),
                 colorspace::tritan(std))
    names(sims) <- paste("Standard \u2013", c("Deuteranopie", "Protanopie", "Tritanopie"))
    rows <- c(rows, sims)
  }
  rows <- c(rows, list(
    "gruen"     = bfh_pal("gruen"),
    "blau"      = bfh_pal("blau"),
    "violett"   = bfh_pal("violett"),
    "ocker"     = bfh_pal("ocker"),
    "rot"       = bfh_pal("rot"),
    "blau, n = 5" = bfh_pal("blau", 5),
    "highlight" = bfh_pal("highlight")
  ))
  for (g in names(bfh_gradients)) {
    rows[[paste0("Verlauf ", g)]] <- bfh_gradient(g, 60)
  }

  df <- do.call(rbind, lapply(seq_along(rows), function(i) {
    cols <- rows[[i]]
    n <- length(cols)
    data.frame(
      row = names(rows)[i], col = cols,
      xmin = (seq_len(n) - 1) / n, xmax = seq_len(n) / n,
      label = if (n <= 8) tolower(cols) else NA,
      dark = grDevices::convertColor(t(grDevices::col2rgb(cols)) / 255,
                                     from = "sRGB", to = "Lab")[, 1] < 60
    )
  }))
  levels <- rev(names(rows))
  df$y <- match(df$row, levels)

  ggplot2::ggplot(df) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax,
                   ymin = .data$y - 0.42, ymax = .data$y + 0.42, fill = .data$col),
      colour = "white", linewidth = 0.5
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = (.data$xmin + .data$xmax) / 2, y = .data$y, label = .data$label,
                   colour = .data$dark),
      size = 2.6, na.rm = TRUE
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "#3c3c3c"),
                                 guide = "none") +
    ggplot2::scale_y_continuous(breaks = seq_along(levels), labels = levels,
                                expand = c(0, 0.3)) +
    ggplot2::scale_x_continuous(expand = c(0, 0)) +
    ggplot2::labs(title = "BFH-Farbpaletten", x = NULL, y = NULL) +
    theme_bfh(grid = "none") +
    ggplot2::theme(axis.text.x = ggplot2::element_blank())
}
