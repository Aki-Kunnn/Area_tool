
    # STEP 1: Install All Necessary Packages for the Tool to Run
      install.packages(c("ggplot2", "dplyr", "tidyr", "broom", "hash", "data.table"))
    
    # STEP 2: Load All Necessary Packages for the Tool to Run
      library(ggplot2)
      library(dplyr)
      library(tidyr)
      library(broom)
      library(hash)
      library(data.table)
      
#######################################################################################################################################      
    
    # Step 3: Load all the functions of the tool:
      tblCreator <- function(path, line_list, day_list, treatment_list) {
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
        #print("Line List: ")
        #print(lineList)
        
        for (line in lineList) {
          
          
          
          if (sum(sapply(line_list, function(d) length(grep(d, basename(line), ignore.case = TRUE)))) == 0) {
            next
          }
          
          line_folder <- file.path(combined_folder, basename(line))
          if (!dir.exists(line_folder)) {
            dir.create(line_folder, recursive = TRUE)
          }
          
          timepoints <- list.dirs(line, full.names = TRUE, recursive = FALSE)
          #print(timepoints)
          
          for (time in timepoints) {
            # Check if the timepoint (e.g., day21) is in the day_list
            
            if (sum(sapply(day_list, function(d) length(grep(d, basename(time), ignore.case = TRUE)))) == 0) {
              next
            }
            
            time_folder <- file.path(line_folder, basename(time))
            if (!dir.exists(time_folder)) {
              dir.create(time_folder, recursive = TRUE)
            }
            
            #print("Fell in day list")
            #print(time)
            file_names <- list.files(time, pattern = "\\.csv$", full.names = TRUE, recursive = FALSE)
            
            data_list <- list()
            file_basename_list <- list()
            max_row <- 0
            
            for (file in file_names) {
              
              print(file)
              
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
              print(df)
            }
            
            
            
            table <- data.frame(matrix(NA, nrow = max_row, ncol = length(data_list)))
            
            
            col <- 1
            for (df in data_list) {
              table[1:nrow(df), col] <- df$Area
              col <- col + 1
            }
            
            colnames(table) <- file_basename_list
            
            if (exists("colSort")) {
              table <- colSort(table, treatment_list)
            }
            
            folder_name <- basename(time)
            
            assign(folder_name, table, envir = .GlobalEnv)
            
            csv_file <- file.path(time_folder, paste(folder_name, ".csv", sep = ""))
            write.csv(table, csv_file, row.names = FALSE)
            
            table_list <- append(table_list, list(table))
            folder_names <- append(folder_names, basename(line))  # Store as Line_Day#
            
            
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
            filename <- file.path(new_folder, paste(paste0(folder_names[i], paste0("_", inputs$day_list[i])), "_MM.csv", sep = ""))
            write.csv(table, filename)
          }
          
          listOfMM[[i]] <- table
        }
        
        return(listOfMM)
      }
      combine_columns <- function(dataframe) {
        # Get column names
        col_names <- colnames(dataframe)
        
        #print(dataframe)
        counter = hash()
        
        
        for (name in col_names){
          keys = keys(counter)
          if (!(name %in% keys)){
            counter[[name]] = 1
            
          }
          else{
            counter[[name]] = counter[[name]] + 1
          }
        }
          
        #print(counter)
        
        max_row = max(values(counter))
        
        
        
        # Create a new dataframe with doubled row size
        new_row_count <- nrow(dataframe) * max_row
        new_col_count <- length(col_names) * 2
        combined_df <- data.frame(matrix(NA, nrow = new_row_count, ncol = new_col_count))
        
        # Set column names
        
        
        new_col_names <- inputs$treatment_names
        
        
        colnames(combined_df) <- new_col_names

        # Combine every two columns
        for (name in new_col_names) {
          #print(paste("Processing Name:", name))
          cols <- which(colnames(dataframe) == name)  # Find all columns with the same name
          vec <- do.call(c, dataframe[, cols, drop = FALSE])  # Stack them
          #print(paste("Combined vector length for", name, "before padding:", length(vec)))
          
          # Pad the vector if it is shorter than the expected length
          expected_length <- nrow(dataframe) * max(values(counter))
          if (length(vec) < expected_length) {
            vec <- c(vec, rep(NA, expected_length - length(vec)))
          }
          
          #print(paste("Combined vector length for", name, "after padding:", length(vec)))
          combined_df[[name]] <- vec
        }
        
        return(combined_df)
      }
      colSort <- function(dataframe, treatment_list) {
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
          
          for (key in keys(treatment_list)){
            if(grepl(key, name, ignore.case = TRUE)){
              newName <- treatment_list[[key]]
              break
            }
          }
          
          # If no match was found, keep the original column name
          if (newName == "") {
            newName <- name  
          }
          
          
          columnNames <- append(columnNames, newName)
          
        }
        
        
        #print("Column Names: ") 
        #print(columnNames)
        colnames(dataframe) <- columnNames
        
        combined_df = combine_columns(dataframe)
        
        
        order <- c(inputs$treatment_names)
        
        
        
        
        # Keep only the columns in the dataframe that match the ordered names, skipping those not present
        
        
        order <- order[order %in% columnNames]
        
        combined_df <- combined_df[, order, drop = FALSE]
        
        
        
        return(combined_df)
      }
      get_user_inputs <- function() {
        path <- readline(prompt = "Enter the path to the results folder: ")
        
        line_input <- readline(prompt = "Enter the Lines you want to run: ")
        
        line_list <- strsplit(line_input, ",")[[1]]
        line_list <- trimws(line_list)
        
        day_input <- readline(prompt = "Enter the day list: ")
        
        # Convert the input string into a list of days
        day_list <- strsplit(day_input, ",")[[1]]
        day_list <- trimws(day_list)  # Remove any leading/trailing spaces
        
        treatment_input <- readline(prompt = "Enter the treatment list: ")
        
        treatment_list <- strsplit(treatment_input, ",")[[1]]
        treatment_list <- trimws(treatment_list)
        
        abb_input <- readline(prompt = "Enter the abbreviated treatment list: ")
        
        abb_list <- strsplit(abb_input, ",")[[1]]
        abb_list <- trimws(abb_list)
        
        treatment_hash <- hash()
        
        for (i in seq_len(length(treatment_list))){
          treatment_hash[[abb_list[i]]] <- treatment_list[i]
          
        }
        
        print(treatment_hash)
        
        # Return as a list
        return(list(path = path, line_list = line_list, day_list = day_list, treatment_names = treatment_list, treatment_list = treatment_hash))
      }

