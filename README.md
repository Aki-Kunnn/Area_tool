# Table of Contents:
- [Install Instructions](#Install-Instructions)
- [Before Running](#What-you-need-before-hand)
- [Tool Usage](#How-to-Use-the-Tool)
  - [Extracting, Consolidating, Sorting](#For-Extracting-and-Consolidating-All-Area-Columns-Into-One-File-And-Sorting-Them)
  - [Normalization To Base Day](#Normalization-To-Your-Base-Day)
- [Runtime, Big O, Memory](#runtime-and-big-o-analysis-memory)
- [Credits](#Credits)
# Install Instructions

Hover over the file that says area_tool, click it and then press the download button on the top right and obtain the R script.
![image](https://github.com/user-attachments/assets/99122386-de17-4474-b4e8-7072299664e1)

# What you need before hand

- **You should have R studio installed to be able to open the script**

  **Folder Format:**
   - All of your lines should be in the same folder, and the naming of the folder should be like something like this: "Line_63_OB15_110324"
   - Within the line folder, it should have seperate timepoint folders which contain your actual data, "day7, day14, ..."
   - It is recommended that you create a folder contains the R_script itself, and the line folder, as it'll be easier for organization and the script can easily access and create the appropriate folders

  **The Required Structure Is Listed Below:**
  ```
  Folder With The following:/
  ├── Area_tool.R
  ├── Folder With All The Lines/  
  │   ├── Line_63_OB15_110324/
  │   │   ├── day7/   → Raw ImageJ Files w/Area Column  
  │   │   ├── day14/  → Raw ImageJ Files w/Area Column 
  │   │   └── day21/  → Raw ImageJ Files w/Area Column  
  │   ├── Line_83_OB19_110327/  
  │   │   ├── day7/   → Raw ImageJ Files w/Area Column 
  │   │   ├── day14/  → Raw ImageJ Files w/Area Column 
  │   │   └── day21/  → Raw ImageJ Files w/Area Column 
  │   .
  │   .
  │   .
  ```


# How to Use the tool

- We'll be **Control(Windows)/Command(Mac) + Enter**, to Run the Script
- You must press both keys at the same time

## For Extracting and Consolidating All Area Columns Into One File And Sorting Them:

This is the first half of the script, at this point the input files are simply the excel sheets straight from ImageJ, the assumption is that you have at least one area column within the file for extraction.

### Step 1: Install All Necessary Packages for the Tool

- <mark>**The first three steps are only necessary when running the script for the first time, or running on a new computer!!!**</mark>

One of the first things you should see when you open up the script for the first time is this window with the code.

![image](https://github.com/user-attachments/assets/fdbbdd6d-de65-451b-b9b3-a32dc7f4b858)

Make sure you are hovering at the very top of the script, simply press control enter once and click yes to any prompts that may come up, this will install all the things necessary for the tool to run. You've now completed step 1.

### Step 2: Load all the Packages:

![image](https://github.com/user-attachments/assets/cfa38151-f763-49a7-9fb0-cbb98627794e)

Now you must load all the packages. Simply press control enter until your cursor reaches the line with all the hashtags, boxed in red. You've now completed step 2.

### Step 3: Load all the functions of the tool:

![image](https://github.com/user-attachments/assets/24b8b89b-f0ce-494f-8608-c9a0c48ea3e8)

Lastly load up the functions for the tool, again simply press control enter until your cursor reaches the second line of hashtags. Note that, the functions will either be open already or will open up, and this is fine. You simply need to hit control enter a total of **5 times**. You've now completed step 3.

### Step 4: Input Your Prompts

![image](https://github.com/user-attachments/assets/af145ba7-0811-4737-99b9-a71338394264)
<a id="inputConsole"></a>
Press Control Enter on inputs. Now you should turn your attention to the console right below the code screen, boxed in yellow:


![inputConsole](https://github.com/user-attachments/assets/1160db8c-0de2-41e5-9125-ca663d47dfd7)

A total of 5 different prompts will appear:

#### **1. Enter the Path to the results folder:**


- For Windows, you can simply open the file manager and navigate to the folder with all your lines, simply copy that, **CHANGE ALL BACKSLASHES TO FORWARD SLASHES**, and paste it into the console.
```
Before: "C:\Users\User\Lab_Data\area_tool\test_dir"
After: "C:/Users/User/Lab_Data/area_tool/test_dir"
```

#### **2. Enter the Lines you want to run:**

As with your folder naming earlier, input each of the line names that you want to run seperated by commas, (i.e: Line_63, Line_83). The important thing is that it should be within the folder name itself when you named your folders earlier, for example Line_63 was in 
"Line_63_OB15_110324"

```
Example:
Enter the Lines you want to run: Line_63, Line_83
```

#### **3. Enter the day list:**

Similar to the previous step, enter the days you want to run in a comma seperated format:

```
Example:
Enter the days list: day7, day14, day21
```

#### **4. Enter the treatment list:**

Follow the comma seperated format. Enter the conditions/treatments you have for all of the data. This will be the names the scripts uses to name the columns, so be sure to enter something you can easily recognize

```
Example:
Enter the treatment list: PFOA, GEN X, PFAS, WATER_1, WATER_2
```

#### **5. Enter the abbreviations for the treatment list:**

Follow the comma seperated format. Enter the abbreviations for the conditions/treatments you have for all of the data. 
##### **IMPORTANT:** 
- Make sure to put the abbreviations in the same order as you did for the nonabbreviated treatment list. For example, if you put int "PFOA" first, you should thus put the abbreviation "oa" first here. 
- Also make sure your raw data files from ImageJ contain these abbreviations, this is so the code can recognize which correspond to which! Also be careful to not name anything to similar, i.e: "o" for "condition_o1" and "oa" for PFAS, as this can cause the code to mix up the data.

```
Example:
Enter the treatment list: oa, gx, as, WATER_1, WATER_2

#Notice how the abbreviations match the treatment list from prompt 4!
```

You should now get a confirmation in the console, it'll display a sanity check to make sure your conditions matched the abbreviated list you inputted. No worries if you notice something off, simply run step 4 again. **Important** make sure that if you're checking the files to close them before you try running the tool! You will get an error message otherwise because your computer is trying to open a file that is being used.

![image](https://github.com/user-attachments/assets/5b1091f3-39b5-4dae-8e52-f48e51da98de)

## Normalization To Your Base Day

- Assume that this is a completely seperate step, the idea is such that as you add more timepoints or lines, you can run this normalization seperate to the consolidation above
- The input are the same as the previous step, except with base day.
- The output of is a normalized file to your base day, assume that you can put this file into whatever imaging/visualization software you would like

### Step 1: **Load the packages and functions:**

Similar to the previous step, please load all the packages and functions:

![image](https://github.com/user-attachments/assets/dc48cc01-0690-4e57-8a29-de702017c3ac)

Simply press control enter until your cursor reaches the line with all the hashtags. You've now completed step 1.

### Step 2: **Input your paramters**

The parameters are **ALMOST** exactly the same as the previous section. However, **base day** is an additional input. We assume that you've run the previous section such that there is a meanMedian directory that contains your base day. For example, let us say you're running this on line 98, timepoint of day 21. Let us say your base day is day 3, make sure that you have a file in the meanMedian folder that has day  3! Run up to mmDir!

**Note: for your inputs, it is similar to the previous section as well. You must input your parameters into the console. If you need to check where the console is, please refer to this [image](#inputConsole):**
![image](https://github.com/user-attachments/assets/8c7a57cc-22fe-4771-b46c-6ff74ce61014)

### Step 3: **Run the normalization**

Press control enter once, and your files should be normalized in the "normalizedFiles" folder. 

**Again,** please note that if you're checking the files, make sure to close them before running the tool!

![image](https://github.com/user-attachments/assets/1f145250-e5e3-4e66-b35c-0c1871779d5f)

You now should have the excel/csv file ready for input into your graphing software!


# Runtime and Big O Analysis, Memory

For anyone interested:

Section 1: O(|# of lines| * |# of days| * | # of samples * # of duplicates + # of hashing parameters|)

The algorithm runs in polynomial time scaling to the number of lines, timepoints and samples/duplicates you choose. Perhaps there is a more efficient way to structure the file format, but from a user perspective this standardizes the folder organization without sacrificing too much runtime. You save some time such that if the folder doesn't match any of your inputs, it'll skip it. Regardless, you have to load each file to pull out the area column anyways of the files you choose. You do save memory as your computer won't have to load the skipped folders's data.

One improvement lies in the search technique, one likely could scale the |# of lines| and |# of days| down to a log scaled big O with an efficient search method or even a hashtable.

Section 2: O(|# of lines| * |# of days| * |# of mean/median files + # of samples|)

Similar to the previous file you still have to iterate through the the # of lines and days. You search for the mean median file and then iterate through the number of samples to normalize. You also save some memory by skipping over files that are not in your input paramters. Overall, this leads to the polynomial time algorithm.

# Credits:
This simple tool was intended for organoid area consolidation as UC San Diego's Dept of Psychiatry, Iakoucheva Lab.








