# Load packages
library(rvest)
library(weatherData)

# Load the Trim function
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

# Load the GetElement function
GetElement <- function(x, num, delim = "[") {
  # Gets specified element from delimited character vector
  #
  # Args:
  #   x: Character Vector.
  #   num: Number element to retrieve.
  #   delim: Delimiter found in x. Defaults to "[".
  #
  # Returns:
  #   Character vector of specified element of x.
  #
  return(sapply(strsplit(x, paste0("[", delim, "]")), "[[", num +1))
}

# Paste the website URL you want to scrape
url <- "http://matchcenter.mlssoccer.com/matchcenter/2015-03-07-dc-united-vs-montreal-impact/boxscore"

# Start scraping using the rvest package
game_data <- html(url)

##############################################################################
# GAME WEEKDAY and DATE

game_date <- game_data %>%
                html_node(".watch") %>%
                html_text() %>%
                as.character()

game_day <- as.character(GetElement(game_date, 0, ","))


url_game_date <- as.character(GetElement(url, 4, "/"))

year <- as.numeric(GetElement(url_game_date, 0, "-"))
month <- as.numeric(GetElement(url_game_date, 1, "-"))
day <- as.numeric(GetElement(url_game_date, 2, "-"))

date <- as.Date(paste0(trim(year),trim("/"), trim(month), trim("/"), trim(day)))

##############################################################################
# GAME ATTENDANCE

attendance <- game_data %>% 
  html_node(".match-info div:nth-child(2)") %>%
  html_text() %>%
  as.character()

# Split attendance character from "Attendance" and make numeric
attendance <- as.numeric(GetElement(attendance, 1, " "))

##############################################################################
# TEAMS

home_team <- game_data %>%
  html_node(".sb-home .sb-club-name-full") %>%
  html_text() %>%
  as.character()

away_team <- game_data %>%
  html_node(".sb-away .sb-club-name-full") %>%
  html_text() %>%
  as.character()
  
##############################################################################
# TEMPERATURE

if (home_team == "D.C. United") {
  temperature <- getWeatherForDate("DCA", date)
} else if
(home_team == "Portland") {
  temperature <- getWeatherForDate("POR", date)
} else if
(home_team == "LA Galaxy") {
  temperature <- getWeatherForDate("LAX", date)
}

max_temperature <- as.numeric(temperature[2])
mean_temperature <- as.numeric(temperature[3])
min_temperature <- as.numeric(temperature[4])

##############################################################################
# Data frame

# Put the values into a data frame
df <- data.frame(date, game_day, home_team, away_team, attendance,
                 max_temperature, mean_temperature, min_temperature,
                 year, month, day, url)

# Merge the data frames
all_games <- rbind(all_games, df)