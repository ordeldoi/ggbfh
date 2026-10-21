# Galerie für GitHub: rendert jede Grafik aus dev/gallery_plots.R als PNG nach
# galerie/ und schreibt GALERIE.md mit Bild und Code. Ausführen im Projektordner:
#   Rscript dev/gallery_md.R
library(ggplot2)
library(ggbfh)

src <- "dev/gallery_plots.R"
lines <- readLines(src, encoding = "UTF-8")
exprs <- parse(src, keep.source = TRUE, encoding = "UTF-8")
refs <- attr(exprs, "srcref")
heads <- grep("^# [0-9]+ .* -+$", lines)
head_text <- sub("^# [0-9]+ (.*) -+$", "\\1", lines[heads])

dir.create("galerie", showWarnings = FALSE)
unlink(list.files("galerie", pattern = "\\.png$", full.names = TRUE))

md <- c("# Galerie",
        "",
        "Beispielgrafiken mit `theme_bfh()` und den BFH-Farbskalen, alle mit",
        "R-Standarddatensätzen. Unter jeder Grafik lässt sich der Code aufklappen.",
        "Zurück zum [README](README.md).")

env <- new.env()
block <- character()   # Datenaufbereitung für die nächste(n) Grafik(en)
block_vars <- character()
after_plot <- TRUE
section <- 0
n <- 0

for (i in seq_along(exprs)) {
  e <- exprs[[i]]
  txt <- as.character(refs[[i]])

  if (!(is.call(e) && identical(e[[1]], as.name("add")))) {
    eval(e, env)
    # Neue Zuweisung an eine Variable nach einer Grafik beginnt einen neuen Block,
    # Änderungen wie d$x <- ... ergänzen den bestehenden
    if (after_plot && is.call(e) && identical(e[[1]], as.name("<-")) && is.name(e[[2]])) {
      block <- character()
      block_vars <- character()
    }
    block <- c(block, txt)
    block_vars <- c(block_vars, all.names(e[[2]])[1])
    after_plot <- FALSE
    next
  }

  after_plot <- TRUE
  n <- n + 1
  s <- max(c(0, which(heads < refs[[i]][1])))
  if (s > section) {
    section <- s
    md <- c(md, "", paste("##", head_text[s]))
  }

  p <- eval(e[[2]], env)
  file <- sprintf("galerie/%02d.png", n)
  ragg::agg_png(file, width = 22, height = 14, units = "cm", res = 120)
  print(p)
  invisible(dev.off())

  # Code ohne add( ... ), Daten nur, wenn die Grafik sie verwendet
  code <- txt
  code[1] <- sub("^add\\(", "", code[1])
  code[length(code)] <- sub("\\)$", "", code[length(code)])
  if (any(block_vars %in% all.names(e))) code <- c(block, "", code)

  title <- p$labels$title
  if (is.null(title)) title <- "Palettenübersicht"
  md <- c(md, "", paste("###", title), "", sprintf("![%s](%s)", title, file), "",
          "<details><summary>Code</summary>", "", "```r", code, "```", "", "</details>")
}

writeLines(enc2utf8(md), "GALERIE.md", useBytes = TRUE)
cat(n, "Grafiken geschrieben: GALERIE.md, galerie/\n")
