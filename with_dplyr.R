#This R program demonstrates the pipelining feature in dplyr

library(jsonlite)
library(tibble)
library(dplyr)
library(stringr)
library(tidyr)

#stream_in() used as it is a NDJSON file; fromJSON works with general json files
yelp <- stream_in(file("yelp_academic_dataset_business.json"))

#Make nested data more readable (dot notation for nesting)
yelp_flat <- flatten(yelp)
str(yelp_flat)

#displays data type and first 10 records
yelp_tbl <- as_data_frame(yelp_flat)
yelp_tbl

#Changing type from list to character so that entries are visible
#yelp_tbl %>% mutate(categories = as.character(categories)) %>% select(yelp_tbl$categories)
yelp_tbl$categories = as.character(yelp_tbl$categories)

#removing unnecessary columns - those that start with hours and attribute
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute"))

#counting nuber of restaurants in the list
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant"))

#checking if count is accounting for list entries in categories
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  mutate(categories = as.character(categories)) %>% select(categories)

#unnest the categories which can be used to count against each categories
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  select(name, categories)

#counting categories
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  select(name, categories) %>%
  count(categories )%>%
  arrange(desc(n))
#in descending order

#removing restaurant from category
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  filter(categories != "Restaurants") %>%
  count(categories) %>%
  arrange(desc(n))

#displaying top categories for condition of (states and categories)
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  filter(categories != "Restaurants") %>%
  count(state, categories) %>%
  arrange(desc(n))

#top category for each state
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  filter(categories != "Restaurants") %>%
  count(state, categories) %>%
  top_n(1, n)

#same as above in descending order
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  filter(categories != "Restaurants") %>%
  count(state, categories) %>%
  top_n(1, n) %>%
  arrange(desc(n))

#all counts above 10
yelp_tbl %>% select(-starts_with("hours"), -starts_with("attribute")) %>%
  filter(str_detect(categories, "Restaurant")) %>%
  unnest(categories) %>%
  filter(categories != "Restaurants") %>%
  count(state, categories) %>%
  filter(n > 10) %>%
  top_n(1, n)

