---
title: "Relationship between Number of Starbucks store and Prosperity"
output:
  pdf_document: default
  html_document: default
---

```{r include = FALSE}
knitr::opts_chunk$set(echo = FALSE, message=FALSE)

```



```{r}
tryCatch({
  if(Sys.getenv('RSTUDIO')=='1'){
    setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  }}, error = function(e){}
)
if(!require(pacman)) install.packages("pacman")
pacman::p_load(knitr,tidyverse)

knitr::opts_chunk$set(tidy=FALSE,strip.white=FALSE,fig.align="center",comment=" #")

library(dplyr)
library(ggplot2)

```



## Introduction


>|      Starbucks was first established in Seattle at 1971. Fifty years later, there are about 25,000 stores around the world, and Starbucks has become an important culture beyond just a cup of coffee. In urban area like Chicago and New York, we can easily see the Starbucks in every block but it is hard to see in the rural area. By observing this kind of situation, our group came up with a simple question: “what makes the difference?” Our group think that the number of Starbucks stores could be one of the indicators that represent the prosperity of city or country. To check our claim, we made a hypothesis: null hypothesis with “there is no relationship between the number of Starbucks stores and the indicators that represents the prosperity of city or country” versus the alternative hypothesis with “there is some relationship between the number of Starbucks stores and the indicators that represents the prosperity of city or country”. In other words, we set our hypothesis $H_0: B_j = 0$ and $H_a: B_j \neq 0$. Note that we used 7 variables including “GDP”, “Happiness Score”, “Cost of Living”, “Rent Price”, “Quality of Life”, "Safety index" and “Population”.

>|      Our group strongly believe that if we can answer out question and find such indicator, we can inversely estimate that indicator by counting number of Starbucks. Furthermore , our group strongly believe that inverse estimation can be used in various fields including economics, business administration, and social studies. For example, economists can predict the estimated GDP of a country by just counting the number of Starbucks, and social scientists can make a further research of how Starbucks and coffee impact people’s wellness and happiness. We expect Starbucks could be one of the important and indescribable index if our research has a meaningful result. In order to conduct our research, we first cleaned the data collected from variety sources and tested our hypothesis.  


## Data explanation

### 1) Data Source and Data Description

> We used the total of six datasets for this project.

> The first data we used is directory.csv from https://www.kaggle.com/starbucks/store-locations. This dataset includes a record for every Starbucks or subsidiary store location in operations worldwide. This data was scraped from the Starbucks store locator webpage by https://github.com/chrismeller/. There are a number of including Brand, Store Number, Store Name, Owenership Type, Street Address, City, and Country. 

> The second data we used is cost_of_living.csv from https://www.kaggle.com/dumbgeek/countries-dataset-2020?select=Cost+of+living+index+by+country+2020.csv updated by Varun Yadav. This dataset includes various variables such as cost of living and rent of each countires worldwide counted as the index number.

> The third dataset we used is quality_of_live.csv from https://www.kaggle.com/dumbgeek/countries-dataset-2020?select=Quality+of+life+index+by+countries+2020.csv updated by Varun Yadav. This data includes variables realted to the indicators of the overall quality of live such as safety index, health care index and quality of life index.

> The fourth dataset we used is happiness.csv from https://www.kaggle.com/unsdsn/world-happiness?select=2017.csv. There are two significant indicators in this dataset, which are happiness ranking of the countries worldwide and the happiness score of the those countries. These happiness scores and ranking use data from the Gallup World Poll. The happiness scores are entirely based on answers to the main life evalution question answered by respondents asked in the poll and the happiness 
ranking are assgined to each countries based on the scores.

> The fifth dataset we used is economic.csv from https://www.kaggle.com/nottisani/worldwide-economics-gdp updated by Gabriela McDavid. The dataset includes a number of variables that help us to get a sense of the economic status of countires worldwide such as the net GDP and the size of the population. 

> The last dataset we used is gdpstate.csv from https://www.bea.gov/data/gdp/gdp-state. 



### 2) Data Cleaning

