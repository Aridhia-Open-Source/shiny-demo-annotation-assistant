documentation_tab <- function() {
  tabPanel("Help",
           fluidPage(width = 12,
                     fluidRow(column(
                       6,
                       h3("Radiology Annotation Assistant"), 
                       p("This RShiny mini-app uses simple text mining techniques to extract structured information from free text radiology reports. **Unstructured data**, 
                       such as free text, froms nearly 80% of the world's data; this is data that does not have a pre-defined data model, which makes it very difficult to analyse 
                       using conventional programs. Text Mining Techniques are used to analyse and process unstructured data in order to retrieve high-quality information from text. 
                         Thus, through text mining techniques it is possible to transform unstructured data into structured data for easy analysis."),
                       
                       h4("How to use the mini-app"),
                       tags$ol(
                         tags$li("Select a report file to display using the drop-down menu. The text will display in the middle of the screen."),
                         tags$li("On the right, you will find the patient's information and the automatically-retrieved information from the text."),
                         tags$li("You can select which annotation class (Pathology, Anatomical Location, Laterality, Negation, Imaging Technique) you want to highlight in the text by selecting one or more classes displayed in the left-side."),
                         tags$li("Javascript extensions allows you to select text and add it to the dictionary to be highlighted in the future. To do this, you only have to select one or more word, select to which class belongs and click to 'Add to dictionary'"),
                         tags$li("To save the findings, click on 'Export findings'; this will save a csv file in the 'results' folder.")
                       ),
                     ),
                     column(
                       6,
                       h3("Walkthrough video"),
                       tags$video(src="annotation-assistant.mp4", type = "video/mp4", width="100%", height = "350", frameborder = "0", controls = NA),
                       p(class = "nb", "NB: This mini-app is for provided for demonstration purposes, is unsupported and is utilised at user's 
                       risk. If you plan to use this mini-app to inform your study, please review the code and ensure you are 
                       comfortable with the calculations made before proceeding. ")
                       
                     ))
                     
                     
                     
                     
           ))
}