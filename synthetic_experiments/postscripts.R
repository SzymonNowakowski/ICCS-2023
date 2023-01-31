library(latex2exp)

one_plot<-function(algo_list, snr_list, res_0.5, setting, md, text_y="RMSE / RMSE(oracle)", ylim=c(0,20), ybar=FALSE) {
        algo_nice_names = c(gic.PDMR="PDMR", gic.DMRnet="DMR", scope8="SCOPE-8", scope32="SCOPE-32", grMCP="group MCP", grLasso="group LASSO", RF="Random Forests")
        colors <- palette("Okabe-Ito")[2:9]
        xlim <- c(snr_list[1], snr_list[length(snr_list)])


        should_legend <- (setting == 1)

        matplot(snr_list,res_0.5, type="l", lty=c(1,1,1,1,2,2,2), col=colors, lwd=1.5,
        xlab="",
        ylab="",
        cex=1.4, cex.lab=1.4,
        main=TeX(paste("Setting ", setting, ", True $MD=", md, "$", sep="")), cex.main=2.2, font.main=1,
        ylim=ylim, xlim=xlim )

        if (should_legend) legend("topleft", algo_nice_names[algo_list], lty=c(1,1,1,1,2,2,2), lwd=1.5, cex=1.4 , col=colors)
        mtext("SNR", side=1, line=2.4, col="black", cex=1)  #xlab
        mtext(text_y, side=2, line=2.4, col="black", cex=1)  #ylab
        if (ybar)
          lines(xlim, c(1.0, 1.0), lwd=1, col="red", lty=2)
}

n<- 500
res_snr <- (1+1/3)^(log(3)/log(1+1/3) - (5:-2))

#below settings by email communication, Wed, Feb 9th, 2022 at 9:14 AM,
settings<-list(high_no=c(    3,                  1,                  8,                  4,                    7,                5),
               oracle_md=c(  10,                 13,                 16,                 21,                   21,               26))  #those numbers also by email communication, Thu, Jan 27, 2022 at 4:55 PM


######

algs<-c( "gic.PDMR", "gic.DMRnet", "scope8", "scope32", "grMCP", "grLasso", "RF" )
res_0.5<-res_0<-matrix(nrow = length(res_snr), ncol = length(algs))

postscript("ICCS_RMSE.ps", horizontal=FALSE,onefile=FALSE)
par(mfrow=c(3,2))

for (setting_selector in 1:6) {
        high_no      <- settings$high_no[setting_selector]
        oracle_md    <- settings$oracle_md[setting_selector]
        for (rho in c(0.5)) {
                for (snr_selector in (1:length(res_snr)) ){

                        snr<-res_snr[snr_selector]

                        for (alg_selector in 1:length(algs)) {

                                alg <- algs[alg_selector]
                                filename <- paste(paste("results_iccs/setHigh", high_no, sep=""), "snr", as.character(round(snr,3)), "rho", as.character(rho), alg, sep="_")
                                A<-read.table(paste(filename, "csv", sep="."), header=TRUE, sep=",")
                                rownames(A)<-A$X
                                A<-A[-1]
                                A<-rbind(A, A["sigma",]^2 * oracle_md/n); rownames(A) <- c(rownames(A)[1:9], "mse_oracle")
                                A<-rbind(A, sqrt(A["mse",]/A["mse_oracle",])); rownames(A) <- c(rownames(A)[1:10], "rmse_alg_div_rmse_oracle")

                                if (rho == 0) {
                                        res_0[snr_selector, alg_selector] <-  mean(as.numeric(A["rmse_alg_div_rmse_oracle", ]))
                                } else {
                                        res_0.5[snr_selector, alg_selector] <- mean(as.numeric(A["rmse_alg_div_rmse_oracle", ]))
                                }
                        }
                }
        }
        one_plot(algs, res_snr, res_0.5, setting_selector, oracle_md)

}


graphics.off()


postscript("ICCS_MD.ps", horizontal=FALSE,onefile=FALSE)
par(mfrow=c(3,2))
algs<-c( "gic.PDMR", "gic.DMRnet", "scope8", "scope32", "grMCP", "grLasso")
res_0.5<-res_0<-matrix(nrow = length(res_snr), ncol = length(algs))

for (setting_selector in 1:6) {

          high_no      <- settings$high_no[setting_selector]
          oracle_md    <- settings$oracle_md[setting_selector]
          for (rho in c(0.5)) {
            for (snr_selector in (1:length(res_snr)) ){

              snr<-res_snr[snr_selector]

              for (alg_selector in seq_len(length(algs)) ) {   #without RF!

                alg <- algs[alg_selector]
                filename <- paste(paste("results_iccs/setHigh", high_no, sep=""), "snr", as.character(round(snr,3)), "rho", as.character(rho), alg, sep="_")
                A<-read.table(paste(filename, "csv", sep="."), header=TRUE, sep=",")
                rownames(A)<-A$X
                A<-A[-1]
                A<-rbind(A, A["md0",]/oracle_md); rownames(A) <- c(rownames(A)[1:9], "MD_alg_div_MD_oracle")

                if (rho == 0) {
                  res_0[snr_selector, alg_selector] <-  mean(as.numeric(A["MD_alg_div_MD_oracle", ]))
                } else {
                  res_0.5[snr_selector, alg_selector] <- mean(as.numeric(A["MD_alg_div_MD_oracle", ]))
                }
              }
            }
          }
          one_plot(algs, res_snr, res_0.5, setting_selector, oracle_md, text_y="Estimated MD / True MD", ylim=c(0,7), ybar=TRUE)

}



graphics.off()


for (snr_selector in 6:7) {
  for (setting_selector in 1:6) {
    high_no      <- settings$high_no[setting_selector]
    for (rho in c(0.5)) {


      snr<-res_snr[snr_selector]
      cat(paste("Setting ", setting_selector, ", snr=", snr, ", $\\rho=$\\textbf{0.5} &", sep=""))
      for (alg_selector in 1:4 ) {   #without RF!

        alg <- algs[alg_selector]
        filename <- paste(paste("results_iccs/setHigh", high_no, sep=""), "snr", as.character(round(snr,3)), "rho", as.character(rho), alg, sep="_")
        A<-read.table(paste(filename, "csv", sep="."), header=TRUE, sep=",")
        rownames(A)<-A$X
        A<-A[-1]
        cat(round(median(as.numeric(A["wall_time",])),2), " & ")
      }
      cat("--- & --- \\\\ \n")
    }
  }

}

