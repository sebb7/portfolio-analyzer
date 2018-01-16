# Add nessesary packages
#install.packages("xts")
library("xts")

# Add used functions
source("script-funs.R")

# Name index
index_ticker <- "WIG30"

# Load data nessesary to create portfolios

# Data on share in stock index - share_data
load(file = "R_data/share_data.Rda")
# List of companies in stock index - index_company_names
load(file = "R_data/index_company_isins.Rda")

# Download company historical data from stooq.com (daily prices)

# Change company names to tickers
listed_stocks_data <- read.csv("other_files/wse_listed_stocks_till_2017.csv", 
                                 stringsAsFactors = FALSE)
tickers <- character()
for(i in 1:length(index_company_isins)){
  tickers[i] <- 
    listed_stocks_data[listed_stocks_data$ISIN == index_company_isins[i], 2]
}

# Download only non-existing files from stooq.com
DownloadHistData(tickers)

# To refresh your data delete your quotation files from 
# companies_and_index_historical_data directory
# file.remove(list.files("companies_and_index_historical_data", 
#             full.names = TRUE ))

# Transform downloaded data but for index data if already downloaded
# Function skips files given as arguments
all_returns <- TransformDataToCombinedXtsReturns(index_ticker)

# Show data which should be downloaded manually
missing_data <- read.csv("other_files/stooq_no_data_files.csv", 
                         stringsAsFactors = FALSE)[,2]
print(missing_data)
# Fill the missing data if necessary
# Remember about stooq.com format

# Download stock index historical prices and transform it
DownloadHistData(c(index_ticker))
stock_index_rr <- TransformDataFrameToXtsReturns(index_ticker)

# Take into account data since first publication of stock index composition
initial_date <- share_data$Date[1]
current_date <- index(tail(all_returns[,1], 1))
stock_index_rr <- stock_index_rr[paste(initial_date, current_date, sep = "/"), ]
all_returns <- all_returns[paste(initial_date, current_date, sep = "/"), ]


# Create portfolios and calculate their return till current date

# Create portfolio and it returns containing all companies which were 
# included in index for  whole time of its existence
portfolio_all <- all_returns
portfolio_all$Mean_rr <- rowMeans(portfolio_all, na.rm = TRUE)


# Create portfolio taking into account share data and only 30 companies per 
# period
share_data_calc <- xts(share_data[, -1], order.by = as.Date(share_data$Date))

colnames(share_data_calc) <- sapply(colnames(share_data_calc), function(n)
  listed_stocks_data[listed_stocks_data$ISIN == n, 2])

# Consider share in returns
# Take into account composition of index for each day
portfolio_iclud_composition <- all_returns

for(ticker in colnames(share_data_calc)){
  
  company_returns <- portfolio_iclud_composition[, paste(ticker, "_rr", sep = "")]
  updated_company_returns <- numeric(length(company_returns))
  
  for(i in 1:length(company_returns)){
    updated_company_returns[i] <- 
      AddNAToCompaniesNotInIndex(company_returns[i], share_data_calc[, ticker])
  }
  # Add calculated data to each column
  portfolio_iclud_composition[, paste(ticker, "_rr", sep = "")] <-
    updated_company_returns
}
#Calculate shares for each day for each company
company_shares_for_each_day <- portfolio_iclud_composition

for(ticker in colnames(share_data_calc)){
  
  company_shares <- company_shares_for_each_day[, paste(ticker, "_rr", sep = "")]
  updated_company_shares <- numeric(length(company_shares))
  
  for(i in 1:length(company_shares)){
    updated_company_shares[i] <- 
      ReturnShareForGivenDay(company_shares[i], share_data_calc[, ticker])
  }
  # Add calculated data to each column
  company_shares_for_each_day[, paste(ticker, "_rr", sep = "")] <-
    updated_company_shares
}

# Calculate weighted mean for each day
Mean_rr <- numeric(nrow(portfolio_iclud_composition))

for(i in 1:nrow(portfolio_iclud_composition)){
  Mean_rr[i] <- weighted.mean(as.vector(portfolio_iclud_composition[i]), 
                              as.vector(company_shares_for_each_day[i]),
                              na.rm = TRUE)
}

portfolio_iclud_composition$Mean_rr <- Mean_rr

# Clear workspace
rm(i, ticker, updated_company_returns, updated_company_shares, Mean_rr, company_shares,
   company_returns)

# Save files necessary to comparison
save(stock_index_rr, file="R_data/stock_index_rr.Rda")
save(portfolio_all, file="R_data/portfolio_all.Rda")
save(portfolio_iclud_composition, file="R_data/portfolio_iclud_composition.Rda")
