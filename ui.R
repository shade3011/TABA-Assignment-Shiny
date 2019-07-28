#Team
#Sharan Basavaraj Biradar - 11915084
#Aditya Auradker - 11915078
#Raashi Hasteer - 11915021

#Importing Libraries
library(udpipe)
library(ggplot2)
library(igraph)
library(ggraph)
library(wordcloud)
library(shiny)
library(tidyr)
library(tidyverse)
library(tidytext)

#Loading the english language model
english_model = udpipe_load_model("./english-ewt-ud-2.3-181115.udpipe")

#This is the code for Shiny UI below
shinyUI(fluidPage(
  
  # Our App title
  titlePanel("UDPipe NLP Workflow for TABA Assignment"),
  
  sidebarPanel(
    #This is for the upload button
    fileInput(inputId = "file_input", label = "Upload text file",
              placeholder = "No file selected"),
    #This is for checkbox to make user choose the POS tags. Noun, Adjective and Proper Nouns are by default
    checkboxGroupInput(inputId = "checkbox_group_input_upos", 
                       label = "Choose the Universal Part of Speech Tags for plotting co-occurrences",
                       choices = c('ADJ', 'NOUN', 'PROPN', 'ADV', 'VERB'),
                       selected = c('ADJ', 'NOUN', 'PROPN'),
                       inline = TRUE,
                       width = NULL)
    
  ),
  
  mainPanel(
    tabsetPanel(
      type = "tabs",
      #This bit is for the output to be displayed
      tabPanel("Introduction to the App", 
               h4(p("What does this App do?")), 
               p("This App is expected to generate UDPipe NLP pipeline for the input text data.
                 It basically gives the user the option to choose the parts of speech to be generated. 
                 It has the option to generate wordcloud. Further, it also has the feature to 
                 generate co-occurrence graph of the top most 30 words."),
               h4(p("What are you expected to do?")), 
               p("Upload a text file that contains sentences. Once uploaded, then click on either of the tabs to get results for the same. 
                 For the co-occurrence graphs, you are free to check either of the boxes. Happy Adventure!"),
               h4(p("Important Note to User")), 
               p("Server side processing takes time in proportion to number of sentences in the input text. Hence please be patient! Thanks :D")),
      
      tabPanel("Annotated document",
               h4(p("Annotations for the Input Data")),
               downloadButton(outputId = "download_annotated_data", label = "Download all results as csv"),
               dataTableOutput("annotate_documents_data")),
      
      tabPanel("WordCloud", 
               h4(p("WordCloud Images")),
               uiOutput("wordcloud")), #After server processing, this creates two tabs for wordclourds (Nouns & Verbs respectively)
      
      tabPanel("Co-occurrences",
               h4(p("Plotting Co-occurrence Graphs")),
               plotOutput("cooccurrence_graphs_result"))
    )
    
  )
  
  
) 
)

#Citations
#1. Class Notes
#2. https://shiny.rstudio.com/articles/dynamic-ui.html
#3. https://shiny.rstudio.com/tutorial/written-tutorial/lesson4/
#4. https://support.rstudio.com/hc/en-us/articles/360007981134-Persistent-Storage-on-RStudio-Connect
#5. https://help.data.world/hc/en-us/articles/115006300048-GitHub-how-to-find-the-sharable-download-URL-for-files-on-GitHub
#6. R Shiny Documentation
#7. https://stackoverflow.com/questions/43155273/how-to-pass-checkbox-input-into-a-function-in-shinyserver
#8. https://stackoverflow.com/questions/22206290/r-shiny-making-sub-panels
#9. https://stackoverflow.com/questions/44980227/shiny-server-functions-with-2-outputs
#10. https://github.com/Lchiffon/wordcloud2/issues/18
#11. https://stackoverflow.com/questions/35176746/datatable-dt-shiny-r-select-all-found-rows
#12. https://stackoverflow.com/questions/25126130/r-shiny-renderdatatable-display-options
#13. https://stackoverflow.com/questions/51730816/remove-showing-1-to-n-of-n-entries-shiny-dt
#14. https://stackoverflow.com/questions/41464449/shiny-data-frame-only-displays-10-rows
#15. https://shiny.rstudio.com/reference/shiny/1.0.4/downloadHandler.html
#16. https://shiny.rstudio.com/reference/shiny/1.0.4/downloadButton.html
#17. https://shiny.rstudio.com/reference/shiny/0.14/renderDataTable.html
#18. https://shiny.rstudio.com/reference/shiny/0.14/tableOutput.html
#19. https://shiny.rstudio.com/articles/download.html
#20. https://rstudio.github.io/DT/
#21. https://stackoverflow.com/questions/44504759/shiny-r-download-the-result-of-a-table
#22. https://stackoverflow.com/questions/41729259/shiny-datatable-save-full-data-frame-with-buttons-extension
