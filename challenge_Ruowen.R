install.packages("tidyverse")
install.packages("dplyr")

library(tidyverse)
library(dplyr)

# Read the file into R
df <- read_csv("RR20221230-001-SSDailyYTD.csv")

# clean the data
# separate the data into two parts: short_percentage and short_volume
# for each sub data, make a longer; then convert the date
cols_to_keep <- !apply(df, 2, function(col) col[1] == "Reported Short Positions")
df1 <- df[, cols_to_keep]
colnames(df1)[1] <- c("security_name")
colnames(df1)[2] <- c("security_code")
df1 <- df1[-1,]

df1_long <- pivot_longer(data = df1,
                         col = -c('security_name','security_code'),
                         names_to = "trade_date",
                         values_to = "short_percentage")

df1_long$trade_date <- as.Date(df1_long$trade_date, format = "%d/%m/%Y")


cols_to_keep <- !apply(df, 2, function(col) col[1] == "% of Total Product in Issue Reported as Short Positions")
df2 <- df[, cols_to_keep]
colnames(df2)[1] <- c("security_name")
colnames(df2)[2] <- c("security_code")
df2 <- df2[-1,]

df2_long <- pivot_longer(data = df2,
                         col = -c('security_name','security_code'),
                         names_to = "trade_date",
                         values_to = "short_volume")

df2_long$trade_date <- as.Date(df2_long$trade_date, format = "%d/%m/%Y")

# join the cleaned two sub data into one
df_tidy <- full_join(df1_long,df2_long) 
# convert the short_percentage and short_volume to numerical
df_tidy$short_percentage <- as.numeric(df_tidy$short_percentage) 
df_tidy$short_volume  <- as.numeric(df_tidy$short_volume)
# drop the NA observation
df_final <- na.omit(df_tidy)