#######################################################################################################################################

      # STEP 4: Press Control Enter and Follow the Prompts On the Terminal:
      
      inputs <- get_user_inputs()
      
      # STEP 5: Press Control Enter on the Tester and You Will Have Complete This Half of the Code
      
      # Proceed with the tblCreator function
      tester <- tblCreator(inputs$path, inputs$line_list, inputs$day_list, inputs$treatment_list)
      
   


######################################################################################################################################
      
      #path, dayList, line_List, name_List
      preprocessing <- function(input) {
        
        parent_dir <- dirname(input$path)
        normalized_folder <- file.path(parent_dir, "normalized_Lines")
        
        # Ensure the "normalized_Lines" folder exists
        if (!dir.exists(normalized_folder)) {
          dir.create(normalized_folder, recursive = TRUE)
        }
        
        mm_files_all <- list.files(mmDir, full.names = TRUE)
        
        lineList <- list.dirs(input$path, full.names = TRUE, recursive = FALSE)
        #print(lineList)
        for (line in lineList) {
          #print(line)
          # Check if line name matches any item in line_List
          if (sum(sapply(input$line_list, function(d) length(grep(d, basename(line), ignore.case = TRUE)))) == 0) {
            next
          }
          
          line_folder <- file.path(normalized_folder, basename(line))
          if (!dir.exists(line_folder)) {
            dir.create(line_folder, recursive = TRUE)
          }
          
          line_name <- basename(line)
          
          # Use grepl to filter files that contain both the line name and base day.
          matching_files <- mm_files_all[sapply(mm_files_all, function(f) {
            grepl(line_name, f, ignore.case = TRUE) && grepl(input$base_day, f, ignore.case = TRUE)
          })]
          
          
          meanmedian_file <- matching_files[1]
          mm_data <- read.csv(meanmedian_file)
          
          
          
          timepoints <- list.dirs(line, full.names = TRUE, recursive = FALSE)

          for (time in timepoints) {
            # Check if timepoint folder matches any item in dayList
            if (sum(sapply(input$day_list, function(d) length(grep(d, basename(time), ignore.case = TRUE)))) == 0) {
              next
            }
            
            time_folder <- file.path(line_folder, basename(time))
            if (!dir.exists(time_folder)) {
              dir.create(time_folder, recursive = TRUE)
            }
            
            files_time <- list.files(time, full.names = TRUE)
            
            data <- read.csv(files_time[1])
            #print(data)
            
            toModify = copy(data)
            
            #mm_data$treatment_name[1]
            
            for (treatment_name in colnames(toModify)){
              toModify[[treatment_name]] <- toModify[[treatment_name]] / mm_data[[treatment_name]][1]
            }
            
            output_path <- file.path(time_folder, paste0(basename(time), "_normalized.csv"))
            
            write.csv(toModify, output_path, row.names = FALSE)
            #print(toModify)
          }
        }
      }
      
