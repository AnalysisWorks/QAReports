#!C:\Program Files\R\R-3.6.1\bin\Rscript.exe
######################################################
# To Execute R in Visual Studio Code
#
# 'CRTL' + 'Enter'
# 'CRTL' + 'A' + 'Enter' (runs whole script)
# This initializes R, then runs the selected code
#
######################################################


######################################################
#		ENVIRONMENT SETUP
######################################################

######################################################
#		Set up Paths
######################################################
if(grepl("aworks200", getwd(), fixed = TRUE)) {
    .libPaths( "\\\\aworks200\\AnalysisWorks\\Applications\\R\\R-3.5.1\\library")
    latexPath <- "\\\\aworks200\\AnalysisWorks\\Applications\\R\\MiKTeX\\miktex\\bin\\x64\\"
    Sys.setenv( PATH = paste( Sys.getenv( "PATH"), latexPath, sep = ";"))
    Sys.setenv( RSTUDIO_PANDOC = "\\\\aworks200\\AnalysisWorks\\Applications\\R\\RStudio\\bin\\pandoc")
}
else{
    Sys.setenv( RSTUDIO_PANDOC = "C:/Program Files/RStudio/bin/pandoc")
    latexPath <- "C:\\Program Files\\MiKTeX 2.9\\miktex\\bin\\x64"
    Sys.setenv( PATH = paste( Sys.getenv( "PATH"), latexPath, sep = ";"))
}

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
checkPSArgs(args, 10)

extract_file <- args[1]
extract_path <- args[2]
file_delimiter <- args[3]
file_text_qualifier <- args[4]
contains_headers <- args[5]
rmd_file <- args[6]
output_name <- args[7]
contains_spaces <- args[8]
extension <- args[9]
plot_Data <- args[10]
output_path <- args[11]
output_name_base <- args[12]

output_path <- "C:\\Users\\zwarnes\\Documents\\ZW_AW\\QualityAssurance\\"
rmd_file <- "C:\\Users\\zwarnes\\Documents\\ZW_AW\\QualityAssurance\\production_markdown.Rmd"

file_text_qualifier <- "\""
contains_headers <- TRUE
contains_spaces <- TRUE


#################################
# TO CHANGE EACH RUN
#################################
base_names <- c(
    "CSBC Completed Cases May31_2019toJun27_2019",
    "CSBC on waitlist May31_2019toJun27_2019",
    "CSBC removed surgery waitlist May31_2019toJun27_2019"
)
extension <- "csv"
file_delimiter <- "|"
extract_path <- "\\\\AWORKS200\\AW_Share\\SFTP-Extracts\\extracts\\2019-07-11-09-19 PHSA dvancise PHSA\\"

#################################


for( i in 1:length(base_names)){
    base_name <- base_names[[i]]
    extract_file <- paste( base_name, extension, sep = ".")
    output_name_base <- paste( base_name, "pdf", sep = ".")
    output_name <- paste( output_path, output_name_base, sep = "")

    ######################################################
    #		Link R Scripts
    ######################################################
    Rloc = dirname(rmd_file)
    source(paste(Rloc, "data_type_checks.R", sep = "\\"))
    source(paste(Rloc, "data_conversion.R", sep= "\\"))
    source(paste(Rloc, "data_manipulation.R", sep= "\\"))
    source(paste(Rloc, "data_package.R", sep= "\\"))
    source(paste(Rloc, "file_reading.R", sep= "\\"))
    source(paste(Rloc, "rmd_setup.R", sep= "\\"))
    source(paste(Rloc, "data_logging.R", sep= "\\"))

    ######################################################
    #		Set up Packages
    ######################################################

    require("tidyverse")
    require("rmarkdown")
    require("tinytex")
    require("knitr")
    require("kableExtra")
    require("readxl")
    require("readr")
    require("stringi")


    ######################################################
    #		Powershell to R, Workarounds
    ######################################################

    ####    TODO
    #Improve parameter passing to handle reserved/key characters
    if(contains_headers == "True" || contains_headers == TRUE){
        containsHeaders <- TRUE
    }
    if(file_delimiter == "pipe"){
        file_delimiter <- "|"
    }
    if(file_delimiter == "carat"){
        file_delimiter <- "^"
    }

    ####    TODO
    #Imporve paramter passing from powershell to handle spaces in files
    extract_file <- gsub("#", " ", extract_file)
    extract_path <- gsub("#", " ", extract_path)
    output_name  <- gsub("#", " ", output_name)

    ######################################################
    #		Run Main Scripts
    ######################################################
    if(extension != "xls" && extension != "xlsx"){

        # default datapackage
        dataPackage( output_path, base_name, ext = extension, txtQual = file_text_qualifier, delim = file_delimiter)

        print(head(malformed_Rows_Check(paste(extract_path, extract_file, sep = "\\"), file_delimiter)))
        extractData <- read(paste(extract_path, extract_file, sep = "\\"),  delim = file_delimiter, ext=extension, textQualifier = file_text_qualifier)
        print( "Read file")

        #Convert POSIX fields to character fields these can then be converted to dates
        extractData <- convertAllPOSIX( extractData)
        print( "converted postix")

        # create QA PDF meta table, and update datapackage schema
        keyData <- metaDataCheck( extractData, output_path, output_name_base, ext = extension, qualifier = file_text_qualifier, delimiter = file_delimiter )
        check <- t( keyData$metaData)
        print( "created check")

        logExtract(t(keyData$logData))
        print( "log data")

        extractData <- determineDataTypes( extractData)$data
        print( "determined data types")

        classes <- as.matrix( sapply( extractData, class))
        print( "determined classes")

        renderMyDocument(rmd_file, output_name, check, extractData, classes, extract_file)

    }else{
        for(sheetNum in 1:length(excel_sheets(paste(extract_path, extract_file, sep = "\\")))){
            dataPackage( output_path, paste( base_name, sheetNum, sep = "_"), ext = extension, txtQual = file_text_qualifier, delim = file_delimiter)
            #Read data into one or more data frames (excel files have one data frame per sheet)
            extractSheet <- read(paste(extract_path, extract_file, sep = "\\"),  delim = file_delimiter, ext=extension, sheetNum = sheetNum)

            if(all(is.na(extractSheet))){
                next
            }
            #Convert POSIX fields to character fields these can then be converted to dates
            extractSheet <- convertAllPOSIX( extractSheet)

            # create QA PDF meta table, and update datapackage schema
            keyData <-  metaDataCheck( extractSheet, output_path, output_name_base, ext = extension, qualifier = file_text_qualifier, delimiter = file_delimiter, isExcel = 1 )
            check <- t( keyData$metaData)
            logExtract(t(keyData$logData))

            extractSheet <- determineDataTypes( extractSheet)$data
            classes <- as.matrix( sapply( extractSheet, class))

            excel_output_name <- paste(paste("Sheet_", sheetNum, sep = ""),output_name, sep = "_")
            renderMyDocument(rmd_file, excel_output_name, check, extractSheet, classes, extract_file)
        }
    }
}
