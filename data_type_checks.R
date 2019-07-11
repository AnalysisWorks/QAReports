#takes in input data and a date format
#returns a boolean vector based on what columns satisfy the format given
dateType <- function(dataFrame, dateFormat = "%d/%m/%y"){
    dataVec = tryCatch(
        #check to see if the format applies to at least 0.1% of the rows 
        sapply( dataFrame, function(x) sum(!is.na( as.Date( as.character(x), format = dateFormat))) > nrow(dataFrame)/1000 ),
    error = function(err) {FALSE})

    dateCheck = dataVec
}
#takes in input data and a date format
#returns a boolean vector based on what columns satisfy the format given
timeType <- function(dataFrame, dateFormat = "%H:%M"){
    dataVec = tryCatch(
        #check to see if the format applies to at least 0.1% of the rows 
        sapply( dataFrame, function(x) sum(!is.na( as.strptime( as.character(x), format = dateFormat))) > nrow(dataFrame)/1000 ),
    error = function(err) {FALSE})

    dateCheck = dataVec
}



#takes in dataframe
#returns boolean with TRUE when the field is numeric 99% of the time
numType <- function(dataFrame){
    numVec = tryCatch(
        sapply( dataFrame, function(x) sum(!is.na( as.numeric(x) ) ) > nrow(dataFrame) * 0.99),
    error = function(err) {FALSE})

    numCheck <- numVec
}

#takes in dataFrame
#returns a boolean vector where the column does not have a type
catType <- function(dataFrame){
    catCheck <- sapply( dataFrame, function(x) is.na(x))
}

#Create functions to check for POSIX data types
is.POSIXct <- function(x) inherits( x, "POSIXct")
is.POSIXlt <- function(x) inherits( x, "POSIXlt")
is.POSIXt <- function(x) inherits( x, "POSIXt")

#Retrive boolean vector to find POSIX data types
POSIXctType <- function(dataFrame){
    POSIXctCheck <- sapply( dataFrame, function(x) is.POSIXct(x))
}
POSIXltType <- function(dataFrame){
    POSIXltCheck <- sapply( dataFrame, function(x) is.POSIXlt(x))
}
POSIXtType <- function(dataFrame){
    POSIXtCheck <- sapply( dataFrame, function(x) is.POSIXt(x))
}