library(rjson)

dataPackage <- function( extractPath, extractName, ext = "csv", txtQual = "\\", nullVal = "", delim = ","){
    dataPackagePath <- paste( extractPath, paste("orig", extractName, sep = "."), sep = "//")
    versionPath     <- paste( dataPackagePath, "v1.0.0", sep = "//")

    dir.create( dataPackagePath)
    dir.create( versionPath)

    # Table.json
    ver <- list( 
                c(
                    version = "1.0.0", 
                    schema = "v1.0.0/schema.json", 
                    assembly = "v1.0.0/assembly.psm1", 
                    active_ind = TRUE
                )
        )
    table <- list(  name = extractName, 
                    type = "import", 
                    decription = "Add a description here, what data is in this file?", 
                    versions = ver
                )
    write(toJSON(table), file = paste( dataPackagePath, "table.json", sep = "//"))

    # Schema.json
    dep <- list( c())

    imprt <- list()
    if( ext == "mdb"){
        imprt <- list(
            fileType = "access",                 
            tableName = "access table for desired extract", 
            password = "access password, if required",      
            sourceFilePath = "SOURCE_FILE"                  #default
            )
    }
    else{
        imprt <- list(
                fileType = "delimited",                
                delimiter = delim,              #passed into R script
                textQualifier = txtQual,        #default to \\
                nullValue = nullVal,            #assume blank is null
                skipRows = 1,                   #assume headers
                encoding = "UTF-8",             #default, could be passed in?
                sourceFilePath = "SOURCE_FILE"  #default
                )
    }



    cols <- list(
                c( name = "placeholder", type = "nvarchar"),
                c( name = "SOURCE_FILE")
            )

    schema <- list( 	
                name = extractName,
                schema = "orig",
                decription = "Add a description here, what data is in this file?", 
                type = "import",
                version = "1.0.0",
                dependencies = dep,
                import = imprt,
                fields = cols
            )
    write(toJSON(schema), file = paste(versionPath, "schema.json", sep = "//"))
    

    # Create Assemble.psm1
    assemble <- "class SchemaAssembly : DataPackageImportSchema {

    # Constructor
    SchemaAssembly([string] $SchemaPath) : base($SchemaPath) {
        
    }

    [void] AssembleData([string] $Server, [string] $Database, [hashtable] $Arguments) {

    }

}"
    write(assemble, file = paste( versionPath, "assembly.psm1", sep = "//"))

}

updateSchema <- function( extractPath, extractName, ext = "csv", txtQual = "\\", nullVal = "", delim = ",", fieldNames, fieldTypes, maxLengths, uniqueValues, dateFormats){

    # Schema.json
    dep <- list( c())

    imprt <- list(
            fileType = "delimited",                 #passed into R scipt
            delimiter = delim,              #passed into R script
            textQualifier = txtQual,        #default to \\
            nullValue = nullVal,            #assume blank is null
            skipRows = 1,                   #assume headers
            encoding = "UTF-8",             #default, could be passed in?
            sourceFilePath = "SOURCE_FILE"  #default
            )

    cols <- list()
    for( i in 1:length( fieldNames) ){
        if( fieldTypes[[i]] == "nvarchar"){
            fieldLength <- `^`(2, ceiling( log( maxLengths[[i]])/ log(2) )) # round to next power of 2
            if( is.na(fieldLength) || fieldLength == 0){
                fieldLength = 255
            }

            if( length( uniqueValues[[i]]) > 10){
                fieldSpecs <- c(
                    name = fieldNames[[i]],
                    type = fieldTypes[[i]],
                    maxLength = fieldLength,
                    allowNull = TRUE,
                    index = FALSE,
                    allowableValues = list(),
                    description = "Add a description here, what do the field values represent?"
                )
                cols[[i]] <- fieldSpecs
            }
            else{
                 fieldSpecs <- c(
                    name = fieldNames[[i]],
                    type = fieldTypes[[i]],
                    maxLength = fieldLength,
                    allowNull = TRUE,
                    index = FALSE,
                    allowableValues = list( append( uniqueValues[[i]], c("", "NULL"))),
                    description = "Add a description here, what do the field values represent?"
                )
                cols[[i]] <- fieldSpecs
            }
        }
        else if( fieldTypes[[i]] == "float"){
            fieldSpecs <- c(
                name = fieldNames[[i]],
                type = fieldTypes[[i]],
                allowNull = TRUE,
                index = FALSE,
                allowableValues = list(),
                description = "Add a description here, what do the field values represent?"
            )
            cols[[i]] <- fieldSpecs
        }
        else{
            fieldSpecs <- c(
                name = fieldNames[[i]],
                type = fieldTypes[[i]],
                allowNull = TRUE,
                index = FALSE,
                #format = dateFormats[[i]],
                allowableValues = list(),
                description = "Add a description here, what do the field values represent?"
            )
            cols[[i]] <- fieldSpecs
        }
    }
    cols$source <- fieldSpecs <- c(
                    name = "SOURCE_FILE",
                    type = "nvarchar",
                    maxLength = 255,
                    allowNull = TRUE,
                    index = FALSE
                )
    
    schema <- list( 	
                name = extractName,
                schema = "orig",
                decription = "Add a description here, what data is in this file?", 
                type = "import",
                version = "1.0.0",
                dependencies = dep,
                import = imprt,
                fields = cols
            )

    dataPackagePath <- paste( extractPath, paste("orig", extractName, sep = "."), sep = "//")
    versionPath     <- paste( dataPackagePath, "v1.0.0", sep = "//")
    write( toJSON(schema) , file = paste(versionPath, "schema.json", sep = "//"))
}
