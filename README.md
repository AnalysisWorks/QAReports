# SFTP Stats QA
 - These R modules are the scripts that generate the QA pdf as part of the SFTP runner script and placed onto aworks200
 - These are initialized with Powershell through the SFTP but can also be run using straight R scripts in visual studio code
 - There are a few requirements to get these reports setup, the main reason there are so many unique softwares is conversion to PDF. These reports can also be created in markdown with less requirements.
 - Once the software below has been added you will need to install the packages specified with the install.packages() command in R
 - Next you should update the environment variable RSTUDIO_PANDOC to the direct path to pandoc. If you've downloaded RStduio it should be within the RStudio folder. Next you will need to update the LaTex path with is the miktex\\bin\\x64 starting from the MikTeX version that you install (see below). You should also update the output path and rmd_file path. These correspond to the desired output folder (usually this folder) and the direct path to the Rmarkdown file respectively.
 - In order to generate the QA PDFs manually, the last step is to update the 'TO CHANGE EACH RUN' Section. Simply add the files to the vector you wish to run the QA on (without file extensions), the extension for the files, the delimiter for the files, and finally the path to the source location of the files (usually aworks200).
    * File paths in R are different from Windows.
    * The '\\' character is interpreted as an escape character.
    * To convert windows file paths to R, replace '\\' with '\\\\' or '/'

 - On a succesful run, the following files should be added to your output path. A pdf for each file that you had specified, a 'rough' import datapackage for each extract, a .log file for the pdf generation, and potentially a .tex file with the Latex used. The .log and .tex files can be disregarded and deleted.


## RStudio, Pandoc, and Knitr
 - When R studio is installed, it should automatically have both knitr and Pandoc built in. You will still have to install the Rmarkdown package through R though.
 - https://stackoverflow.com/questions/40563479/relationship-between-r-markdown-knitr-pandoc-and-bookdown
 - RStudio IDE for R with some extentions to R. As part of R stduio, pandoc should also be installed.
 - Pandoc is a document conversion software that allows markdown documents to be converted into PDFs. This is a command line software but the RMarkdown library allows this to be used directly from R code.
 - Knitr is built into R and allows R code to written and executed in Rmd (R markdown files). Markdown files combine both LaTeX and R code and knitr executes code blocks in order to combine the two.
    * These tools require a verions of LaTeX to be installed called MiKTex with handles document formatting.


## MiKTeX
 - MiKTex is a essentially a latex generation software. It contains many libraries to support layout and formatting of several document types.
 - The installation of MiKTeX will also include a package management GUI. This will allow you to install missing packages and set package installation preferences.
    * You should set your installation preference to either 'yes' or 'no' as the default is to ask before each installtion and this prompt can bug out, and cause errors with document rendering
    * The package source is also blocked by our firewall. To get around this you'll have to access the site you specify the download from in a browser and allow access manually. Once this is done you shouldn't have any issues installing packages.

## R and Visual Studio
 - R like any other programming language is not initially setup in visual studio code. You will have to add the extension. The first extension will work with this Code.
 - To run a section of R code you will have to update your R term path in visual studio prior to executing code. This can be update in 'File > Preferences > Settings > User Settings > * Select the {} icon in the top right corner* and add the line "r.rterm.windows": "C:\\Program Files\\R\\R-3.6.1\\bin\\x64\\R.exe", to the json object. You can specify different versions of R here but as of writing this 3.6.1 is the most up to date version.
 - In order to execute a section of code press 'CRTL' + 'Enter' this should initialize an R prompt in your terminal. Once this prompt is present, you can write R code through the prompt or to execute an entire script press 'CRTL' + 'A' + 'Enter' to run the whole script. You can also select portions to run independently.

