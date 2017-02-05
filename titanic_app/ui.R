#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library('dplyr')
library('caret')
library('reshape2')
library('zoo')

# Define UI for application that draws a histogram
shinyUI(
  tagList(
    tags$head(
      tags$link(rel="stylesheet", type = "text/css", href = "style.css"),
      tags$script(src = 'init.js')
    ),
    navbarPage(
      theme = shinytheme("paper"),  # <--- To use a theme, uncomment this
            "Titanic",
      
      tabPanel("Czy przeżyjesz?",
               tags$div(id="row1"),
               div(class="col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3",
                 div(class="card",
                     div(class="card-content",
                         textInput("name", "Imie", ""),
                         textInput("surname", "Nazwisko", ""),
                         numericInput('age', 'Wiek', 30,
                                      min = 1),
                         selectInput('Sex', 'Płeć', c("Kobieta"="female", "Mężczyzna"="male")),
                         selectInput('Embarked', 'Port', c("Cherbourg" = "C" , "Queenstown" = "Q", "Southampton" = "S")),
                         selectInput('PClass', 'Klasa', c("Pierwsza"="1", "Druga"="2", "Trzecia"=3)),
                         div(class="entry raffle", id="raffle-red", style="content: romek",div(class="no-scale", textOutput("txtFare"))),
                         actionButton("survived", "Kup bilet i wchodż na pokład", class = "btn-primary"),
                         textOutput("txtFareCode")
                         )
                     )
               )
      )
    )
  )
)
