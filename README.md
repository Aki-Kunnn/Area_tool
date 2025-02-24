# Install Instructions

Hover over the file that says area_tool, click it and then press the download button on the top right and obtain the R script.
![image](https://github.com/user-attachments/assets/99122386-de17-4474-b4e8-7072299664e1)

You can do the same with this Instructional README file as well, if you'd like to reference it on you personal computer.

# What you need before hand

This script assumes a few things:

**You should have R studio installed to be able to open the script**

  **Folder Format:**
    - All of your lines should be in the same folder, and the naming of the folder should be like something like this: "Line_63_OB15_110324"
    - Within the line folder, it should have seperate timepoint folders which contain your actual data, "day7, day14, ..."
    Folder/ │── Line_1/ │ ├── day7/ -> actual data │ ├── day14/ -> actual data │ ├── day21/ -> actual data │── Line_2/ │ ├── day7/ -> actual data │ ├── day14/ -> actual data │ ├── day21/ -> actual data │── Line_3/ │ ├── day7/ -> actual data │ ├── day14/ -> actual data │ ├── day21/ -> actual
# How to Use the tool

You can initialize the tool by using the following command, you can type it or copy paste, but it should go into the R terminal.

```
source(area_tool.R)
```
