# source some packages and functions --------------------------------------

# you can use Ctr+Shift+R to insert new code section - these show up in the toc
#you can source several packages and functions, listed in one file
source("code/packages_and_functions.R")

#Ctrl > Shift > r
#enter a title, this shows up in table of contents

# introduction ------------------------------------------------------------



# working dir and session info --------------------------------------------

#print the working directory
getwd()
#print the session and version info
sessionInfo()
rstudioapi::versionInfo()

#save them to file
writeLines(capture.output(sessionInfo()), "code/sessionInfo.txt")
writeLines(capture.output(rstudioapi::versionInfo()), "code/versionInfo.txt")



# plotting with ggplot ----------------------------------------------------

#a simple plot from the iris dataset (part of base R)

iris %>%  #we use a pipe to input the data to ggplot, piping used as an alternative to ggplot(data = x...)
  ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +  #we use + to add different elements of the plot
  geom_point() +
  geom_smooth() +
  theme_minimal() #removes grey background, changes to white, theme_bw() is the same but with black axes on the plot

#another plot
ggplot(data=diamonds, mapping=aes(x = carat, y = price, color = cut))+
  geom_point()

#a histogram
ggplot(data=diamonds) + 
  geom_histogram(aes(x=carat), binwidth=0.1) + #bin width = how much do you divide up the distribution
  geom_freqpoly(mapping=aes(x=carat, color=cut), binwidth=0.1) #frquency plot

#change the theme of the plot
iris %>%  
  ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_boxplot(notch = TRUE) +
  theme_minimal()


iris %>%  
  ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_density2d_filled() +
  theme_light()

# faceting ----------------------------------------------------------------
iris %>%  
  ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point() +
  theme_minimal() +
  facet_wrap(vars(Species)) 

#try the Esquisse 'ggplot2 builder' add-on
install.packages("esquisse")

library(esquisse)
help("esquisse")

#Addins > 'ggplot2 builder'

library(ggplot2)
#plot inserted from esquisse - plotting cheat, trying out different types of plot
ggplot(datasets::airquality) +
 aes(x = Month, y = Ozone, colour = Month) +
 geom_point(shape = "circle", 
 size = 2.8) +
 scale_color_gradient() +
 theme_minimal()


# modify legends ----------------------------------------------------------

#another plot - changing the legends
#assign plot to the variable - this is now in the environment
iris_plot <- iris %>%  
  ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point() +
  theme_minimal() +
  facet_wrap(vars(Species)) +
  labs(x = "x axis label", y = "y axis label") +
  theme_minimal() +
  theme(legend.position = "left")

iris_plot

#saving a plot
#ggsave is part of ggplot
#ggplot2::ggsave("pictures/iris_test.png", bg = "white")
ggsave("pictures/iris_test.png", bg = "white") #saves to picture folder, with the background white rather than transparent

ggsave("pictures/iris_test.png", bg = "white",
       width = 100,
       height = 100, units = "mm",
       dpi = 300) #saves to picture folder, with the background white rather than transparent, changes the size of plot. need to specify units as "in", "cm", "mm", "px". can also specift dpi

# Tibbles - tidy your data ------------------------------------------------

vignette("tibble")

#A simple tibble
  
tb <- tibble(variable_1 = c(1,2,3,4,5,6), 
             variable_2 = c(2,3,4,5,6,7),
             variable_3 =  c("a", "a", "a", "b", "b", "c"))
tb %>%
  ggplot(aes(x = variable_1, y = variable_2, color = variable_3)) +
  geom_point()

#A more realistic example - 1
  
tb <- tibble(genotype = c("wt","wt","wt","mut","mut","mut"), 
             eye_color = c("red", "red", "red", "white", "white", "white"),
             eye_size =  c(35, 39, 33, 12, 14, 11))
tb
tb %>%
  ggplot(aes(x = genotype, y = eye_size, color = eye_color)) +
  geom_point()

#A more realistic example - 2

tb <- tibble(inhibitor = c("DMSO","DMSO","DMSO","drug1","drug1","drug1","drug1","drug1","drug1"), 
             activity = c(32,34,23,67,65,57, 56,64,62),
             replicate =  c("rep1", "rep1", "rep1", "rep1", "rep1", "rep1", "rep2", "rep2", "rep2"))
tb
tb %>%
  ggplot(aes(x = inhibitor, y = activity, color = replicate)) +
  geom_point()


# Example dataset from from Barnali ---------------------------------------

