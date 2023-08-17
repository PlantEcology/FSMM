#' Fraxinus Survival and Mortality Model (v 0.7)
#'
#' Provides probabilities and likelihood of mortality of street and park ash trees exposed to emerald ash borer.
#'
#' Clark, RE, KN Boyes, LE Morgan, AJ Storer, and JM Marshall. 2015. Development and assessment of ash mortality models in relation to emerald ash borer infestation. Arboriculture & Urban Forestry 41, 270-278.
#'
#' @param dat Data frame including trees in rows with columns of unique tree ID, BS (bark split presence, 1/0), DBH (diameter at breast height, cm), DB (dieback, 5-100%), V (vigor rating, 1-5 with 1 as healthiest and 5 as crown half dead), and WP (woodpecker activity presence, 1/0). BS and DBH are required for all model types. DB is required for "dieback" model, V is required for "vigor" model, and WP is required for "woodpecker" model.
#' @param type Determines model variables to include "dieback", "vigor", "woodpecker". Three model types are available each includes presence of bark splits (1,0) and diameter at breast height (DBH, in cm) ("dieback", "vigor", "woodpecker"). Default type is "dieback", which provides model output using inputs of percent dieback, DBH, and bark splits. Published model had 83.8% correct prediction of mortality. Type "vigor" provides model output using inputs of vigor, DBH, and bark splits. Published model had 86.5% correct prediction of mortality. Type "woodpecker" provides model output using inputs of wood pecker activity, DBH, and bark splits. Published model had 75.7% correct prediction of mortality.
#' @param threshold Probability of mortality that will define if a tree dies within 3 years (continuous 0-1). Default threshold is 0.65
#' @param year Model to predict the year after data collection year in which a tree will die (TRUE, FALSE). Default year is FALSE (year=FALSE) because it requires percent dieback and DBH. Published model had 71.6% correct prediction of mortality year.
#' @keywords ash mortality fraxinus
#' @export

FSMM <- function(dat,type="dieback",threshold="0.65",year=FALSE){
	rCount<-nrow(dat)
	tempDBH<-dat$DBH
	tempBS<-dat$BS
	prob<-rep(NA,rCount)
	dead<-rep(NA,rCount)
	if (type=="dieback") {
		tempDB<-dat$DB
		for (j in 1:rCount) {
			prob[j]<-ifelse(tempDB[j]<12,ifelse(tempDBH[j]<27,ifelse(tempBS[j]<0.5,0,0.21),0.71),ifelse(tempDBH[j]>=38,0.62,0.89))
			dead[j]<-ifelse(prob[j]>=threshold,1,0)
		}
	} else if (type=="vigor") {
		tempV<-dat$V
		for (j in 1:rCount) {
			prob[j]<-ifelse(tempV[j]<1.5,ifelse(tempDBH[j]<39,ifelse(tempBS[j]<0.5,0,0.28),0.71),0.84)
			dead[j]<-ifelse(prob[j]>=threshold,1,0)
		}
	} else {
		tempWP<-dat$WP
		for (j in 1:rCount) {
			prob[j]<-ifelse(tempBS[j]<0.5,ifelse(tempDBH[j]<29,0.026,0.75),ifelse(tempDBH[j]<16,ifelse(tempWP[j]<0.5,0.32,0.68),0.75))
			dead[j]<-ifelse(prob[j]>=threshold,1,0)
		}
	}
	dat$Mortality.Probability<-prob
	dat$Mortality<-dead
	if (year==TRUE) {
		yr<-rep(NA,rCount)
		tempDB<-dat$DB
		for (j in 1:rCount) {
			yr[j]<-ifelse(dead[j]==0,0,ifelse(tempDB[j]<78,ifelse(tempDBH[j]<21,2,ifelse(tempDBH[j]<18,ifelse(tempDBH[j]<12,3,2),1)),2))
		}
		dat$Year<-yr
	}
	if (type=="dieback") {
			Tree<-c("Survival","Mortality","Total")
			mort<-sum(dat$Mortality)
			surv<-rCount-mort
			Count_of_Trees<-c(surv,mort,rCount)
			resDBH<-rbind.data.frame(group=1:2,with(dat,tapply(DBH,dead,function(x) c(mean(x)))))
			Mean_DBH<-c(resDBH[2,1],resDBH[2,2],mean(dat$DBH))
			resDB<-rbind.data.frame(group=1:2,with(dat,tapply(DB,dead,function(x) c(mean(x)))))
			Mean_Dieback<-c(resDB[2,1],resDB[2,2],mean(dat$DB))
	            resBS<-rbind.data.frame(group=1:2,with(dat,tapply(BS,dead,function(x) c(sum(x)))))
			Percent_Barksplit<-c(resBS[2,1]/surv*100,resBS[2,2]/mort*100,sum(dat$BS)/rCount*100)
			output<-data.frame(Tree,Count_of_Trees,Mean_DBH,Mean_Dieback,Percent_Barksplit)
			print(output)
	}
	if (type=="vigor") {
			Tree<-c("Survival","Mortality","Total")
			mort<-sum(dat$Mortality)
			surv<-rCount-mort
			Count_of_Trees<-c(surv,mort,rCount)
			resDBH<-rbind.data.frame(group=1:2,with(dat,tapply(DBH,dead,function(x) c(mean(x)))))
			Mean_DBH<-c(resDBH[2,1],resDBH[2,2],mean(dat$DBH))
			resV<-rbind.data.frame(group=1:2,with(dat,tapply(V,dead,function(x) c(stats::median(x)))))
			Median_Vigor<-c(resV[2,1],resV[2,2],stats::median(dat$V))
	            resBS<-rbind.data.frame(group=1:2,with(dat,tapply(BS,dead,function(x) c(sum(x)))))
			Percent_Barksplit<-c(resBS[2,1]/surv*100,resBS[2,2]/mort*100,sum(dat$BS)/rCount*100)
			output<-data.frame(Tree,Count_of_Trees,Mean_DBH,Median_Vigor,Percent_Barksplit)
			print(output)

	}
	if (type=="woodpecker") {
			Tree<-c("Survival","Mortality","Total")
			mort<-sum(dat$Mortality)
			surv<-rCount-mort
			Count_of_Trees<-c(surv,mort,rCount)
			resDBH<-rbind.data.frame(group=1:2,with(dat,tapply(DBH,dead,function(x) c(mean(x)))))
			Mean_DBH<-c(resDBH[2,1],resDBH[2,2],mean(dat$DBH))
			resWP<-rbind.data.frame(group=1:2,with(dat,tapply(WP,dead,function(x) c(sum(x)))))
			Percent_Woodpecker<-c(resWP[2,1]/surv*100,resWP[2,2]/mort*100,sum(dat$WP)/rCount*100)
	            resBS<-rbind.data.frame(group=1:2,with(dat,tapply(BS,dead,function(x) c(sum(x)))))
			Percent_Barksplit<-c(resBS[2,1]/surv*100,resBS[2,2]/mort*100,sum(dat$BS)/rCount*100)
			output<-data.frame(Tree,Count_of_Trees,Mean_DBH,Percent_Woodpecker,Percent_Barksplit)
			print(output)
	}
	return(dat)
	#if (is.null(export)) {
	#write.csv(dat,file=paste('FSMM-',Sys.Date(),'.csv',sep=''),row.names=FALSE)
	#} else {
	#write.csv(dat,file=export,row.names=FALSE)
	#}
}
