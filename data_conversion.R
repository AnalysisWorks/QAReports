
# Some clients use horrible date time formats that
# should only be used if absolutely required
# i.e. yyyymmdd = %Y%m%d cannot be distinguished from
# any number with the same or similar length nor can
# order of day month year be determined.
# some datetime foramts are rarely used and have been commented out
# the two lists below should cover most possible dateforamts
date.Formats <- c( 
    #"%Y%m%d",
    "%Y-%m-%d",  
    "%m/%d/%Y",  
    "%d/%m/%Y",
    "%Y/%m/%d",
    
	"%b-%d-%Y", 
	"%B-%d-%Y",  
	"%d-%m-%Y",
	"%d-%b-%Y",
	"%m-%d-%Y",
	"%Y-%b-%d",
	"%Y-%B-%d",
    
    "%b/%d/%Y",
    "%d/%m/%Y",
	"%B/%d/%Y",
    "%m/%d/%Y",  
	"%Y/%b/%d",
	"%Y/%B/%d",
    "%b %d, %Y",
    
    #"%Y%m%d"
	
    "%B %d, %Y",
	"%B %d, %Y %H:%M"

    #"%Y%b%d",   
	#"%Y%B%d", 
	#"%d%b%Y",

    #"%Y-%m-%d %H:%M:%S%f",
	#"%d-%b-%Y %H:%M:%S",
	#"%d-%b-%Y %I:%M:%S",  
	#"%Y-%m-%d %H:%M:%S",

    #"%d/%m/%Y %H:%M:%S",
	#"%d/%m/%Y %I:%M",
	#"%d/%m/%Y %I:%M:%S",
    #"%d%b%Y %H:%M:%S"
)

date.FormatsExtra <- c(    
    "%Y-%m-%d %H%M%S%f",  "%Y/%m/%d %H:%M:%S%f",  "%Y%m%d %H%M%S%f",
	"%Y%m%d %H:%M:%S%f",  "%m/%d/%Y %H:%M:%S%f",  "%m-%d-%Y %H:%M:%S%f",
	"%Y-%b-%d %H:%M:%S%f",  "%Y/%b/%d %H:%M:%S%f",  "%Y%b%d %H%M%S%F",
	"%Y%b%d %H:%M:%S%F",  "%b/%d/%Y %H:%M:%S%f",  "%b-%d-%Y %H:%M:%S%f",
	"%d.%b.%Y %H:%M:%S%f",  "%d%b%Y %H%M%S%f",  "%d%b%Y %H:%M:%S%f",
	"%d-%b-%Y %H%M%S%f",  "%d-%b-%Y %H:%M:%S%f",  "%Y-%B-%d %H:%M:%S%f",
	"%Y/%B/%d %H:%M:%S%f",  "%Y%B%d %H%M%S%f",  "%Y%B%d %H:%M:%S%f",
	"%B/%d/%Y %H:%M:%S%f",  "%B-%d-%Y %H:%M:%S%f",  "%d.%B.%Y %H:%M:%S%f",
	"%a %b %d %H:%M:%S%F %Y",  "%a %d %b %Y %H:%M:%S%F",  "%Y-%m-%d %H:%M:%S%Z",
	"%a %b %d %H:%M:%S%F xxx %Y"  
)

time.Formats <- c( 
    "%H:%M",
    "%H:%M:%S",
    "%H.%M",
    "%H.%M.$S"
)

#takes in input data, boolean vector and date format
#returns data with date columns formatted
dateConvert <- function( dataFrame, booleanVec,dateForms, dateFormat){
    for(i in 1:length( booleanVec)){
        if( booleanVec[[i]] && is.na( dateForms[[i]])){
            dataVec = tryCatch(
            {
                as.Date( as.character( dataFrame[[i]]), dateFormat)
            }, 
            warning = function(w) {
                dataFrame[[i]]
                print(w)
            }, 
            error = function(e) {
                dataFrame[[i]]
            }, 
            finally = {
                #Clean up code
            }
            )
            dataFrame[[i]] <- dataVec
        }
    }
    dataFrame
}

