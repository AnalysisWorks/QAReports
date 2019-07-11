require(RODBC)

connectionString <- function(Server, Database, user = "ro", password = "read") {
  cs <- odbcDriverConnect(paste0("DRIVER={SQL Server};
                                 server=",Server,";
                                 database=",Database,";
                                 uid=",user,";
                                 pwd=",password))
  cs
}

# run a SQL query and return the results as a data frame
runSQL <- function(cs, sql, close = FALSE) {
  sqlQuery(cs, sql)
  odbcClose(cs)
}


logExtract <- function( extractDetails){
    tmpcsv <- "//aworks300/Public/Documents/tmp/tmp.csv"
    write.table(extractDetails,tmpcsv, quote = TRUE,sep="|",row.names=FALSE,col.names=FALSE,append=FALSE, na = "");
    cs <- connectionString("aworks300\\development", "Automated_quality")
    sqlQuery(cs,"BULK INSERT Automated_quality.kpi.ind_quality_base
                FROM 'C:/Users/Public/Documents/tmp/tmp.csv'
                WITH
                (
                FIELDTERMINATOR = '|',
                ROWTERMINATOR = '\\n'
                )")
    odbcClose(cs)
}