
server <- function(input, output, session) {
  
  lab <- reactive(withProgress(message = "Loading Annotations", {
 	  labels <- read.csv(paste0(workspace_home, "/datafiles/annotation_assistant_datafiles/labels.csv"))
  }))
  
  file_input <- reactive({
    paste0(workspace_home, "/datafiles/annotation_assistant_datafiles/", input$files)
  })
  
 # Read and pre-process files
  readText <- reactive(withProgress(message = "Reading file...", value = 0, {
    txt <- paste(str_trim(readLines(file_input())), collapse = " ")
    
    # Strip truncation
    txt <- gsub("[\r\n]", " ", txt)
    txt <- gsub("\\s+", " ", txt)
    txt <- gsub("\\s+\\.", ".", txt)    
    txt2 <- as.character(unlist(paste(list(txt), sep = "")))
  }))
  
  # Extract Name, DOB, Exam type
  patientInfo <- reactive(withProgress(message = "Extracting Patient info...", value = 0, {
    #txt <- readText()
    #name <- trimws(as.character(genXtract(txt, 'PATIENT: ', 'DOB:', with = FALSE)))[1]
    #dob <- trimws(as.character(genXtract(txt, 'DOB: ', 'FILE', with = FALSE)))[1]
    #exam <- trimws(as.character(genXtract(txt, 'EXAM: ', 'DATE:', with = FALSE)))[1]
    #df <- data.frame(c(name,dob,exam), row.names = c('Name','DOB','Exam'))
    
    #colnames(df) <- NULL
    #df
    dat <- switch(input$files,
                  "brain-mri-sample-report-1.txt" = c("pat_001", "Gandalf", "Brain MRI"),
                  "neck-mri-with-andwithout-contrast-sample-report-1.txt" = c("pat_002", "Aragorn", "Neck MRI"),
                  "pituitary-mri-with-and-without-contrast-sample-report-1.txt" = c("pat_003", "Legolas", "Pituitary MRI"),
                  "thoracic-spine-mri-without-contrast-sample-report-1.txt" = c("pat_004", "Gimli", "Thoratic-spine MRI")
    )
    df <- data.frame(dat, row.names = c("Patient ID: ", "Name: ", "Exam: "))
    colnames(df) <- NULL
    df
  }))

  # Extract findings from free text 
  findingsInfo <- reactive(withProgress(message = "Processing text...", value = 0, {
    txt <- readText()
    txt2 <- gsub(".*FINDINGS\\s*|IMPRESSION.*", "", txt)
    txt <- gsub("[\r\n | | | |, ]", " ", txt2)
    txt <- gsub("Page 2 of 2", " ", txt)
    s <- c("Report approved on    NationalRad | Headquartered: Florida | Diagnostic Imaging Services: Nationwide | 877.734.6674 | www.NationalRad.com" )
    txt <- gsub(s, " ", txt) 
  }))
  
  # Generate match table
  matchTable <- eventReactive(readText(), withProgress(message = "Finding matches...", value = 0, {
    txt <- findingsInfo()
    labels <- lab()
    paperCorp <- VCorpus(VectorSource(txt))
    
    # Process text 
    paperCorp <- tm_map(paperCorp, removePunctuation)
    paperCorp <- tm_map(paperCorp, removeNumbers)
    paperCorp <- tm_map(paperCorp, stripWhitespace)
    
    # Create Document Term Matrix 
    # Use N-Gram tokenizer
    opinions.tdm <- DocumentTermMatrix(paperCorp, control = list(tokenize = WordGrammTokenizer))
    df <- data.frame(terms=opinions.tdm[[6]]$Terms)
    
    # Obtain original position for matched all N-gramm terns terms
    names_list <- apply(df,1,FUN = getPositions,Text = tolower(txt))
    df_filter <- do.call(rbind.data.frame, names_list)
    colnames(labels) <- c('match','class')
    #levels(labels$match) <- levels(labels$match))
    
    # Now fuzzy match terms
    df_filter$match <- apply(df_filter, 1, FUN = ClosestMatch2, stringVector = labels)
    df_filter <- merge(df_filter, labels, by = "match")
    
    # Remove overlapping terms
    ranges <- df_filter[, c("start", "end")]
    ir <- data.frame(reduce(IRanges(ranges$start, ranges$end)))[, c("start", "end")]
    
    df_filter[which(df_filter$start %in% ir$start | df_filter$end %in% ir$end), ]
  }))
  
  # Look up tables per class
  pathology <- reactive({
    mt <- matchTable()
    mt[mt$class == "Pathology", ]
  })
  
  aLoc <- reactive({
    mt <- matchTable()
    mt[mt$class == "Anatomical Location", ]
  })
  
  laterality<- reactive({
    mt <- matchTable()
    mt[mt$class == "Laterality", ]
  })
  
  negation<- reactive({
    mt <- matchTable()
    mt[mt$class == 'Negation', ]
  })
  
  imaging<- reactive({
    mt <- matchTable()
    mt[mt$class == "Imaging technique", ]
  })
  
  annotated_vec <- function(table, class, selected) {
    if(!(class %in% selected)) {
      return(NULL)
    }
    s <- table$start
    e <- table$end + 1
    col <- paste0('<span class="', class, '">')
    list(rep(col, length(s)), s)
  }
  
  annotatedFile <- reactive(withProgress(message = "Annotating report...", value = 0, {
    txt <- findingsInfo()
    m <- matchTable()
    starts <- m$start
    ends <- m$end + 1

    pat_vec <- annotated_vec(pathology(), "pathology", input$radio)
    loc_vec <- annotated_vec(aLoc(), "location", input$radio)
    lat_vec <- annotated_vec(laterality(), "laterality", input$radio)
    neg_vec <- annotated_vec(negation(), "negation", input$radio)
    im_vec <- annotated_vec(imaging(), "imaging", input$radio)
    
    insert_str(
      txt, 
      insert = c(pat_vec[[1]], loc_vec[[1]], lat_vec[[1]], neg_vec[[1]], im_vec[[1]], rep("</span>", length(ends))),
      index = c(pat_vec[[2]], loc_vec[[2]], lat_vec[[2]], neg_vec[[2]], im_vec[[2]], ends)
    )
  }))
  
  #Removing negated terms
  negSent <- reactive({
    txt <- tolower(findingsInfo())
    
    sentList <- sent_detect(txt, endmarks = ".")
    x <- sentList[lapply(sentList, nchar) > 10]
    
    out <- unlist(lapply(strsplit(x, "without"), "[", 1))
    arg <- lapply(out, FUN = tolower)
    positions <- lapply(arg, FUN = getPositions_sent, Text = txt)

    df <- data.frame(matrix(unlist(positions), nrow = length(positions), 
                            byrow = T), stringsAsFactors = FALSE)
    colnames(df) <- c("sentStart", "sentEnd")
    df[df$sentStart > 0, ]
  })
  
  removeNegations <- function(sentRange, negations) {
    starts <- negations$start
    ends <- negations$end
    if(any(sentRange["sentStart"] <= starts & sentRange["sentEnd"] >= ends)) {
      return(1)
    }
    return(0)
  }

  observedPathology <- function(pathology, filteredSent) {
    starts <- filteredSent$sentStart
    ends <- filteredSent$sentEnd
    
    if(any(pathology["start"] >= starts & pathology["end"] <= ends)) {
      return(1)
    }   
    return(0)
  }
  
  removeNeg <- reactive({
    sentRange <- negSent()
    negRange <- negation()[, c("start", "end")]
    sentRange$neg <- apply(sentRange, 1, FUN = removeNegations, negations = negRange)
    filteredSent <- sentRange[sentRange$neg != 1, c("sentStart", "sentEnd")]

    pat <- pathology()
    loc <- aLoc()
    pat$neg<- apply(pat, 1, FUN = observedPathology, filteredSent = filteredSent)
    loc$neg<- apply(loc, 1, FUN = observedPathology, filteredSent = filteredSent)
    
    pat <- pat[pat$neg == 1, "terms"]
    head(pat[!duplicated(pat)], 10)
  })
  
  # Write keywords
  observe({
    df <- data.frame(phrase = input$mydata[1], class = input$mydata[2], row.names = NULL)
    colnames(df) <- NULL

    write.table(df, paste0(workspace_home, "/datafiles/annotation_assistant_datafiles/labels.csv"), row.names = FALSE, append = TRUE, sep = ",")
  })
  
  writeTable <- function (df, tablename) {
    dbWriteTable(xap.conn, c(xap.db.sandbox, tablename), as.data.frame(df), 
                 row.names = F, overwrite = F, append = TRUE)
  }
  
  onoClick <- observeEvent(input$writeDB, {
    i <- input$writeDB
    if (i < 1) {
      return()
    }

    tableName <- "radiology_text_findings"
    pat <- t(patientInfo())
    
    output <- removeNeg()
    output <- c(output, rep(NA, 10 - length(output)))
    
    df <- data.frame(t(output))
    colnames(df) <- paste0("Pathology", 1:10)
    
    df2 <- cbind(pat, df)
  	withProgress(message = paste("Exporting to ", tableName, "...") , value = 0, 
  	  writeTable(df2, tableName)
  	)
  })
  
  ### Outputs ###
  output$patient <- renderTable(patientInfo(), rownames = TRUE)
  
  output$text <- renderUI({
    txt <- paste(annotatedFile())
    #cat(file = stderr(), txt, "\n")
    str1 <- p(HTML(txt))
  })
  
  output$matchTable <- renderTable({
    d <- data.frame(removeNeg())
    colnames(d) <- c("Observed Pathologies")
    d
  })
}