>|    Firstly, we cleaned up six dataset separately in order to select variables that we needed to address the topic of our research and curiousity. In addition, since the original dataset we used have their own distinct form of a data frame, we tidyed up each dataset having similar form of a data frame in order for us to combine the dataset and make the single data frame for the analysis. We made the two data frames, one for the analysis of the number of Starbucks in countries worldwide and its relation to the indicators of the overall quality of life, which are the net GDP, happiness score, cost of living, rent, quality of life index, safety index and the size of population and the other for the analysis of the number of Starbucks in 50 states of United States and its association with the net GDP of each states (We conducted this analysis because the United States is a huge outlier when it comes to the number of Starbucks stores and the net GDP).
>|    Most importantly, for the orginal directory.csv dataset, the country names were recorded as an abbreviation such as "KR" for "South Korea" and "JP" for "Japan", so we revised the name of the countries into their full name. Also, there were some errors in the name of the countries so that we couldn't count the number of Starbucks stores in each countries properly. In order to address this type of error, we looked into the variables of "Street address," "City," "Province," and "Postcode" and figured out that some country names like South Korea, China and Japan were in these variables, not in the column of "Country". After fixing this error, we counted the number of Starbucks based on the countries and made a new data frame named "starbucks". <br> Without huge difficulties, we cleaned up the rest of the dataset and combined them with the newly made starbucks dataframe (the number of Starbucks in each countries). In order to analyze the number of Starbucks in each states in the United States and its association with GDP of each states, we only filtered out the country of United States in the data frame of "starbucks" and made a new column of "states". Lastly, we recounted the number of Starbucks stores based on the states and combine this data frame with the gdpstate.csv.


```{r include = FALSE}
#cost of living data
cost_of_living <- read.csv("cost_of_living.csv") %>%
  rename(Country = 癤풠ountry, Cost_of_living = Cost.of.Living.Index, Rent = Rent.Index) %>%
  select(Country, Cost_of_living, Rent) %>%
  mutate(Country = str_to_upper(Country))
cost_of_living

```


```{r include = FALSE}
#quality_of_life data
quality_of_life <- read.csv("quality_of_life.csv") %>%
  rename(Country = 癤풠ountry) %>%
  mutate(Country = str_to_upper(Country)) %>%
  select("Country" ,"Quality.of.Life.Index", "Safety.Index")

quality_of_life
```


```{r include = FALSE}
#happiness rank data

happiness <- read.csv("happiness.csv") %>%
  select(Country, Happiness.Score) %>%
  mutate(Country = str_to_upper(Country))
happiness

```





```{r include = FALSE}
#starbucks data
starbucks <- read.csv("directory.csv")

starbucks <- starbucks %>%
  mutate(Country = case_when(        
        Country == "AD" ~ "Andorra",
        Country == "AE" ~ "United Arab Emirates",
        Country == "AR" ~ "Argentina",
        Country == "AT" ~ "Austria",
        Country == "AU" ~ "Australia",
        Country == "AW" ~ "Aruba",
        Country == "AZ" ~ "Azerbaijan",
        Country == "BE" ~ "Belgium",
        Country == "BG" ~ "Bulgaria",
        Country == "BH" ~ "Bahrain",
        Country == "BN" ~ "Brunei",
        Country == "BO" ~ "Bolivia",
        Country == "BR" ~ "Brazil",
        Country == "BS" ~ "Bahamas",
        Country == "CA" ~ "Canada",
        Country == "CH" ~ "Switzerland",
        Country == "CL" ~ "Chile",
        (Country == "CN" | Street.Address == "CN" | City == "CN" | State.Province == "CN" | Postcode == "CN") ~ "China",
        Country == "CO" ~ "Colombia",
        Country == "CR" ~ "Costa Rica",
        Country == "CW" ~ "Curaçao",
        Country == "CY" ~ "Cyprus",
        Country == "CZ" ~ "Czech Republic",
        Country == "DE" ~ "Germany",
        Country == "DK" ~ "Denmark",
        Country == "EG" ~ "Egypt",
        Country == "ES" ~ "Spain",
        Country == "FI" ~ "Finland",
        Country == "FR" ~ "France",
        Country == "GB" ~ "United Kingdom",
        Country == "GR" ~ "Greece",
        Country == "GT" ~ "Guatemala",
        Country == "HU" ~ "Hungary",
        Country == "ID" ~ "Indonesia",
        Country == "IE" ~ "Iceland",
        Country == "IN" ~ "India",
        Country == "JO" ~ "Jordan",
        (Country == "JP" | Street.Address == "JP" | City == "JP" | State.Province == "JP" | Postcode == "JP") ~ "Japan",
        Country == "KH" ~ "Cambodia",
        (Country == "KR" | Street.Address == "KR" | City == "KR" | State.Province == "KR" | Postcode == "KR") ~ "South Korea",
        Country == "KW" ~ "Kuwait",
        Country == "KZ" ~ "Kzakhstan",
        Country == "LB" ~ "Lebanon",
        Country == "LU" ~ "Luxembourg",
        Country == "MA" ~ "Morocco",
        Country == "MC" ~ "Monaco",
        Country == "MX" ~ "Mexico",
        Country == "MY" ~ "Malaysia",
        Country == "NL" ~ "Netherlands",
        Country == "NO" ~ "Norway",
        Country == "NZ" ~ "New Zealand",
        Country == "OM" ~ "Oman",
        Country == "PA" ~ "Panama",
        Country == "PE" ~ "Peru",
        Country == "PH" ~ "Philippines",
        Country == "PL" ~ "Poland",
        Country == "PR" ~ "Puerto Rico",
        Country == "PT" ~ "Portugal",
        Country == "QA" ~ "Qatar",
        Country == "RO" ~ "Romania",
        Country == "RU" ~ "Russia",
        Country == "SA" ~ "Saudi Arabia",
        Country == "SE" ~ "Sweden",
        Country == "SG" ~ "Singapore",
        Country == "SK" ~ "Slovakia",
        Country == "SV" ~ "El Salvador",
        Country == "TH" ~ "Thailand",
        Country == "TR" ~ "Turkey",
        Country == "TT" ~ "Trinidad Tobago",
        Country == "TW" ~ "Taiwan",
        Country == "US" ~ "United States",
        Country == "VN" ~ "Vietnam",
        Country == "ZA" ~ "South Africa"))


starbucks_final <- starbucks %>%
  mutate(Country = str_to_upper(Country)) %>%
  group_by(Country) %>%
  summarise(starbucks = n()) %>%
  arrange(starbucks)

starbucks_final
```

