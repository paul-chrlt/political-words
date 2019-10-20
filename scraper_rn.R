## parameters
targetUrl <- "https://rassemblementnational.fr/actualites/"
pagerParameter <- "page/"
nPagesTarget <- 5

## waiting function

randompause <- function(){
    Sys.sleep(runif(1,2,5))
}

## links retrieval
library(rvest)
articleLinks <- data.frame(title = character(),link=character())
titlesCss <- ".entry-title"
linksCss <- ".entry-title > a"

randompause()
linksPage <- read_html(targetUrl)
titles <- html_text(html_nodes(linksPage,titlesCss))
links <- html_attrs(html_nodes(linksPage,linksCss))
articleLinks <- rbind(articleLinks,cbind(titles,links))

for(i in 2:nPagesTarget){
    randompause()
    linksPage <- read_html(paste0(targetUrl,pagerParameter,i))
    titles <- html_text(html_nodes(linksPage,titlesCss))
    links <- html_attrs(html_nodes(linksPage,linksCss))
    articleLinks <- rbind(articleLinks,cbind(titles,links))
}
articleLinks$titles <- unlist(articleLinks$titles)
articleLinks$links <- unlist(articleLinks$links)
write.csv(articleLinks,file="rnArticles.csv",row.names = FALSE)

## articles retrieval
library(stringr)
articleContentCss <- ".post-content"
dateCss <- ".fusion-meta-info-wrapper > span:nth-child(4)"
titleCss <- "h1"

articles <- data.frame(title = character(),date=character(),content=character())

for(i in 1:length(articleLinks$links)){
    print(paste("article",i,"on",length(articleLinks$links)))
    randompause()
    articlePage <- read_html(articleLinks$links[i])
    articleTitle <- html_text(html_node(articlePage,titleCss))
    articleDate <- html_text(html_node(articlePage,dateCss))
    articleContent <- html_text(html_node(articlePage,articleContentCss))
    articleContent <- str_replace_all(articleContent,"\\n","")
    articleContent <- str_replace_all(articleContent,"\\t","")
    articles <- rbind.data.frame(articles,cbind(articleTitle,articleDate,articleContent),stringsAsFactors = FALSE)
}
write.csv(articles,file="articlesRN.csv",row.names = FALSE)
articlesRN <- articles
save(articlesRN,file="articlesRN.Rdata")
