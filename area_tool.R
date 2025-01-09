# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(broom)


# Function to get user input for folder path and action
getUserInput <- function() {
  # Prompt the user for the folder path
  folder_dir <- readline(prompt = "Enter the path to the folder: ")
  
  # Prompt the user for the action
  funct <- readline(prompt = "Enter the action you want to perform (i.e., 'Everything', 'Extract_Mean_SD', 'Combine_Normalize', 'Graph'): ")
  
  return(list(folder_path = folder_path, action = action))
}

# Function to perform actions based on user input
performAction <- function(folder_path, action) {
  # Check if the folder exists
  if (!dir.exists(folder_path)) {
    stop("The specified folder does not exist.")
  }
  
  # Perform the specified action
  result <- switch(action,
                   "Everything" = 
                    
                     ,
                   
                   
                   
                   "count_files" = length(list.files(folder_path)),
                   stop("Invalid action specified.")
  )
  
  return(result)
}

# Main execution
user_args <- getUserInput()

# Perform the action based on user input
tryCatch({
  result <- performAction(user_args$folder_path, user_args$action)
  print(result)
}, error = function(e) {
  cat("An error occurred:", e$message, "\n")
})

tblCreator <- function(path) {
  setwd(path)
  main_folder <- path
  
  # Define the directories to process
  dirs <- list.dirs(main_folder, full.names = TRUE, recursive = FALSE)
  
  for (folder in dirs) {
    # Get the full path of the directory
    folder_path <- file.path(main_folder, folder)
    
    # Get the list of CSV files in the directory
    file_names <- list.files(folder_path, pattern = "*.csv", full.names = TRUE, recursive = FALSE)
    
    # Print the directory name
    print(paste("Directory:", folder))
    
    # Initialize an empty list to store Area data for the current directory
    area_data_list <- list()
    file_names_short <- gsub(".csv", "", basename(file_names))  # Get the short file names without extensions
    
    # Iterate over each CSV file in the directory
    for (file in file_names) {
      print(paste("Processing file:", file))  # Print the file name with indentation
      # Read the CSV file
      data <- read.csv(file)
      
      # Extract the 'Area' column and convert to numeric if needed
      if ("Area" %in% colnames(data)) {
        data$Area <- as.numeric(as.character(data$Area))
        
        # Store the Area data in the list
        area_data_list[[basename(file)]] <- data$Area
      }
    }
    
    # Combine all Area data into a single data frame
    combined_area_data <- do.call(cbind, area_data_list)
    colnames(combined_area_data) <- file_names_short  # Set the column names to the short file names
    
    output_path <- "C:/Users/sword/Downloads/Lab_Data/011224-e6.1-ob15-21d-processed-20240723T184203Z-001/011224-e6.1-ob15-21d-processed/combined_files"
    
    # Construct the output file path for the combined data
    output_file <- file.path(output_path, paste0("Combined_Area_", folder, ".csv"))
    
    # Save the combined data frame to a CSV file
    write.csv(combined_area_data, output_file, row.names = FALSE)
    
    print(paste("Saved combined Area data to:", output_file))
    
  }
}

