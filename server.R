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

#Loading the english langauge model in case it failed to load from UI.R code execution
english_model = udpipe_load_model("./english-ewt-ud-2.3-181115.udpipe")

#Below is the code for server processing
shinyServer(function(input, output) {
  
  input_data <- reactive({
    #Blank input, don't do anything
    if (is.null(input$file_input)) {
      return(NULL)
    }
    else {
      input_data = readLines(input$file_input$datapath)
      return(input_data) #Returns the content of the file uploaded
    }
  })
  
  #This code does annotation of the input data. This only returns a subset of the final result (100 rows). (Slightly time consuming)
  annotate_documents_data <- reactive({
    #annotate_documents_data <- tibble(text = input_data()) %>%
    #  mutate(text = gsub('<.*?>', '', text)) %>% 
    #  mutate(text = gsub('[[:punct:]]', '', text))
    #annotate_documents_data <- as.character(annotate_documents_data)
    data = input_data()
    #data = readLines('./test_input.txt')
    data = gsub("<.*?>", "", data)
    data = gsub("[[:punct:]]", "", data)
    annotate_documents_data <- udpipe_annotate(english_model, x = data)
    annotate_documents_data <- as.data.frame(annotate_documents_data)
    annotate_documents_data <- annotate_documents_data %>% 
      select(-sentence) %>% 
      mutate(rn = row_number()) %>% 
      filter(rn <= 100) %>% 
      select(-rn)
    
    return(annotate_documents_data)
  })
  output$annotate_documents_data <- renderDataTable(annotate_documents_data(),
                                                    options = list(
                                                      pageLength = 20
                                                    ))
  
  #This code does annotation of the input data. (Slightly time consuming)
  annotate_documents_data_full <- reactive({
    #annotate_documents_data <- tibble(text = input_data()) %>%
    #  mutate(text = gsub('<.*?>', '', text)) %>% 
    #  mutate(text = gsub('[[:punct:]]', '', text))
    #annotate_documents_data <- as.character(annotate_documents_data)
    data = input_data()
    #data = readLines('./test_input.txt')
    data = gsub("<.*?>", "", data)
    data = gsub("[[:punct:]]", "", data)
    annotate_documents_data <- udpipe_annotate(english_model, x = data)
    annotate_documents_data <- as.data.frame(annotate_documents_data)
    annotate_documents_data <- annotate_documents_data %>% 
      select(-sentence)
    return(annotate_documents_data)
  })
  
  #Download functionality for the user to download entire annotations data
  output$download_annotated_data <- downloadHandler(
    filename = function(){
      paste('Annotated Data for your Input.csv', sep = '')
    },
    content = function(con) {
      write.csv(annotate_documents_data_full(), con, row.names = FALSE)
    }
  )
  
  #Creation of separate tabs & populating the word cloud images for both nouns and verbs
  output$wordcloud <- renderUI({
    tabsetPanel(id = "WordCloud Tab", 
                tabPanel("nouns_wordcloud_tab",
                         plotOutput("word_cloud_nouns_tab")),
                tabPanel("verbs_wordcloud_tab",
                         plotOutput("word_cloud_verbs_tab"))
    )
  })
  
  #Creation of word cloud for nouns based on term frequency
  word_cloud_nouns <- reactive({
    data_for_word_cloud = annotate_documents_data_full()
    all_nouns_in_data = data_for_word_cloud %>% 
      filter(upos == "NOUN")
    nouns_freq = txt_freq(all_nouns_in_data$lemma)
    nouns_word_cloud = wordcloud(words = nouns_freq$key,
                                 freq = nouns_freq$freq,
                                 min.freq = 2,
                                 max.words = 100,
                                 random.order = FALSE,
                                 colors = brewer.pal(6, "Dark2"))
    return(nouns_word_cloud)
  })
  
  output$word_cloud_nouns_tab <- renderPlot({word_cloud_nouns()})
  
  #Creation of word cloud for verbs based on term frequency
  word_cloud_verbs <- reactive({
    data_for_word_cloud = annotate_documents_data_full()
    all_verbs_in_data = data_for_word_cloud %>% 
      filter(upos == "VERB")
    verbs_freq = txt_freq(all_verbs_in_data$lemma)
    verbs_word_cloud = wordcloud(words = verbs_freq$key,
                                 freq = verbs_freq$freq,
                                 min.freq = 2,
                                 max.words = 100,
                                 random.order = FALSE,
                                 colors = brewer.pal(6, "Dark2"))
    return(verbs_word_cloud)
  })
  
  output$word_cloud_verbs_tab <- renderPlot({word_cloud_verbs()})
  
  #Creation of co-occurrence graph for top 30 word combinations
  cooccurrence_graphs_result <- reactive({
    data_for_co_occur = annotate_documents_data_full()
    checkbox_user_input = input$checkbox_group_input_upos
    data_for_co_occur_subset_based_on_choices = subset(data_for_co_occur, 
                                                       upos %in% checkbox_user_input)
    co_occur_data_computed = cooccurrence(x = data_for_co_occur_subset_based_on_choices,
                                          term = "lemma",
                                          group = c("doc_id", "paragraph_id", "sentence_id"))
    
    co_occur_word_network = head(co_occur_data_computed, 30)
    co_occur_word_network = igraph::graph_from_data_frame(co_occur_word_network)
    
    cooccurrence_graphs_result = ggraph(co_occur_word_network, layout = "fr") +  
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "blue", size = 4) +
      theme_graph(base_family = "Calibri") +  
      theme(legend.position = "none") +
      labs(title = "Cooccurrences of words", subtitle = "For selected POS tags...")
    return(cooccurrence_graphs_result)
  })
  
  output$cooccurrence_graphs_result <- renderPlot({cooccurrence_graphs_result()})
  
  
}  

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
