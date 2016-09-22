# Annotation Assistant mini-app

This is a mini-app which uses simple text mining techniques to extract structured information from free text radiology reports.

# Caveats 
If run offline application relies on Xpdf binaries http://www.foolabs.com/xpdf/download.html to extract raw text information from .pdf files
If run via AnalytixAgility platform process has to be completed manually inside VM 

# Functionality

Allows users to select free text radiology files 

Application uses Regex technique to extract FINDINGS section from free text radiology report

Uses fuzz look-up method to match relevant terms in the free text. Matched classes are: Pathology, Anatomical Location, Laterality, Negation 
and Imaging Tecnique

Uses rules to remove negated terms

Creates vector array consisting of extracted patient information (ID, Name), type of radiology exam, (e.g Brain MRI) & extracted pathology terms and writes 
to PostgreSQL database  

Javascript extension allows users to select text and manually add to dictionary to be mapped in the future. 