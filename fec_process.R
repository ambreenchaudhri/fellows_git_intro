###################################
### Process FEC Candidate Data  ###
###################################

# Clear Workspace
rm(list=ls())

# libraries
library(tidyverse)
library(plyr)
library(dplyr)
library(reshape2)
library(stringr)
library(fs)


# Set Working Directory
setwd("~/2_automation/FEC/")

########################
# Make Changes Universal

# read in all data files
filenames <- dir_ls(glob = "*.txt") %>% as.character() %>% sort()

# combine datasets
fec <- data.frame()
for (filename in filenames){
  fec_add <- read.table(filename, header = FALSE, sep = "|", quote = "\"", comment.char = "")
  fec <- rbind(fec, fec_add)
}
rm(fec_add, filename, filenames)

# add headers
names(fec) <- c("CAND_ID","CAND_NAME","CAND_ICI","PTY_CD","CAND_PTY_AFFILIATION",
                "TTL_RECEIPTS","TRANS_FROM_AUTH","TTL_DISB","TRANS_TO_AUTH",
                "COH_BOP","COH_COP","CAND_CONTRIB","CAND_LOANS","OTHER_LOANS",
                "CAND_LOAN_REPAY","OTHER_LOAN_REPAY","DEBTS_OWED_BY","TTL_INDIV_CONTRIB",
                "CAND_OFFICE_ST","CAND_OFFICE_DISTRICT","SPEC_ELECTION","PRIM_ELECTION",
                "RUN_ELECTION","GEN_ELECTION","GEN_ELECTION_PRECENT",
                "OTHER_POL_CMTE_CONTRIB","POL_PTY_CONTRIB","CVG_END_DT",
                "INDIV_REFUNDS","CMTE_REFUNDS")

#colnames(fec)

# cash raised
class(fec$COH_BOP)
class(fec$COH_COP)
fec$raised <- fec$COH_COP - fec$COH_BOP


# fec annual data
class(fec$CVG_END_DT)
fec$year <- str_sub(fec$CVG_END_DT, start=-4)

# Save Results
write.csv(fec, file="~/2_automation/FEC/fec_final.csv", row.names=FALSE)

# create a pdf file
pdf("fec.pdf")

fec$CAND_PTY_AFFILIATION <- trimws(fec$CAND_PTY_AFFILIATION)
years <- aggregate(fec$raised~fec$year+fec$CAND_PTY_AFFILIATION,fec,sum)
names(years) <- c("Years", "party", "Funds_Raised")
years <- subset(years, years$party=="DEM"|
                  years$party=="REP")

# plot the data

library(ggplot2)
ggplot(years,                                     
       aes(x = Years,
           y = Funds_Raised,
           fill = party)) +
  geom_bar(stat = "identity",
           position = "dodge") +
  scale_fill_manual("legend", values = c("DEM" = "blue", 
                                           "REP" = "red"))


dev.off()

# regressions
fec_reg <- subset(fec, fec$CAND_PTY_AFFILIATION=="REP" |
                    fec$CAND_PTY_AFFILIATION=="DEM")


fec_reg$battle <- ifelse(fec_reg$CAND_OFFICE_ST=="GA"|
                       fec_reg$CAND_OFFICE_ST=="FL"|
                       fec_reg$CAND_OFFICE_ST=="PA"|
                       fec_reg$CAND_OFFICE_ST=="MI"|
                       fec_reg$CAND_OFFICE_ST=="WI"|
                       fec_reg$CAND_OFFICE_ST=="AZ", 1, 0)
                       

reg1 <- lm(raised ~ CAND_PTY_AFFILIATION + year, data=fec_reg)
reg2 <- lm(raised ~ CAND_PTY_AFFILIATION + year, data=fec_reg)
reg3 <- lm(raised ~ CAND_PTY_AFFILIATION + year + battle, data=fec_reg)

sink("fec_reg.txt")
print(summary(reg3))
sink()




print("The FEC data was processed successfully.")
