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
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d09f0b3522d74ed58661fff41610c740)](https://app.codacy.com/app/sk-sahu/EcoGEx?utm_source=github.com&utm_medium=referral&utm_content=sk-sahu/EcoGEx&utm_campaign=Badge_Grade_Dashboard)

***
**Why this package/app** when one can go over available set of large Excel files and dig out the information?
Because, recently I came across this tweet of Hadley Wickham, which insipred me to write my first full fledged code (Well, atleast in my mind!).

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en"><p lang="en" dir="ltr">Automate everything that can be automated. I had to work hard to make it easier for others</p>&mdash; Hadley Wickham (@hadleywickham) <a href="https://twitter.com/hadleywickham/status/911992796441083906?ref_src=twsrc%5Etfw">September 24, 2017</a></blockquote>

And this also mentioned as his phillospohy of package development in his book [Introduction to R-packages](http://r-pkgs.had.co.nz/intro.html)
> Anything that can be automated, should be automated.

I know this code in production is not perfect. Most functions are messy and lot of improvements to do, but the idea of [MVP](https://en.wikipedia.org/wiki/Minimum_viable_product) can lead.

***

Testing in Dev branch.
