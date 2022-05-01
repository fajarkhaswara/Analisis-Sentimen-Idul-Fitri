## load rtweet
library(rtweet)

## store api keys (these are fake example values; replace with your own keys)
api_key <- "XXXXXXXXXXXXXX"
api_secret_key <- "XXXXXXXXXXXXXX"
access_token <- "XXXXXXXXXXXXXX"
access_token_secret <- "XXXXXXXXXXXXXX"

## authenticate via web browser
token <- create_token(
  app = "XXXXXXXXXXXXXX",
  consumer_key = api_key,
  consumer_secret = api_secret_key)

## save token to home directory
path_to_token <- file.path(path.expand("~"), ".twitter_token.rds")
saveRDS(token, path_to_token)

## create env variable TWITTER_PAT (with path to saved token)
env_var <- paste0("TWITTER_PAT=", path_to_token)

## save as .Renviron file (or append if the file already exists)
cat(env_var, file = file.path(path.expand("~"), ".Renviron"), 
    fill = TRUE, append = TRUE)

## refresh .Renviron variables
readRenviron("~/.Renviron")