combineColumns <- function(input_csv, output_dir) {
  # Read the CSV file
  data <- read.csv(input_csv)
  
  # Initialize a list to store the combined data
  combined_data <- list()
  
  # Get the number of columns
  num_cols <- ncol(data)
  
  if (num_cols == 21) {
    # Combine columns 5 to 7 together
    combined_data[[1]] <- unlist(data[, 5:7], use.names = FALSE)
    
    # Combine every other column in pairs (excluding columns 5 to 7)
    column_indices <- c(1:4, 8:num_cols)
    combined_index <- 2
    
    for (i in seq(1, length(column_indices), by = 2)) {
      col1_index <- column_indices[i]
      col2_index <- ifelse(i + 1 <= length(column_indices), column_indices[i + 1], NA)
      
      col1 <- data[, col1_index]
      if (!is.na(col2_index)) {
        col2 <- data[, col2_index]
        combined_data[[combined_index]] <- c(col1, col2)
      } else {
        combined_data[[combined_index]] <- col1
      }
      
      combined_index <- combined_index + 1
    }
  } else if (num_cols == 19) {
    # Combine columns normally but skip column 8
    combined_index <- 1
    
    for (i in seq(1, num_cols, by = 2)) {
      if (i == 8) {
        next  # Skip column 8
      }
      
      col1_index <- i
      col2_index <- ifelse(i + 1 <= num_cols, i + 1, NA)
      
      col1 <- data[, col1_index]
      if (!is.na(col2_index)) {
        col2 <- data[, col2_index]
        combined_data[[combined_index]] <- c(col1, col2)
      } else {
        combined_data[[combined_index]] <- col1
      }
      
      combined_index <- combined_index + 1
    }
  } else if (num_cols == 6 || num_cols == 12){
    next
    } else {
    # Combine every other column in pairs normally
    combined_index <- 1
    
    for (i in seq(1, num_cols, by = 2)) {
      col1_index <- i
      col2_index <- ifelse(i + 1 <= num_cols, i + 1, NA)
      
      col1 <- data[, col1_index]
      if (!is.na(col2_index)) {
        col2 <- data[, col2_index]
        combined_data[[combined_index]] <- c(col1, col2)
      } else {
        combined_data[[combined_index]] <- col1
      }
      
      combined_index <- combined_index + 1
    }
  }
  
  # Create a dataframe from the combined data
  combined_df <- as.data.frame(do.call(cbind, combined_data))
  
  # Generate the output file name
  input_file_name <- basename(input_csv)
  output_file_name <- paste0(tools::file_path_sans_ext(input_file_name), ".combined.", tools::file_ext(input_file_name))
  output_csv <- file.path(output_dir, output_file_name)
  
  # Write the combined data to a new CSV file
  write.csv(combined_df, file = output_csv, row.names = FALSE)
  
  return(output_csv)
}

