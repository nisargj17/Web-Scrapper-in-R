Articles = read.csv("Genome Biology and Evolution.txt",sep = "", header = FALSE, dec = ".", stringsAsFactors = F)

Arts = Articles$V1
for ( i in 1:length(Arts)) {
Arts[[i]] = strsplit(Arts[[i]], split=";; ")[1]
}
for ( i in 1:length(Arts)) {
  Arts[[i]] = Arts[[i]][[1]]
}
