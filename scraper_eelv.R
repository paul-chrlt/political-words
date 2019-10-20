## parameters
targetUrl <- "https://eelv.fr/categories/actu/"
pagerParameter <- "page/"
nPagesTarget <- 5

## waiting function

randompause <- function(){
    Sys.sleep(runif(1,2,5))
}

## links retrieval
library(rvest)
articleLinks <- data.frame(title = character(),link=character())
titlesCss <- ".content-gutter h2"
linksCss <- ".content-gutter h2 > a"

randompause()
linksPage <- read_html(targetUrl)
titles <- html_text(html_nodes(linksPage,titlesCss))[1:10]
links <- html_attrs(html_nodes(linksPage,linksCss))
articleLinks <- rbind(articleLinks,cbind(titles,links))

for(i in 2:nPagesTarget){
    randompause()
    linksPage <- read_html(paste0(targetUrl,pagerParameter,i))
    titles <- html_text(html_nodes(linksPage,titlesCss))[1:10]
    links <- html_attrs(html_nodes(linksPage,linksCss))
    articleLinks <- rbind(articleLinks,cbind(titles,links))
}
articleLinks$titles <- unlist(articleLinks$titles)
articleLinks$links <- unlist(articleLinks$links)
write.csv(articleLinks,file="eelvArticles.csv",row.names = FALSE)

## articles retrieval
library(stringr)
articleContentCss <- ".entry-content-container > p"
dateCss <- ".entry-date"
titleCss <- "h1 span"

articles <- data.frame(title = character(),date=character(),content=character())

for(i in 1:length(articleLinks$links)){
    print(paste("article",i,"on",length(articleLinks$links)))
    randompause()
    articlePage <- read_html(articleLinks$links[i])
    articleTitle <- html_text(html_node(articlePage,titleCss))
    articleDate <- html_text(html_node(articlePage,dateCss))
    articleContent <- html_text(html_nodes(articlePage,articleContentCss))
    articleContent <- paste(articleContent,collapse = " ")
    articles <- rbind.data.frame(articles,cbind(articleTitle,articleDate,articleContent),stringsAsFactors = FALSE)
}
write.csv(articles,file="articlesEELV.csv",row.names = FALSE)
articlesEELV <- articles
save(articlesRN,file="articlesEELV.Rdata")


.entry-content-container > p
