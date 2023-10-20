rm(list=ls())
set.seed(123)
library(readr)
library(tidyverse)
library(dplyr)
library(tidyr)

##Importing the data set without col names##
url<-"https://download.asic.gov.au/short-selling/RR20221230-001-SSDailyYTD.csv"
asic<-read.csv(url, header = FALSE) ##without col names is convenient##

##replacing "Reported Short Positions" and "% of Total Product in Issue Reported as Short Positions" in the data
asic <- replace(asic, asic == "Reported Short Positions", "Shortvol")
asic <- replace(asic, asic == "% of Total Product in Issue Reported as Short Positions", "Short%")


## separating dates in different numeric format and removes / to match with second row data##
Trade_Date <- unlist(asic[1, -c(1, 2)])
Trade_Date <- as.numeric(str_replace_all(Trade_Date, "/", ""))
#Trade_Date11<-as.character(Trade_Date2)
#Trade_Date <- paste(substr(Trade_Date11, 5, 8), substr(Trade_Date11, 3, 4), substr(Trade_Date11, 1, 2), sep = "-")

## assigning new col names and merging the first two rows into one column and labelled it as col names##
c1<- asic[2,]  
c2<- c1[-c(1,2)]
c3<- paste(c2, Trade_Date, sep = "_")
new_colnames <- c("Security_name", "Security_Code")
colnames(asic) <- c(new_colnames, c3)

##remove first two rows of asic data##
asic <- asic[-c(1:2), ]

##Making long table and distribute variables##

asic_Pivot_L<- pivot_longer(data = asic, 
                               cols = starts_with("short"),
                               names_to = "variable",
                               values_to = "values" ) |> 
  separate(col = variable, into = c("type", "Trade_Date"), sep ="_" )

asic_Pivot_W<- pivot_wider(data= asic_Pivot_L, names_from= type, values_from = values)

##filter data##
asic_Final <- asic_Pivot_W[asic_Pivot_W$Shortvol!= "-", ]

##rename and date format##
asic_Final$Trade_Date <-ifelse(nchar(asic_Final$Trade_Date) == 7, paste0("0", asic_Final$Trade_Date), asic_Final$Trade_Date)
asic_Final$Trade_Date <- paste(substr(asic_Final$Trade_Date, 5, 8), substr(asic_Final$Trade_Date, 3, 4), substr(asic_Final$Trade_Date, 1, 2), sep = "-")

##date format##
asic_Final$Trade_Date <- as.Date(asic_Final$Trade_Date, format = "%Y-%m-%d")

#rename two columns#
colnames(asic_Final)[c(4, 5)] <- c("short_Volume", "short_percent")

asic_Final
