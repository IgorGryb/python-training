---
title: Fiji earthquake sample explorer
subtitle: An interactive Shiny teaching application
author: Igor Grybek — AI-assisted draft
date: 15 October 2026
framework: io2012
highlighter: highlight.js
hitheme: tomorrow
mode: selfcontained
onefile: true
knit: slidify::knit2slides
---

## Explore a historical sample without writing code

- A table of 1,000 events is difficult to explore quickly.
- Filter magnitude and depth, then inspect the remaining observations.
- This application makes its calculations and limitations visible.

---

## Simple controls, reactive results

- Set minimum magnitude and maximum depth with the sliders.
- Change the histogram bin count to inspect the depth distribution.
- `server.R` filters the data and calculates the event count, median magnitude and mean depth.
- The summary, histogram and first 15 table rows update together.

---

## A reproducible R calculation


``` r
d <- subset(datasets::quakes, mag >= 5 & depth <= 300)
data.frame(events=nrow(d), median_magnitude=median(d$mag),
           mean_depth_km=round(mean(d$depth),1))
```

```
##   events median_magnitude mean_depth_km
## 1    127              5.2         110.2
```

The app uses the same filtering rule with values supplied by the sliders.

---

## Try it and interpret responsibly

- Start at magnitude 4.0 and depth 680 km to show all 1,000 records.
- Raise the magnitude threshold and compare the summary and histogram.
- Instructions and data documentation are included on the app.
- Historical teaching data; no live monitoring or earthquake forecast.
- [Open the app](https://igorgryb.shinyapps.io/fiji-earthquake-explorer/) · [Source code](https://github.com/IgorGryb/python-training/tree/gh-pages/data-products/Shiny)
- Source: R `datasets::quakes`, Harvard PRIM-H / John Woodhouse.
