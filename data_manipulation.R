library(stringi)

presenceCheck <- function( extractData){
    
    presenceVec <- cbind()
    NullVal <- ""
    #Determine column counts for possible null values
    vecNA      <- sapply( extractData, function(x) sum(!is.na(x)))

    #Define functions to create vector
    percentFunction <- function(x) round( (x / nrow(extractData)), 2) 
    percentStringFunction <- function(x) paste(toString(x*100), "%", sep="")

    presenceVec <- sapply( sapply(vecNA, percentFunction), percentStringFunction)
    NullVal <- "na"
    
    presenceVec <- list("prensenceVec" = presenceVec, "NULL_Value" = NullVal)
}

presenceNumber <- function(extractData){
    presenceVec <- cbind()
    NullVal <- ""
    #Determine column counts for possible null values
    vecNA      <- sapply( extractData, function(x) sum(!is.na(x)))

    #Define functions to create vector
    percentFunction <- function(x) round( (x / nrow(extractData)), 2) 

    presenceVec <- sapply(vecNA, percentFunction)
    presenceVec
}

#takes in data frame from csv 
#determines the data types for each field
#returns a data frame, with meta data about the extract
metaDataCheck <- function( extractData, extractPath, extractName, ext, qualifier, delimiter, isExcel = 0){
    
    #Calculate how often a field is populated
    Presence <- presenceCheck( extractData)
    NullValue <- Presence$NULL_Value

    print( paste("Null value used: " , NullValue))
    Presence <- Presence$prensenceVec

    #counts the distinct values in each field
    Uniques <- apply(extractData, 2, function(x) length( unique( x)))
    print( "Unique Values checked")

    #calculate data types
    typedDataList <- determineDataTypes( extractData)
    print( "data types determined")

    extractDataTyped <- typedDataList$data
    dateForm <- typedDataList$formats

    #determine the type of each field
    typeVec <- sapply( extractDataTyped, class)
    print( "data classes determined")

    #determine top 3 values for each field for categorical fields
    #determine min and max for date and numeric fields
    Type <- cbind()
    DPType <- cbind()
    DPLen <- cbind()
    Features <- cbind()

    Description <- cbind()
    Detail_1 <- cbind()
    Detail_2 <- cbind()
    Detail_3 <- cbind()

    FieldCols <- list()

    for(i in 1:ncol( extractDataTyped) ){

        if ( typeVec[i] == "numeric"){

            maxVal <- max(extractDataTyped[,i], na.rm = TRUE)
            minVal <- min(extractDataTyped[,i], na.rm = TRUE)
            avgVal <- mean(extractDataTyped[,i], na.rm = TRUE)

            Type[i] <- "Numeric"
            Features[i] <- sprintf("Max: %f, Min: %f", maxVal, minVal)

            Description[i] <- "Min Value - Max Value - Average Value"
            Detail_1[i] <- minVal
            Detail_2[i] <- maxVal
            Detail_3[i] <- avgVal
        }
        else if ( typeVec[i] == "Date"){
            maxVal <- format(max(extractDataTyped[,i], na.rm = TRUE),"%B %d %Y")
            minVal <- format(min(extractDataTyped[,i], na.rm = TRUE),"%B %d %Y")

            Type[i] <- "Datetime"
            Features[i] <- sprintf("Start: %s, End: %s, Format[%s]", minVal, maxVal, dateForm[i])

            Description[i] <- "Start Date - End Date - Date Format"
            Detail_1[i] <- minVal
            Detail_2[i] <- maxVal
            Detail_3[i] <- dateForm[i]
        }
        else if ( typeVec[i] == "POSIXct" || typeVec[i] == "POSIXlt" || typeVec[i] == "POSIXt" ){
            maxVal <- format(max(extractDataTyped[,i], na.rm = TRUE),"%H:%M")
            minVal <- format(min(extractDataTyped[,i], na.rm = TRUE),"%H:%M")

            Type[i] <- "Datetime"
            Features[i] <- sprintf("Start: %s, End: %s, Format: [%s]", minVal, maxVal, dateForm[i])
        }
        else{
            frequencyTable <- sort( table( extractDataTyped[,i]), decreasing = TRUE)[1:3]
            val <- as.character(frequencyTable)
            key <- names(frequencyTable)
            key <- replace(key, is.na(key), "Null")
            if(all(is.na(key))){
                Type[i] <- "Empty"
                Features[i] <- sprintf( "No values parsed in this field.")

                Description[i] <- "No values parsed in this field"
                Detail_1[i] <- "NULL"
                Detail_2[i] <- "NULL"
                Detail_3[i] <- "NULL"
            }
            else{
                Type[i] <- "Text"
                FeatureString <- sprintf("Top Values: %s (%s)", key[1], val[1])
                if (!is.na(val[2])) FeatureString <- paste(FeatureString, sprintf(", %s (%s)", key[2], val[2]))
                if (!is.na(val[3])) FeatureString <- paste(FeatureString, sprintf(", %s (%s)", key[3], val[3]))
                Features[i] <- FeatureString

                Description[i] <- "Top 3 occuring values - [occurences]"
                Detail_1[i] <- paste0( key[1], " [", val[1], "]")
                Detail_2[i] <- paste0( key[2], " [", val[2], "]")
                Detail_3[i] <- paste0( key[3], " [", val[3], "]")
            }
        }
    }
    metaData <- rbind(Presence, Uniques , Type, Features)
    logData <- rbind( extractName, ext, delimiter, format(Sys.Date(), "%Y-%m-%d"), names(extractData), Type, presenceNumber(extractData), Uniques, Description, Detail_1, Detail_2, Detail_3,  format(Sys.Date(), "%Y-%m-%d"), "")
    keyData <- list("metaData" = metaData, "logData" = logData)
    keyData
}
