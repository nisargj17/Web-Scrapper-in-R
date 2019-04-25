How to run:
1. Run the commands in script "Crawler.r" for downloading all articles to .html files.
2. Run the commands in script "Parser.r" for extracting specific information from each article and store data into a .txt file.

Scripts details:
Crawler.r:
in this script, we first install and load the package "Rcurl" and "XML"(line 1-3), then initialize a variable "Year_input" to store a link which we will be using for this project.
We initialize an another variable "Year_URL" which is a vector to extract the number of years of issue.
We create a "filename" to save downloaded .html files.
We are looping all .html pages and downloading all URLs.
We generate the url that we finally need to crawl from by combining the numbers we got from the last line and 'https://academic.oup.com/dnaresearch/issue/'.

Parser.r:
In this script, we are extracting every required fields using "lapply" method and pasting in text file and if field is empty then we print "NA" in the text file. We are saving every field information on a data frame "df1" and then writing these information directly to a text file called "Genome Biology and Evolution.txt". 