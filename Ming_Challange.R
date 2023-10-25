#load the package
install.packages("tidyr")
library(tidyr)
install.packages("tidyverse")
library(tidyverse)
library(dplyr)

#read the data and merge date and volume, percent together
url <- "https://download.asic.gov.au/short-selling/RR20221230-001-SSDailyYTD.csv"
StSale <- read.csv(url, header = FALSE)
StSale[StSale == "Reported Short Positions"] <- "shortvolume"
StSale[StSale == "% of Total Product in Issue Reported as Short Positions"] <- "shortpercent"
StSale[1,] <- as.numeric(gsub("/", "", StSale[1,]))

dates <- unlist(StSale[1, -c(1, 2)])
new_colnames <- c("Product", "Product Code")
for (i in seq(1, length(dates), by = 2)) {
  new_colnames <- c(new_colnames,
                    paste0("shortvolume_", dates[i]),
                    paste0("shortpercent_", dates[i]))
}
colnames(StSale) <- new_colnames

#drop the first two rows
StSale <- StSale[-(1:2), ]

#transfer the dataset
tidy_data <- StSale |>
  pivot_longer(cols = starts_with("short"),
               names_to = "variable",
               values_to = "value") |>
  separate(col = variable, into = c("type", "date"), sep = "_") |>
  pivot_wider(names_from = type, values_from = value) |>
  rename(ID = date,
         shortvolume = shortvolume,
         shortpercent = shortpercent)

#adjust the date
tidy_data$ID[ nchar(as.character(tidy_data$ID)) == 7 ] <-
  paste0("0", tidy_data$ID[ nchar(as.character(tidy_data$ID)) == 7 ])
tidy_data$ID <- lubridate::dmy(tidy_data$ID)
unique(tidy_data$ID[is.na(tidy_data$ID)])
tidy_data

#rename the variables as the table shown in class
tidy_data <- tidy_data |>
  rename(security_name = Product , security_code = 'Product Code' ,trade_date = ID ,short_volume =shortvolume, short_percent= shortpercent)

#drop all missing values
tidy_data <- tidy_data |>
  filter(short_volume != "-" | short_percent != "-")
tidy_data

#change the variable type from <chr> to <dbl>
tidy_data <- tidy_data %>%
  mutate(
    short_volume = as.numeric(short_volume),
    short_percent = as.numeric(short_percent)
  )
tidy_data