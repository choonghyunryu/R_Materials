#!/bin/sh

if [ "$#" -ne 1 ]
then
   echo "Usage : get_summary_system.sh top_n" >&2
   exit 1
else
   top_n=$1
fi

cut -d ' ' -f 1-6 /var/log/system.log | uniq | awk '{gsub(/\[[0-9]+\][:]*/, ""); print}' | \
  grep "^Oct" | cut -d ' ' -f 5 | sort | uniq -c | awk '{print $2","$1}' > call_service.csv
  
R --quiet --no-echo --vanilla << RCH
library(tidyverse)

call_service <- read.csv("call_service.csv", header = FALSE)

p <- call_service %>% 
  mutate(frequency = V2,
         service = forcats::fct_reorder(V1, V2, .desc = TRUE)) %>% 
  arrange(desc(frequency)) %>%        
  head(n = $top_n) %>%        
  ggplot(aes(x = service, y = frequency)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  ggtitle("Frequency of service call") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

ggsave(file = "service.pdf", width = 6, height = 4)
RCH

rm call_service.csv