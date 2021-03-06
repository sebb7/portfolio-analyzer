DownloadHistData <- function(ticker_vector){
  # Downloads only non-existing files from stooq.com
  # Returns nothing
  # Saves the files in companies_and_index_historical_data directory
  companies_having_data <- unlist(lapply(list.files(
    "companies_and_index_historical_data"), gsub, pattern = ".csv", 
    replacement = ""))
  
  for(ticker in ticker_vector){
    if(!(ticker %in% companies_having_data)){
      download.file(paste("https://stooq.com/q/d/l/?s=", ticker,"&i=d",
                          sep=""),
                    destfile = paste("./companies_and_index_historical_data/", 
                                     ticker,".csv", sep = ""))
    }
  }
}

TransformDataToCombinedXtsReturns <- function(to_skip){
  # Transforms all downloaded files from companies_and_index_historical_data 
  # folder but for ticker given as function argument
  # Returns xts
  # Returned data is comapnies reurns from previous years
  # If given file has no data saves it in stooq_no_data_files.csv
  
  # List files
  exstg_files_tickers <- unlist(lapply(list.files(
    "companies_and_index_historical_data"), gsub, pattern = ".csv",
    replacement = ""))
  
  # Skip given tickiers
  exstg_files_tickers <- setdiff(exstg_files_tickers, to_skip)
  
  file_list <- list()
  no_data_files <- character()
  for(i in 1:length(exstg_files_tickers)){
    file_list[[i]] <- read.csv(paste("./companies_and_index_historical_data/", 
                                     exstg_files_tickers[i], ".csv", sep=""),
                               header=TRUE)
    # Consider lack of data
    if(colnames(file_list[[i]])[1] != "No.data"){
      file_list[[i]] <- xts(file_list[[i]][c("Close")], 
                            order.by = as.Date(file_list[[i]]$Date))
      file_list[[i]] <-diff(log(file_list[[i]]))
      names(file_list[[i]]) <- c(paste(exstg_files_tickers[i], "rr", 
                                       sep = "_"))
    }else{
      no_data_files <- append(exstg_files_tickers[i], no_data_files)
    }
  }
  
  # Print and save as csv list of files with no data
  print(paste("No data for:", no_data_files))
  write.csv(no_data_files, "other_files/stooq_no_data_files.csv")
  
  all_returns <- Reduce(function(x, y) merge(x, y, all=TRUE), file_list)
  return(all_returns)
}

TransformDataFrameToXtsReturns <- function(ticker){
  # Transforms data frame to xts
  # Returns only returns
  df <- read.csv(paste("./companies_and_index_historical_data/", ticker,
                       ".csv", sep=""), header=TRUE)
  
  df <- xts(df$Close, order.by = as.Date(df$Date))
  returns <- diff(log(df))
  names(returns) <- c(paste(ticker, "rr"))
  return(returns)
}

AddNAToCompaniesNotInIndex <- function(xts_frame, xts_share){
  # Check data and multiply it by 1 or NA
  # Returns only non-xts return
  
  # Get share for given date
  share <- tail(xts_share[paste("/", index(xts_frame), sep = "")], 1)[[1]]
  
  multiplier <- share/share
  result <- xts_frame[[1]] * multiplier
  return(result)
}

ReturnShareForGivenDay <- function(xts_frame, xts_share){
  # Check data and comapny name and return share for it
  # Returns only non-xts percentage share for given day
  
  # Get share for given date
  share <- tail(xts_share[paste("/", index(xts_frame), sep = "")], 1)[[1]]
  percentage_share <- share/100
  result <- percentage_share
  return(result)
}