# INPUT2: Specify the line name! For example, 83.2_day_7 change 83.2 to whatever line you want
    
      get_user_inputs2 <- function() {
        path <- readline(prompt = "Enter the path to the combined_Lines folder: ")
        
        line_input <- readline(prompt = "Enter the Lines you want to run (e.g., '83.2, 63'): ")
        
        line_list <- strsplit(line_input, ",")[[1]]
        line_list <- trimws(line_list)
        
        day_input <- readline(prompt = "Enter the day list (e.g., 'day21, day22'): ")
        
        # Convert the input string into a list of days
        day_list <- strsplit(day_input, ",")[[1]]
        day_list <- trimws(day_list)  # Remove any leading/trailing spaces
        
        base_day <- readline(prompt = "Enter the base day (e.g., 'day7'): ")
        
        # Convert the input string into a list of days
        base_day_list <- strsplit(base_day, ",")[[1]]
        base_day_list <- trimws(base_day_list)  # Remove any leading/trailing spaces
        
        treatment_input <- readline(prompt = "Enter the treatment list (e.g., 'PFOA, GEN.X'): ")
        
        treatment_list <- strsplit(treatment_input, ",")[[1]]
        treatment_list <- trimws(treatment_list)
        
        MMnames <- list()
        
        for (name in treatment_list){
          #print(paste0(name, "_Mean"))
          MMnames <- append(MMnames, paste0(name, "_Mean"))
          
        }
        
        for (name in treatment_list){
          #print(paste0(name, "_SD"))
          MMnames <- append(MMnames, paste0(name, "_SD"))
          
        }
        
        
        
        
        abb_input <- readline(prompt = "Enter the abbreviated treatment list (e.g., 'OA, gx'), where OA = PFOA, and gx = GEN.X: ")
        
        abb_list <- strsplit(abb_input, ",")[[1]]
        abb_list <- trimws(abb_list)
        
        treatment_hash <- hash()
        
        for (i in seq_len(length(treatment_list))){
          treatment_hash[[abb_list[i]]] <- treatment_list[i]
          
        }
        
        print(treatment_hash)
        
        # Return as a list
        return(list(path = path, line_list = line_list, day_list = day_list, base_day = base_day_list, MMnames = MMnames, treatment_list = treatment_hash))
      }
      
      # C:/Users/sword/Downloads/Lab_Data/area_tool/combined_Lines
      # day21
      # Water_1, Water_2, DMSO_1, DMSO_2, PFOS, PFBS, GEN X, PFNA, PFOA, PFHXS
      # Water_1, Water_2, DMSO_1, DMSO_2, os, bs, gx, na, pfoa, hx
      
      inputs2 <- get_user_inputs2()
      
      print(inputs2$MMnames)
      
      mmDir = file.path(dirname(inputs$path), "MeanMedian")
        
      df_83_2 <- preprocessing(inputs2)
      
      df_83_2 <- preprocessing(day7_83_2, day14_83_2, day21_83_2,nameList83_2)

######################################################################################################################################