# Function to read data and extract mean and SD
read_and_process_data <- function(file_path, day) {
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

# Combines and Normalizes Data
preprocessing <- function(day7, day14, day21, nameList){
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
  
  
  
  print(colnames(combined_means_filter))
  print(colnames(combined_sds_filter))
  
  #debug checkers:
  print(combined_means_filter)
  print(combined_sds_filter)
  
  combined_data <- merge(combined_means_filter, combined_sds_filter, by = "Day", suffixes = c("_Mean", "_SD"))
  
  data_cols <- colnames((combined_data[-1]))
  
  final_data <- combined_data %>% select(Day)
  
  names <- nameList
  
  final_data <- combined_data %>% mutate(across(all_of(names), ~ NA))
  
  
  
  for (treatment in names){
    row <- 1
    
    #print(paste(treatment, ":"))
    #print(combined_data[treatment][row,])
    
    for (i in 1:nrow(combined_data)){
      day7 <- combined_data[treatment][1,]
      processingVal <- combined_data[treatment][i,]
      
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
  
  print(final_data)
  return (final_data)
}



day7_63 <- "C:/Users/sword/Downloads/Lab_Data/OB14-122023-7d-20240328T174453Z-001/OB14-122023-7d/63_OB14-122023-7d.csv"
day14_63 <- "C:/Users/sword/Downloads/Lab_Data/E6_OB14_122723_14d/63MM_E6_OB14_122723_14d.csv"
day21_63 <- "C:/Users/sword/Downloads/Lab_Data/E6-010324-ob14_21/combined_files/MeanMedian/63MM_E6-010324-ob14_21.csv"

nameList63 <- c("Water_Mean", "DMSO_Mean", "PFOS_Mean", "PFBS_Mean", "GEN.X_Mean","PFNA_Mean","PFOA_Mean", "PFHXS_Mean", "Water_SD",   
                "DMSO_SD", "PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")


df_63 <- preprocessing(day7_63, day14_63, day21_63, nameList63)

###################################################################################################################################################################################

day7_83 <- "C:/Users/sword/Downloads/Lab_Data/OB14-122023-7d-20240328T174453Z-001/OB14-122023-7d/83_OB14-122023-7d.csv"
day14_83 <- "C:/Users/sword/Downloads/Lab_Data/E6_OB14_122723_14d/83MM_E6_OB14_122723_14d.csv"
day21_83 <- "C:/Users/sword/Downloads/Lab_Data/E6-010324-ob14_21/combined_files/MeanMedian/83MM_E6-010324-ob14_21.csv"
nameList83 <- c("Water_Mean", "Wat.P1.W6_Mean", "Wat.P2.W2_Mean", "Wat.P2.W3_Mean", "DMSO_Mean","DMSO.P2_Mean","PFOS_Mean", "PFBS_Mean", "GEN.X_Mean", "PFNA_Mean", "PFOA_Mean", "PFHXS_Mean",   
                "Water_SD", "Wat.P1.W6_SD", "Wat.P2.W2_SD", "Wat.P2.W3_SD", "DMSO_SD","DMSO.P2_SD","PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")

df_83 <- preprocessing(day7_83, day14_83, day21_83, nameList83)

###################################################################################################################################################################################

day7_121 <- "C:/Users/sword/Downloads/Lab_Data/e6-122923-ob15-pre-day7-processed-20240723T184152Z-001/e6-122923-ob15-pre-day7-processed/121MM_OB15_day7.csv"
day14_121 <- "C:/Users/sword/Downloads/Lab_Data/ob15-e6-010524-14d-processed-20240723T184156Z-001/ob15-e6-010524-14d-processed/121MM_OB15_day14.csv"
day21_121 <- "C:/Users/sword/Downloads/Lab_Data/011224-e6.1-ob15-21d-processed-20240723T184203Z-001/011224-e6.1-ob15-21d-processed/combined_files/combined_final/MeanMedian/121MM_011224-e6.1-ob15-21d.csv"

nameList121 <- c("Water_Mean", "Water.P2_Mean", "DMSO_Mean", "DMSO.P2_Mean", "PFOS_Mean", "PFBS_Mean", "GEN.X_Mean", "PFNA_Mean", "PFOA_Mean", "PFHXS_Mean", "Water_SD", "Water.P2_SD", "DMSO_SD",
                 "DMSO.P2_SD", "PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")

df_121 <- preprocessing(day7_121, day14_121, day21_121, nameList121)

###################################################################################################################################################################################

day7_55 <- "C:/Users/sword/Downloads/Lab_Data/e6-122923-ob15-pre-day7-processed-20240723T184152Z-001/e6-122923-ob15-pre-day7-processed/55_2MM_OB15_day7.csv"
day14_55 <- "C:/Users/sword/Downloads/Lab_Data/ob15-e6-010524-14d-processed-20240723T184156Z-001/ob15-e6-010524-14d-processed/55_2MM_OB15_day14.csv"
day21_55 <- "C:/Users/sword/Downloads/Lab_Data/011224-e6.1-ob15-21d-processed-20240723T184203Z-001/011224-e6.1-ob15-21d-processed/combined_files/combined_final/MeanMedian/55.2MM_011224-e6.1-ob15-21d.csv"

nameList55 <- c("Water_Mean", "Water.P2_Mean", "DMSO_Mean", "DMSO.P2_Mean", "PFOS_Mean", "PFBS_Mean", "GEN.X_Mean", "PFNA_Mean", "PFOA_Mean", "PFHXS_Mean", "Water_SD", "Water.P2_SD", "DMSO_SD",
                "DMSO.P2_SD", "PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")

df_55 <- preprocessing(day7_55, day14_55, day21_55, nameList55)

###################################################################################################################################################################################

day7_57 <- "C:/Users/sword/Downloads/Lab_Data/e6-122923-ob15-pre-day7-processed-20240723T184152Z-001/e6-122923-ob15-pre-day7-processed/57_2MM_OB15_day7.csv"
day14_57 <- "C:/Users/sword/Downloads/Lab_Data/ob15-e6-010524-14d-processed-20240723T184156Z-001/ob15-e6-010524-14d-processed/57_2MM_OB15_day14.csv"
day21_57 <- "C:/Users/sword/Downloads/Lab_Data/011224-e6.1-ob15-21d-processed-20240723T184203Z-001/011224-e6.1-ob15-21d-processed/combined_files/combined_final/MeanMedian/57.2MM_011224-e6.1-ob15-21d.csv"

nameList57 <- c("Water_Mean", "Water.P2_Mean", "DMSO_Mean", "DMSO.P2_Mean", "PFOS_Mean", "PFBS_Mean", "GEN.X_Mean", "PFNA_Mean", "PFOA_Mean", "PFHXS_Mean", "Water_SD", "Water.P2_SD", "DMSO_SD",
                "DMSO.P2_SD", "PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")

df_57 <- preprocessing(day7_57, day14_57, day21_57, nameList57)

###################################################################################################################################################################################

day7_83.2 <- "C:/Users/sword/Downloads/Lab_Data/e6-122923-ob15-pre-day7-processed-20240723T184152Z-001/e6-122923-ob15-pre-day7-processed/83.2MM_OB15_day7.csv"
day14_83.2 <- "C:/Users/sword/Downloads/Lab_Data/ob15-e6-010524-14d-processed-20240723T184156Z-001/ob15-e6-010524-14d-processed/83.2MM_OB15_day14.csv"
day21_83.2 <- "C:/Users/sword/Downloads/Lab_Data/011224-e6.1-ob15-21d-processed-20240723T184203Z-001/011224-e6.1-ob15-21d-processed/combined_files/combined_final/MeanMedian/83.2MM_011224-e6.1-ob15-21d.csv"

nameList83.2 <- c("Water_Mean", "Water.P2_Mean", "DMSO_Mean", "DMSO.P2_Mean", "PFOS_Mean", "PFBS_Mean", "GEN.X_Mean", "PFNA_Mean", "PFOA_Mean", "PFHXS_Mean", "Water_SD", "Water.P2_SD", "DMSO_SD",
                  "DMSO.P2_SD", "PFOS_SD", "PFBS_SD", "GEN.X_SD", "PFNA_SD", "PFOA_SD", "PFHXS_SD")

df_83.2 <- preprocessing(day7_83.2, day14_83.2, day21_83.2, nameList83.2)

# Function to create and save plots
create_plot <- function(treatment) {
  mean_col <- paste0(treatment, "_Mean")
  sd_col <- paste0(treatment, "_SD")
  dmso_mean_col <- "DMSO_Mean"
  dmso_sd_col <- "DMSO_SD"
  
  p <- ggplot(final_data, aes(x = Day)) +
    geom_point(aes(y = !!sym(mean_col), color = treatment)) +
    geom_errorbar(aes(ymin = !!sym(mean_col) - !!sym(sd_col),
                      ymax = !!sym(mean_col) + !!sym(sd_col),
                      color = treatment),
                  width = 0.2) +
    #geom_smooth(aes(y = !!sym(mean_col), color = treatment), method = "lm", se = FALSE, linetype = "dashed") +
    geom_point(aes(y = !!sym(dmso_mean_col), color = "DMSO")) +
    geom_errorbar(aes(ymin = !!sym(dmso_mean_col) - !!sym(dmso_sd_col),
                      ymax = !!sym(dmso_mean_col) + !!sym(dmso_sd_col),
                      color = "DMSO"),
                  width = 0.2) +
    #geom_smooth(aes(y = !!sym(dmso_mean_col), color = "DMSO"), method = "lm", se = FALSE, linetype = "dashed") +
    geom_text(aes(y = !!sym(mean_col), label = sprintf("%.3f", !!sym(mean_col))), vjust = -1, hjust = 1, color = "blue") + 
    geom_text(aes(y = !!sym(dmso_mean_col), label = sprintf("%.3f", !!sym(dmso_mean_col))), vjust = -1, hjust = 1, color = "red") + 
    
    labs(title = paste("Line 63, Treatment:", treatment, "with DMSO as Control"),
         x = "Day",
         y = "Value",
         color = "Legend") +
    theme_minimal()
  
  # Save the plot to the current directory
  ggsave(filename = paste0(treatment, "_with_DMSO_63.png"), plot = p)
}

# List of treatments excluding DMSO
treatments <- c("Water", "PFOS", "PFBS", "GEN.X", "PFNA", "PFOA", "PFHXS")

# Create and save plots for each treatment
lapply(treatments, create_plot)

listdf <- list(df_63, df_83, df_121, df_55, df_57, df_83.2)

print(df_83.2)

create_plot <- function(treatments, list_data) {
  # Define colors for treatments
  
  
  # Iterate over each treatment
  for (treatment in treatments) {
    
    color_map <- c(setNames(rep("blue", length(treatments)), treatments))
    color_map[treatment] <- "red"
    color_map["Water"] <- "blue"
    
    mean_col <- paste0(treatment, "_Mean")
    sd_col <- paste0(treatment, "_SD")
    
    # Calculate mean of means and average SD for each time point for treatment
    treatment_summary <- bind_rows(list_data) %>%
      group_by(Day) %>%
      summarise(
        Treatment_Mean = mean(!!sym(mean_col), na.rm = TRUE),
        Treatment_SD = sd(!!sym(mean_col), na.rm = TRUE),
        
        
      )
    
    # Print treatment summary for checking
    cat("Processing Treatment:", treatment, "\n")
    print(treatment_summary)
    
    # Calculate mean and SD for DMSO
    DMSO_mean_col <- "Water_Mean"
    DMSO_sd_col <- "Water_SD"
    
    DMSO_summary <- bind_rows(list_data) %>%
      group_by(Day) %>%
      summarise(
        DMSO_Mean = mean(!!sym(DMSO_mean_col), na.rm = TRUE),
        DMSO_SD = sd(!!sym(DMSO_mean_col), na.rm = TRUE)
      )
    
    
    
    # Print DMSO summary for checking
    cat("Processing DMSO Summary:\n")
    print(DMSO_summary)
    
    # Combine both summaries for plotting
    summary_data <- treatment_summary %>%
      left_join(DMSO_summary, by = "Day")
    
    # Print combined summary data for final check
    cat("Combined Summary Data for Plotting:\n")
    print(summary_data)
    
    # Create the plot
    p <- ggplot(summary_data, aes(x = Day)) +
      geom_point(aes(y = Treatment_Mean, color = treatment)) +
      geom_errorbar(aes(ymin = Treatment_Mean - Treatment_SD, ymax = Treatment_Mean + Treatment_SD), color = "red",width = 0.2) +
      geom_point(aes(y = DMSO_Mean, color = "Water")) +
      geom_errorbar(aes(ymin = DMSO_Mean - DMSO_SD, ymax = DMSO_Mean + DMSO_SD), color = "blue", width = 0.2) +
      geom_text(aes(y = Treatment_Mean, label = sprintf("%.2f", Treatment_Mean), color = treatment), 
                vjust = 1.5, hjust = 0.5, show.legend = FALSE) +  # Adjusted position for treatment mean
      geom_text(aes(y = DMSO_Mean, label = sprintf("%.2f", DMSO_Mean), color = "Water"), 
                vjust = -1.5, hjust = 0.5, show.legend = FALSE) +  # Adjusted position for Water mean
      labs(title = paste("AVG_mean_sds_for", treatment, "with Water Control"),
           x = "Day",
           y = "Mean Value",
           color = "Legend") +
      scale_color_manual(values = color_map) +  # Set manual colors
      theme_minimal()
    
    # Set the working directory
    setwd("C:/Users/sword/Downloads/Lab_Data/combined_graphs/Graphs")
    
    # Save the plot to the current directory
    ggsave(filename = paste0(treatment, "_Mean_with_Water_Control.png"), plot = p)
  }
}


create_plot(treatments, listdf)

create_plotDMSO <- function(treatments, list_data) {
  # Define colors for treatments
  
  
  # Iterate over each treatment
  for (treatment in treatments) {
    
    color_map <- c(setNames(rep("blue", length(treatments)), treatments))
    color_map[treatment] <- "red"
    color_map["DMSO"] <- "blue"
    
    mean_col <- paste0(treatment, "_Mean")
    sd_col <- paste0(treatment, "_SD")
    
    # Calculate mean of means and average SD for each time point for treatment
    treatment_summary <- bind_rows(list_data) %>%
      group_by(Day) %>%
      summarise(
        Treatment_Mean = mean(!!sym(mean_col), na.rm = TRUE),
        Treatment_SD = sd(!!sym(mean_col), na.rm = TRUE)
      )
    
    # Print treatment summary for checking
    cat("Processing Treatment:", treatment, "\n")
    print(treatment_summary)
    
    # Calculate mean and SD for DMSO
    DMSO_mean_col <- "DMSO_Mean"
    DMSO_sd_col <- "DMSO_SD"
    
    DMSO_summary <- bind_rows(list_data) %>%
      group_by(Day) %>%
      summarise(
        DMSO_Mean = mean(!!sym(DMSO_mean_col), na.rm = TRUE),
        DMSO_SD = sd(!!sym(DMSO_mean_col), na.rm = TRUE)
      )
    
    
    # Print DMSO summary for checking
    cat("Processing DMSO Summary:\n")
    print(DMSO_summary)
    
    # Combine both summaries for plotting
    summary_data <- treatment_summary %>%
      left_join(DMSO_summary, by = "Day")
    
    # Print combined summary data for final check
    cat("Combined Summary Data for Plotting:\n")
    print(summary_data)
    
    # Create the plot
    p <- ggplot(summary_data, aes(x = Day)) +
      geom_point(aes(y = Treatment_Mean, color = treatment)) +
      geom_errorbar(aes(ymin = Treatment_Mean - Treatment_SD, ymax = Treatment_Mean + Treatment_SD), color = "red", width = 0.2) +
      geom_point(aes(y = DMSO_Mean, color = "DMSO")) +
      geom_errorbar(aes(ymin = DMSO_Mean - DMSO_SD, ymax = DMSO_Mean + DMSO_SD), color = "blue", width = 0.2) +
      geom_text(aes(y = Treatment_Mean, label = sprintf("%.2f", Treatment_Mean), color = treatment), 
                vjust = -1.5, hjust = 0.25, show.legend = FALSE) +  # Adjusted position for treatment mean
      geom_text(aes(y = DMSO_Mean, label = sprintf("%.2f", DMSO_Mean), color = "DMSO"), 
                vjust = 1.5, hjust = 0.5, show.legend = FALSE) +  # Adjusted position for DMSO mean
      labs(title = paste("AVG_mean_sds_for", treatment, "with DMSO Control"),
           x = "Day",
           y = "Mean Value",
           color = "Legend") +
      scale_color_manual(values = color_map) +  # Set manual colors
      theme_minimal()
    
    # Set the working directory
    setwd("C:/Users/sword/Downloads/Lab_Data/combined_graphs/Graphs")
    
    # Save the plot to the current directory
    ggsave(filename = paste0(treatment, "_Mean_with_DMSO_Control.png"), plot = p)
  }
}


create_plotDMSO(treatments, listdf)

combined_df <- bind_rows(df_63, df_83, df_121, df_55, df_57, df_83.2)

