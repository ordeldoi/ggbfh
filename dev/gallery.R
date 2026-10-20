# Testgalerie für ggbfh mit R-Standarddatensätzen (Paket datasets).
# Ausführen im Projektordner nach Installation:  R CMD INSTALL .
library(ggplot2)
library(ggbfh)

dir.create("output", showWarnings = FALSE)
unlink(list.files("output", pattern = "^g\\d", full.names = TRUE))
cat("Schrift:", bfh_font(), "\n")

# 1 Balken, eine Farbe: chickwts
d1 <- aggregate(weight ~ feed, chickwts, mean)
p1 <- ggplot(d1, aes(reorder(feed, -weight), weight)) +
  geom_col(width = 0.7) +
  labs(title = "Gewicht von Küken nach Futter",
       subtitle = "Mittleres Gewicht nach 6 Wochen in g",
       x = NULL, y = NULL, caption = "Quelle: datasets::chickwts") +
  theme_bfh()
bfh_save("output/g1_balken.png", p1, width = 16, height = 10)

# 2 Gruppierte Balken, Standardpalette: HairEyeColor
d2 <- aggregate(Freq ~ Hair + Eye, as.data.frame(HairEyeColor), sum)
p2 <- ggplot(d2, aes(Hair, Freq, fill = Eye)) +
  geom_col(position = position_dodge(width = 0.85), width = 0.8) +
  labs(title = "Haar- und Augenfarbe", subtitle = "Anzahl Studierende",
       x = "Haarfarbe", y = NULL, fill = "Augenfarbe",
       caption = "Quelle: datasets::HairEyeColor") +
  theme_bfh()
bfh_save("output/g2_gruppiert.png", p2, width = 16, height = 10)

# 3 Liniendiagramm: Orange
d3 <- Orange
d3$Tree <- factor(as.character(d3$Tree))  # ungeordnet -> Standardpalette
p3 <- ggplot(d3, aes(age, circumference, colour = Tree)) +
  geom_line() +
  labs(title = "Wachstum von Orangenbäumen", subtitle = "Stammumfang in mm",
       x = "Alter (Tage)", y = NULL, colour = "Baum",
       caption = "Quelle: datasets::Orange") +
  theme_bfh()
bfh_save("output/g3_linien.png", p3, width = 16, height = 10)

# 4 Streudiagramm mit Glättung, Facetten: iris
p4 <- ggplot(iris, aes(Sepal.Length, Petal.Length)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x) +
  facet_wrap(~Species) +
  labs(title = "Kelch- und Kronblattlänge",
       subtitle = "Punkte in Schriftgrau, Regressionsgerade in BFH-Orange",
       x = "Kelchblattlänge (cm)", y = "Kronblattlänge (cm)",
       caption = "Quelle: datasets::iris") +
  theme_bfh(grid = "xy")
bfh_save("output/g4_streu_facetten.png", p4, width = 16, height = 9)

# 5 Streudiagramm mit Farbgruppen: mtcars
p5 <- ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
  geom_point() +
  labs(title = "Verbrauch nach Gewicht", x = "Gewicht (1000 lbs)",
       y = "Meilen pro Gallone", colour = "Zylinder",
       caption = "Quelle: datasets::mtcars") +
  theme_bfh(grid = "xy")
bfh_save("output/g5_streu_farben.png", p5, width = 16, height = 10)

# 6 Kontinuierliche Skala: volcano
d6 <- data.frame(x = rep(seq_len(nrow(volcano)), ncol(volcano)),
                 y = rep(seq_len(ncol(volcano)), each = nrow(volcano)),
                 hoehe = as.vector(volcano))
p6 <- ggplot(d6, aes(x, y, fill = hoehe)) +
  geom_raster() +
  coord_fixed(expand = FALSE) +
  labs(title = "Maunga Whau", subtitle = "Kontinuierliche Skala (Standard: Verlauf Blau)",
       x = NULL, y = NULL, fill = "Höhe (m)", caption = "Quelle: datasets::volcano") +
  theme_bfh(grid = "none", legend_position = "right") +
  theme(axis.text = element_blank())
bfh_save("output/g6_kontinuierlich.png", p6, width = 16, height = 11)

# 7 Divergierende Skala: Korrelationen mtcars
cm <- cor(mtcars)
d7 <- data.frame(x = rep(colnames(cm), each = nrow(cm)),
                 y = rep(rownames(cm), ncol(cm)), r = as.vector(cm))
d7$x <- factor(d7$x, levels = colnames(cm))
d7$y <- factor(d7$y, levels = rev(rownames(cm)))
p7 <- ggplot(d7, aes(x, y, fill = r)) +
  geom_tile() +
  scale_fill_bfh_c("divergierend", limits = c(-1, 1)) +
  coord_fixed() +
  labs(title = "Korrelationen", subtitle = "Divergierende Skala",
       x = NULL, y = NULL, fill = "r", caption = "Quelle: datasets::mtcars") +
  theme_bfh(grid = "none", legend_position = "right")
bfh_save("output/g7_divergierend.png", p7, width = 16, height = 13)

# 8 Highlight: mtcars
d8 <- head(mtcars[order(-mtcars$mpg), ], 10)
d8$auto <- rownames(d8)
d8$fokus <- d8$auto == "Honda Civic"
p8 <- ggplot(d8, aes(mpg, reorder(auto, mpg), fill = fokus)) +
  geom_col(width = 0.7) +
  scale_fill_bfh("highlight", guide = "none") +
  labs(title = "Die 10 sparsamsten Autos", subtitle = "Honda Civic hervorgehoben",
       x = "Meilen pro Gallone", y = NULL, caption = "Quelle: datasets::mtcars") +
  theme_bfh(grid = "x")
bfh_save("output/g8_highlight.png", p8, width = 16, height = 10)

# 9 Farbfamilie, gestapelt (4 Stufen -> Aufhellung): esoph
d9 <- aggregate(ncases ~ agegp + alcgp, esoph, sum)
p9 <- ggplot(d9, aes(agegp, ncases, fill = alcgp)) +
  geom_col(width = 0.7) +
  scale_fill_bfh("gruen", reverse = TRUE) +
  labs(title = "Speiseröhrenkrebs nach Alter", subtitle = "Farbfamilie Grün, 4 Stufen",
       x = "Altersgruppe", y = "Fälle", fill = "Alkohol (g/Tag)",
       caption = "Quelle: datasets::esoph") +
  theme_bfh()
bfh_save("output/g9_familie.png", p9, width = 16, height = 10)

# 10 Palettenübersicht
bfh_save("output/g10_paletten.png", bfh_show_palettes(cvd = TRUE), width = 20, height = 16)

# PDF-Export
bfh_save("output/g2_gruppiert.pdf", p2, width = 16, height = 10)
