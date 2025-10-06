##Libraries to use##

library(fpp3)
library(lubridate) #para tratar de dados com datas em R
library(urca) #para fazer unit root testing e outros

##Setting a correct path for the data##

setwd("C:\Users\Francisco\Desktop\universidade\2nd year\Forecasting Methods\our_project_forecast")
getwd()


##Importing data##

eletric = read.csv('Electric_Production.csv')
eletric = read.csv("/Users/franciscogomes/Desktop/Faculdade/2nd year/2nd year - 2nd semester/Forecasting Methods/our_project_forecast 2/Electric_Production.csv")
View(eletric)


##Data Transformation##

#turning the dataset into a tsibble and initial adjustments
eletric_tsibble = eletric %>%
  mutate(Month = yearmonth(DATE)) %>%
  select(Month, IPG2211A2N) %>%
  as_tsibble(index = Month)

View(eletric_tsibble)


##Starting Analysis##

eletric_tsibble %>% gg_tsdisplay(IPG2211A2N, plot_type = 'partial', lag_max = 36)

eletric_tsibble %>% gg_season()
#similar behaviors throughout the years, but with rising values
   #high values in the beginning of the years
   #drop in values from march to may
   #with a following rising pattern in the summer


eletric_tsibble %>% autoplot()
#rising trend and seasonality present


eletric_tsibble %>% gg_subseries()



##Train/Test##

# training set - jan 1985 to dec 2015
eletric_training = eletric_tsibble %>%
  filter(year(Month)<2016)

# test set - jan 2016 - jan 2018
eletric_test = eletric_tsibble %>%
  filter(year(Month)>=2016)

##Visualizing the variance##
eletric_training %>% autoplot(IPG2211A2N) 

#Slight increase in variance over time - use of a logarithm to stabilize it.
eletric_training %>% autoplot(log(IPG2211A2N)) 



#### Dickey-Fuller Tests & Differencing ####



# Dickey-Fuller test on the original stabilized data 

summary(ur.df(na.omit(log(eletric_training$IPG2211A2N)), type = c("trend"), lags = 12))  

#test-statistic (-0.9588) > critical values at all significance levels
   #null hypothesis of the presence of a unit root cannot be rejected
        #time series still not stationary - so we will apply a seasonal difference



### First Seasonal Difference ###

eletric_training_diff <- eletric_training %>%
  mutate(first_dif = difference(log(IPG2211A2N), 12))


# Dickey-Fuller test with first seasonal difference

summary(ur.df(na.omit(eletric_training_diff$first_dif), type = c("drift"), lags = 12))
# test-statistic (-4.9697) < critical values at all significance levels 
    #null hypothesis of the presence of a unit root is rejected
         #time series is now stationary :))


# Visualize ACF and PACF
eletric_training_diff %>% gg_tsdisplay(first_dif, plot_type = 'partial')



### Model identification: Fit various possible SARIMA/ARIMA models ### 
 
fit <- eletric_training %>%
  model(
    sarima000011 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(0,0,0) + PDQ(0,1,1)),
    sarima001011 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(0,0,1) + PDQ(0,1,1)),
    sarima100110 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(1,0,0) + PDQ(1,1,0)),
    
    sarima001111 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(0,0,1) + PDQ(1,1,1)),
    sarima100011 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(1,0,0) + PDQ(0,1,1)),
    sarima101111 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(1,0,1) + PDQ(1,1,1)),
    
    sarima200211 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(2,0,0) + PDQ(2,1,1)),
    sarima201211 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(2,0,1) + PDQ(2,1,1))
  )




### #Model Selection# ###

#####Information Criteria#####

fit %>%
  glance()


#chose the 3 best models based on information criteria

best_mod <- eletric_training %>%
  model(
    sarima201211  = ARIMA(log(IPG2211A2N) ~ 0 + pdq(2,0,1) + PDQ(2,1,1)),
    
    sarima101111 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(1,0,1) + PDQ(1,1,1)),
    
    sarima200211 = ARIMA(log(IPG2211A2N) ~ 0 + pdq(2,0,0) + PDQ(2,1,1)), 
   
  )



#Plot residuals for best models

best_mod %>%
  select(sarima201211) %>%
  gg_tsresiduals() # white noise

best_mod %>%
  select(sarima101111) %>%
  gg_tsresiduals() #white noise

best_mod %>%
  select(sarima200211) %>%
  gg_tsresiduals() # not exactly white noise



###Ljung-Box test####

augment(best_mod) %>%
  filter(.model=='sarima201211') %>%
  features(.innov, ljung_box, lag = 12 )   #no autocorrelation in the residuals
 

augment(best_mod) %>%
  filter(.model=='sarima101111') %>%
  features(.innov, ljung_box, lag = 12 ) # p-value < 0.05 - autocorrelation in residuals

augment(best_mod) %>%
  filter(.model=='sarima200211') %>%
  features(.innov, ljung_box, lag = 12 ) #  p-value < 0.05 -  autocorrelation in residuals



###Best Models###

best_mod %>%
  select(sarima201211) %>%
  report()

best_mod %>%
  select(sarima101111) %>%
  report()

best_mod %>%
  select(sarima200211) %>%
  report()



####Forecasting####

# Forecasting for the next 36 months (2 & 1/5 years)
fit_fc <- best_mod %>%
  select(sarima201211, sarima101111, sarima200211) %>%
  forecast(h = "36 months")


fit_fc %>%
  autoplot(eletric_tsibble, level= NULL) +
  labs(y = "Electric Production",
       title = "Electric Production Forecasts using Best Models") +
  theme_minimal()


## OU 

fit_fct<- best_mod %>%
  forecast(eletric_test)

fit_fct %>%
  autoplot(eletric_test,
           level= NULL) +labs(y= '',title = 'Electric Production')



### Accuracy ###

accuracy_metrics <- fit_fct %>%
  accuracy(eletric_test)

print(accuracy_metrics)



### Final Model ###

best_mod %>%
  forecast(h=36) %>%
  filter(.model=='sarima201211') %>%
  autoplot(eletric_training)



