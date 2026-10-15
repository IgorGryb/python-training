library(slidify)
# Slidify 0.5 calls markdownExtensions(), removed from modern markdown.
# Preserve Slidify's renderer while adapting its Markdown-to-HTML helper.
assignInNamespace('md2html', function(md) markdown::markdownToHTML(text=md,fragment.only=TRUE), ns='slidify')
slidify::slidify('Pitch.Rmd')

# Upgrade legacy Slidify asset URLs for HTTPS hosting.
p <- readLines('Pitch.html', warn=FALSE)
p <- gsub('http://ajax.aspnetcdn.com','https://ajax.aspnetcdn.com',p,fixed=TRUE)
p <- gsub('http://ajax.googleapis.com','https://ajax.googleapis.com',p,fixed=TRUE)
writeLines(p,'Pitch.html')
f <- 'libraries/frameworks/io2012/css/slidify.css'
s <- readLines(f,warn=FALSE)
writeLines(gsub('http://fonts.googleapis.com','https://fonts.googleapis.com',s,fixed=TRUE),f)
