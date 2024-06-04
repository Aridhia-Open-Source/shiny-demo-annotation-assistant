# ANNOTATION ASSISTANT

This RShiny mini-app uses simple text mining techniques to extract structured information from free text radiology reports. **Unstructured data**, such as free text, froms nearly 80% of the world's data; this is data that does not have a pre-defined data model, which makes it very difficult to analyse using conventional programs. 

**Text Mining Techniques** are used to analyse and process unstructured data in order to retrieve high-quality information from text. Thus, through text mining techniques it is possible to transform unstructured data into structured data for easy analysis.

This mini-app is the *tm package* and *Regex technique* to extract findings from the free text radiology reports. To analyse your own free text, you can save the raw TXT files inside the *data* folder; within this same folder you will find the *labels.csv* file, which contains the dictionary of tems and their labels.


## About the Annotation Assistant RShiny mini-app

To use this RShiny mini-app:

1. Select a report file to display using the drop-down menu. The text will display in the middle of the screen.
2. On the right, you will find the patient's information and the automatically-retrieved information from the text.
3. This app uses fuzzy loop-up methods to match relevant terms in free text. You can select which annotation class (Pathology, Anatomical Location, Laterality, Negation, Imaging Technique) you want to highlight in the text by selecting one or more classes displayed in the left-side.
4. Javascript extensions allows you to select text and add it to the dictionary to be highlighted in the future. To do this, you only have to select one or more word, select to which class belongs and click to "Add to dictionary"
5. To save the findings, click on 'Export findings'; this will save a csv file in the 'results' folder.

### Checkout and run

You can clone this repository by using the command:

```
git clone https://github.com/aridhia/demo-annotation-assistant
```

Open the .Rproj file in RStudio and use `runApp()` to start the app.

### Deploying to the workspace

1. Download this GitHub repo as a .zip file.
2. Create a new blank Shiny app in your workspace called "annotation-assistant".
3. Navigate to the `annotation-assistant` folder under "files".
4. Delete the `app.R` file from the `annotation-assistant` folder. Make sure you keep the `.version` file!
5. Upload the .zip file to the `annotation-assistant` folder.
6. Extract the .zip file. Make sure "Folder name" is blank and "Remove compressed file after extracting" is ticked.
7. Navigate into the unzipped folder.
8. Select all content of the unzipped folder, and move it to the `annotation-assistant` folder (so, one level up).
9. Delete the now empty unzipped folder.
10. Start the R console and run the `dependencies.R` script to install all R packages that the app requires.
11. Run the app in your workspace.

For more information visit https://knowledgebase.aridhia.io/article/how-to-upload-your-mini-app/