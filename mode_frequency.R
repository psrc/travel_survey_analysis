source('travel_survey_analysis_functions.R')
# Code Examples -----------------------------------------------------------
#Read the data from Elmer

#You can do this by using read.dt function. The function has two arguments: 
# first argument passes a sql query or a table name (as shown in Elmer)
# in the second argument user should specify if the first argument is 'table_name' or 'sqlquery'

#Here is an example using sql query - first, you need to create a variable with the sql query
# and then pass this variable to the read.dt function
sql.query = paste("SELECT * FROM HHSurvey.v_persons_2017_2019_in_house")
person = read.dt(sql.query, 'sqlquery')

#If you would like to use the table name, instead of query, you can use the following code
#that will produce the same results
person = read.dt("HHSurvey.v_persons_2017_2019", 'table_name')


#Check the data
# this step will allow you to understand the variable and the table that you are analyzing
#you can use the following functions to check for missing values, categories, etc.

#this function will allow you to see all of the variables in the table, check the data type,
#and see the first couple of values for each of the variables
glimpse(person)

# to check the distribution of a specific variable, you can use the following code
#here, for example, we are looking at mode_freq_5 category 
person %>% group_by() %>% summarise(n=n())

#if you analyze a numerical variable, you can use the following code to see the variable range
describe()


#to delete NA you can use the following code
#the best practices suggest to create a new variable with the updated table

person_no_na = person %>% filter(!is.na(mode_freq_1))

#when we re-run the distribution code, we see that we've eliminated NAs
person_no_na %>% group_by(mode_freq_1) %>% summarise(n=n())

# to exclude missing codes, you can use the following code
#note, that we've assigned missing_codes at the beginning of the script(lines 20-21)
person_no_na = person_no_na %>% filter(!mode_freq_1 %in% missing_codes)


#Create summaries

# to create a summary table based on one variable, you can use create_table_one_var function.
#The function create_table_one_var has 3 arguments:
# first, you have to specify the variable you are analyzing
#second, enter table name
#third, specify the table type e.g. person, household, vehicle, trip, or day. This will
# help to use correct weights

#here is an example for mode_freq_5 variable

transit<-create_table_one_var("mode_freq_1", person_no_na,"person" )
write.table(transit, "clipboard", sep="\t", row.names=FALSE)




person_no_na = person %>% filter(!is.na(mode_freq_2))

#when we re-run the distribution code, we see that we've eliminated NAs
person_no_na %>% group_by(mode_freq_2) %>% summarise(n=n())

# to exclude missing codes, you can use the following code
#note, that we've assigned missing_codes at the beginning of the script(lines 20-21)
person_no_na = person_no_na %>% filter(!mode_freq_2 %in% missing_codes)


#Create summaries

# to create a summary table based on one variable, you can use create_table_one_var function.
#The function create_table_one_var has 3 arguments:
# first, you have to specify the variable you are analyzing
#second, enter table name
#third, specify the table type e.g. person, household, vehicle, trip, or day. This will
# help to use correct weights

#here is an example for mode_freq_5 variable

transit<-create_table_one_var("mode_freq_2", person_no_na,"person" )
write.table(transit, "clipboard", sep="\t", row.names=FALSE)




person_no_na = person %>% filter(!is.na(mode_freq_3))

#when we re-run the distribution code, we see that we've eliminated NAs
person_no_na %>% group_by(mode_freq_3) %>% summarise(n=n())

# to exclude missing codes, you can use the following code
#note, that we've assigned missing_codes at the beginning of the script(lines 20-21)
person_no_na = person_no_na %>% filter(!mode_freq_3 %in% missing_codes)


#Create summaries

# to create a summary table based on one variable, you can use create_table_one_var function.
#The function create_table_one_var has 3 arguments:
# first, you have to specify the variable you are analyzing
#second, enter table name
#third, specify the table type e.g. person, household, vehicle, trip, or day. This will
# help to use correct weights

#here is an example for mode_freq_5 variable

transit<-create_table_one_var("mode_freq_3", person_no_na,"person" )
write.table(transit, "clipboard", sep="\t", row.names=FALSE)
