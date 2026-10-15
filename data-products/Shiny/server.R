library(shiny)
shinyServer(function(input,output,session){
 selected <- reactive({
  req(input$min_mag,input$max_depth)
  subset(datasets::quakes,mag>=input$min_mag & depth<=input$max_depth)
 })
 output$summary <- renderText({
  d<-selected()
  if(nrow(d)==0)return('No matching events. Reduce the minimum magnitude or increase the maximum depth.')
  sprintf('%d of 1000 events\nMedian magnitude: %.2f\nMean depth: %.1f km',nrow(d),median(d$mag),mean(d$depth))
 })
 output$depth_plot <- renderPlot({
  d<-selected();validate(need(nrow(d)>0,'No events match these filters.'))
  hist(d$depth,breaks=as.integer(input$bins),col='#24758b',border='white',xlab='Depth (km)',main='Depth distribution of selected events')
 })
 output$preview <- renderTable({head(selected(),15)},digits=2)
})
