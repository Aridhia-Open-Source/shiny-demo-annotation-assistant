xap.require(
  "rJava",
  "qdap",
  "shiny",
  "tm",
  "stringdist",
  "RWeka",
  "stringr",
  "IRanges",
  "qdap",
  "data.table"
)


if(exists("xap.conn")) {
  workspace_home <- "~"
} else {
  workspace_home <- workspace_path()
}


split_str_by_index <- function(target, index) {
  index <- sort(index)
  substr(rep(target, length(index) + 1),
         start = c(1, index),
         stop = c(index -1, nchar(target)))
}

interleave <- function(v1,v2)
{
  ord1 <- 2*(1:length(v1))-1
  ord2 <- 2*(1:length(v2))
  c(v1,v2)[order(c(ord1,ord2))]
}

insert_str <- function(target, insert, index) {
  insert <- insert[order(index)]
  index <- sort(index)
  paste(interleave(split_str_by_index(target, index), insert), collapse="")
}

getPositions <- function( Terms, Text, drop=TRUE) {
  #positions <- aregexec(Terms, Text,  max.distance = 0.1, fixed = TRUE, ignore.case = TRUE)
  p <-data.frame(data.frame(str_locate_all(Text,Terms)))
  if (nrow(p)<1) {
  }
  else {
    p$terms <- Terms
    return(p)
  }
}  

getPositions_sent <- function(Terms, Text, drop = TRUE) {
  positions <- aregexec(Terms, Text,  max.distance = 0.1, fixed = TRUE)
  
  
  r<- data.frame(ss=as.numeric(0), se=as.numeric(0))
  r$ss<-  unlist(positions[1])
  r$se <-  as.integer(positions[1])+as.integer(nchar(Terms))
  r
}  


ClosestMatch2 = function(dataframe, stringVector){
  string <- as.character(dataframe[[3]])
  vector <- as.vector(stringVector[[1]])
  vector[amatch(string, vector, maxDist=1)]
}



#Tokenizer element
WordGrammTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 4))