```{r include = FALSE}
#gdp data

gdp <- read.csv("economic.csv") %>%
  rename(Country = "癤풠ountry") %>%
  select(Country, GDP, Population) %>%
  mutate(Country = str_to_upper(Country))
gdp
```


```{r}
#Merge data

s_p <-left_join(starbucks_final, happiness)

s_p_c <- left_join(s_p, cost_of_living)

s_p_c_q <- left_join(s_p_c, quality_of_life)

Final_data <- left_join(s_p_c_q, gdp) 

Final_data <- Final_data %>%
  select(Country, starbucks, GDP, everything()) %>%
  drop_na()

Final_data

```

> The above dataframe is our final combined data for the analysis of the relationship between the number of starbucks in countries worldwide and significant indicators related to the overall quality of life.



```{r include = FALSE}
# number of stores in each states

states <-starbucks %>% filter(Country=="United States") %>%
  mutate(State = state.name[match(State.Province, state.abb)]) %>%
  group_by(State) %>%
  summarise(store = n()) %>%
  arrange(desc(store))


states

```

```{r}

#DF merge (abb-name)
StateGDP <- read.csv("gdpstate.csv",skip=5,col.names=c("code","State","GDP"))

State_GDP_SB<-merge(StateGDP,states,by="State") %>%
  mutate(State = str_to_lower(State))
State_GDP_SB

```

> The above dataframe is our final combined data for the second analysis of the relationship between the number of Starbucks in each of 50 states in America and its association with the net GDP.

## Method & Analysis

> After cleaning the dataset, our group mainly used “linear regression” for the analysis so that we are able to observe the dependency between the number of Starbucks and other variables. Our group checked whether there is a relationship between specific variables and number of Starbucks, we checked the associated p-value and found that only “GDP” and “Population” seemed meaningful for initial hypothesis. Hence, we made deeper analyzations on both “GDP” and “Population”. We then used R-squared to check the fitness of our model. Moreover, our group detected that the number of Starbucks in USA seems to be too large compared to other datasets and therefore, we decided to subdivide the “USA” into “each states” to prevent USA being an outlier in terms of the number of Starbucks. Furthermore, to help the audience look our data at ease, our group used Choropleth map to compare the distribution of Starbucks in USA and GDP at glances. <br> As non-linearity of the response-predictor relationship is one of the main concern in linear regression model, our group also checked whether there is a non-linear association with each variables to check which model is suitable by checking the associated p-value. 



## Results

### 1) Country: Relationship between Number of Starbucks and overall Quality of Life

#### (a) Linear regression

```{r}

fit_all = lm(starbucks ~. -Country, data = Final_data)
summary(fit_all)

``` 

> From multiple linear regression, we found out that "GDP" and "Population" were highly statistically significant variabels with extremely low p-values. Hence we may reject the null hypothesis for "GDP" and "Population".  


```{r}
# r squared value of our model
"R squared Value"
summary(fit_all)$r.squared


# adjusted r squared value of our model
"Adjust R squared Value"
summary(fit_all)$adj.r.squared
```

> According to summary of our model, both r-squared(0.8804866) and adjusted r-squared(0.8622998) had values close to 1, so we can say that our model is good and reliable.

