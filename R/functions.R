#' Fraxinus Survival and Mortality Model (v 0.4)
#'
#' Provides probabilities and likelihood of mortality of street and park ash trees exposed to emerald ash borer.
#'
#' Clark, RE, KN Boyes, LE Morgan, AJ Storer, and JM Marshall. 2015. Development and assessment of ash mortality models in relation to emerald ash borer infestation. Arboriculture & Urban Forestry 41, 270-278.
#'
#' @param type Determines model variables to include "dieback", "vigor", "woodpecker". Three model types are available each includes presence of bark splits (1,0) and diameter at breast height (DBH, in cm) ("dieback", "vigor", "woodpecker"). Default type is "dieback", which provides model output using inputs of percent dieback, DBH, and bark splits. Published model had 83.8% correct prediction of mortality. Type "vigor" provides model output using inputs of vigor, DBH, and bark splits. Published model had 86.5% correct prediction of mortality. Type "woodpecker" provides model output using inputs of wood pecker activity, DBH, and bark splits. Published model had 75.7% correct prediction of mortality.
#' @param threshold Probability of mortality that will define if a tree dies within 3 years (continuous 0-1). Default threshold is 0.65
#' @param year Model to predict the year after data collection year in which a tree will die (TRUE, FALSE). Default year is FALSE (year=FALSE) because it requires percent dieback and DBH. Published model had 71.6% correct prediction of mortality year.
#' @param display Output basic statistics from trees, including counts, means of input variables, mean probability of mortality, for trees that will survive, die, and total (based on threshold of mortality value). (TRUE, FALSE). Default display is TRUE (display=TRUE)
#' @keywords ash mortality fraxinus
#' @export
#' @examples
#' FSM("tree10000.csv")

FSM <- function(fname,type="dieback",threshold="0.65",year=FALSE,display=TRUE){
	modData<-read.csv(fname)
	rCount<-nrow(modData)
	tempDBH<-modData$DBH
	tempBS<-modData$BS
	prob<-rep(NA,rCount)
	dead<-rep(NA,rCount)
	if (type=="dieback") {
		tempDB<-modData$DB
		for (j in 1:rCount) {
			prob[j]<-ifelse(tempDB[j]<12,ifelse(tempDBH[j]<27,ifelse(tempBS[j]<0.5,0,0.21),0.71),ifelse(tempDBH[j]>=38,0.62,0.89))
			dead[j]<-ifelse(prob[j]>=threshold,1,0)
		}
	} else if (type=="vigor") {
		tempV<-modData$V
		for (j in 1:rCount) {
			prob[j]<-ifelse(tempV[j]<1.5,ifelse(tempDBH[j]<39,ifelse(tempBS[j]<0.5,0,0.28),0.71),0.84)
			dead[j]<-ifelse(prob[j]>=threshold,1,0)
		}
	} else {
		tempWP<-modData$WP
		for (j in 1:rCount) {
			prob[j]<-ifelse(tempBS[j]<0.5,ifelse(tempDBH[j]<29,0.026,0.75),ifelse(tempDBH[j]<16,ifelse(tempWP[j]<0.5,0.32,0.68),0.75))
			dead[j]<-ifelse(prob[j]>=threshold,1,0)
		}
	}
	modData$Mortality.Probability<-prob
	modData$Mortality<-dead
	if (year==TRUE) {
		yr<-rep(NA,rCount)
		tempDB<-modData$DB
		for (j in 1:rCount) {
			yr[j]<-ifelse(dead[j]==0,0,ifelse(tempDB[j]<78,ifelse(tempDBH[j]<21,2,ifelse(tempDBH[j]<18,ifelse(tempDBH[j]<12,3,2),1)),2))
		}
		modData$Year<-yr
	}
	if ((display==TRUE) & (type=="dieback")) {
			Tree<-c("Survival","Mortality","Total")
			mort<-sum(modData$Mortality)
			surv<-rCount-mort
			Count_of_Trees<-c(surv,mort,rCount)
			resDBH<-rbind.data.frame(group=1:2,with(modData,tapply(DBH,dead,function(x) c(mean(x)))))
			Mean_DBH<-c(resDBH[2,1],resDBH[2,2],mean(modData$DBH))
			resDB<-rbind.data.frame(group=1:2,with(modData,tapply(DB,dead,function(x) c(mean(x)))))
			Mean_Dieback<-c(resDB[2,1],resDB[2,2],mean(modData$DB))
	            resBS<-rbind.data.frame(group=1:2,with(modData,tapply(BS,dead,function(x) c(sum(x)))))
			Percent_Barksplit<-c(resBS[2,1]/surv*100,resBS[2,2]/mort*100,sum(modData$BS)/rCount*100)
			output<-data.frame(Tree,Count_of_Trees,Mean_DBH,Mean_Dieback,Percent_Barksplit)
			print(output)
	}
	if ((display==TRUE) & (type=="vigor")) {
			Tree<-c("Survival","Mortality","Total")
			mort<-sum(modData$Mortality)
			surv<-rCount-mort
			Count_of_Trees<-c(surv,mort,rCount)
			resDBH<-rbind.data.frame(group=1:2,with(modData,tapply(DBH,dead,function(x) c(mean(x)))))
			Mean_DBH<-c(resDBH[2,1],resDBH[2,2],mean(modData$DBH))
			resV<-rbind.data.frame(group=1:2,with(modData,tapply(V,dead,function(x) c(median(x)))))
			Median_Vigor<-c(resV[2,1],resV[2,2],median(modData$V))
	            resBS<-rbind.data.frame(group=1:2,with(modData,tapply(BS,dead,function(x) c(sum(x)))))
			Percent_Barksplit<-c(resBS[2,1]/surv*100,resBS[2,2]/mort*100,sum(modData$BS)/rCount*100)
			output<-data.frame(Tree,Count_of_Trees,Mean_DBH,Median_Vigor,Percent_Barksplit)
			print(output)
	}
	if ((display==TRUE) & (type=="woodpecker")) {
			Tree<-c("Survival","Mortality","Total")
			mort<-sum(modData$Mortality)
			surv<-rCount-mort
			Count_of_Trees<-c(surv,mort,rCount)
			resDBH<-rbind.data.frame(group=1:2,with(modData,tapply(DBH,dead,function(x) c(mean(x)))))
			Mean_DBH<-c(resDBH[2,1],resDBH[2,2],mean(modData$DBH))
			resWP<-rbind.data.frame(group=1:2,with(modData,tapply(WP,dead,function(x) c(sum(x)))))
			Percent_Woodpecker<-c(resWP[2,1]/surv*100,resWP[2,2]/mort*100,sum(modData$WP)/rCount*100)
	            resBS<-rbind.data.frame(group=1:2,with(modData,tapply(BS,dead,function(x) c(sum(x)))))
			Percent_Barksplit<-c(resBS[2,1]/surv*100,resBS[2,2]/mort*100,sum(modData$BS)/rCount*100)
			output<-data.frame(Tree,Count_of_Trees,Mean_DBH,Percent_Woodpecker,Percent_Barksplit)
			print(output)
	}
	write.csv(modData,file=paste('FSM-',fname,sep=''),row.names=FALSE)
}
