## parameters
targetUrl <- "https://en-marche.fr/articles"
rootUrl <- "https://en-marche.fr"
pagerParameter <- "/tout/"
nPagesTarget <- 30

## waiting function

randompause <- function(){
    Sys.sleep(runif(1,2,5))
}

## links retrieval
library(rvest)
library(stringr)

articleLinks <- data.frame(title = character(),link=character())
titlesCss <- "article.l__wrapper--narrow h2"
linksCss <- "article.l__wrapper--narrow h2 > a"

randompause()
linksPage <- read_html(targetUrl)
titles <- html_text(html_nodes(linksPage,titlesCss))
titles <- str_replace_all(titles,"\\n","")
titles <- str_replace_all(titles,"\\s+"," ")
links <- html_attrs(html_nodes(linksPage,linksCss))
articleLinks <- rbind(articleLinks,cbind(titles,links))

for(i in 2:nPagesTarget){
    randompause()
    linksPage <- read_html(paste0(targetUrl,pagerParameter,i))
    titles <- html_text(html_nodes(linksPage,titlesCss))
    titles <- str_replace_all(titles,"\\n","")
    titles <- str_replace_all(titles,"\\s+"," ")
    links <- html_attrs(html_nodes(linksPage,linksCss))
    articleLinks <- rbind(articleLinks,cbind(titles,links))
}
articleLinks$titles <- unlist(articleLinks$titles)
articleLinks$links <- unlist(articleLinks$links)
articleLinks$links <- paste0(rootUrl,articleLinks$links)
write.csv(articleLinks,file="lrmArticles.csv",row.names = FALSE)

## articles retrieval
articleContentCss <- "article > p"
dateCss <- "h2.text--gray"
titleCss <- "h1"

articles <- data.frame(title = character(),date=character(),content=character())

for(i in 73:length(articleLinks$links)){
    print(paste("article",i,"on",length(articleLinks$links)))
    randompause()
    articlePage <- read_html(articleLinks$links[i])
    articleTitle <- html_text(html_node(articlePage,titleCss))
    articleTitle <- str_replace_all(articleTitle,"\\n","")
    articleDate <- html_text(html_node(articlePage,dateCss))
    articleDate <- str_extract(articleDate,"[0-9]*.[aA-zZ]*.[0-9]*")
    articleContent <- html_text(html_nodes(articlePage,articleContentCss))
    articleContent <- paste(articleContent,collapse = " ")
    articles <- rbind.data.frame(articles,cbind(articleTitle,articleDate,articleContent),stringsAsFactors = FALSE)
}
write.csv(articles,file="articlesLRM.csv",row.names = FALSE)
articlesLRM <- articles
save(articlesLRM,file="articlesLRM.Rdata")
