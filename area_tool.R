### Step 1: Press Control Enter Until the line where it says input 1

      # Load necessary libraries
      library(ggplot2)
      library(dplyr)
      library(tidyr)
      library(broom)
      
      

      fileNames <- list()
      
      tblCreator <- function(path) {
        setwd(path)
        table_list <- list()
        folder_names <- list()  # Store folder names for naming MeanMedian files
        main_folder <- path
        
        parent_dir <- dirname(path)
        combined_folder <- file.path(parent_dir, "combined_Lines")
        if (!dir.exists(combined_folder)) {
          dir.create(combined_folder, recursive = TRUE)
        }
        
        lineList <- list.dirs(main_folder, full.names = TRUE, recursive = FALSE)
        print("Line List: ")
        print(lineList)
        
        for (line in lineList) {
          line_folder <- file.path(combined_folder, basename(line))
          if (!dir.exists(line_folder)) {
            dir.create(line_folder, recursive = TRUE)
          }
          
          timepoints <- list.dirs(line, full.names = TRUE, recursive = FALSE)
          
          print(timepoints)
          
          for (time in timepoints) {
            
            time_folder <- file.path(line_folder, basename(time))
            if (!dir.exists(time_folder)) {
              dir.create(time_folder, recursive = TRUE)
            }
            
            file_names <- list.files(time, pattern = "\\.csv$", full.names = TRUE, recursive = FALSE)
            
            data_list <- list()
            file_basename_list <- list()
            max_row <- 0
            
            for (file in file_names) {
              df <- read.csv(file)
              if ("Area" %in% colnames(df)) {
                df$Area <- suppressWarnings(as.numeric(as.character(df$Area)))
              } else {
                warning(paste("Column 'Area' not found in file:", file))
                next
              }
              
              data_list[[file]] <- df
              file_basename_list <- append(file_basename_list, tools::file_path_sans_ext(basename(file)))
              
              max_row <- max(max_row, nrow(df), na.rm = TRUE)
            }
            
            table <- data.frame(matrix(NA, nrow = max_row, ncol = length(data_list)))
            
            col <- 1
            for (df in data_list) {
              table[1:nrow(df), col] <- df$Area
              col <- col + 1
            }
            
            colnames(table) <- file_basename_list
            
            if (exists("colSort")) {
              table <- colSort(table)
            }
            
            folder_name <- basename(time)
            
            assign(folder_name, table, envir = .GlobalEnv)
            
            csv_file <- file.path(time_folder, paste(folder_name, ".csv", sep = ""))
            write.csv(table, csv_file, row.names = FALSE)
            
            table_list <- append(table_list, list(table))
            folder_names <- append(folder_names, basename(time))  # Store as Line_Day#
          }
        }
        
        table_list <- append(table_list, list(NULL))
        
        meanMedian(table_list, folder_names)
        
        return(table_list)
      }
      
      meanMedian <- function(listOfDF, folder_names) {
        #Function that calculates the mean and medians and puts it into one data table
        listOfMM <- list()
        
        parent_dir = dirname(getwd())
        
        new_folder <- file.path(parent_dir, "MeanMedian")
        if (!dir.exists(new_folder)){
          dir.create(new_folder, recursive = TRUE)
        }
        
        for (i in seq_along(listOfDF)) {
          datalist <- listOfDF[[i]]
          if (!is.data.frame(datalist)) {
            warning("Input is not a data frame. Skipping...")
            next
          }
          
          num_cols <- ncol(datalist)
          if (num_cols == 0) {
            warning("Input data frame has no columns. Skipping...")
            next
          }
          
          table <- matrix(NA, nrow = 3, ncol = num_cols, dimnames = list(c("Mean", "Median", "SD"), names(datalist)))
          
          for (col in 1:num_cols) {
            table[1, col] <- mean(datalist[[col]], na.rm = TRUE)  
            table[2, col] <- median(datalist[[col]], na.rm = TRUE)  
            table[3, col] <- sd(datalist[[col]], na.rm = TRUE)
          }
          
          if (!is.null(folder_names[i])) {
            filename <- file.path(new_folder, paste(folder_names[i], "_MM.csv", sep = ""))
            write.csv(table, filename)
          }
          
          listOfMM[[i]] <- table
        }
        
        return(listOfMM)
      }
      
      combine_columns <- function(dataframe) {
        # Get column names
        col_names <- colnames(dataframe)
        
        # Ensure an even number of columns
        if (length(col_names) %% 2 != 0) {
          stop("The dataframe must have an even number of columns.")
        }
        
        # Create a new dataframe with doubled row size
        new_row_count <- nrow(dataframe) * 2
        new_col_count <- length(col_names) / 2
        combined_df <- data.frame(matrix(NA, nrow = new_row_count, ncol = new_col_count))
        
        # Set column names
        new_col_names <- col_names[seq(1, length(col_names), by = 2)]
        colnames(combined_df) <- new_col_names
        
        # Combine every two columns
        for (i in seq(1, length(col_names), by = 2)) {
          col1 <- dataframe[, i]
          col2 <- dataframe[, i + 1]
          
          combined_df[, (i + 1) / 2] <- c(col1, col2)  # Stack second column below first
        }
        
        return(combined_df)
      }
    
      colSort <- function(dataframe) {
        #Helper Function to label and sort the columns
        #print("Col sort is running")
        
        # Check if dataframe argument is empty
        if (missing(dataframe) || is.null(dataframe)) {
          stop("Dataframe argument is empty or does not exist.")
          
        }
        
        
        rawColNames <- colnames(dataframe)
        columnNames <- list()
        
        #print(rawColNames)
        
        for (name in rawColNames){
          newName <- ""
          
          # if (grepl("83", name, ignore.case = TRUE) & !grepl("83.2", name, ignore.case = TRUE)){
          #   if (grepl("w1", name, ignore.case = TRUE) & grepl("P1", name, ignore.case = TRUE)) {
          #     newName <- "GEN X"
          #   } else if (grepl("w2", name, ignore.case = TRUE) & grepl("P1", name, ignore.case = TRUE)) {
          #     newName <- "PFOS"
          #   } else if (grepl("w3", name, ignore.case = TRUE) & grepl("P1", name, ignore.case = TRUE)) {
          #     newName <- "PFBS"
          #   } else if (grepl("Water", name, ignore.case = TRUE) & grepl("\\d", name)) {
          #     newName <- sub(".*(Water_\\d+).*", "\\1", name)
          #   } else if ( grepl("DMSO", name, ignore.case = TRUE) & grepl("\\d", name)) {
          #     if(grepl("DMSO110", name, ignore.case = TRUE)){
          #       newName <- sub(".*(DMSO110_\\d+).*", "\\1", name)
          #     } else {
          #       newName <- sub(".*(DMSO_\\d+).*", "\\1", name)
          #       }
          #   } else if (grepl("w4", name, ignore.case = TRUE) & grepl("p2", name, ignore.case = TRUE)) {
          #     newName <- "PFNA"
          #   } else if (grepl("w5", name, ignore.case = TRUE) & grepl("p2", name, ignore.case = TRUE)) {
          #     newName <- "PFOA"
          #   } else if (grepl("w6", name, ignore.case = TRUE) & grepl("p2", name, ignore.case = TRUE)) {
          #     newName <- "PFHXS"
          #   } else {
          #     newName <- "unknown"
          #   }
            
          #} 
        
        if (grepl("63", name, ignore.case = TRUE) ){
            if (grepl("w1", name, ignore.case = TRUE) & grepl("Pl1", name, ignore.case = TRUE)) {
              newName <- "PFNA"
            } else if (grepl("w1", name, ignore.case = TRUE) & grepl("Pl2", name, ignore.case = TRUE)) {
              newName <- "GEN X"
            } else if (grepl("w2", name, ignore.case = TRUE) & grepl("Pl1", name, ignore.case = TRUE)) {
              newName <- "PFOA"
            } else if (grepl("Water", name, ignore.case = TRUE) & grepl("\\d", name)) {
              newName <- sub(".*(Water_\\d+).*", "\\1", name)
            } else if (grepl("w3", name, ignore.case = TRUE)) {
              newName <- "PFHXS"
            } else if (grepl("w4", name, ignore.case = TRUE)) {
              newName <- "PFBS"
            } else if (grepl("w5", name, ignore.case = TRUE)) {
              newName <- "PFOS"
            } else if (grepl("w6", name, ignore.case = TRUE) & (grepl("pl1", name, ignore.case = TRUE)) ) {
              newName <- "DMSO_1"
            } else if (grepl("w2", name, ignore.case = TRUE) & grepl("pl2", name, ignore.case = TRUE)) {
              newName = "Water_1"
            }
            
          } else {
            if (grepl("gx", name, ignore.case = TRUE) | grepl("GenX", name, ignore.case = TRUE)) {
              newName <- "GEN X"
            } else if (grepl("na", name, ignore.case = TRUE)) {
              newName <- "PFNA"
            } else if (grepl("a", name, ignore.case = TRUE) & !grepl("water", name, ignore.case = TRUE)& !grepl("na", name, ignore.case = TRUE)) {
              newName <- "PFOA"
            } else if (grepl("hx", name, ignore.case = TRUE) | grepl("hxs", name, ignore.case = TRUE)) {
              newName <- "PFHXS"
            } else if (grepl("Water", name, ignore.case = TRUE) & grepl("\\d", name)) {
              newName <- sub(".*(Water_\\d+).*", "\\1", name)
            } else if (grepl("DMSO", name, ignore.case = TRUE) & grepl("\\d", name)) {
              newName <- sub(".*(DMSO_\\d+).*", "\\1", name)
            } else if (grepl("os", name, ignore.case = TRUE)) {
              newName <- "PFOS"
            } else {
              newName <- "PFBS"
            }
          }

          columnNames <- append(columnNames, newName)
          
        }
        

        #print("Column Names: ") 
        #print(columnNames)
        colnames(dataframe) <- columnNames
        
        combined_df = combine_columns(dataframe)
        
        
        order <- c("Water_1", "Water_2", "DMSO_1", "DMSO_2", "PFOS", "PFBS", "GEN X", "PFNA", "PFOA", "PFHXS")
        
        
        

        # Keep only the columns in the dataframe that match the ordered names, skipping those not present
        
        
        order <- order[order %in% columnNames]

        combined_df <- combined_df[, order, drop = FALSE]

        
        
        return(combined_df)
      }

