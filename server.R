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

shinyServer(function(input, output) {
  
  input_data <- reactive({
    
    if (is.null(input$file_input)) {
      return(NULL)
    }
    else {
      input_data = readLines(input$file_input$datapath)
      return(input_data)
    }
  })
  
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
  
  output$download_annotated_data <- downloadHandler(
    filename = function(){
      paste('Annotated Data for your Input.csv', sep = '')
    },
    content = function(con) {
      write.csv(annotate_documents_data_full(), con, row.names = FALSE)
    }
  )
  
  output$wordcloud <- renderUI({
    tabsetPanel(id = "WordCloud Tab", 
                tabPanel("nouns_wordcloud_tab",
                         plotOutput("word_cloud_nouns_tab")),
                tabPanel("verbs_wordcloud_tab",
                         plotOutput("word_cloud_verbs_tab"))
    )
  })
  
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
  
  cooccurrence_graphs_result <- reactive({
    data_for_co_occur = annotate_documents_data_full()
    checkbox_user_input = input$checkbox_group_input_upos
    data_for_co_occur_subset_based_on_choices = subset(data_for_co_occur, 
                                                       upos %in% checkbox_user_input)
    co_occur_data_computed = cooccurrence(x = data_for_co_occur_subset_based_on_choices,
                                          term = "lemma",
                                          group = c("doc_id", "paragraph_id", "sentence_id"))
    
    co_occur_word_network = head(co_occur_data_computed, 50)
    co_occur_word_network = igraph::graph_from_data_frame(co_occur_word_network)
    
    cooccurrence_graphs_result = ggraph(co_occur_word_network, layout = "fr") +  
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      theme_graph(base_family = "Arial Narrow") +  
      theme(legend.position = "none") +
      labs(title = "Cooccurrences within 3 words distance", subtitle = checkbox_user_input)
    return(cooccurrence_graphs_result)
  })
  
  output$cooccurrence_graphs_result <- renderPlot({cooccurrence_graphs_result()})
  
  
}  

)
