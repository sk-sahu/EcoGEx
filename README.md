## EcoGEx : Ecotype-specific Gene Expression (R-📦 + 🕸️-App)

[![Build Status](https://img.shields.io/travis/sk-sahu/EcoGEx.svg?logo=travis)](https://travis-ci.org/sk-sahu/EcoGEx)
[![GitHub release](https://img.shields.io/github/release-pre/sk-sahu/EcoGEx.svg?logo=github&logoColor=white)](https://github.com/sk-sahu/EcoGEx/releases)

If this helps you please cite: [![DOI](https://zenodo.org/badge/171301910.svg)](https://zenodo.org/badge/latestdoi/171301910)

## Quick Start

### EcoGEx Web instance can be accessed - [here](https://sangram.shinyapps.io/EcoGEx) [![](https://img.shields.io/badge/Web_App-Active_and_Runing-Green.svg)](https://sangram.shinyapps.io/EcoGEx/)

### Install the package and run the shiny app locally
```R
require(devtools)
devtools::install_github("sk-sahu/EcoGEx")
```
To run EcoGEx instance locally:
```R
library(EcoGEx)
runEcoGEx()
```

***
## About
Arabidopsis EcoGEx is a shinny web app to find Expression of a Gene across different accessions/strains of Arabidopsis and their geographical locations information of origin.

By simply using an AGI (Arabidopsis Gene Identifier) you can look at their Expression pattern and also can Compare between diffrent accessions.

Here is an example of some graphical outputs from the results after running the app:
<img src="./inst/app/images/EcoGEx_results.png">

***
If you have an idea for improvement or found a bug then please [raise an issue](https://github.com/sk-sahu/EcoGEx/issues).  
Or simply email on: sangramk@iisermohali.ac.in

***
