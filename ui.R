library(udpipe)
library(ggplot2)
library(igraph)
library(ggraph)
library(wordcloud)
library(shiny)
library(tidyr)
library(tidyverse)
library(tidytext)

english_model = udpipe_load_model("./english-ewt-ud-2.3-181115.udpipe")

shinyUI(fluidPage(
  
  # Application title
  titlePanel("UDPipe NLP Workflow"),
  
  sidebarPanel(
    
    fileInput(inputId = "file_input", label = "Upload text file",
              placeholder = "No file selected"),
    
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
      
      tabPanel("Introduction to the App", 
               h4(p("What does this App do?")), 
               p("This App is expected to generate UDPipe NLP pipeline for the input text data.
                 It basically gives the user the option to choose the parts of speech to be generated. 
                 It has the option to generate wordcloud. Further, it also has the feature to 
                 generate co-occurrence graph of the top most 30 words."),
               h4(p("What are you expected to do?")), 
               p("Upload a text file that contains sentences. Once uploaded, then click on either of the tabs to get results for the same. 
                 For the co-occurrence graphs, you are free to check either of the boxes. Happy Adventure!")),
      
      tabPanel("Annotated document",
               h4(p("Annotations for the Input Data")),
               downloadButton(outputId = "download_annotated_data", label = "Download all results as csv"),
               dataTableOutput("annotate_documents_data")),
      
      tabPanel("WordCloud", 
               h4(p("WordCloud Images")),
               uiOutput("wordcloud")),
      
      tabPanel("Co-occurrences",
               h4(p("Plotting Co-occurrence Graphs")),
               plotOutput("cooccurrence_graphs_result"))
    )
    
  )
  
  
) 
)