#### INPUT1 : specify the path to the results from ImageJ, afterward press control enter until you see input 2
      
      # Put it to the right of the arrow, make sure to make all the back slashes (Looks like this: \ ), a forward slash 
      # (Looks like this: / ) 
      path <- "C:/Users/sword/Downloads/Lab_Data/area_tool/test_dir - Copy" 
      tester <- tblCreator(path)
   


######################################################################################################################################
      
      read_and_process_data <- function(file_path, day) {
        # Helper Function to read data and extract mean and SD
        data <- read.csv(file_path, header = TRUE)
        
        means <- data[1, ]
        sds <- data[3, ]
        
        # Add 'Day' and '_SD' suffixes to the columns
        colnames(means) <- paste0(colnames(means), "_Mean")
        colnames(sds) <- paste0(colnames(sds), "_SD")
        
        means$Day <- day
        sds$Day <- day
        
        list(means = means, sds = sds)
        
        #print(means)
        #print(sds)
      }
      
      # Need an extra day? Add the following after day 14: day21,
      preprocessing <- function(day7, day14, day21, nameList){
        # Combines and Normalizes Data
        data_7 <- read_and_process_data(day7, 7)
        data_14 <- read_and_process_data(day14, 14)
        data_21 <- read_and_process_data(day21, 21)
        
        #print(combined_means)
        
        combined_means <- bind_rows(data_7$means, data_14$means, data_21$means)
        combined_sds <- bind_rows(data_7$sds, data_14$sds, data_21$sds)
        
        
        combined_means_filter <- combined_means
        combined_sds_filter <- combined_sds
        #note abt filtering, check if everything is there
        
        if ("Statistic_Mean" %in% colnames(combined_means)){
          combined_means_filter <- combined_means %>% select(-Statistic_Mean)
          
        }
        
        if ("Statistic_SD" %in% colnames(combined_sds)){
          combined_sds_filter <- combined_sds %>% select(-Statistic_SD)
          
        }
        
        
        
        #print(colnames(combined_means_filter))
        #print(colnames(combined_sds_filter))
        
        #debug checkers:
        #print(combined_means_filter)
        #print(combined_sds_filter)
        
        combined_data <- merge(combined_means_filter, combined_sds_filter, by = "Day", suffixes = c("_Mean", "_SD"))
        
        data_cols <- colnames((combined_data[-1]))
        
        final_data <- combined_data %>% select(Day)
        
        names <- nameList
        
        final_data <- combined_data %>% mutate(across(all_of(names), ~ NA))
        
        
        
        for (treatment in names){
          row <- 1
          
          #print(paste(treatment, ":"))
          #print(combined_data[treatment][row,])
          
          #print("Combined Data: ")
          #print(combined_data)
          for (i in 1:nrow(combined_data)){
            day7 <- combined_data[treatment][1,]
            processingVal <- combined_data[treatment][i,]
            
            if(treatment == "GEN.X_Mean" || treatment == "GEN.X_SD")
              print(paste("Treatment:", treatment))
            print(paste("This is the normalization factor:", day7))
            print(paste("This is the value being inputted:", processingVal))
            print(paste("This is the final value:", processingVal / day7))
            final_data[treatment][row,] <- processingVal / day7
            
            #print(combined_data[treatment][i,])
            row <- row + 1
            
            if (row > 4){
              row <- 1
            }
          }
        }
        
        #print(colnames(final_data))
        if ("X_Mean" %in% colnames(final_data)){
          final_data <- final_data %>% select(-X_Mean)  
        }
        
        if ("X_SD" %in% colnames(final_data)){
          final_data <- final_data %>% select(-X_SD)  
        }
        
        print(combined_data)
        print(final_data)
        return (final_data)
      }

      mmDir = file.path(dirname(path), "MeanMedian")
      
      
      # INPUT2: Specify the line name! For example, 83.2_day_7 change 83.2 to whatever line you want
      day7_83_2 <- file.path(mmDir, paste0("83.2_day7_", "MM.csv"), sep = "")
      day14_83_2 <- file.path(mmDir, paste0("83.2_day14_", "MM.csv"), sep = "")
      day21_83_2 <- file.path(mmDir, paste0("83.2_day21_", "MM.csv"), sep ="")
      
      # Also update your nameList accordingly, if you line has certain treatments vs not some
      nameList83_2 <- c("Water_1_Mean", "Water_2_Mean", "DMSO_1_Mean", "DMSO_2_Mean", "PFOS_Mean", "PFBS_Mean", "GEN.X_Mean", "PFNA_Mean", "PFOA_Mean", "PFHXS_Mean", "Water_1_SD", "Water_2_SD", "DMSO_1_SD",
                      "DMSO_2_SD", "PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")
      
      df_83_2 <- preprocessing(day7_83_2, day14_83_2, day21_83_2,nameList83_2)

