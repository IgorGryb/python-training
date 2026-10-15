library(shiny)
shinyUI(fluidPage(
 titlePanel('Fiji earthquake sample explorer'),
 sidebarLayout(sidebarPanel(
  sliderInput('min_mag','Minimum magnitude',min=4,max=6.4,value=4,step=.1),
  sliderInput('max_depth','Maximum depth (km)',min=40,max=680,value=680,step=10),
  selectInput('bins','Histogram bins',choices=c(10,20,30),selected=20),
  helpText('Use the two sliders to filter historical events. The summary, histogram and first 15 matching rows update automatically.'),
  helpText('Reset to magnitude 4.0 and depth 680 km to see all 1,000 records. If no events match, widen the filters.')),
 mainPanel(
  h3('Selected events'),verbatimTextOutput('summary'),plotOutput('depth_plot'),tableOutput('preview'),
  h3('How to use this application'),
  p('Minimum magnitude keeps events at or above your chosen value. Maximum depth keeps events at or below your chosen depth. Histogram bins change only the chart resolution. Counts, median magnitude and mean depth are calculated from the selected records.'),
  p('The table shows only the first 15 matching records; the summary and histogram use all matches. Depth is in kilometres. These historical data are not a live earthquake feed, risk forecast or safety service.'),
  p('Source: R datasets::quakes; Harvard PRIM-H project / John Woodhouse. Created 15 October 2026. AI-assisted project draft.'),
  a('Dataset documentation',href='https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/quakes.html')
 ))))
