#-------------------------Package Installer--------------------------
# load packages and install if missing
# thanks to Richard Schwinn for the original code, http://stackoverflow.com/a/33876492
# this code has been improved over time by Egor Kotov

# list the packages you need
p <- c("data.table", "tidyverse", "igraph", "visNetwork", "tidygraph")

# this is a package loading function
loadpacks <- function(package.list = p){
new.packages <- package.list[!(package.list %in% installed.packages()[,'Package'])]
  if(length(new.packages)) {
    install.packages(new.packages, Ncpus = parallel::detectCores(), type = "binary")
  }
lapply(eval(package.list), require, character.only = TRUE)
}

loadpacks(p) # calling function to load and/or install packages
rm(loadpacks, p) # cleanup namespace
#----------------------End of Package Installer----------------------

#------------------------------Options-------------------------------

data.table::setDTthreads(threads = parallel::detectCores())
options(scipen = 999)

#---------------------------End of Options---------------------------

main <- function() {
  
  edge_list2_use <- read_csv("../1_data/humans_ties.csv")
  gg = graph_from_data_frame(d = edge_list2_use, directed = TRUE)
  
  gg_tbl <- as_tbl_graph(gg)
  
  gg_tbl <- gg_tbl %>%
    activate(nodes) %>% 
    mutate(c_degree = centrality_degree(mode = "all")) %>% 
    mutate(group = if_else(c_degree == max(c_degree), "top", "ordinary"))

  
  gg_vis <- gg_tbl %>% 
    mutate(value = c_degree) %>% 
    mutate(name = paste0(name, ", DC: ", value)) %>% 
    visIgraph(idToLabel = T, layout = "layout_with_kk", physics = T) %>%
    visPhysics(enabled = T, maxVelocity = 5, solver = "forceAtlas2Based", timestep = 0.01,
    forceAtlas2Based = list(gravitationalConstant = -1000, centralGravity = 0.001)) %>%
    visNodes(color = list(background = "grey", border = "#5B5B5B", highlight = 'darkblue'), font = list(strokeWidth = 20, strokeColor = "white")) %>%
    visEdges(arrows = NULL, color = list(highlight = 'blue'), smooth = list(enabled = T, type = "continuous")) %>%
    visLayout(randomSeed = 3) %>% 
    visInteraction(hover = T, hoverConnectedEdges = T, multiselect = T, selectConnectedEdges = T, navigationButtons = F, selectable = T) %>%
    visOptions(highlightNearest = list(enabled =TRUE)) %>% 
    visGroups(groupname = "top", color = "red") %>%
    visGroups(groupname = "ordinary", color = "grey") %>%
    visLegend(main = "Degree Centrality (DC)")
  
  print(gg_vis)
  
  visNetwork::visSave(gg_vis, file = "EKotov_netw_vis.html", selfcontained = TRUE)
  
}

main()
