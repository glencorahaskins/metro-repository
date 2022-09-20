setwd("C:/Users/ghask/The Brookings Institution/Metro Research - JParilla/Glencora/GitHub/metro-repository/metro-repository-app")

library(devtools)
# acs_cty <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/acs_cty.R"
# source_url(acs_cty)
# acs_cbsa <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/acs_cbsa.R"
# source_url(acs_cbsa)

cty <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/_co_all.R"
source_url(cty)

library(metro.data)
county_cbsa_st <- county_cbsa_st %>% select('stco_code', 'stco_name', 'co_type', 'st_code', 'st_name', 'cbsa_code', 'cbsa_name', 'cbsa_type', 'cbsa_is.top100', 'cbsa_size')
county_cbsa_st <- county_cbsa_st %>% relocate(stco_name, .after = stco_code)
county_cbsa_st <- county_cbsa_st[complete.cases(county_cbsa_st),]
county_cbsa_st$cbsa_name <- sort(county_cbsa_st$cbsa_name, decreasing = FALSE, na.last = TRUE)

#
# TO DO
# (/) SWITCH BETWEEN COUNTY/CBSA
# (/) DOWNLOAD DATASETS
# (/) Add README
# ( ) Add master file

library(dplyr)
library(shiny)
library(markdown)
library(ggplot2)
library(plotly)

# load("data/co_all.rda")
# load("data/cbsa_all.rda")
# load("data/list_all_co.rda")
# load("data/list_all_cbsa.rda")
# load("data/county_cbsa_st.rda")

create_scatter <- function(df, var_x, var_y,...){
  ggplot(df, aes_string(x = var_x, y = var_y,...))+
    geom_point(stat = "identity")+
    geom_smooth(method = "lm")+
    theme(rect = element_rect(fill = NA, colour=NA),
          panel.background = element_rect(fill = NA,colour = NA),
          plot.background = element_rect(fill = NA, colour = NA),
          panel.grid = element_blank(),
          legend.background = element_rect(fill = "transparent"),
          legend.key = element_rect(fill = "transparent", color = NA),
          legend.box.background = element_rect(fill = "transparent", colour = NA),
          axis.ticks = element_blank())
}

# UI design, three tabs, README + County + Metro
ui <- navbarPage(
  "Metro Data Warehouse",
  
  tabPanel(
    "README",
    includeMarkdown("README.md")
  ),
  
  tabPanel(
    "County",
    helpText("If you have any questions or comments, please contact Sifan Liu (sliu@brookings.edu)"),
    
    # Sidebar
    sidebarLayout(
      sidebarPanel(
        selectizeInput(
          "co_places", "1. Search for the counties: (or, leave blank to select all)",
          choices = co_all$stco_name, multiple = TRUE
        ),
        selectizeInput(
          "cbsa_co_places", " Or, select all the counties within the metros:",
          choices = county_cbsa_st$cbsa_name, multiple = TRUE
        ),
        selectizeInput(
          "co_datasets", "2. Search and select the datasets:", 
          # selected = "co_acs",
          choices = names(list_all_co), multiple = TRUE
        ),
        actionButton("update_co", "Show county data"),
        
        downloadButton("download_co", label = "Download csv"), 
        
      ),
      
      # Show data table
      mainPanel(
        DT::dataTableOutput("table_co")
      )
    )
  ),
#  tabPanel(
#    "Metro",
#    helpText("If you have any questions or comments, please contact Sifan Liu (sliu@brookings.edu)"),
#    
#    # Sidebar
#    sidebarLayout(
#      sidebarPanel(
#        h3("Data table"),
#        
#        
#        selectizeInput(
#          "cbsa_places", "1. Search and select the metros: (or, leave blank to select all)",
#          choices = county_cbsa_st$cbsa_name, multiple = TRUE
#        ),
#        selectizeInput(
#          "cbsa_datasets", "2. Search and select the datasets:", 
#          # selected = "cbsa_acs",
#          choices = names(list_all_cbsa), multiple = TRUE
#        ),
#        actionButton("update_cbsa", "Show metro data"), 
#        
#        downloadButton("download_cbsa", label = "Download csv"),
#        
#        h3("Scatter plot"),
#        checkboxInput("scatter_plot", label = "Create a scatter plot", value = FALSE),
#        
#        conditionalPanel(
#          condition = "input.scatter_plot == true",
#          
#          selectizeInput(
#            "x_var", "varibles on x axis", choices = "cbsa_emp"
#          ),
#          selectizeInput(
#            "y_var", "varibles on y axis", choices = "cbsa_pop"
#          ),
#          
#          plotlyOutput ("Plot")
#        )
#        
#      ),
#      
#      
#      # Show data table
#      mainPanel(
#        DT::dataTableOutput("table_cbsa")
#      )
#    )
#  )
)



