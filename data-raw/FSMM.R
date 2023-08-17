## code to prepare `FSMM` dataset goes here
tree1000=read.csv('data-raw/tree10000.csv')
usethis::use_data(tree1000, overwrite = TRUE)
