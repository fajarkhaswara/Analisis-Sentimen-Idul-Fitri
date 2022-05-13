# combine all sentiment data
df.1 <- read.csv("~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Idul Fitri.csv")
df.2 <- read.csv("~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Shalat Id.csv")
df.3 <- read.csv("~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Silaturahmi.csv")
df.4 <- read.csv("~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Takbiran.csv")
df.5 <- read.csv("~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Ziarah.csv")

df12345 <- rbind(df.1, df.2, df.3, df.4, df.5)
df12345 <- na.omit(df12345)

write.csv(x = df12345,
          file = "~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Total.csv")