# Define server logic
server <- function(input, output, session) {
  # update input variables
  info_co <- eventReactive(input$update_co, {
    if (is.null(input$co_places) & is.null(input$cbsa_co_places)) {
      co_codes <- county_cbsa_st$stco_code
    } else {
      co_codes <- c(
        (co_all %>% filter(stco_name %in% input$co_places))$stco_code,
        (county_cbsa_st %>% filter(cbsa_name %in% input$cbsa_co_places))$stco_code
      )
    }
    
    if (is.null(input$co_datasets)){
      validate(need(!is.null(input$co_datasets), "Please choose your datasets"))
    } else {
      co_columns <- unlist(list_all_co[input$co_datasets], use.names = F)
    }
    
    
    co_df <- co_all %>%
      filter(stco_code %in% co_codes) %>%
      select(co_columns) %>%
      tidyr::drop_na(-all_of(contains("stco_"))) %>% 
      unique() %>%
      left_join(county_cbsa_st %>% select(dplyr::contains("co_"),"cbsa_code","cbsa_name") %>% unique(), by = "stco_code")%>%
      mutate_if(is.numeric, ~ round(., 2))
    
  })
  
#  info_cbsa <- eventReactive(input$update_cbsa, {
#    if (is.null(input$cbsa_places)) {
#      cbsa_codes <- county_cbsa_st$cbsa_code
#    } else {
#      (cbsa_codes <- (county_cbsa_st %>% filter(cbsa_name %in% input$cbsa_places))$cbsa_code)
#    }
#    
#    if (is.null(input$cbsa_datasets)){
#      validate(need(!is.null(input$cbsa_datasets), "Please choose your datasets"))
#    } else{
#      cbsa_columns <- unlist(list_all_cbsa[input$cbsa_datasets], use.names = F)
#    }
#    
#    updateSelectizeInput(session, "x_var", "Choose a variable on x axis ", choices = c(cbsa_columns,"cbsa_pop", "cbsa_emp"), selected = "cbsa_pop")
#    updateSelectizeInput(session, "y_var", "Choose a variable on y axis ", choices = c(cbsa_columns,"cbsa_pop", "cbsa_emp"), selected = "cbsa_emp")
#    
#    
#    cbsa_df <- cbsa_all %>%
#      filter(cbsa_code %in% cbsa_codes) %>%
#      select(cbsa_columns) %>%
#      tidyr::drop_na(-all_of(contains("cbsa_"))) %>% 
#      unique() %>%
#      left_join(county_cbsa_st %>% select(dplyr::contains("cbsa_"),-cbsa_name) %>% unique(), by = "cbsa_code") %>%
#      mutate_if(is.numeric, ~ round(., 2))
#  })
  
  # show output table
  output$table_co <- DT::renderDataTable({
    co_df <- info_co()
    
    DT::datatable(
      co_df,
      options = list(
        lengthMenu = list(c(5, 15, -1), c("5", "15", "All")),
        pageLength = 100
      )
    )
  })
  
#  output$table_cbsa <- DT::renderDataTable({
#    cbsa_df <- info_cbsa()
#    
#    DT::datatable(
#      cbsa_df,
#      options = list(
#        lengthMenu = list(c(5, 15, -1), c("5", "15", "All")),
#        pageLength = 100
#      )
#    )
#  })
  
#  # info_plot <- eventReactive(input$update_plot, )
  
#  output$Plot <- renderPlotly({
#    
#    df <- info_cbsa()
#    # var <- info_plot()
#    
#    create_scatter(df, input$x_var, input$y_var, label = "cbsa_name")
#    
#  })
  
  
  # get download link
  output$download_co <- downloadHandler(
    filename = function() {
      paste("co_", Sys.Date(), ".csv")
    },
    content = function(filename) {
      write.csv(info_co(), filename)
    }
  )
  
#  output$download_cbsa <- downloadHandler(
#    filename = function() {
#      paste("cbsa_", Sys.Date(), ".csv")
#    },
#    content = function(filename) {
#      write.csv(info_cbsa(), filename)
#    }
#  )
}

# Run the application
shinyApp(ui = ui, server = server)







