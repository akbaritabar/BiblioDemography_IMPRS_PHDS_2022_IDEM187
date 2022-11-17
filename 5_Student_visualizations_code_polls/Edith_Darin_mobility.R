library(tidyverse)
library(lubridate)
library(tmap)
library(sf)
library(tmaptools)
library(animation)

trajectory <- read_csv('./Day 4 Akbaritabar Bibliometric Data/1_data/example_mobility_trajectory.csv')
life <- read_csv('./Day 4 Akbaritabar Bibliometric Data/1_data/example_life_events.csv')


trajectory_year <- trajectory |> 
  arrange(start_date) |> 
  mutate(year=lubridate::year(start_date),
         end_year = lead(year),
         end_year = ifelse(is.na(end_year),2022, end_year),
         freq= end_year-year) |> 
  uncount(freq) |> 
  mutate(year= 1986:2021)

life_year <- life |> 
  arrange(event_date) |> 
  mutate(
    year = year(event_date)
  ) 

df <- full_join(
  trajectory_year |> 
    select(affiliation, city, year, latitude, longitude),
  life_year |> 
    select(event, year)
)

df_pts <- st_as_sf(df, coords = c("longitude","latitude"), remove = FALSE, crs='wgs84')

bbox <- st_centroid(df_pts) |> 
  st_buffer(70000)

osm <- read_osm(bbox, mergeTiles = T)

tm_shape(osm)+
  tm_rgb()


tmap_mode('plot')

saveGIF({
for(idx in 1:nrow(df_pts)){
  single_df <- df_pts[idx,]
  map <- tm_shape(osm)+
    tm_rgb()+
    tm_shape(single_df)+
    tm_dots(size=1)+
    tm_text('affiliation', just=c(0.5,-2),fontface = "bold", size=1.5)+
    tm_layout(title = single_df$year, title.size = 2, title.fontface ='bold', 
              title.bg.color = 'grey10', title.color = 'grey90')
  
  if(!is.na(single_df$event)){
  map <- map + tm_credits(paste0("Event: ", single_df$event), fontface = "bold", position = "left", size=1.5)
  }
  
  print(map)
}
  }, movie.name = "mobility.gif", interval = 1, ani.width = 1000, ani.height = 700)
