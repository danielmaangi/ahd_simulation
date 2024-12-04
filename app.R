library(shiny)
library(leaflet)
library(ggplot2)
library(dplyr)
library(plotly)
library(sf) # For spatial data
library(randomForest) # For modeling

# Synthetic data (Replace with real data in practice)
data <- data.frame(
  region = c("Region A", "Region B", "Region C", "Region D"),
  lat = c(-1.28, -1.25, -1.32, -1.35),
  lon = c(36.82, 36.84, 36.85, 36.78),
  cases = c(120, 80, 150, 90),
  ART_adherence = c(0.7, 0.8, 0.6, 0.5),
  CD4_mean = c(300, 400, 250, 280)
)

# Define UI
ui <- fluidPage(
  titlePanel("AHD Epidemiological Modeling and Policy Simulation"),
  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Select Region:", choices = c("All", unique(data$region))),
      sliderInput("adherence_increase", "ART Adherence Improvement (%):", min = 0, max = 30, value = 10),
      actionButton("simulate", "Run Simulation")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Hotspot Map", leafletOutput("map")),
        tabPanel("Trends", plotlyOutput("trend_plot")),
        tabPanel("Simulation Results", plotlyOutput("simulation_plot"))
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Filter data based on region selection
  filtered_data <- reactive({
    if (input$region == "All") {
      data
    } else {
      filter(data, region == input$region)
    }
  })
  
  # Render Hotspot Map
  output$map <- renderLeaflet({
    df <- filtered_data()
    leaflet(df) %>%
      addTiles() %>%
      addCircleMarkers(
        ~lon, ~lat,
        radius = ~cases / 10,
        label = ~paste0(region, ": ", cases, " cases"),
        color = "red",
        fillOpacity = 0.7
      )
  })
  
  # Render Trends Plot
  output$trend_plot <- renderPlotly({
    df <- data
    df <- df %>%
      mutate(
        trend = cases * ART_adherence,
        year = rep(2020:2023, each = nrow(df) / 4)
      )
    
    p <- ggplot(df, aes(x = year, y = trend, color = region)) +
      geom_line() +
      labs(title = "AHD Cases Trends", x = "Year", y = "Estimated Cases")
    ggplotly(p)
  })
  
  # Run Simulation and Render Results
  simulation_results <- eventReactive(input$simulate, {
    df <- data
    df$simulated_cases <- df$cases * (1 - (input$adherence_increase / 100) * df$ART_adherence)
    df
  })
  
  output$simulation_plot <- renderPlotly({
    df <- simulation_results()
    p <- ggplot(df, aes(x = region, y = simulated_cases, fill = region)) +
      geom_bar(stat = "identity") +
      labs(title = "Simulated Impact of ART Adherence Improvement", x = "Region", y = "Simulated Cases")
    ggplotly(p)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
