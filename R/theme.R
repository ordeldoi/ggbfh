#' BFH-Theme für ggplot2
#'
#' Ein schlichtes Theme, angelehnt an das BFH-Markendesign: Lucida Sans,
#' Text und Gitterlinien in BFH-Schriftgrau, linksbündige Titel und Legende
#' oben links. Das Theme setzt zudem die BFH-Paletten als Standard für
#' Farbskalen, sodass `scale_*_bfh()` nur für andere Paletten nötig ist.
#'
#' @param base_size Basisschriftgrösse in pt. Alle anderen Grössen skalieren
#'   mit. Für Folien etwa 14–16 verwenden.
#' @param base_family Schriftfamilie, Standard ist [bfh_font()].
#' @param grid Welche Gitterlinien angezeigt werden: `"y"` (horizontal),
#'   `"x"` (vertikal), `"xy"` oder `"none"`.
#' @param legend_position Position der Legende, z.B. `"top"`, `"right"`,
#'   `"bottom"` oder `"none"`.
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Petal.Length, colour = Species)) +
#'   geom_point() +
#'   labs(title = "Iris", caption = "Quelle: datasets::iris") +
#'   theme_bfh()
#' @export
theme_bfh <- function(base_size = 10, base_family = bfh_font(), grid = "y",
                      legend_position = "top") {
  grid <- match.arg(grid, c("y", "x", "xy", "none"))
  ink <- bfh_colors[["schriftgrau"]]
  paper <- "white"
  grid_line <- ggplot2::element_line(colour = ink, linewidth = 0.2)

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family,
                         ink = ink, paper = paper) +
    ggplot2::theme(
      # Text
      text = ggplot2::element_text(colour = ink),
      plot.title = ggplot2::element_text(
        face = "bold", size = ggplot2::rel(1.3), hjust = 0,
        margin = ggplot2::margin(b = base_size * 0.4)
      ),
      plot.subtitle = ggplot2::element_text(
        size = ggplot2::rel(1), hjust = 0,
        margin = ggplot2::margin(b = base_size * 1.2)
      ),
      plot.caption = ggplot2::element_text(
        size = ggplot2::rel(0.75), hjust = 0, colour = bfh_colors[["grau"]],
        margin = ggplot2::margin(t = base_size * 1.2)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.text = ggplot2::element_text(size = ggplot2::rel(0.85), colour = ink),
      axis.title = ggplot2::element_text(size = ggplot2::rel(0.9)),
      strip.text = ggplot2::element_text(
        face = "bold", size = ggplot2::rel(0.95), hjust = 0, colour = ink,
        margin = ggplot2::margin(b = base_size * 0.4)
      ),

      # Gitter und Achsen
      panel.grid.major.x = if (grid %in% c("x", "xy")) grid_line else ggplot2::element_blank(),
      panel.grid.major.y = if (grid %in% c("y", "xy")) grid_line else ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      panel.spacing = grid::unit(base_size * 1.2, "pt"),

      # Legende
      legend.position = legend_position,
      legend.justification = "left",
      legend.location = "plot",
      legend.title = ggplot2::element_text(size = ggplot2::rel(0.9)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.85)),
      legend.key.size = grid::unit(base_size * 1.1, "pt"),
      legend.margin = ggplot2::margin(0, 0, 0, 0),

      # Hintergrund
      plot.background = ggplot2::element_rect(fill = paper, colour = NA),
      plot.margin = ggplot2::margin(base_size, base_size, base_size, base_size),

      # Standardfarben der Geoms (Linien/Punkte/Text in Schriftgrau,
      # Flächen in Dunkelblau, geom_smooth & Co. in BFH-Orange).
      # Linienstärken und Punktgrössen bleiben beim ggplot2-Standard.
      geom = ggplot2::element_geom(
        ink = ink, paper = paper, accent = bfh_colors[["orange"]],
        fill = bfh_colors[["dunkelblau"]],
        family = base_family, fontsize = base_size * 0.85
      ),

      # Standardpaletten für Farbskalen
      palette.colour.discrete = function(n) bfh_pal("standard", n),
      palette.fill.discrete = function(n) bfh_pal("standard", n),
      palette.colour.continuous = bfh_gradient("blau", 7),
      palette.fill.continuous = bfh_gradient("blau", 7)
    )
}
