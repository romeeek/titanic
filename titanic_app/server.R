#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library('dplyr')
library('caret')
library('reshape2')
library('zoo')

fit_fare <- readRDS("fit_fare.rds")
fit_survived <- readRDS("fit_survived.rds")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$txtout <- renderText({
    paste(input$txt, input$slider, format(input$date), sep = ", ")
  })
  output$table <- renderTable({
    head(cars, 4)
  })
  output$txtFareCode <- renderText({
    paste(substr(input$name, 1, 1),substr(input$surname,1,1),input$PClass,input$age,input$Embarked, sep = "")
  })
  
  fare <- reactive({
    round(predict(fit_fare, data.frame("Sex"=input$Sex,"Embarked"=input$Embarked, "Pclass" = as.numeric(input$PClass), "Age" = input$age)),2)
  })
  
  output$txtFare <- renderText({
    paste(fare(), "$", sep=)
  })
  
  surived<-reactive({
    predict(fit_survived, data.frame("Sex"=input$Sex,"Embarked"=input$Embarked, "Pclass" = as.numeric(input$PClass), "Age" = input$age, "Fare" = fare()))
  })
  
  modalText <- "W nocy z 14 na 15 kwietnia 1912 roku, podczas swojego dziewiczego rejsu statek otarł się o górę lodową. Uderzenie uszkodziło kadłub, a w konsekwencji doprowadziło do zatonięcia. Na okręcie znajdowało się 20 szalup mogących pomieścić jedynie połowę pasażerów i członków załogi.  "
  
  observeEvent(input$survived, {
    showModal(modalDialog(
      title = "Uwaga góra lodowa!!!!",
      renderText(modalText),
        if (surived()==0){
          if(input$Sex == 'female'){
            tags$span(style="color: red", "Niestety ten rejs zakończył się dla Ciebie tragicznie i umarlaś.")
          }else{
            tags$span(style="color: red", "Niestety ten rejs zakończył się dla Ciebie tragicznie i umarleś.")
          }
        } else {
          if(input$Sex == 'female'){
            tags$span(style="color: green", "Jesteś szczęściarą!!. Szybko wskoczyłaś na szalupę ratunkową i udało Ci się przeżyć.")
          }else{
            tags$span(style="color: green", "Jesteś szczęściarzem!! Szybko wskoczyłeś na szalupę ratunkową i udało Ci się przeżyć.")
          }
        },
      footer = tagList(
        modalButton("Zamknij")
        )
    ))
  })
})
