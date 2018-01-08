#install.packages("xts")
library("xts")

# Load data nessesary to create portfolios

# Data on share in stock index - share_data
load(file = "./R_data/share_data.Rda")
# List of companies in stock index - index_company_names
load(file = "./R_data/index_company_isins.Rda")

# Download company historical data from stooq.com (daily prices)

# Change company names to tickers
listed_stocks_data <- read.csv("wse_listed_stocks_till_2017.csv", 
                                 stringsAsFactors = FALSE)
tickers <- character()
for(i in 1:length(index_company_isins)){
  tickers[i] <- 
    listed_stocks_data[listed_stocks_data$ISIN == index_company_isins[i], 2]
}

# Download only non-existing files from stooq.com
# To refresh your data delete manually your share quotation files
exstg_files <- unlist(lapply(list.files("./companies_and_index_historical_data"),
                         gsub, pattern = ".csv", replacement = ""))
for(ticker in tickers){
  if(!(ticker %in% exstg_files)){
    download.file(paste("https://stooq.com/q/d/l/?s=", ticker,"&i=d",
                                                  sep=""),
                  destfile = paste("./companies_and_index_historical_data/", 
                                   ticker,".csv", sep = ""))
  }
}

