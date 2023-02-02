library(vioplot)


postscript("ICCS_real_data.ps", horizontal=FALSE,onefile=FALSE)

par(mfrow=c(5,2), mai=c(0.4, 0.4, 0.25, 0.08), cex=.9, cex.main=1.3, cex.lab=6)
color_palette <- palette("Okabe-Ito")[2:9]


alg <- c("PDMR","DMR",
      #"Pr","Dr",
      "S-8","S-32", "gMCP","gL")#,"L")

alg_rf <- c("PDMR","DMR",
      #"Pr","Dr",
      "S-8","S-32", "gMCP","gL", "RF")#,"L")


#######   a i r b n b
set_name <- "Airbnb:"
A <- read.csv("results/airbnb_errors.csv")
A <- cbind(A, rep(1.0, 200))
A <- A[,c(2, 3,     7, 7,    5, 6, 7)]#3, 8, 6, 11,     17, 17,    13, 16, 12)]
colnames(A) <- alg_rf
vioplot(A,outline=FALSE, main=paste(set_name,"PE"), ylim=c(.05,0.4), col=color_palette[1:ncol(A)], cex.axis=0.7)
text(3,0.05+(0.4-0.05)/2,substitute(paste(italic("not available"))), srt = 90)
text(4,0.05+(0.4-0.05)/2,substitute(paste(italic("not available"))), srt = 90)
text(7,0.05+(0.4-0.05)/2,substitute(paste(italic("not available"))), srt = 90)

A1 <- read.csv("results/airbnb_model_sizes.csv")
A1 <- cbind(A1, rep(100, 200))
A1 <- A1[,c(2, 3,    7, 7,     5, 6)]#, 12)]
colnames(A1) <- alg
vioplot(A1,outline=FALSE, main=paste(set_name,"MD"),  ylim=c(0,60), col=color_palette[1:ncol(A)], cex.axis=0.7)
text(3,30,substitute(paste(italic("not available"))), srt = 90)
text(4,30,substitute(paste(italic("not available"))), srt = 90)



mdU=30
#######   a n t i g u a
set_name <- "Antigua:"
A <- read.csv("results/antigua_errors.csv")
A <- A[,c(2, 3,     5, 4, 8, 9, 7)]#, 14)]
colnames(A) <- alg_rf
vioplot(A,outline=FALSE, main=paste(set_name,"PE"), ylim=c(.5,2), col=color_palette[1:ncol(A)], cex.axis=0.7)

A1 <- read.csv("results/antigua_model_sizes.csv")
A1 <- A1[,c(2, 3,     5, 4, 7, 8)]#, 14)]
colnames(A1) <- alg
vioplot(A1,outline=FALSE, main=paste(set_name,"MD"),  ylim=c(0,mdU), col=color_palette[1:ncol(A1)], cex.axis=0.7)

#######   i n s u r a n c e
set_name <- "Insurance:"
A <- read.csv("results/insurance_errors.csv")
A <- A[,c(2, 3,     5, 4, 7, 8)]#, 14)]
A <- cbind(A, rep(10, nrow(A)))
colnames(A) <- alg_rf
ymin <- 4.0
ymax <- 5.8
vioplot(A, outline=FALSE, main=paste(set_name,"PE"), col=color_palette[1:ncol(A)], cex.axis=0.7, ylim=c(ymin, ymax))
text(7,ymin+(ymax-ymin)/2,substitute(paste(italic("not available"))), srt = 90)

A1 <- read.csv("results/insurance_model_sizes.csv")
A1 <- A1[,c(2, 3,     5, 4, 7, 8)]#, 14)]
colnames(A1)=alg
vioplot(A1,outline=FALSE, main=paste(set_name,"MD"), ylim=c(0,60), col=color_palette[1:ncol(A1)], cex.axis=0.7)


alg <- c("PDMR","DMR",
      #"Pr","Dr",
      "S-100","S-250", "gMCP","gL")#,"L")

alg_rf <- c("PDMR","DMR",
         #"Pr","Dr",
         "S-100","S-250", "gMCP","gL", "RF")#,"L")

#######   a d u l t
set_name <- "Adult:"
A <- read.csv("results/adult_errors.csv")
A <- A[,c(2, 3,     5, 4, 8, 9, 7)]#, 14)]
colnames(A)=alg_rf
vioplot(A,outline=FALSE, main=paste(set_name,"PE"), ylim=c(.17,.3), col=color_palette[1:ncol(A)], cex.axis=0.65)

A1 <- read.csv("results/adult_model_sizes.csv")
A1 <- A1[,c(2, 3,     5, 4, 7, 8)]#, 14)]
colnames(A1)=alg
vioplot(A1,outline=FALSE, main=paste(set_name,"MD"), ylim=c(0,mdU), col=color_palette[1:ncol(A1)], cex.axis=0.65)


#######   p r o m o t e r
set_name <- "Promoter:"
A <- read.csv("results/promoter_errors.csv")
A <- A[,c(2, 3,     5, 4, 8, 9, 7)]#, 14)]
colnames(A)=alg_rf
vioplot(A,outline=FALSE, main=paste(set_name,"PE"),  ylim=c(0,.30), col=color_palette[1:ncol(A)], cex.axis=0.65)

A1 <- read.csv("results/promoter_model_sizes.csv")
A1 <- A1[,c(2, 3,     5, 4, 7, 8)]#, 14)]
colnames(A1)=alg
vioplot(A1,outline=FALSE, main=paste(set_name,"MD"), ylim=c(0,mdU), col=color_palette[1:ncol(A1)], cex.axis=0.65)



graphics.off()

