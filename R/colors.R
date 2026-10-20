# Farben -----------------------------------------------------------------------
# Quelle: BFH Markenmanual kompakt (CD-Essentials, 01.06.2025), Kap. 1.3

#' BFH-Farben
#'
#' Benannter Vektor mit allen Farben aus dem BFH-Markenmanual: Markenfarben,
#' Sekundärfarben (für Infografiken) und Online-Grauwerte.
#'
#' @examples
#' bfh_colors["dunkelblau"]
#' @export
bfh_colors <- c(
  # Markenfarben
  grau          = "#697d91",
  orange        = "#fac300",
  # Sekundärfarben
  dunkelgruen   = "#556455",
  mittelgruen   = "#699673",
  hellgruen     = "#8caf82",
  dunkelblau    = "#506e96",
  mittelblau    = "#699bbe",
  hellblau      = "#87b9c8",
  dunkelviolett = "#645078",
  mittelviolett = "#825a7d",
  hellviolett   = "#a087aa",
  dunkelocker   = "#786450",
  mittelocker   = "#96825f",
  hellocker     = "#b99164",
  dunkelrot     = "#b41428",
  mittelrot     = "#d25a50",
  hellrot       = "#e1917d",
  # Online-Werte
  schriftgrau   = "#4b647d",
  dunkelgrau    = "#3c3c3c",
  grauwert1     = "#64788b",
  grauwert2     = "#a2aeb9",
  grauwert3     = "#c1c9d1",
  grauwert4     = "#e0e4e8",
  grauwert5     = "#eff1f3"
)

# Paletten ---------------------------------------------------------------------

#' BFH-Paletten
#'
#' Diskrete Paletten als Vektoren von Farbnamen aus [bfh_colors].
#'
#' * `standard`: Reihenfolge optimiert auf Unterscheidbarkeit, auch bei
#'   Deutan-, Protan- und Tritan-Simulation. Ab ca. 6 Farben nimmt der Abstand
#'   deutlich ab.
#' * `gruen`, `blau`, `violett`, `ocker`, `rot`: Farbfamilien (dunkel bis hell)
#'   für zusammengehörige Kategorien.
#' * `highlight`: Grau für den Rest, BFH-Orange für das Hervorgehobene. Passt zu
#'   einer logischen Variable (`FALSE`, `TRUE`).
#'
#' @export
bfh_palettes <- list(
  standard  = c("dunkelblau", "hellocker", "hellblau", "dunkelgruen",
                "hellviolett", "mittelrot", "dunkelviolett", "mittelocker"),
  gruen     = c("dunkelgruen", "mittelgruen", "hellgruen"),
  blau      = c("dunkelblau", "mittelblau", "hellblau"),
  violett   = c("dunkelviolett", "mittelviolett", "hellviolett"),
  ocker     = c("dunkelocker", "mittelocker", "hellocker"),
  rot       = c("dunkelrot", "mittelrot", "hellrot"),
  highlight = c("grauwert3", "orange")
)

families <- c("gruen", "blau", "violett", "ocker", "rot")

#' Aufhellung einer Farbe
#'
#' Mischt eine Farbe in `n` Stufen mit Weiss (Manual 1.5.3: 100/80/60/40/20 %).
#'
#' @param color Farbname aus [bfh_colors] oder Hex-Wert.
#' @param n Anzahl Stufen.
#' @param min Anteil der Farbe in der hellsten Stufe.
#' @export
bfh_tints <- function(color, n = 5, min = 0.2) {
  if (color %in% names(bfh_colors)) color <- bfh_colors[[color]]
  share <- seq(1, min, length.out = n)
  rgb <- grDevices::col2rgb(color)
  mix <- vapply(share, function(s) rgb * s + 255 * (1 - s), numeric(3))
  grDevices::rgb(t(mix), maxColorValue = 255)
}

#' Diskrete BFH-Palette
#'
#' @param palette Name einer Palette aus [bfh_palettes].
#' @param n Anzahl Farben. Familien mit `n > 3` werden über einen Verlauf von
#'   der dunklen bis zu einer aufgehellten hellen Farbe erweitert.
#' @param reverse Reihenfolge umkehren.
#' @return Vektor mit Hex-Werten.
#' @examples
#' bfh_pal("standard", 4)
#' bfh_pal("blau", 5)
#' @export
bfh_pal <- function(palette = "standard", n = NULL, reverse = FALSE) {
  palette <- match.arg(palette, names(bfh_palettes))
  cols <- unname(bfh_colors[bfh_palettes[[palette]]])
  if (is.null(n)) n <- length(cols)
  if (n > length(cols)) {
    if (palette %in% families) {
      # Reine Aufhellung der dunklen Farbe wirkt schnell grau; daher Verlauf
      # über dunkel - mittel - hell bis zur aufgehellten hellen Farbe.
      stops <- c(cols, bfh_tints(cols[[3]], 2, min = 0.5)[2])
      cols <- if (n == length(stops)) stops else
        grDevices::colorRampPalette(stops, space = "Lab")(n)
    } else {
      warning("Palette '", palette, "' hat nur ", length(cols), " Farben, ",
              n, " werden ben\u00f6tigt.", call. = FALSE)
    }
  }
  cols <- cols[seq_len(min(n, length(cols)))]
  if (reverse) rev(cols) else cols
}

#' BFH-Farbverläufe
#'
#' Stützfarben für kontinuierliche Skalen (Farbnamen aus [bfh_colors] oder
#' Hex-Werte): je ein Verlauf pro Farbfamilie (von der auf 35 % aufgehellten
#' hellen Farbe zur dunklen Farbe, damit auch die tiefsten Werte auf weissem
#' Hintergrund sichtbar bleiben) und ein divergierender Verlauf
#' (Blau – Grau – Rot).
#'
#' @export
bfh_gradients <- lapply(bfh_palettes[families], function(fam) {
  c(bfh_tints(fam[[3]], 2, min = 0.35)[2], rev(fam))
})
bfh_gradients$divergierend <- c("dunkelblau", "mittelblau", "hellblau", "grauwert4",
                                "hellrot", "mittelrot", "dunkelrot")

#' Kontinuierlicher BFH-Farbverlauf
#'
#' @param palette Name eines Verlaufs aus [bfh_gradients].
#' @param n Anzahl Farben.
#' @param reverse Richtung umkehren.
#' @return Vektor mit Hex-Werten.
#' @export
bfh_gradient <- function(palette = "blau", n = 256, reverse = FALSE) {
  palette <- match.arg(palette, names(bfh_gradients))
  cols <- bfh_gradients[[palette]]
  named <- cols %in% names(bfh_colors)
  cols[named] <- bfh_colors[cols[named]]
  if (reverse) cols <- rev(cols)
  grDevices::colorRampPalette(cols, space = "Lab")(n)
}
