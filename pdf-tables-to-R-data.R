# Redo pdfs from gpw - WIG30 composition since 2014.06.20
# Save list of companies and their share in given index 
# Used library https://github.com/ropensci/tabulizer
###############################################################################

#install.packages("tabulizer", "stringr")
library(tabulizer)
library(stringr)

pdf_tables <- list.files(path = "./historical_compositions_of_index",
                         full.names = TRUE)

for(table in pdf_tables){
  extracted_table <- extract_tables(table, method = "data.frame", 
                                    area = list(c(126, 300, 174, 417)))
  
  if(length(extracted_table) == 0){
    extracted_table <- extract_tables(table, method = "data.frame", 
                                      area = list(c(126, 149, 212, 462)))
    extracted_table[[1]] <- (extracted_table[[1]])[-c(2,3), ]
  }
  
  date <- gsub(".*/|_WIG.pdf", "", table)
  date2 <- paste(substr(date,1,4),"-",substr(date,6,7), "-",substr(date,9,10),
                 sep="")
  
  for(i in 1:length(extracted_table)){
    extracted_table[[i]] <- subset(extracted_table[[i]], select = c(X, Udział))
    colnames(extracted_table[[i]]) <- c("ISIN", "Share")
    extracted_table[[i]] <- (extracted_table[[i]])[-c(1), ]
    extracted_table[[i]]$Date <- as.Date(date2)
  }
  df <- do.call(rbind.data.frame, extracted_table)
  rownames(df) <- NULL
  
  # Create data frame for share in index
  df_share <- data.frame(df$Date, df$ISIN, df$Share)
  colnames(df_share) <- c("Date", "ISIN", "Share")
  # Correct ISIN
  df_share$ISIN <- unlist(lapply(df_share$ISIN, str_sub, start = -12, end = -1))
  assign(paste("WIG30SHARE",gsub("-", "", date2),sep=""), df_share)
}

# Merge shares
list_df_share <- lapply(ls(pattern = "WIG30SHARE"), 
                        function(x) if (class(get(x)) == "data.frame") get(x))

df_share <- do.call(rbind.data.frame, list_df_share)
share_data <- reshape(df_share, idvar = "Date", timevar="ISIN", 
                      direction = "wide")
colnames(share_data) <- lapply(colnames(share_data), gsub, pattern = "Share.", 
                               replacement = "")

# Get comapny names
temp_comapny_isins <-colnames(share_data)[-1]
index_company_isins <- unlist(temp_comapny_isins)

# Clean workspace after extracting data
rm(df, df_share, extracted_table, date, date2, i, pdf_tables, 
   table, list=ls(pattern="WIG"), list_df_share, temp_comapny_isins)


# Save proper data
save(share_data, file = "./R_data/share_data.Rda")
save(index_company_isins, file = "./R_data/index_company_isins.Rda")
