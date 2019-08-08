
server <- function(input, output, session) {
  
  lab <- reactive({
    # Progress 
    progress <- shiny::Progress$new()
    progress$set(message = "Loading Annotations..", value = 0)
    Sys.sleep(1)
    on.exit(progress$close())
 	  labels <- read.csv(paste0(workspace_home, '/datafiles/annotation_assistant_datafiles/labels.csv'))
  })
  
  file_input <- reactive({
    paste0(workspace_home, "/datafiles/annotation_assistant_datafiles/", input$files)
  })
  
 # Read and pre-process files
  readText <- reactive({
    progress <- shiny::Progress$new()
    progress$set(message = "Reading file...", value = 0)
    Sys.sleep(1)
    on.exit(progress$close())
    txt <- paste(str_trim(readLines(file_input())), collapse = " ")
    
    # Strip truncation
    txt <- gsub("[\r\n]", " ", txt)
    txt <- gsub("\\s+", " ", txt)
    txt <- gsub("\\s+\\.", ".", txt)    
    txt2 <- as.character(unlist(paste(list(txt), sep = '')))
  })
  
  
  # Extract Name, DOB, Exam type
  
  patientInfo <- reactive({
    progress <- shiny::Progress$new()
    progress$set(message = "Extracting Patients info...", value = 0)
    Sys.sleep(1)
    on.exit(progress$close())
    #txt <- readText()
    #name <- trimws(as.character(genXtract(txt, 'PATIENT: ', 'DOB:', with = FALSE)))[1]
    #dob <- trimws(as.character(genXtract(txt, 'DOB: ', 'FILE', with = FALSE)))[1]
    #exam <- trimws(as.character(genXtract(txt, 'EXAM: ', 'DATE:', with = FALSE)))[1]
    #df <- data.frame(c(name,dob,exam), row.names = c('Name','DOB','Exam'))
    
    #colnames(df) <- NULL
    #df
    if(input$files == 'brain-mri-sample-report-1.txt') {
      pat_id <- 'pat_001'
      pat_name <- 'Gandalf'
      study <- 'Brain MRI'
    }
    if(input$files == 'neck-mri-with-andwithout-contrast-sample-report-1.txt') {
	    pat_id <- 'pat_002'
      pat_name <- 'Aragorn'
      study <- 'Neck MRI'
	  }
    if(input$files == 'pituitary-mri-with-and-without-contrast-sample-report-1.txt') {
	    pat_id <- 'pat_003'
      pat_name <- 'Legolas'
      study <- 'Pituitary MRI'
	  }
    if(input$files == 'thoracic-spine-mri-without-contrast-sample-report-1.txt') {
  	  pat_id <- 'pat_004'
      pat_name <- 'Gimli'
      study <- 'Thoratic-spine MRI'
	  }
    df <- data.frame(c(pat_id, pat_name, study), row.names = c('Patients ID: ', 'Name: ', 'Exam: '))
    colnames(df) <- NULL
    df
  })

  # Extract findings from free text 
  findingsInfo <- reactive({
    progress <- shiny::Progress$new()
    progress$set(message = "Processing text...", value = 0)
    Sys.sleep(1)
    on.exit(progress$close())
    txt <- readText()
    txt2<- gsub(".*FINDINGS\\s*|IMPRESSION.*", "", txt)
    txt <- gsub("[\r\n | | | |, ]", " ", txt2)
    txt <- gsub("Page 2 of 2", " ", txt)
    s = c("Report approved on    NationalRad | Headquartered: Florida | Diagnostic Imaging Services: Nationwide | 877.734.6674 | www.NationalRad.com" )
    txt <- gsub(s, " ", txt) 
    
  })
  
  # Generate match table
  matchTable <- eventReactive(readText(), {
    progress <- shiny::Progress$new()
    progress$set(message = "Finding matches...", value = 0)
    Sys.sleep(1)
    on.exit(progress$close())
    txt <-findingsInfo()
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
    clean_out <- df_filter[which(df_filter$start %in% ir$start | df_filter$end %in% ir$end), ]
  })
  
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
  
  annotatedFile <- reactive({
    progress <- shiny::Progress$new()
    progress$set(message = "Annotating report...", value = 0)
    Sys.sleep(1)
    on.exit(progress$close())
    
    txt <- findingsInfo()
    m <- matchTable()
    starts <- matchTable()[, "start"]
    ends <- matchTable()[, "end"] + 1
  
    pat_vec <- NULL
    loc_vec <- NULL
    lat_vec <- NULL
    neg_vec <- NULL
    im_vec <- NULL
    
    if ("pat" %in% input$radio) {
      pat_table <- pathology()
      s <- pat_table[, "start"]
      e <- pat_table[, "end"] + 1
      col <- '<span class="pathology">'
      pat_vec <- list(rep(col, length(s)), s)
    }
    
    if ("loc" %in% input$radio) {
      ploc_table <- aLoc()
      s <- ploc_table[, "start"]
      e <- ploc_table[, "end"] + 1
      col <- '<span class ="location">'
      loc_vec <- list(rep(col, length(s)), s)
    }
    
    if ("lat" %in% input$radio) {
      lat_table <- laterality()
      s <- lat_table[, "start"]
      e <- lat_table[, "end"] + 1
      col <- '<span class="laterality">'
      lat_vec <- list(rep(col, length(s)), s)
    }
    
    if ("neg" %in% input$radio)
    {
      neg_table <- negation()
      s <- neg_table[, "start"]
      e <- neg_table[, "end"] + 1
      col <- '<span class="negation">'
      neg_vec <- list(rep(col, length(s)), s)
    }
    
    
    if ("imaging" %in% input$radio) {
      im_table <- imaging()
      s <- im_table[, "start"]
      e <- im_table[, "end"] + 1
      col <- '<span class="imaging">'
      im_vec <- list(rep(col, length(s)), s)
    }
    annotated <- insert_str(
      txt, 
      insert = c(unlist(pat_vec[1]), unlist(loc_vec[1]), unlist(lat_vec[1]), 
                 unlist(neg_vec[1]), unlist(im_vec[1]), rep("</span>", length(ends))),
      index = c(unlist(pat_vec[2]), unlist(loc_vec[2]), unlist(lat_vec[2]),
                unlist(neg_vec[2]), unlist(im_vec[2]), ends)
    )
  })
  
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
    for (i in 1:nrow(negations)) {
      start <- negations[i, "start"]
      end <- negations[i, "end"]
      if(as.integer(sentRange["sentStart"]) <= as.integer(start) && 
         as.integer(sentRange["sentEnd"]) >= as.integer(end)) {
        return(1)
      } else {
        
      }
    }
  }

  observedPathology <- function(pathology, filteredSent) {
    for(i in 1:nrow(filteredSent)) {
      start <- filteredSent[i, "sentStart"]
      end <- filteredSent[i, "sentEnd"]
      
      if(as.integer(pathology["start"]) >= as.integer(start) && 
         as.integer(pathology["end"]) <= as.integer(end)) {
        return(1)
      } else {
        
      }
    }
  }
  
  removeNeg <- reactive({
    sentRange <- negSent()
    negRange <- negation()[, c("start", "end")]
    sentRange$neg <- as.vector(as.character(apply(sentRange, 1, FUN = removeNegations, negations = negRange)))
    filteredSent <- sentRange[sentRange$neg != "1", c("sentStart", "sentEnd")]

    pat <- pathology()
    loc <- aLoc()
    pat$neg<- as.vector(as.character(apply(pat, 1, FUN = observedPathology, filteredSent = filteredSent)))
    loc$neg<- as.vector(as.character(apply(loc, 1, FUN = observedPathology, filteredSent = filteredSent)))
    
    pat <- pat[pat$neg == "1", "terms"]
    head(pat[!duplicated(pat)], 10)
  })
  
  # Write keywords
  
  observe({
    df <- data.frame(phrase= input$mydata[1], class= input$mydata[2],row.names = NULL)
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
     
    output <- removeNeg()[1:10]
    df <- data.frame(Pathology1  = 0,
                     Pathology2  = 0,
                     Pathology3  = 0,
                     Pathology4  = 0,
                     Pathology5  = 0,
                     Pathology6  = 0,
                     Pathology7  = 0,
                     Pathology8  = 0,
                     Pathology9  = 0,
                     Pathology10 = 0)
     
    df <- rbind(df, output)[2, ]
    df2 <- cbind(pat, df)
  	writeTable(df2, tableName)
  	progress <- shiny::Progress$new()
    progress$set(message = paste("Exporting to ", tableName, '...') , value = 0)
    Sys.sleep(5)
    on.exit(progress$close())
  })
  
  ### Outputs ###
  output$patient <- renderTable({
    patientInfo()
  })
  
  output$text <- renderUI({
    txt <- paste(annotatedFile())
    cat(file = stderr(), txt, "\n")
    str1 <- p(HTML(txt))
  })
  
  output$matchTable <- renderTable({
    d <- data.frame(removeNeg())
    colnames(d) <- c("Observed Pathologies")
    d
  })
}
