# PDF-Galerie für ggbfh: möglichst viele ggplot2-Optionen auf je einer Seite.
# Nur R-Standarddatensätze (Paket datasets). Ausführen im Projektordner:
#   Rscript dev/gallery_pdf.R
library(ggplot2)
library(ggbfh)

dir.create("output", showWarnings = FALSE)
pal <- bfh_colors
pages <- list()
add <- function(p) pages[[length(pages) + 1]] <<- p


# Textseiten (Inhalt des README) -----------------------------------------------
# Textseiten sind Funktionen, die mit grid zeichnen; sie erhalten die
# Schriftfamilie des jeweiligen Geräts (Cairo-PDF bzw. ragg-Vorschau).

page_h <- 140  # mm
margin <- 12
col_x <- c(margin, 113)           # linke/rechte Spalte (mm)
col_w <- c(95, 95)                # Spaltenbreite (mm)
mono_family <- "Lucida Sans Typewriter"
ink <- pal[["schriftgrau"]]

pt_mm <- function(pt) pt * 25.4 / 72

# Blöcke: list(type, text, col), col = 1, 2 oder 0 (ganze Breite)
text_page <- function(blocks) {
  function(family) {
    grid::grid.newpage()
    pos <- c(margin, margin)  # Abstand von oben je Spalte (mm)
    # Mehrzeiliger Text: jede Zeile einzeln mit festem Zeilenabstand
    txt <- function(label, x, top, size, face = "plain", col = ink, fam = family,
                    lh = pt_mm(size) * 1.2) {
      lines <- strsplit(label, "\n", fixed = TRUE)[[1]]
      for (i in seq_along(lines)) {
        grid::grid.text(lines[i], x = grid::unit(x, "mm"),
                        y = grid::unit(page_h - top - (i - 1) * lh, "mm"),
                        just = c("left", "top"),
                        gp = grid::gpar(fontfamily = fam, fontface = face,
                                        fontsize = size, col = col))
      }
    }
    for (b in blocks) {
      cols <- if (b$col == 0) 1:2 else b$col
      x <- col_x[cols[1]]
      w <- if (b$col == 0) sum(col_w) + diff(col_x) - col_w[1] else col_w[b$col]
      top <- max(pos[cols])
      chars <- function(size) floor(w / (pt_mm(size) * 0.52))
      h <- switch(b$type,
        title = {
          grid::grid.rect(x = grid::unit(x, "mm"), y = grid::unit(page_h - top, "mm"),
                          width = grid::unit(22, "mm"), height = grid::unit(1.6, "mm"),
                          just = c("left", "top"), gp = grid::gpar(fill = pal[["orange"]], col = NA))
          txt(b$text, x, top + 4, 30, "bold")
          16
        },
        sub = { txt(b$text, x, top, 12); 7 },
        meta = { txt(b$text, x, top, 8, col = pal[["grau"]]); 9 },
        h2 = { txt(b$text, x, top + 1.5, 11, "bold"); 8 },
        p = {
          lines <- strwrap(b$text, chars(8.5))
          txt(paste(lines, collapse = "\n"), x, top, 8.5)
          length(lines) * pt_mm(8.5) * 1.2 + 3
        },
        bullets = {
          y <- 0
          for (item in b$text) {
            lines <- strwrap(item, chars(8.5) - 3)
            txt("•", x, top + y, 8.5)
            txt(paste(lines, collapse = "\n"), x + 3.5, top + y, 8.5)
            y <- y + length(lines) * pt_mm(8.5) * 1.2 + 1.5
          }
          y + 2
        },
        code = {
          lh <- pt_mm(7.5) * 1.25
          bh <- length(b$text) * lh + 3.5
          grid::grid.rect(x = grid::unit(x, "mm"), y = grid::unit(page_h - top, "mm"),
                          width = grid::unit(w, "mm"), height = grid::unit(bh, "mm"),
                          just = c("left", "top"),
                          gp = grid::gpar(fill = pal[["grauwert5"]], col = NA))
          txt(paste(b$text, collapse = "\n"), x + 2.5, top + 2, 7.5,
              col = pal[["dunkelgrau"]], fam = mono_family, lh = lh)
          bh + 3.5
        },
        table = {
          y <- 0
          for (i in seq_len(nrow(b$text))) {
            lines <- strwrap(b$text[i, 2], 62)
            rh <- max(length(lines), 1) * pt_mm(8) * 1.2 + 2.2
            if (i %% 2 == 1) {
              grid::grid.rect(x = grid::unit(x, "mm"), y = grid::unit(page_h - top - y, "mm"),
                              width = grid::unit(w, "mm"), height = grid::unit(rh, "mm"),
                              just = c("left", "top"),
                              gp = grid::gpar(fill = pal[["grauwert5"]], col = NA))
            }
            txt(b$text[i, 1], x + 2, top + y + 1.1, 7.5, col = pal[["dunkelgrau"]],
                fam = mono_family)
            txt(paste(lines, collapse = "\n"), x + 88, top + y + 1.1, 8)
            y <- y + rh
          }
          y + 4
        }
      )
      pos[cols] <- top + h
    }
  }
}

