# Install Instructions

Hover over the file that says area_tool, click it and then press the download button on the top right and obtain the R script.
![image](https://github.com/user-attachments/assets/99122386-de17-4474-b4e8-7072299664e1)

You can do the same with this Instructional README file as well, if you'd like to reference it on you personal computer.

# What you need before hand

- **You should have R studio installed to be able to open the script**

  **Folder Format:**
   - All of your lines should be in the same folder, and the naming of the folder should be like something like this: "Line_63_OB15_110324"
   - Within the line folder, it should have seperate timepoint folders which contain your actual data, "day7, day14, ..."

  **Example: **
  ```
  Folder with all Lines/
  ├── Line_1/
  │   ├── day7/   → actual data
  │   ├── day14/  → actual data
  │   └── day21/  → actual data
  ├── Line_2/
  │   ├── day7/   → actual data
  │   ├── day14/  → actual data
  │   └── day21/  → actual data
  ├── Line_3/
  │   ├── day7/   → actual data
  │   ├── day14/  → actual data
  │   └── day21/  → actual data
  ```


# How to Use the tool

- We'll be **Control(Windows)/Command(Mac) + Enter**, to Run the Script
- You must press both keys at the same time

## For Extracting and Consolidating all Area Columns into one file and Sorting them:

This is the first half of the script, at this point the input files are simply the excel sheets straight from ImageJ, the assumption is that you have at least one area column within the file for extraction.

### Step 1: Install All Necessary Packages for the Tool

- **This step is only necessary when running the script for the first time**

One of the first things you should see when you open up the script for the first time is this window with the code.

![image](https://github.com/user-attachments/assets/fdbbdd6d-de65-451b-b9b3-a32dc7f4b858)

Make sure you are hovering at the very top of the script, simply press control enter once and click yes to any prompts that may come up, this will install all the things necessary for the tool to run. You've now completed step 1.

## Step 2: Load all the Packages:

![image](https://github.com/user-attachments/assets/cfa38151-f763-49a7-9fb0-cbb98627794e)

Now you must load all the packages. Simply press control enter until your cursor reaches the line with all the hashtags, boxed in red. You've now completed step 2.

## Step 3: Load all the functions of the tool:

![image](https://github.com/user-attachments/assets/24b8b89b-f0ce-494f-8608-c9a0c48ea3e8)

Lastly load up the functions for the tool, again simply press control enter until your cursor reaches the second line of hashtags. You've now completed step 3.



