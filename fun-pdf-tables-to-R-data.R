# Redo pdfs from gpw - WIG30 composition since 2014.06.20
# Save list of companies and their share in given index 
# Used library https://github.com/ropensci/tabulizer
###############################################################################
library(tabulizer)

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
    extracted_table[[i]] <- tryCatch(
      {
        subset(extracted_table[[i]], select = c(X.2, Kurs, Udział))
      },
      error=function(e){
        return(subset(extracted_table[[i]], select = c(X.2, X.3, Udział)))
      })
    colnames(extracted_table[[i]]) <- c("Company", "Price", "Share")
    extracted_table[[i]] <- (extracted_table[[i]])[-c(1), ]
    extracted_table[[i]]$Date <- as.Date(date2)
  }
  df <- do.call(rbind.data.frame, extracted_table)
  rownames(df) <- NULL
  
  # Create data frame for share in index
  df_share <- data.frame(df$Date, df$Company, df$Share)
  colnames(df_share) <- c("Date", "Company", "Share")
  assign(paste("WIG30SHARE",gsub("-", "", date2),sep=""), df_share)
}

# Merge prices and shares
list_df_share <- lapply(ls(pattern = "WIG30SHARE"), 
                        function(x) if (class(get(x)) == "data.frame") get(x))

df_share <- do.call(rbind.data.frame, list_df_share)
share_data <- reshape(df_share, idvar = "Date", timevar="Company", 
                      direction = "wide")

## Get comapny names
temp_comapny_names <-colnames(share_data)[-1]
temp_comapny_names1 <- lapply(temp_comapny_names, gsub, pattern = "Share.", 
                              replacement = "")
index_company_names <- unlist(temp_comapny_names1)

# Clean workspace after extracting data
rm(df, df_share, extracted_table, date, date2, i, pdf_tables, 
   table, list=ls(pattern="WIG"), list_df_share, temp_comapny_names,
   temp_comapny_names1)


#save or load extracted nad proper data
save(share_data, file = "./R_data/share_data.Rda")
save(index_company_names, file = "./R_data/index_company_names.Rda")