add(text_page(list(
  list(type = "title", text = "ggbfh", col = 0),
  list(type = "sub", text = "ggplot2-Theme und Farbpaletten im Stil der BFH", col = 0),
  list(type = "meta", col = 0, text = paste0(
    "Version ", packageVersion("ggbfh"), " · ", format(Sys.Date(), "%d.%m.%Y"),
    " · Oliver Lehmann")),
  list(type = "p", col = 0, text = paste(
    "ggbfh ist ein R-Paket, das ggplot2-Grafiken ein einheitliches Erscheinungsbild",
    "im Stil der BFH gibt. Die Farbwerte stammen aus dem BFH-Markenmanual, als Schrift",
    "wird Lucida Sans verwendet. Dieses Dokument zeigt auf den folgenden Seiten",
    "Beispielgrafiken für viele Diagrammtypen und Optionen.")),
  list(type = "h2", text = "Installation", col = 1),
  list(type = "code", col = 1, text = c(
    "install.packages(\"remotes\")",
    "remotes::install_github(\"ordeldoi/ggbfh\")",
    "install.packages(\"ragg\")  # für die Schrift")),
  list(type = "p", col = 1, text = paste(
    "Benötigt R ≥ 4.1 und ggplot2 ≥ 4.0. Damit Lucida Sans korrekt",
    "erscheint, in RStudio unter Tools › Global Options › General ›",
    "Graphics das Backend auf «AGG» stellen.")),
  list(type = "h2", text = "Verwendung", col = 2),
  list(type = "code", col = 2, text = c(
    "library(ggplot2)",
    "library(ggbfh)",
    "",
    "ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +",
    "  geom_point() +",
    "  labs(title = \"Verbrauch nach Gewicht\") +",
    "  theme_bfh()",
    "",
    "bfh_save(\"grafik.png\", width = 16, height = 10)  # cm")),
  list(type = "p", col = 2, text = paste(
    "theme_bfh() setzt die BFH-Standardpalette bereits als Vorgabe.",
    "scale_*_bfh() braucht es nur für andere Paletten."))
)))

add(text_page(list(
  list(type = "h2", text = "Funktionen", col = 0),
  list(type = "table", col = 0, text = rbind(
    c("theme_bfh(base_size, grid, legend_position)",
      "Das Theme. grid = \"y\", \"x\", \"xy\" oder \"none\"; base_size für Folien auf 14–16 erhöhen."),
    c("scale_fill_bfh() / scale_colour_bfh()",
      "Diskrete Skalen: \"standard\", \"gruen\", \"blau\", \"violett\", \"ocker\", \"rot\", \"highlight\"."),
    c("scale_fill_bfh_c() / scale_colour_bfh_c()",
      "Kontinuierliche Skalen: Farbfamilien oder \"divergierend\"."),
    c("bfh_colors",
      "Alle Farben als benannter Vektor, z.B. bfh_colors[\"dunkelblau\"]."),
    c("bfh_pal(), bfh_gradient(), bfh_tints()",
      "Farbvektoren für eigene Zwecke."),
    c("bfh_show_palettes(cvd = TRUE)",
      "Übersicht aller Paletten, optional mit Simulation von Farbsehschwächen."),
    c("bfh_save()",
      "Export als PNG, JPEG, TIFF oder PDF mit korrekter Schrift; Masse in cm.")
  )),
  list(type = "h2", text = "Hinweise", col = 0),
  list(type = "bullets", col = 0, text = c(
    paste("Die Standardpalette hat 8 Farben, ist aber nur bis ca. 5 Kategorien auch bei",
          "Farbsehschwächen gut unterscheidbar. Bei mehr Kategorien besser direkt",
          "beschriften oder gruppieren."),
    paste("Farbfamilien (\"blau\" usw.) werden bei mehr als 3 Kategorien automatisch",
          "erweitert. \"highlight\" passt zu einer logischen Variable: FALSE grau, TRUE orange."),
    "Geordnete Faktoren (ordered) erhalten automatisch die Farbfamilie Blau.",
    paste("In R Markdown / Quarto die Chunk-Option dev = \"ragg_png\" setzen; das",
          "Standard-PDF-Gerät pdf() kann Lucida Sans nicht verwenden und weicht auf",
          "Helvetica aus. PDF-Dateien mit bfh_save(\"datei.pdf\") erzeugen."),
    "Hilfe zu allen Funktionen: help(package = \"ggbfh\") bzw. ?theme_bfh."
  ))
)))


source("dev/gallery_plots.R", local = TRUE, encoding = "UTF-8")


# Ausgabe ----------------------------------------------------------------------

file <- "output/ggbfh_galerie.pdf"
grDevices::cairo_pdf(file, width = 22 / 2.54, height = 14 / 2.54, onefile = TRUE,
                     family = "Lucida Sans")
for (p in pages) {
  if (is.function(p)) p("Lucida Sans") else print(ggbfh:::with_family(p, "Lucida Sans"))
}
invisible(dev.off())
cat(length(pages), "Seiten geschrieben:", file, "\n")

# PNG-Vorschau jeder Seite (zur Kontrolle)
if (length(args <- commandArgs(TRUE)) && nzchar(args[1])) {
  dir.create(args[1], showWarnings = FALSE, recursive = TRUE)
  for (i in seq_along(pages)) {
    ragg::agg_png(file.path(args[1], sprintf("seite_%02d.png", i)),
                  width = 22, height = 14, units = "cm", res = 110)
    if (is.function(pages[[i]])) pages[[i]](bfh_font()) else print(pages[[i]])
    invisible(dev.off())
  }
}
