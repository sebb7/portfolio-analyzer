# Necessary libraries
library(urca)
library(PerformanceAnalytics)
library(fBasics)
library(xtable)

# Risk-free rate in Poland (2013 - now) sorce: www.market-risk-premia.com
rf_rate <- 0.0328

# Load necessary files
load(file = "R_data/stock_index_rr.Rda")
load(file = "R_data/portfolio_all.Rda")
load(file = "R_data/portfolio_iclud_composition.Rda")

# Get data regarding basic information about returns
basicStats(stock_index_rr)
basicStats(portfolio_all$Mean_rr)
basicStats(portfolio_iclud_composition$Mean_rr)

# Sharp ratio - risk free rate
SharpeRatio.annualized(stock_index_rr, rf_rate, scale = 1)
SharpeRatio.annualized(portfolio_all$Mean_rr, rf_rate, scale = 1)
SharpeRatio.annualized(portfolio_iclud_composition$Mean_rr, rf_rate, scale = 1)

# Sharp ratio - WIG30
SharpeRatio.annualized(stock_index_rr, Rf = colMeans(stock_index_rr),
                       scale = 1)
SharpeRatio.annualized(portfolio_iclud_composition$Mean_rr,
                       colMeans(stock_index_rr), scale = 1)

# Portfolios returns to benchmark return
table.CAPM(portfolio_all$Mean_rr, stock_index_rr, Rf = rf_rate)
table.CAPM(portfolio_iclud_composition$Mean_rr, stock_index_rr, Rf = rf_rate)
table.CAPM(portfolio_iclud_composition$Mean_rr, stock_index_rr, Rf = rf_rate)

# Plots for returns
plot(stock_index_rr, main = "WIG30 returns")
plot(portfolio_all$Mean_rr$Mean_rr, main = "All companies portfolio returns")
plot(portfolio_iclud_composition$Mean_rr, main =
       "Portfolio including composition returns")

