# Overview

This is a mini-app which uses simple text mining techniques to extract structured information from free text radiology reports.

# Deployment
Clone or download repository and navigate inside workspace folder. 

Zip the contents of the workspace folder and upload the archive to the data folder in the destination workspace. 

# Dependencies 
If run offline application relies on Xpdf binaries http://www.foolabs.com/xpdf/download.html to extract raw text information from .pdf reports. Otherwise supply raw .txt files in workspace/datafiles/annotation_assistant_datafiles/ folder.
labels.csv contains dictionary of terms and their labels. label.csv must be located in workspace/datafiles/annotation_assistant_datafiles/ folder.

# Functionality

Allows users to select free text radiology files 

Application uses Regex technique to extract FINDINGS section from free text radiology report

Uses fuzzy look-up method to match relevant terms in the free text. Matched classes are: Pathology, Anatomical Location, Laterality, Negation 
and Imaging Technique

Uses rules to remove negated terms

Creates vector array consisting of extracted patient information (ID, Name), type of radiology exam, (e.g Brain MRI) & extracted pathology terms and writes 
to PostgreSQL database  

Javascript extension allows users to select text and add to the dictionary to be highlighted in the future. 