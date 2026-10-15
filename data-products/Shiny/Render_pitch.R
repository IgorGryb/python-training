library(slidify)
# Slidify 0.5 calls markdownExtensions(), removed from modern markdown.
# Preserve Slidify's renderer while adapting its Markdown-to-HTML helper.
assignInNamespace('md2html', function(md) markdown::markdownToHTML(text=md,fragment.only=TRUE), ns='slidify')
slidify::slidify('Pitch.Rmd')
