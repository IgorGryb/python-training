library(shiny)
server <- source('server.R')$value
shiny::testServer(server, {
 session$setInputs(min_mag=4,max_depth=680,bins='20')
 stopifnot(nrow(selected())==1000L,grepl('1000 of 1000',output$summary))
 session$setInputs(min_mag=5,max_depth=300)
 stopifnot(nrow(selected())==127L,grepl('Median magnitude: 5.20',output$summary),grepl('Mean depth: 110.2',output$summary))
 session$setInputs(min_mag=6.4,max_depth=40)
 stopifnot(nrow(selected())==0L,grepl('No matching events',output$summary))
})
cat('PASS: default 1000 records, filtered 127 / median 5.20 / mean depth 110.2, empty result handling\n')
sessionInfo()