Syn_data <- read_csv("data/a-Syn-Data.csv") #as opposed to read.csv which reads data as dataframe rather than a tibble
Syn_data
#another way of plotting the data quickly is put in brackets e.g.
(Syn_data <- read_csv("data/a-Syn-Data.csv"))

#Need to do some tidying...
#the structure of this table needs to be changed as different treatments have been entered in different columns
#tibbles cannot have the same column names. 

#use piping %>% and pivot_longer to convert into long form
Syn_tb <- Syn_data %>%
  rename_with(~ gsub("_", "-", .x, fixed = TRUE)) %>% #rename _ to - (gsub means substitution)
  rename_with(~ gsub("...", "_", .x, fixed = TRUE)) %>% #rename ... to underscores
  pivot_longer(matches("aSyn"), #pivot_longer makes tibble into long format, only the columns that match aSyn
               names_to = c("condition", "sample"), names_sep = "_",
               values_to = "fluorescence") %>% #the values go to the variable fluorescence
  group_by(condition)

Syn_tb
#Let's plot the tidied tibble

Syn_tb %>%
  ggplot(aes(x = Time, y = fluorescence, color = condition)) +
  geom_smooth() +
  theme_minimal()

ggsave("pictures/synuclein_data.png", bg = "white")


# Example data from Kei ---------------------------------------------------

Ca <- read_csv("data/WTvsNOS11_cPRC_INNOS.csv") #read as tibble
Ca
#Example data from Kei - first let's rename some variables 
(Ca <- Ca %>% 
    rename(genotype = phenotype, intensity = intesnsity)
)

#Example data from Kei
Ca %>% 
  ggplot(aes(x = frame, y = intensity, color = genotype, 
             group = genotype)) +
  geom_smooth(level = 0.99, size = 0.5, span = 0.1, method = "loess") + #smooth average curves
  geom_line(aes(group = sample), size =  0.5, alpha = 0.1) + #geometric line plot
  theme_classic() +
  facet_wrap(vars(cell))

Ca %>% 
  ggplot(aes(x = frame, y = intensity, color = genotype, 
             group = genotype)) +
  geom_smooth(level = 0.99, size = 0.5, span = 0.1, method = "loess") + #smooth average curves
  geom_line(size =  0.5, alpha = 0.1) + #geometric line plot - takes out individual lines, does not group individual samples
  theme_classic() +
  facet_wrap(vars(cell))

#saves the last plot run
ggsave("pictures/Kei_NOS_data.png", bg = "white")


# Example data from Tom ---------------------------------------------------

#Example data from Tom - not raw data
filo <- read_csv("data/Tom_filopodia_analyses.csv")
filo

#Example data from Tom - raw data
#raw data collected from elyra so names need changing

filo_raw <- read_csv("data/spine activity_raw.csv")
filo_raw

#Example data from Tom - let's tidy it up
filo_raw_tb_int <- filo_raw %>%
  rename_with(~ gsub("SR_R", "SR-R", .x, fixed = TRUE)) %>%
  rename_with(~ gsub("_Area!!", "-Area!!", .x, fixed = TRUE)) %>%
  rename_with(~ gsub("Time::Relative Time!!R", "time", .x, fixed = TRUE)) %>%
  rename_with(~ gsub("_IntensityMean!!", "-IntensityMean!!", .x, fixed = TRUE)) %>%
  pivot_longer(matches("Channel"), 
               names_to = c("channel", "region", "measurement"), 
               names_sep = "_|::",
               values_to = "value") %>%
  filter(measurement == 'IntensityMean')

filo_raw_tb_int

#Let's plot the tidied tibble

filo_raw_tb_int %>%
  ggplot(aes(x = time, y = value, color = region)) +
  geom_line(aes(group = region)) +
  theme_minimal()

ggsave("pictures/Tom_filo_data.png", bg = "white")


# Assemble multi-panel figures with cowplot and patchwork packages -----------------

#if you want to do a line drawing - use Illustrator
#For microscope images, plots, tables, you do not need illustrator

### read the images with readPNG from pictures/ folder
img1 <- readPNG("pictures/Platynereis_SEM_inverted_nolabel.png")
img2 <- readPNG("pictures/synuclein_data.png")
img3 <- readPNG("pictures/Kei_NOS_data.png")
img4 <- readPNG("pictures/Tom_filo_data.png")
img5 <- readPNG("pictures/MC3cover-200um.png")

