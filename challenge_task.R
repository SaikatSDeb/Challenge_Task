library(tidyverse)
url <- "https://download.asic.gov.au/short-selling/RR20221230-001-SSDailyYTD.csv"
short_sale22 <- read.csv(url)



short_sale22_long<- pivot_longer(data = short_sale22,
                                 col = -c(X,Trade.Date),
                                 names_to = "Date",
                                 values_to = c("Short_info")
)

short_sale22_long2 <- separate(data = short_sale22_long,
                               col = Date, 
                               into = c("day", "Month", "Year","option"),
)


short_sale22_long3 <- pivot_wider(data = short_sale22_long2,
                                  names_from = "option", 
                                  values_from = "Short_info")

new_names <- c("Security_name", "security_code", "day", "month", "year", "Short_volume", "Short_percent")
names(short_sale22_long3) <- new_names 


short_sale22_long4 <- filter(short_sale22_long3, !grepl("Reported Short Positions|-", Short_volume))

short_sale22_long4 <- short_sale22_long4 |> mutate(day = substr(day, 2, nchar(day)))

#changing the order of variables
short_sale22_long5 <- short_sale22_long4 |> select(Security_name, security_code, year, month, day, Short_volume,Short_percent)

short_sale22_long6 <- unite(short_sale22_long5, year, month, day, col = trade.date, sep = "-")


short_sale22_long6 <- short_sale22_long6 |> 
  mutate(trade.date = as.Date(trade.date))|> 
  mutate_at(vars(4,5), as.numeric)

head(short_sale22_long6)
View(short_sale22_long6)