```{r, echo=FALSE}


country_starbucks_lm = lm(GDP ~ starbucks, data= Final_data)
ggplot(Final_data, show.legend=TRUE) + 
  ggtitle("Figure1: Number of Starbucks Stores in Relation to GDP (All Countries)") +
  geom_point(aes(x=starbucks, y=GDP)) + 
  geom_abline(slope=country_starbucks_lm$coefficients[2], intercept = country_starbucks_lm$coefficients[1], color="red")

country_starbucks_data_wo_US = Final_data %>% filter(row(Final_data) != 1) # except USA
country_starbucks_wo_US_lm = lm(GDP ~ starbucks, data= country_starbucks_data_wo_US)
ggplot(country_starbucks_data_wo_US, show.legend=TRUE) + 
  ggtitle("Figure2: Number of Starbucks Stores in Relation to GDP (exceptU.S.)") +
  geom_point(aes(x=starbucks, y=GDP)) + 
  geom_abline(slope=country_starbucks_wo_US_lm$coefficients[2], intercept = country_starbucks_wo_US_lm$coefficients[1], color="red")
# The above plot represents the relationship between the number of starbucks and the net GDP of each countries except U.S. The States has above 10000 number of starbucks, which is a comparatively irregular and it makes the slope exceedingly steep so we made a plot without the U.S.

country_starbucks_data_lt_1000 = Final_data %>% filter(starbucks < 1000)
country_starbucks_lt_1000_lm = lm(GDP ~ starbucks, data= country_starbucks_data_lt_1000)
ggplot(country_starbucks_data_lt_1000, show.legend=TRUE) + 
  ggtitle("Figure3: Number of Starbucks Stores in Relation to GDP (<= 1000 stores)") +
  geom_point(aes(x=starbucks, y=GDP)) + 
  geom_abline(slope=country_starbucks_lt_1000_lm$coefficients[2], intercept = country_starbucks_lt_1000_lm$coefficients[1], color="red")

```


>  Above *Figure1* *Figure2* *Figure3* show that linearity of starbucks stores with countries' GDP and all of them show good linearity. The *Figure1*, as U.S. overwhelmingly has too many stores, on the *Figure2*, we singled out U.S. and represented the rest of countries. Also, on the *Figure3* in order to check possible distortions of our data, we checked countries with stores less than 1,000. Regardelss of the number of stores of each country, there was a good linearity between GDP and number of stores. However there were some points deviating from the regression line, which leaves the room for further alternative analysis.



```{r, echo=FALSE}

country_starbucks_lm = lm(Population ~ starbucks, data= Final_data)
ggplot(Final_data, show.legend=TRUE) + 
  ggtitle("Figure4: Number of Starbucks Stores in Relation to Population (All Countries)") +
  geom_point(aes(x=starbucks, y=Population)) + 
  geom_abline(slope=country_starbucks_lm$coefficients[2], intercept = country_starbucks_lm$coefficients[1], color="red")

country_starbucks_wo_US_lm = lm(Population ~ starbucks, data= country_starbucks_data_wo_US)
ggplot(country_starbucks_data_wo_US, show.legend=TRUE) + 
  ggtitle("Figure5: Number of Starbucks Stores in Relation to Population (except U.S.)") +
  geom_point(aes(x=starbucks, y=Population)) + 
  geom_abline(slope=country_starbucks_wo_US_lm$coefficients[2], intercept = country_starbucks_wo_US_lm$coefficients[1], color="red")

country_starbucks_lt_1000_lm = lm(Population ~ starbucks, data= country_starbucks_data_lt_1000)
ggplot(country_starbucks_data_lt_1000, show.legend=TRUE) + 
  ggtitle("Figure6: Number of Starbucks Stores in Relation to Population (<= 1000 stores)") +
  geom_point(aes(x=starbucks, y=Population)) + 
  geom_abline(slope=country_starbucks_lt_1000_lm$coefficients[2], intercept = country_starbucks_lt_1000_lm$coefficients[1], color="red")




```


>  Using the separated datsets, we found above *Figure4* *Figure5* *Figure6* showed good linearity of starbucks stores with countries.' But there were still some few points far off from the regression line, so we had to take additional approach.

#### (b) Non-linear Association

```{r, echo=FALSE}

fit_gdp = lm(starbucks ~ poly(GDP, 4), data = Final_data)
summary(fit_gdp)

```

> Additionally, we went on to check whether there were non-lineaer association in this datset. Using poly() function, in terms of GDP, (except 4th polynomial) they had siginificantly low p-values. At this point, we may say that there is a non-linear association between the number of Starbucks stores and the level of GDP of each countries.