#takes in input data, boolean vector and time format
#returns data with time columns formatted
timeConvert <- function( dataFrame, booleanVec, timeForms, timeFormat){
    for(i in 1:length( booleanVec)){
        if( booleanVec[[i]] && is.na(timeForms[[i]])){
            dataVec = tryCatch(
            {
                strptime( as.character(dataFrame[[i]]), timeFormat)
            }, 
            warning = function(w) {
                dataFrame[[i]]
                print(w)
            }, 
            error = function(e) {
                dataFrame[[i]]
            }, 
            finally = {
                #Clean up code
            }
            )
            dataFrame[[i]] <- dataVec
        }
    }
    dataFrame
}

#takes in input data, boolean vector
#returns data with numeric columns formatted
numConvert <- function( dataFrame, booleanVec){
    for(i in 1:length( booleanVec)){
        if( booleanVec[[i]]){
            dataFrame[[i]] <- as.numeric( dataFrame[[i]])
        }
    }
    dataFrame
}

#takes in the extract data and a boolean vector
#converts unknown data types to categorical (factor) data type
catConvert <-function( dataFrame, booleanVec){
    for(i in 1:length( booleanVec)){
        if( booleanVec[[i]]){
            dataFrame[[i]] <- type.convert( dataFrame[[i]], as.is = TRUE)
        }
    }
    dataFrame
}

#Convert all POSIX data types into character types
#Character types can then be properly converted to dates
#These data types are used for timezones, currently these are not needed
convertAllPOSIX <- function( dataFrame){
    boolPOSIX <- POSIXctType( dataFrame)

    for(i in 1: length( boolPOSIX)){
        if( boolPOSIX[[i]]){
            dataFrame[[i]] <- as.character( dataFrame[[i]])
        }
    }
    boolPOSIX <- POSIXltType( dataFrame)

    for(i in 1: length( boolPOSIX)){
        if( boolPOSIX[[i]]){
            dataFrame[[i]] <- as.character( dataFrame[[i]])
        }
    }
    boolPOSIX <- POSIXtType( dataFrame)

    for(i in 1: length( boolPOSIX)){
        if( boolPOSIX[[i]]){
            dataFrame[[i]] <- as.character( dataFrame[[i]])
        }
    }
    dataFrame
}

####TODO 
#Update to handle fields with only time values
#Set dates as global variable
determineDataTypes <- function( dataFrame){
    #check for numeric fields
    bool.Vec <- numType( dataFrame)
    newData <- numConvert( dataFrame, bool.Vec)

    #hold specific format information by column
    dateForm <- data.frame( matrix( nrow = 1, ncol = ncol( dataFrame))) 
    names(dateForm) <- names( dataFrame)

    #check for date fields
    for(form in date.Formats){
        
        bool.Vec <- dateType( newData, form)
        if( any( bool.Vec)){
            #convert the date field
            newData <- dateConvert( newData, bool.Vec, dateForm, form) 

            #update the format dataframe
            for(i in 1:length(bool.Vec)){
                if(bool.Vec[[i]] && is.na(dateForm[[i]])){
                    dateForm[i] <- form
                }
            }
        }
    }
    "
    #check for time fields
    for(form in time.Formats){
        bool.Vec <- timeType( newData, form)
        if( any( bool.Vec)){
            #convert the date field
            newData <- timeConvert( newData, bool.Vec, dateForm, form) 

            #update the format dataframe
            for(i in 1:length(bool.Vec)){
                if(bool.Vec[[i]] && is.na(dateForm[[i]])){
                    dateForm[i] <- form
                }
            }
        }
    }
    "
    typeDataList <- list("data" = newData, "formats" = dateForm)
    typeDataList
}
