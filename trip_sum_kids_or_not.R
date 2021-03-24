source('travel_survey_analysis_functions.R')




#where you are running your R code
wrkdir <- "C:/Users/SChildress/Documents/GitHub/travel_studies/2019/analysis"

#where you want to output tables

sql.trip.query <- paste("SELECT age, person_dim_id, d_purpose, main_mode,mode_simple, trip_wt_combined, trip_weight_revised, trip_wt_2019,
                        trip_path_distance, travelers_hh
                        FROM HHSurvey.v_trips_2017_2019")
trips <- read.dt(sql.trip.query, 'sqlquery')
trips_no_na<-trips %>% drop_na(all_of('trip_wt_combined'))
# this could get siblings going places to together, but whatever, this is kids traveling with household members
kid_trips_w_hh<-trips_no_na%>%filter(age<18 & travelers_hh>1)
kid_trips_all<-trips_no_na %>% filter(age<18 )
trips_no_kids<-trips_no_na %>% filter(age>=18)

#how many trips were observed and weighted?
count(trips_no_na)
count(kid_trips_w_hh)
count(kid_trips_all)


#weighted trips
sum(trips_no_na$trip_wt_combined)
sum(kid_trips_w_hh$trip_wt_combined)
sum(kid_trips_all$trip_wt_combined)


#all weighted trips by mode
create_table_one_var('main_mode', trips_no_na, "trip")
create_table_one_var('main_mode', trips_no_kids, "trip")

#all weighted trips by purpose
create_table_one_var('d_purpose', trips_no_na, "trip")
create_table_one_var('d_purpose', trips_no_kids, "trip")