```{r, echo=FALSE}

fit_pop = lm(starbucks ~ poly(Population, 4), data = Final_data)
summary(fit_pop)

```


> Also, we wanted to check non-linear assocaition win terms of Population. Except third polynomial, the rest of them were statistically significant.


### 2) US: Relationship between Number of Starbucks and State GDP

#### (a) Linear regression


```{r}

#lm number of store VS GDP
lm_df=lm(store~GDP,  data=State_GDP_SB)

summary(lm_df)

```


> According to Starbucks data, there was a total of 24,459 Starbucks stores in the world. However, we found that more than half of the Starbucks stores were found in the United States, which 13,608 stores. So we decided to separate US data and analyzed the correlation between the number of Starbucks stores in each state and each state GDP.

> *Figure7* and *Figure8* are the choropleth map that shows the number of GDP and stores in the US. Both figures show similar trends that California and Texas have both high GDP and number of the store. 
However, to find a more accurate correlation, we implemented a linear model of the number of stores and GDP. 

> *Figure9* shows the linear regression graph our linear model. The plot is normally distributed and each point are lined well on the straight dashed line.Moreover, the p-value of the linear model was 2e-16 which is smaller than 0.05, and R squared and adjusted R squared is 0.85, which close to 1. Therefore, since we got a significant p-value, R squared, and adjust R squared, we can conclude it is statistically significant between the number of Starbucks stores and GDP.


```{r}

# r squared value of our model
"R squared Value"
summary(lm_df)$r.squared


# adjusted r squared value of our model
"Adjust R squared Value"
summary(lm_df)$adj.r.squared

```
> According to summary of our model, both r-squared(0.8804866) and adjusted r-squared(0.8622998) had values close to 1, so we can say that our model is good and reliable.

```{r}

ggplot(State_GDP_SB, show.legend=TRUE) + 
  ggtitle("Figure7: Number of Starbucks Stores relation to GDP by State") +
  geom_point(aes(y=store, x=GDP)) + 
  geom_abline(slope=lm_df$coefficients[2], intercept = lm_df$coefficients[1], color="red")

#P-value <2e-16 -> significant

```


#### (b) Choropleth map

```{r message=FALSE, echo=FALSE}

library(ggiraphExtra)


state_map<-map_data("state")

ggChoropleth(data=State_GDP_SB,
             mapping=aes(map_id=State,fill=GDP),map=state_map, title = "Figure8: Choropleth map of GDP by State")


ggChoropleth(data=State_GDP_SB,
             mapping=aes(map_id=State,fill=store),map=state_map, title = "Figure9: Choropleth map of Number Starbucks Store by State ")


```

#### (c) Non-linear Association

```{r, echo=FALSE}

fit_gdp2 = lm(store ~ poly(GDP, 4), data = State_GDP_SB)
summary(fit_gdp2)

```
> We had check non-linear association terms between number of Starbucks store and GDP using Polynomial Regression. From the result,except quadratic term, the rest of them were statistically significant.

## Conclusion

>| We were interested in the relationship between the number of starbucks stores and other various countries' data. Then, we found out that United States had overwhelmingly many starbucks stores compared to other countries, so as a country scale, including United States in the data had the possibility of distorting data. Accordingly, we separated United States and delved into it in a more domestic and microscopic way. According to subsequent linear regression analyzing the correlation between the number of starbucks stores with other predictors on a U.S. state level, we discovered that 'GDP' was the most explanatory predictor. We found out the relation with GDP using linear regression model and geographic visualizations. Back to a country scale excluding United States, 'GDP' and 'Pouplation' of countries had higher correlation with the number of starbucks stores according to linear regression model. To quench our curiosity, we also went on to check non-linear association and re-confirmed that 'GDP' and 'Population were still statistically significant. <br> We have done by dissecting this project into two parts: United State's domestic level, and international level. By looking at U.S. domestic level and international level with United States, GDP was assumed to be the strong predictor correlated with the number of stores. <br> Of course, there existed limitation on these results. The number of stores in starbucks dataset was not accurate, due to missing countries (Italy) and wrong data inputs. Also, the correlation we found is not equivalent to causality. Therefore, more explanations and further analysis has to be done. Also, off the top of our head, we intuitively can predict that the more prosperous and richer the region or country is, the more starbucks stores located at. Though there was not a novel discovery in our project, it is an undeniable fact that 'GDP' is the powerful predictor correlated with the number of starbucks stores. To sum up, in terms of the indicators of 'GDP' and 'population' we were able to reject the null hypotheses.
