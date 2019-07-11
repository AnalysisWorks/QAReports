
######################################################
#		Assign Arguments from PowerShell
######################################################

checkPSArgs <- function(args, argLen){
    ####    TODO
    #Replace powershell input arguments with a single hashtable
    for(i in 1:argLen){
        if(is.null(args[i])){
            stop("Missing PS arugment:", i, call.=FALSE)
        }
    }
}
########	Arguments from RScript.exe		########
args <- commandArgs(trailingOnly =  TRUE)
checkPSArgs(args, 4)

extract_file <- args[1]
extract_path <- args[2]
file_delimiter <- args[3]
extension <- args[4]


######################################################
#		Link R Scripts
######################################################

source("C:\\Users\\zwarnes\\Documents\\ZW_AW\\QA-Tools\\Manual QA Tool\\Local-Tests\\RScripts\\data_type_checks.R")
source("C:\\Users\\zwarnes\\Documents\\ZW_AW\\QA-Tools\\Manual QA Tool\\Local-Tests\\RScripts\\data_conversion.R")
source("C:\\Users\\zwarnes\\Documents\\ZW_AW\\QA-Tools\\Manual QA Tool\\Local-Tests\\RScripts\\file_reading.R")

######################################################
#		Set up Packages
######################################################

require("readxl")
require("readr")

######################################################
#		Powershell to R, Workarounds
######################################################

if(file_delimiter == "pipe"){
    file_delimiter <- "|"
}
if(file_delimiter == "carat"){
    file_delimiter <- "^"
}

####    TODO
#Improve paramter passing from powershell to handle spaces in files
extract_file <- gsub("#", " ", extract_file)
extract_path <- gsub("#", " ", extract_path)

extract_file <- paste(extract_path, extract_file, sep = "\\")

print(extract_file)

######################################################
#		Run Main Scripts
######################################################
classCounts <- rbind()

if(extension != "xls" && extension != "xlsx"){
    #extractData <- read(extract_file,  delim = file_delimiter, ext=extension)
    extractData <- read(extract_file,  delim = file_delimiter, ext=extension)

    #Convert POSIX fields to character fields these can then be converted to dates
    extractData <- convertAllPOSIX( extractData)
    #check <- t( metaDataCheck( extractData))

    extractData <- determineDataTypes( extractData)$data

    classes <- as.matrix( sapply( extractData, class))
    classCounts <- classes

}else{
    for(sheetNum in 1:length(excel_sheets(extract_file))){
        #Read data into one or more data frames (excel files have one data frame per sheet)
        extractSheet <- read(extract_file,  delim = file_delimiter, ext=extension, sheetNum = sheetNum)

        if(all(is.na(extractSheet))){
            next
        }
        #Convert POSIX fields to character fields these can then be converted to dates
        extractSheet <- convertAllPOSIX( extractSheet)
        #check <- t( metaDataCheck( extractSheet))

        extractSheet <- determineDataTypes( extractSheet)$data
        classes <- as.matrix( sapply( extractSheet, class))
        classCounts <- classCounts + classes
    }
}

classCounts