### convert to image panel and add text labels with cowplot::draw_image and draw_label
#ggdraw allows you to add labels, scale bars, annotations to your panel which will be part of the figure

install.packages("magick")
library(magick)

panelA <- cowplot::ggdraw() + cowplot::draw_image(img1, scale = 1) + 
  draw_label("Platynereis larva", x = 0.35, y = 0.99, fontfamily = "sans", fontface = "plain",
             color = "black", size = 11, angle = 0, lineheight = 0.9, alpha = 1) +
  draw_label(expression(paste("50 ", mu, "m")), x = 0.27, y = 0.05, fontfamily = "sans", fontface = "plain",
             color = "black", size = 10, angle = 0, lineheight = 0.9, alpha = 1) + 
  draw_label("head", x = 0.5, y = 0.85, fontfamily = "sans", fontface = "plain",
             color = "black", size = 9, angle = 0, lineheight = 0.9, alpha = 1) + 
  draw_label("sg0", x = 0.52, y = 0.67, fontfamily = "sans", fontface = "plain",
             color = "black", size = 9, angle = 0, lineheight = 0.9, alpha = 1)
panelA

#Make panels B-D
panelB <- ggdraw() + draw_image(img2)
panelC <- ggdraw() + draw_image(img3)
panelD <- ggdraw() + draw_image(img4)


panelB
panelC
panelD
    

# Adding scale bars -------------------------------------------------------

#when you open an image in an imaging program, the program info will tell you the scale of the image
#make sure the callibration is working
#once you export as a tif/png, that data is lost.
#once you have saved the image, add into the file name the scale of the picture e.g. you know an image across is 200um

panelE <- ggdraw() + draw_image(img5, scale = 1) + 
  draw_line(x = c(0.1, 0.3), y = c(0.07, 0.07), color = "black", size = 0.5) #draw scale bar. define the poits of the line by the proportion/percentage of the image
#with draw_label() you can write in the length, or put in figure legend
panelE


# Assemble figure with patchwork ------------------------------------------
#e.g. figure labels
# First, we define the layout with textual representation (cool and intuitive!)

layout <- "ABCDE"

#define figure panels, layout, annotations and theme
Figure1 <- panelA + panelB + panelC + panelD + panelE +
  patchwork::plot_layout(design = layout, heights = c(1, 1)) + #define relative heights and widths of columns
  patchwork::plot_annotation(tag_levels = "A") &
  ggplot2::theme(plot.tag = element_text(size = 12, face='plain'))


#save figure as png (pdf also works)
ggsave("figures/Figure1.png", limitsize = FALSE, 
       units = c("px"), Figure1, width = 4000, height = 800, bg = "white")


#Change the layout of the panels
  
# Change the textual layout definition
# We also need to change the dimensions of the exported figure

layout <- 
  "AABC
   AADE"

Figure1 <- panelA + panelB + panelC + panelD + panelE +
  patchwork::plot_layout(design = layout, heights = c(1, 1)) +
  patchwork::plot_annotation(tag_levels = "a") &
  ggplot2::theme(plot.tag = element_text(size = 12, face='bold'))

ggsave("figures/Figure1_layout2.png", limitsize = FALSE, 
       units = c("px"), Figure1, width = 3200, height = 1600, bg = "white")

#you have to find appropriate widths and heights for the figure so that there isn't empty space


# Practice ----------------------------------------------------------------

panelA <- cowplot::ggdraw() + cowplot::draw_image(img1, scale = 1) + 
  draw_label("Platynereis larva", x = 0.35, y = 0.99, fontfamily = "sans", fontface = "plain",
             color = "black", size = 11, angle = 0, lineheight = 0.9, alpha = 1) +
  draw_label(expression(paste("50 ", mu, "m")), x = 0.27, y = 0.05, fontfamily = "sans", fontface = "plain",
             color = "black", size = 10, angle = 0, lineheight = 0.9, alpha = 1) + 
  draw_label("head", x = 0.5, y = 0.85, fontfamily = "sans", fontface = "plain",
             color = "black", size = 9, angle = 0, lineheight = 0.9, alpha = 1) + 
  draw_label("sg0", x = 0.52, y = 0.67, fontfamily = "sans", fontface = "plain",
             color = "black", size = 9, angle = 0, lineheight = 0.9, alpha = 1)
panelA

#Make panels B-D
panelB <- ggdraw() + draw_image(img2)+
  draw_label("This is very very signficant", x = 0.5, y = 0.5)
