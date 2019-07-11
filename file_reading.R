require("readr")
require("readxl")
require("stringr")

#### TODO
# File handling for various formats of same file extensions
#
# csv with trailing ',' currently a fake column is created
# missing columns for txt and csv
#

#returns data frame with all the data from the relevant file
read <- function( extractName, delim, ext, sheetNum = 1, textQualifier = "\""){

    # Column specs determined when reading the first 100,000 rows
    # this can cause errors in the column presence if a field is determined to be different than what is actual.
    # However this column spec is still beneficial when manipulating data, thus no default is set.
    # White space is removed
    n_max <- 100000    
    if(ext == "xls" || ext == "xlsx"){
        dataFrame <- as.data.frame( readExcel( extractName, sheetNum))
    }
    # \t gets interpreted as \\t literal in R
    else if( delim == "\\t"){
        dataFrame <- as.data.frame( read_tsv( file = extractName, guess_max = n_max, na = c("", "NA", "NULL" ), trim_ws = TRUE ))
    }
    else if( delim == "fixed"){


        line <- readLines( extractName, n = 1)

        widths <- list( nchar(unlist(regmatches(line, gregexpr("\\s+\\S+", line)))))
        #for( i in 1:length(line)){
        #    w[i] <- list( nchar(unlist(regmatches(line[i], gregexpr("\\s+\\S+", line[i])))))
        #}
        ## TODO
        # determine highest occurence of list
        # this determines the unique widths determined 
    
        dataFrame <- as.data.frame( read.fwf( file = extractName, widths = widths, header = FALSE, strip.white = TRUE, na.strings = c("","NA","NULL")))
    }
	else{
		dataFrame <- as.data.frame( read_delim( file = extractName, delim = delim, guess_max = n_max, na = c("", "NA", "NULL" ), trim_ws = TRUE ))
	}
	dataFrame
}


readExcel <- function( extractName, sheetNum){

    if(sheetNum > length(excel_sheets( extractName))){
        extractData <- NA
    }
    else{
        extractData = tryCatch(
            {
                read_excel( extractName, sheet = sheetNum)
            }, 
            warning = function(w) 
            {
                print("Warning in read function, some features may be limited")
                print(w)
            },
            error = function(e)
            {
                print("Error in excel read function")
                print(e)
                break
            },
            finally = 
            {
                print("Finished reading excel sheet")
            }
        )
    }
    extractData <- as.data.frame( extractData)

    #If there is less than 100 cells, assume the sheet is notes
    if( nrow( extractData) * ncol( extractData) < 100){
        extractData <- NA
    }
    extractData
}

malformed_Rows_Check <- function(file, delim){
    library(stringr)
	res <- readLines(file)
	columns <- str_count(res[1], delim)	

	problem_rows <- c()
	for(i in 2:length(res)){
		if(str_count(res[[i]], delim) != columns){
			problem_rows <- c(problem_rows, i)	
		}
	}
    problem_rows
}