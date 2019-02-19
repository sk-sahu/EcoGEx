## EcoGEx : Ecotype-specific Gene Expression (R-📦 + 🕸️-App)

![GitHub](https://img.shields.io/github/license/sk-sahu/EcoGEx.svg?style=flat)
![GitHub repo size in bytes](https://img.shields.io/github/repo-size/sk-sahu/EcoGEx.svg?style=flat)
![GitHub last commit](https://img.shields.io/github/last-commit/sk-sahu/EcoGEx.svg?style=flat)
[![](https://img.shields.io/website-up-down-green-orange/https/sangram.shinyapps.io/EcoGEx.svg?style=flat)](https://sangram.shinyapps.io/EcoGEx)

**EcoGEx Web instance can be accessed here:** https://sangram.shinyapps.io/EcoGEx 

**If you want to use it Locally:**

Install through `install_github` fucntion from `devtools` package
```
library(devtools)
install_github("sk-sahu/EcoGEx")
```
To run EcoGEx instance locally:
```
library(EcoGEx)
runEcoGEx()
```
**Though the app is running properly**, I tried to R CMD check but [![Build Status](https://travis-ci.org/sk-sahu/EcoGEx.svg?branch=master)](https://travis-ci.org/sk-sahu/EcoGEx) So if any can help on this matter will be appreciated.

--------------
### About

**Arabidopsis EcoGEx** helps to find Expression of a Gene across different ecotypes of Arabidopsis and the geographical locations information.

By simply using AGI (Arabidopsis Gene Identifier) ID you can look at their Expression pattern and Compare.

<img src="./inst/app/images/EcoGEx_results.png">

--------------
#### Contact:
[Sangram Keshari Sahu](https://sksahu.net) and Prince Saini

For any query please email on: sangramk@iisermohali.ac.in

Also you can arise a issue here or ask for a pull request.

---------------
#### ChangeLog:
Last update:
(7/12/2018)
* v0.6.7 : Download options for graphs and table added.
