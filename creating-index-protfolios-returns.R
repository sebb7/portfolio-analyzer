# Add nessesary packages
#install.packages("xts")
library("xts")

# Add used functions
source("script-funs.R")

# Load data nessesary to create portfolios

# Data on share in stock index - share_data
load(file = "./R_data/share_data.Rda")
# List of companies in stock index - index_company_names
load(file = "./R_data/index_company_isins.Rda")

# Download company historical data from stooq.com (daily prices)

# Change company names to tickers
listed_stocks_data <- read.csv("other_files/wse_listed_stocks_till_2017.csv", 
                                 stringsAsFactors = FALSE)
tickers <- character()
for(i in 1:length(index_company_isins)){
  tickers[i] <- 
    listed_stocks_data[listed_stocks_data$ISIN == index_company_isins[i], 2]
}
rm(i)

# Download only non-existing files from stooq.com
DownloadHistData(tickers)

# To refresh your data delete your quotation files from 
# companies_and_index_historical_data directory
# file.remove(list.files("companies_and_index_historical_data", 
#             full.names = TRUE ))

# Transform downloaded data
all_returns <- TransformDataToCombinedXts()
# Fill the missing data if necessary

