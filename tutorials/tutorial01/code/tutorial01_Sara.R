############################
# Tutorial 1: Web Scraping #
############################

## Packages
library(tidyverse) 
library(rvest) # Read HTML content ... Turn HTML table into R dataframes ... 
library(xml2) # Same, but both HTML and XML 

# Apparently package jsonlite is the equivalente for JSON

##################
# Importing html #
##################

# We use the read_html() function from rvest to read in the html
bowlers <- "https://stats.espncricinfo.com/ci/content/records/93276.html"

html <- read_html(bowlers)
html

# We can inspect the structure of this html using xml_structure() from xml2
xml_structure(html)
capture.output(xml_structure(html))

# That's quite a big html! maybe we should go back to square 1 and inspect the 
# page...

###################
# Inspecting html #
###################

# On my browser (firefox) I can use ctrl-u to open the html source code. 
# I can also locate a specific element of the html code by inspecting it (right 
# clicking the mouse and selecting "inspect"). See if you can find where the 
# table begins.
# En Mac Safari también ya funciona, es opt + command + U

################# 
# Querying html #
#################

# There are different ways of querying html documents. The two main methods are 
# xpath and css selectors. Today we'll focus on xpaths, but you may sometimes 
# come across css as well. This website - https://exadel.com/news/how-to-choose-selectors-for-automation-to-make-your-life-a-whole-lot-easier
# gives a good overview of the difference between the two.

# html nodes using html_nodes()
html %>%
  html_nodes("table") # try searching for the table node (the answer is "table")

html %>% 
  html_nodes(".ds-table") # try searching using the class (add a dot)

# Dont really know what a node is but apparently one table in the website
# will create one node, two will create two, so on. 

# xpaths
# To search using xpath selectors, we need to add the xpath argument.
html %>%
  html_nodes(xpath = "//table[position()=1]") 

# "table" for html_nodes; "//table" for xpath. 
# The rest of the arguments come from the link. 
# xpath allows to select certain tables within a website with many, or subtables within tables
# on a website (see "Selecting nodes" from the link, also "Predicates")
# Here's a useful guide to xpath syntax: https://www.w3schools.com/xml/xpath_syntax.asp

# Try selecting the first node of the table class, and assign it to a new object
tab1 <- html %>%
  html_nodes(xpath = "//table[position()=1]")

# Let's look at the structure of this node. We could use the xml_structure() 
# function, but the html is still too big. Try inspecting the object in the 
# environment window.

# We basically want "thead" and "tbody". How might we get those?
tab2 <- tab1 %>%
  html_nodes(xpath = "//table/thead | //table/tbody")

# We now have an object containing 2 lists. With a bit of work we can extract 
# the text we want as a vector:
heads <- tab2[1] %>%
  html_nodes(xpath = "") %>%
  html_text()

body <- tab2[2] %>%
  html_nodes(xpath = "") %>%
  html_text()

# We now have two vectors, one with our categories and one with our data. We 
# could use our R wrangling skills to shape these into a rectangular data.frame. 
# There is an easier way though - the html_table() function. Let's trace back a 
# few steps to our tab1 object...
xml_children(tab1)

# We can see that tab1 has three children. Our categories are stored in the 
# "thead" node, and our data are in the "tbody" node. 

# IGNORE ALL OF THE ABOVE WITH TAB2
# Apparently all of the above doesn't work because the website was changed
# So ignore table 2, our attempt to do it manually
# Look at tab1, the html node we're interested in. 
# Now we're gonna use html_table to make a tibble we can work with. 
# The html_table() function can parse this type of structure automatically. 
# Try it out, and assign the result to an object.

?html_table

dat <- html_table(tab1, header = T)[[1]] 

# Without the [1], the tibble is a list, with the [[1]] I am selecting
# The dataframe within the list... 

head(dat)

# x is tab1 (the html node we're interested in)

dat %>%
  filter(grepl("ENG|AUS", Player)) %>%
  ggplot(aes(Balls, Wkts)) +
    geom_text(aes(label = Player)) +
    geom_smooth(method = "lm")

##############################
# Putting it all together... #
##############################

# Now that we've managed to do that for bowlers, try completing all the steps 
# yourselves on a new html - top international batsmen!

batsmen <- "https://stats.espncricinfo.com/ci/content/records/223646.html"

html2 <- read_html(batsmen)
html2

html2 %>%
  html_nodes("table")

html2 %>% 
  html_nodes(".ds-table")

tab3 <- html2 %>%
  html_nodes(xpath = "//table[position()=1]")

dat2 <- html_table(tab3, header = T)[[1]] 

dat2 %>%
  filter(grepl("IND", Player)) %>%
  ggplot(aes(Runs, BF)) +
  geom_text(aes(label = Player)) +
  geom_smooth(method = "lm")

# Then we would just have to get rid of the "+" 
# We could do a regex for this :) 

