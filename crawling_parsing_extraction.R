library(RCurl)
library(XML)


#year
Year_input <- 'https://academic.oup.com/gbe/issue-archive'
Year_html <-getURL(Year_input, followlocation=TRUE)
Year_doc <- htmlParse(Year_html, asText = TRUE)
Year_links <- xpathSApply(Year_doc, "//*[@id='main']/section/div/div/div/div/a",xmlAttrs,'href')
Year_URL <- paste('https://academic.oup.com',Year_links,sep='')

#issues
Issue_html<-getURL(Year_URL, followlocation=TRUE)
Issue_doc <- htmlParse(Issue_html, asText = TRUE)
Issue_links <- xpathSApply(Issue_doc, "//*[@id='item_ResourceLink']/a",xmlAttrs,'href')
Issue_names <- xpathSApply(Issue_doc, "//*[@id='item_ResourceLink']/a",xmlValue)
Issue_URL <- paste('https://academic.oup.com',Issue_links,sep='')

#Articles
Art_html<-getURL(Issue_URL, followlocation=T)
Art_doc <- htmlParse(Art_html, asText = T)
Art_links <- xpathSApply(Art_doc, "//*[@id='resourceTypeList-OUP_Issue']/div/section/div/div/div/h5/a",xmlAttrs,'href')
Art_URL <- paste('https://academic.oup.com',Art_links,sep='')

#get URL
filename<-as.character(seq(1,1960,1))
for(i in 9:500){
  download.file(Art_URL[i],filename[i])
}

#Parsing
myfiles<-list.files(pattern = "[0-9]+")
test_html<-list()
for (i in 1:length(myfiles)){
  test_html[[i]]<-htmlParse(myfiles[i])
}

#DOI
DOI <- lapply(test_html, xpathSApply, path="//div[@class='ww-citation-primary']/a/@href")

#save html 
DOInames <-  sub("https://doi.org/",'',DOI)
DOInames <- gsub('/',':',DOInames)
for (i in 1:length(test_html)){
  saveXML(test_html[[i]],file=paste0('/Users/nisargjoshi/Downloads/',DOInames[i],'.html'))
}


#Extraction

#Title
Title <- lapply(test_html, xpathSApply,path="//h1[@class='wi-article-title article-title-main']",xmlValue)
Title <- lapply(Title, function(x){gsub('\r\n|\r|\n|^ +| +$','',x)})

#Authors
Authors <- lapply(test_html,xpathSApply, path="//a[@class='linked-name']",xmlValue)
Authors <- lapply( Authors, function(x){paste(x, collapse=",")})

#Author Affiliations
Affiliations <- lapply(test_html, xpathSApply, path="//*[@id='authorInfo_OUP_ArticleTop_Info_Widget']/div[2]/div[1]",xmlValue)
Affiliations <- lapply( Affiliations, function(x){if(length(x)==0) 'NA' else paste(x,collapse=",")})

#Corresponding Authors
Corresponding <- lapply(test_html, xpathSApply, path='//*[@id="ContentColumn"]/div[2]/div[1]/div/div/div[1]/div/span[.//*[@class="info-author-correspondence"]]/a', xmlValue)
Corresponding <- lapply( Corresponding, function(x){if(length(x)==0) x='NA' else paste(x,collapse=",")})

#Corresponding Authors Email
Emails <- lapply(test_html, xpathSApply, path='//*[@id="ContentColumn"]/div[2]/div[1]/div/div/div[1]/div/span[.//*[@class="info-author-correspondence"]][1]/span/div/div[4]/a', xmlValue)
Emails <- lapply( Emails, function(x){if(length(x)==0) x='NA' else paste(x,collapse = ";")})

#Publication Date
PubDate <- lapply(test_html, xpathSApply, path="//div[@class='citation-date']",xmlValue)
PubDate <- lapply( PubDate, function(x){if(length(x)==0) x='NA' else x})

#Abstract
Abstract <- lapply(test_html, xpathSApply, path="//section[@class='abstract']/p", xmlValue)
Abstract <- lapply( Abstract, function(x){if(length(x)==0) x='NA' else paste(x,collapse = "\n")})

#Keywords
Keywords <- lapply(test_html, xpathSApply, path="//div[@class='kwd-group']/a", xmlValue)
Keywords <- lapply( Keywords, function(x){if(length(x)==0) x='NA' else paste(x, collapse=",")})

#Full Text
Full_Text <- lapply(test_html, xpathSApply, "//div[contains(@class,'widget-items')] | //div[contains(@class,'widget-items')]//p | //div[contains(@class,'section-title')]//p | /*//h2/following-sibling::p|/*//h3/following-sibling::p|/*//h2/following-sibling::div|/*//h3/following-sibling::div",xmlValue)
Full_Text <- lapply( Full_Text, function(x){if(length(x)==0) x='NA' else x})
Full_Text <- lapply(Full_Text, function(x){gsub('\r\n|\r|\n|^ +| +$',' ',x)})
Full_Text <- lapply(Full_Text, function(x){gsub(' +',' ',x)})
Full_Text <- lapply(Full_Text, function(x){paste(x, collapse="\n")})


df1 = list()
for( i in 1:length(DOI)) {
 df1[[i]] = list(toString(DOI[[i]]), toString(Title[[i]]), toString(Authors[[i]]), toString(Affiliations[[i]]), toString(Corresponding[[i]]), toString(Emails[[i]]), toString(PubDate[[i]]), toString(Abstract[[i]]),  toString(Keywords[[i]]),  toString(Full_Text[[i]]) )
}
df1 = lapply( df1, function(x){paste(x,collapse= ";;  ")})
write.table(df1, "Genome Biology and Evolution.txt", row.names=F, col.names=F, sep="\n")


