# Forecasting Electric Production with SARIMA Models

A data science project applying the **Box-Jenkins methodology** to forecast monthly **U.S. electric production** using time series modeling. The study explores transformations, model identification, evaluation, and forecasting with SARIMA, providing insights for energy planning and resource optimization.

---

## 🧰 Tech Stack

- **R** (forecasting and time series libraries)  
- **R Markdown** / **knitr** (for reproducible report and poster)  
- **SARIMA Models** (Box-Jenkins methodology)  
- **Kaggle dataset** – Monthly U.S. electric production (1985–2018)  

---

## 📁 Repository Structure

~~~text
.
├─ electric_production.csv  # dataset from Kaggle
├─ eletric_production.rmd
├─ Report.pdf                 
├─ README.md
└─ LICENSE
└─ requirements.txt

~~~

---

## 📊 Methodology

1. **Data Preprocessing**  
   - Converted monthly data into time series objects (`tsibble`).  
   - Applied log transformation to stabilize variance.  
   - Seasonal differencing for stationarity.  

2. **Model Identification**  
   - ACF/PACF analysis suggested AR and MA components.  
   - Candidate SARIMA models compared with AIC/BIC.  

3. **Evaluation**  
   - Residual diagnostics (Ljung-Box test, white noise assumption).  
   - Accuracy metrics: RMSE, MAE, MAPE.  

4. **Forecasting**  
   - Selected **SARIMA(2,0,1)(2,1,1)** as the best model.  
   - Produced forecasts for 2016–2018, validated against test set.  

---

## 🔎 Results

- SARIMA(2,0,1)(2,1,1) showed the best performance, passing the Ljung-Box test and minimizing forecast error.  
- Forecasts captured seasonal patterns and trends effectively.  
- Insights suggest stable electricity production cycles, useful for **energy firms to optimize resources, plan labor, and anticipate demand fluctuations**.  

---

## ✅ Requirements

- **R 4.0+**  
- Libraries:  
  - `forecast`  
  - `fpp3`  
  - `tseries`  
  - `ggplot2`  
  - `dplyr`  

---

## 🚀 How to Run

1. Clone this repository:
   ~~~bash
   git clone https://github.com/<your-username>/forecasting-electric-production.git
   cd forecasting-electric-production
   ~~~

2. Open the R Markdown files in RStudio.  

3. Knit the documents to reproduce results and generate the poster.  

---

## 📄 License

This project is under MIT License
