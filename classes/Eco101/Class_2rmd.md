** KEEP THE EXTRAS at the end. makes it easer
---
title: "Econometrics 101 - Part I"
subtitle: "The Hardest Class You will have"  
author: 
  - "Fernando Rios-Avila"
date: '`r Sys.Date()`'
output:
  xaringan::moon_reader:
    css: xaringan-themer.css
    nature:
      slideNumberFormat: "%current%"
      highlightStyle: github
      highlightLines: true
      ratio: 16:9
      countIncrementalSlides: true
 
---

class: center, middle

# Are you afraid of numbers?


```{r xaringanExtra, echo=FALSE}
xaringanExtra::use_xaringan_extra(c("tile_view","editable",
                                    "share_again","scribble",
                                    "panelset","tachyons",
                                    "freezeframe","clipboard",
                                    "extra_styles"))
#xaringanExtra::use_logo(  image_url = "https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/xaringan.png")
```

```{r setup, include=FALSE}
options(htmltools.dir.version = FALSE)
knitr::opts_chunk$set(
  fig.width=9, fig.height=3.5, fig.retina=3,
  out.width = "100%",
  cache = FALSE,
  echo = TRUE,
  message = FALSE, 
  warning = FALSE,
  hiline = TRUE
)
```

```{r xaringan-themer, include=FALSE, warning=FALSE}
library(xaringanthemer)

style_duo_accent(primary_color = "#23395c", secondary_color = "#035AA6",
 colors = c(
  red = "#f34213",
  purple = "#3e2f5b",
  orange = "#ff8811",
  green = "#136f63",
  white = "#FFFFFF")
 )

code_font_google   = google_font("Fira Mono")

```

```{css echo=FALSE}
.title-slide {
  background-image: url(https://upload.wikimedia.org/wikipedia/commons/3/39/Naruto_Shiki_Fujin.svg);
  background-size: cover;
}
```
