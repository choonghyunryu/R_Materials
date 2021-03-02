library(dlookr)
library(dplyr)

##############################################################################
## 데이터 품질 진단
##############################################################################

## 데이터 요약 ===============================================================
# Generate data for the example
carseats <- ISLR::Carseats
carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA

ov <- carseats %>% 
  overview()

ov

summary(ov)

# sort by data type of variables
plot(ov, order_type = "type")

## 데이터 품질 진단 ===========================================================
# Diagnosis of missing variables
carseats %>%
  diagnose() %>%
  filter(missing_count > 0)

# Extraction of level that is more than 60% of categorical data
carseats %>%
  diagnose_category()  %>%
  filter(ratio >= 60)

# Information records of zero variable more than 0
carseats %>%
  diagnose_numeric()  %>%
  filter(zero > 0)

# outlier_ratio is more than 1%
carseats %>%
  diagnose_outlier()  %>%
  filter(outliers_ratio > 1)


## 결측치 진단 ===========================================================
# Visualize distribution of missing value by combination of variables.
mice::boys %>%
  plot_na_pareto()

# Visualize distribution of missing value by combination of variables.
mice::boys %>%
  plot_na_hclust()

# Visualize distribution of missing value by combination of variables.
mice::boys %>%
  plot_na_intersect()


##############################################################################
## 탐색적 데이터 분석
##############################################################################

## 범주형 일변량 변수 탐색 ===================================================
all_var <- carseats %>% 
  univar_category()

all_var

summary(all_var)

plot(all_var)


## 수치형 일변량 변수 탐색 ===================================================
all_var <- carseats %>% 
  univar_numeric()

all_var

summary(all_var)

plot(all_var)


## 범주형 이변량 변수 탐색 ===================================================
all_var <- carseats %>% 
  compare_category()

all_var

summary(all_var)

plot(all_var)


## 수치형 이변량 변수 탐색 ===================================================
all_var <- carseats %>% 
  compare_numeric()

all_var

summary(all_var)

plot(all_var)


## 상관관계 파악 =============================================================
# Correlation coefficient
# that eliminates redundant combination of variables
carseats %>%
  correlate() %>%
  filter(as.integer(var1) > as.integer(var2))

carseats %>% 
  plot_correlate()


## 정규성 검정 ===============================================================
carseats %>% 
  normality()

carseats %>% 
  plot_normality("Income", "Price")


## 인과관계 파악 =============================================================
# If the target variable is a categorical variable
categ <- carseats %>% 
  target_by(US)

# If the variable of interest is a numerical variable
cat_num <- categ %>% 
  relate(Sales)

cat_num

summary(cat_num)

plot(cat_num)


# If the target variable is a categorical variable
categ <- carseats %>% 
  target_by(US)

# If the variable of interest is a categorical variable
cat_cat <- categ %>% 
  relate(ShelveLoc)

cat_cat

summary(cat_cat)

plot(cat_cat)


# If the target variable is a categorical variable
num <- carseats %>% 
  target_by(Sales)

# If the variable of interest is a categorical variable
num_cat <- num %>% 
  relate(ShelveLoc)

num_cat

summary(num_cat)

plot(num_cat)


##############################################################################
## 기타 특징들
##############################################################################

## 자동화 리포트 ============================================================
# create pdf file. file name is DataDiagnosis_Report.pdf
diagnose_report(carseats)

# create pdf file. file name is ./Diagn.pdf and not browse
diagnose_report(carseats, output_dir = ".", output_file = "Diagn.pdf", 
                browse = FALSE)

# create html file. file name is Diagn.html
diagnose_report(carseats, output_format = "html", output_file = "Diagn.html")

# create pdf file. file name is EDA_carseats.pdf and not browse
eda_report(carseats, "US", output_dir = ".", output_file = "EDA_carseats.pdf", 
           browse = FALSE)

## target variable is numerical variable
# reporting the EDA information
eda_report(carseats, "Sales", output_dir = ".", output_file = "EDA_carseats2.pdf")


## DBMS 테이블 지원 ==========================================================
library(dplyr)

# Generate data for the example
carseats <- ISLR::Carseats
carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA

# connect DBMS
con_sqlite <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

# copy carseats to the DBMS with a table named TB_CARSEATS
copy_to(con_sqlite, carseats, name = "TB_CARSEATS", overwrite = TRUE)

# Using pipes ---------------------------------
# Positive values select variables
con_sqlite %>% 
  tbl("TB_CARSEATS") %>% 
  describe(Sales, CompPrice, Income)


## tidyverse와의 궁합 ========================================================
carseats %>% 
  diagnose(Sales, Age)

carseats %>% 
  select(Sales, Age) %>% 
  diagnose

# Compute the correlation coefficient of Sales variable by 'ShelveLoc'
# and 'US' variables. And extract only those with absolute
# value of correlation coefficient is greater than 0.5
carseats %>%
  group_by(ShelveLoc, US) %>%
  correlate(Sales) %>%
  filter(abs(coef_corr) >= 0.5)


# Test log(Income) variables by 'ShelveLoc' and 'US',
# and extract only p.value greater than 0.01.
carseats %>%
  mutate(log_income = log(Income)) %>%
  group_by(ShelveLoc, US) %>%
  normality(log_income) %>%
  filter(p_value > 0.01)


carseats %>% 
  group_by(ShelveLoc) %>% 
  plot_box_numeric()



