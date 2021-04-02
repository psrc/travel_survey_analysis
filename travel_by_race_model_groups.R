source('travel_survey_analysis_functions.R')




#where you are running your R code
wrkdir <- "C:/Users/SChildress/Documents/GitHub/travel_studies/2019/analysis"

#where you want to output tables
file_loc <- 'C:/Users/SChildress/Documents/HHSurvey/race_story/afr_am/new_cats'

sql.trip.query <- paste("SELECT race_category, person_dim_id, mode_simple, trip_wt_combined FROM HHSurvey.v_trips_2017_2019")
trips <- read.dt(sql.trip.query, 'sqlquery')

sql.person.query<-paste("SELECT  race_afam, race_aiak, race_asian, race_hapi, race_hisp, race_white, race_other, race_noanswer,age_category, race_category,person_id, vehicle_count,commute_auto_time,
commute_auto_Distance, mode_freq_1,  mode_freq_2,  mode_freq_3, mode_freq_4, mode_freq_5,
wbt_transitmore_1, wbt_transitmore_2, wbt_transitmore_3, wbt_bikemore_1, wbt_bikemore_2, wbt_bikemore_3,
hh_wt_combined FROM HHSurvey.v_persons_2017_2019_in_house")


persons<-read.dt(sql.person.query, 'sqlquery')

race_cols <- c('race_afam', 'race_aiak', 'race_asian', 'race_hapi', 'race_hisp', 'race_white', 'race_other')
race_cols_non_hisp <- c('race_afam', 'race_aiak', 'race_asian', 'race_hapi', 'race_white', 'race_other')
non_white_races<-c('race_afam', 'race_aiak', 'race_asian', 'race_hapi', 'race_other')

persons<-persons %>% mutate_at(race_cols,funs(recode(.,'Selected'=1, 'Not Selected'=0, .default=0))) %>%
                    mutate_at(race_cols,funs(as.numeric(.))) %>%
                    rowwise() %>%
                    mutate(num_races =sum(c_across(race_cols_non_hisp))) %>%
                    mutate(num_non_white_races =sum(c_across(non_white_races)))
  

persons<-persons %>%
  dplyr::mutate(
    model_race_category = dplyr::case_when(num_races>1 ~ "Two or more races",
                                         race_hisp==1 & num_non_white_races>=1 ~ "Hispanic, Non-white",
                                         race_hisp==1 ~ "Hispanic, white",
                                         race_aiak==1 | race_hapi==1 | race_other== 1 ~ "Non-Hispanic, Other",
                                         race_afam==1 ~ "Non-Hispanic, Black",
                                         race_asian== 1 ~ "Non-Hispanic, Asian",
                                         race_white==1 ~ "Non-Hispanic, White")
  )

persons<- persons %>%
  mutate(model_race_category=replace_na(model_race_category='Missing'))
         
  




  
         mutate
persons<-persons %>%
  mutate(afr_am_race_category=ifelse(afr_am_race_category %in% c('Child','Missing'), 
                                     'Child, Missing', afr_am_race_category))



trips$afr_am_race_category<-trips$race_category


trips<-trips %>%
  mutate(afr_am_race_category=ifelse(afr_am_race_category %in% c('Hispanic', 'Other'), 
                                     'Hispanic, or Other Race', afr_am_race_category))

trips<-trips %>%
  mutate(afr_am_race_category=ifelse(afr_am_race_category %in% c('Child','Missing'), 
                                     'Child, Missing', afr_am_race_category))

# Find the count of people in each category
person_wt_field<- 'hh_wt_combined'
person_count_field<-'person_dim_id'
group_cat <- 'afr_am_race_category'

persons_no_na<-persons %>% drop_na(all_of(person_wt_field))


sample_size_group<- persons_no_na %>%
                    group_by(afr_am_race_category) %>%
                    summarize(sample_size = n_distinct((person_dim_id)))
  
sample_size_MOE<- categorical_moe(sample_size_group)

# Auto Ownership ####################################################

vars_to_summarize<-c('vehicle_count', 'mode_freq_1',  'mode_freq_2',  'mode_freq_3', 'mode_freq_4', 'mode_freq_5',
                    'wbt_transitmore_1', 'wbt_transitmore_2', 'wbt_transitmore_3', 
                    'wbt_bikemore_1', 'wbt_bikemore_2', 'wbt_bikemore_3')

for(var in vars_to_summarize){
  cross_table<-cross_tab_categorical(persons_no_na,group_cat, var, person_wt_field)
  cross_table_w_MOE<-merge(cross_table, sample_size_MOE, by=group_cat)
  write_cross_tab(cross_table_w_MOE,group_cat,var,file_loc)
}

trips_no_na<-trips %>% drop_na(all_of('trip_wt_combined'))

cross_table<-cross_tab_categorical(trips_no_na,group_cat, 'mode_simple', 'trip_wt_combined')
cross_table_w_MOE<-merge(cross_table, sample_size_MOE, by=group_cat)
write_cross_tab(cross_table_w_MOE,group_cat,'mode_simple',file_loc)