######################################################################################################################################

# Input 3: Update your treatment list, press control enter until you past create plot

treatments <- c("Water_1", "Water_2", "DMSO_1", "DMSO_2", "PFOS", "PFBS", "GEN.X", "PFNA", "PFOA", "PFHXS")

listdf <- list(df_83_2)

create_plot <- function(treatments, list_data) {
  # Load necessary library
  library(ggplot2)
  library(dplyr)
  
  # Define colors for treatments
  color_map <- setNames(rep("blue", length(treatments)), treatments)
  
  # Iterate over each treatment
  for (treatment in treatments) {
    color_map[treatment] <- "red"
    color_map["Water"] <- "blue"
    
    mean_col <- paste0(treatment, "_Mean")
    sd_col <- paste0(treatment, "_SD")
    
    # Calculate mean of means for each time point for treatment
    treatment_summary <- bind_rows(list_data) %>%
      group_by(Day) %>%
      summarise(
        Treatment_Mean = mean(!!sym(mean_col), na.rm = TRUE),
        Treatment_SD = mean(!!sym(sd_col), na.rm = TRUE) # CHANGE THIS B/C NEED MORE DATA POINTS, after figuring out how to get the day 21 going...
      )
    
    # Use the pre-calculated SD values from your data for error bars
    DMSO_summary <- bind_rows(list_data) %>%
      group_by(Day) %>%
      summarise(
        DMSO_Mean = mean(DMSO_1_Mean, na.rm = TRUE),
        DMSO_SD = mean(DMSO_1_SD, na.rm = TRUE)
      )
    
    # Combine both summaries for plotting
    summary_data <- left_join(treatment_summary, DMSO_summary, by = "Day")
    
    print(summary_data)
    
    # Create the plot using the SD values from the list_data
    p <- ggplot(summary_data, aes(x = Day)) +
      geom_point(aes(y = Treatment_Mean, color = treatment)) +
      geom_errorbar(aes(ymin = Treatment_Mean - Treatment_SD, ymax = Treatment_Mean + Treatment_SD, color = treatment), width = 0.2) +
      geom_point(aes(y = DMSO_Mean, color = "Water")) +
      geom_errorbar(aes(ymin = DMSO_Mean - DMSO_SD, ymax = DMSO_Mean + DMSO_SD, color = "Water"), width = 0.2) +
      labs(title = paste("AVG_mean_sds_for", treatment, "with Water Control"),
           x = "Day",
           y = "Mean Value",
           color = "Legend") +
      scale_color_manual(values = color_map) +
      theme_minimal()
    
    # Set directory and save plot
    parent_dir <- dirname(getwd())
    new_folder <- file.path(parent_dir, "Graphs")
    
    if (!dir.exists(new_folder)) {
      dir.create(new_folder, recursive = TRUE)
    }
    
    ggsave(filename = file.path(new_folder, paste0(treatment, "_Mean_with_DMSO_Control.png")), plot = p)
  }
}


create_plot(treatments, listdf)