panelC <- ggdraw() + draw_image(img3)
panelD <- ggdraw() + draw_image(img4)


panelB
panelC
panelD


# Adding scale bars -------------------------------------------------------

#when you open an image in an imaging program, the program info will tell you the scale of the image
#make sure the callibration is working
#once you export as a tif/png, that data is lost.
#once you have saved the image, add into the file name the scale of the picture e.g. you know an image across is 200um

panelE <- ggdraw() + draw_image(img5, scale = 1) + 
  draw_line(x = c(0.1, 0.3), y = c(0.07, 0.07), color = "black", size = 0.5) #draw scale bar. define the poits of the line by the proportion/percentage of the image
#with draw_label() you can write in the length, or put in figure legend
panelE


# Assemble figure with patchwork ------------------------------------------
#e.g. figure labels
# First, we define the layout with textual representation (cool and intuitive!)

layout <- "ABCDE"

#define figure panels, layout, annotations and theme
Figure1_practice <- panelA + panelB + panelC + panelD + panelE +
  patchwork::plot_layout(design = layout, heights = c(1)) + #define relative heights and widths of columns
  patchwork::plot_annotation(tag_levels = "A") &
  ggplot2::theme(plot.tag = element_text(size = 12, face='plain'))


Figure1_practice

#save figure as png (pdf also works)
ggsave("figures/Figure1_practice.png", limitsize = FALSE, 
       units = c("px"), Figure1, width = 4000, height = 800, bg = "white")


#Change the layout of the panels

# Change the textual layout definition
# We also need to change the dimensions of the exported figure

layout <- 
  "AABC
   AADE"

Figure1 <- panelA + panelB + panelC + panelD + panelE +
  patchwork::plot_layout(design = layout, heights = c(1, 1)) +
  patchwork::plot_annotation(tag_levels = "a") &
  ggplot2::theme(plot.tag = element_text(size = 12, face='bold'))

Figure1

layout <- 
  "EDACB"

Figure1_more_practice <- panelA + panelB + panelC + panelD + panelE +
  patchwork::plot_layout(design = layout, heights = c(1, 2), widths = c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)) +
  patchwork::plot_annotation(tag_levels = "a") &
  ggplot2::theme(plot.tag = element_text(size = 20, face='bold.italic', angle = 180))

Figure1_more_practice

ggsave("figures/Figure1_more_practice.png", limitsize = FALSE, 
       units = c("px"), Figure1, width = 4000, height = 1000, bg = "white")

#you have to find appropriate widths and heights for the figure so that there isn't empty space



### use Kei's data and facet by both cell and genotype

Ca <- read_csv("data/WTvsNOS11_cPRC_INNOS.csv") #read as tibble
Ca
#Example data from Kei - first let's rename some variables 
(Ca <- Ca %>% 
    rename(genotype = phenotype, intensity = intesnsity)
)

install.packages("viridis")
library(viridis)

#Example data from Kei
#facet by genotype
Ca %>% 
  ggplot(aes(x = frame, y = intensity, color = cell, 
             group = genotype)) +
  geom_smooth(level = 0.99, size = 0.5, span = 0.1, method = "loess") + #smooth average curves
  geom_line(aes(group = sample), size =  0.5, alpha = 0.1) + #geometric line plot
  scale_color_viridis(option = "plasma", discrete = T, alpha = 1)+
  theme_classic() +
  facet_wrap(vars(genotype))+
  theme(text = element_text(size = 15),
        axis.title.x = element_text(size = 14, face = 'bold'),
        axis.title.y = element_text(size = 14, face = 'bold'))

Ca %>% 
  ggplot(aes(x = frame, y = intensity, color = genotype, 
             group = cell)) +
  geom_smooth(level = 0.99, size = 0.5, span = 0.1, method = "loess") + #smooth average curves
  geom_line(aes(group = sample), size =  0.5, alpha = 0.1) + #geometric line plot - takes out individual lines, does not group individual samples
  scale_color_viridis(option = "plasma", discrete = T, alpha = 1)+
  theme_classic() +
  facet_wrap(vars(cell))+
  theme(text = element_text(size = 15),
        axis.title.x = element_text(size = 14, face = 'bold'),
        axis.title.y = element_text(size = 14, face = 'bold'))





#saves the last plot run
ggsave("pictures/Kei_NOS_data_practice.eps", bg = NA) #no background
#saves as .eps

