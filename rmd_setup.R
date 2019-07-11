#Pass arguments into Rmarkdown file
#report name is the file name
#outputname is the output name, formatted and with desired direct path
#param1 is the meta data about the extract
#param2 is the raw extract data, to be modified in the Rmarkdown file
#param3 contains the classes for each of the fields
renderMyDocument <- function(reportName, outputName, param1, param2, param3, Title) {
    rmarkdown::render(reportName, output_file = outputName,  params = list(
        check = param1,
        rawData = param2,
        classes = param3,
        set_title = Title
    ))
}
