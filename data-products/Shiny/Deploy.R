# Run after authorizing rsconnect with your own shinyapps.io account.
# Only these two app files are sent to hosting.
rsconnect::deployApp(appDir=normalizePath('.'), appFiles=c('ui.R','server.R'),
  appName='fiji-earthquake-explorer', appTitle='Fiji earthquake sample explorer',
  account='igorgryb', server='shinyapps.io', launch.browser=FALSE)
