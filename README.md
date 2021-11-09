# FSMM
Fraxinus Survival and Mortality Model (version 0.5)

Provides probabilities and likelihood of mortality of street and park ash trees exposed to emerald ash borer

## Install
Installation requires <a href="https://cran.r-project.org/package=devtools">devtools</a>.
```
install_github("PlantEcology/FSMM")
```

## Data Format
Data should be organized in a CSV file with trees in rows (tree10000.csv is an example data set with 10,000 trees). The function will add mortality probability, mortality prediction (0,1 based on a threshold), and mortality year (1-3 after data year, not included by default) columns to the data file. Required data for models vary, however, bark splits and DBH are required for all models. 

Variable | Description 
------|-----
Tree | Unique tree ID
BS | presence/absence of bark splits (1/0) [required for all model types]
DBH | diameter at breast height (cm) [required for all model types]
DB | percent crown dieback (5-100%) [required for "dieback" model type]
V | vigor rating (1-5, with 1 = healthiest and 5 = crown half dead) [required for "vigor" model type]
WP | presence/absence of woodpecker activity (1/0) [required for "woodpecker" model type]

## type
Defines the variables to include in model predictions. Three model types are available each includes presence of bark splits (1,0) and diameter at breast height (DBH [cm]) ("dieback", "vigor", "woodpecker"). 

Option | Description
------|-----
"dieback" | Provides model output using inputs of percent dieback, DBH, and bark splits. Clark et al. (2015) model had 83.8% correct prediction of mortality.
"vigor" | provides model output using inputs of vigor, DBH, and bark splits. Clark et al. (2015) model had 86.5% correct prediction of mortality.

Type "woodpecker" provides model output using inputs of wood pecker activity, DBH, and bark splits. Clark et al. (2015) model had 75.7% correct prediction of mortality.

Default
```
type="dieback"
```

## threshold
Probability of mortality that will define if a tree dies within 3 years. Mortality threshold defined by user as a continuous probability (0 to 1).

Default
```
threshold=0.65
```

## year
Model can predict the year (after data collection) in which a tree will die. Year is a Boolean option. Clark et al. (2015) model had 71.6% correct prediction of mortality year. Requires inclusion of dieback if used with "vigor" or "woodpecker" type models. 

Default
```
year=FALSE
```

## display
Output basic statistics from trees, including counts, means of input variables, mean probability of mortality, for trees that will survive, die, and total (based on threshold of mortality value). Display is a Boolean option.

Default 
```
display=TRUE
```

## Example
This example would take the tree10000.csv file and produce a model based on vigor, DBH, bark splits, and a mortality threshold probability of 0.65 and output a file named FSM-tree10000.csv that would now include probability of mortality, a decision of mortality (1 or 0), and when mortality would occur (year). It would also output a table of basic statistics in the R terminal.
```
FSMM("tree10000.csv", type="vigor", threshold="0.65", year=TRUE, display=TRUE)
```

## Citation
Clark, RE, KN Boyes, LE Morgan, AJ Storer, and JM Marshall. 2015. Development and assessment of ash mortality models in relation to emerald ash borer infestation. Arboriculture & Urban Forestry 41, 270-278. (<a href="http://joa.isa-arbor.com/request.asp?JournalID=1&ArticleID=3370&Type=2">article</a>)
