
##############################
#GILLIAN KIMUNDI - 222403295 #
##############################
#Week 6 - CHALLENGE TASK     #
##############################

library(tidyverse)
library(lubridate)
library(dbplyr)
library(readxl)

library(RPostgres)

shortsellurl= "https://download.asic.gov.au/short-selling/RR20221230-001-SSDailyYTD.csv"

short_sale=read.csv(shortsellurl, header=FALSE)

colnames(short_sale)<-paste(short_sale[1,], short_sale[2,], sep = "_") #MAIN 1

short_sale<-short_sale[-c(1:2),]

shortsale_long <- pivot_longer( #MAIN 2
  data = short_sale,
  cols = -c("_Product","Trade Date_Product Code"),
  names_to = "date_variable",
  values_to = "value"
) |>
  separate(sep="_", col = date_variable, #MAIN 3
           into = c("trade_date", "variable")
  ) |>
  pivot_wider(names_from = "variable", #MAIN 4
              values_from = "value"
  ) |>
  mutate(trade_date=dmy(trade_date)) #MAIN 5

names(shortsale_long)<-c("security_name","security_code","trade_date","short_volume","short_percent")

GILLIAN_shortsale_long<-  filter(shortsale_long,!(str_detect(short_volume, "-")))
