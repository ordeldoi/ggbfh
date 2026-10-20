#' Diskrete BFH-Farbskalen
#'
#' @param palette Name einer Palette aus [bfh_palettes].
#' @param reverse Reihenfolge umkehren.
#' @param ... Weitere Argumente für [ggplot2::discrete_scale()], z.B. `name`
#'   oder `labels`.
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(factor(gear), fill = factor(cyl))) +
#'   geom_bar() +
#'   scale_fill_bfh("blau")
#' @export
scale_colour_bfh <- function(palette = "standard", reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    "colour", palette = function(n) bfh_pal(palette, n, reverse), ...
  )
}

#' @rdname scale_colour_bfh
#' @export
scale_color_bfh <- scale_colour_bfh

#' @rdname scale_colour_bfh
#' @export
scale_fill_bfh <- function(palette = "standard", reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    "fill", palette = function(n) bfh_pal(palette, n, reverse), ...
  )
}

#' Kontinuierliche BFH-Farbskalen
#'
#' @param palette Name eines Verlaufs aus [bfh_gradients].
#' @param reverse Richtung umkehren.
#' @param ... Weitere Argumente für [ggplot2::continuous_scale()], z.B.
#'   `name`, `limits` oder `labels`.
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg, colour = hp)) +
#'   geom_point() +
#'   scale_colour_bfh_c("gruen")
#' @export
scale_colour_bfh_c <- function(palette = "blau", reverse = FALSE, ...) {
  ggplot2::continuous_scale(
    "colour", palette = scales::pal_gradient_n(bfh_gradient(palette, 7, reverse)),
    guide = "colourbar", ...
  )
}

#' @rdname scale_colour_bfh_c
#' @export
scale_color_bfh_c <- scale_colour_bfh_c

#' @rdname scale_colour_bfh_c
#' @export
scale_fill_bfh_c <- function(palette = "blau", reverse = FALSE, ...) {
  ggplot2::continuous_scale(
    "fill", palette = scales::pal_gradient_n(bfh_gradient(palette, 7, reverse)),
    guide = "colourbar", ...
  )
}
