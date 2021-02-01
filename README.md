# ANNOTATION ASSISTANT

This RShiny mini-app uses simple text mining techniques to extract structured information from free text radiology reports. **Unstructured data**, such as free text, froms nearly 80% of the world's data; this is data that does not have a pre-defined data model, which makes it very difficult to analyse using conventional programs. 

**Text Mining Techniques** are used to analyse and process unstructured data in order to retrieve high-quality information from text. Thus, through text mining techniques it is possible to transform unstructured data into structured data for easy analysis.

This mini-app is the *tm package* and *Regex technique* to extract findings from the free text radiology reports. To analyse your own free text, you can save the raw TXT files inside the *data* folder; within this same folder you will find the *labels.csv* file, which contains the dictionary of tems and their labels.



Uses fuzzy look-up method to match relevant terms in the free text. Matched classes are: Pathology, Anatomical Location, Laterality, Negation 
and Imaging Technique

Uses rules to remove negated terms

Creates vector array consisting of extracted patient information (ID, Name), type of radiology exam, (e.g Brain MRI) & extracted pathology terms and writes 
to PostgreSQL database  

Javascript extension allows users to select text and add to the dictionary to be highlighted in the future. 



## About the Annotation Assistant RShiny mini-app

To use this RShiny mini-app:

1. Select a report file to display using the drop-down menu. The text will display in the middle of the screen.
2. On the right, you will find the patient's information and the automatically-retrieved information from the text.
3. This app uses fuzzy loop-up methods to match relevant terms in free text. You can select which annotation class (Pathology, Anatomical Location, Laterality, Negation, Imaging Technique) you want to highlight in the text by selecting one or more classes displayed in the left-side.
4. Javascript extensions allows you to select text and add it to the dictionary to be highlighted in the future. To do this, you only have to select one or more word, select to which class belongs and click to "Add to dictionary"

### Checkout and run

You can clone this repository by using the command:

```
git clone https://github.com/aridhia/demo-annotation-assistant
```

Open the .Rproj file in RStudio and use `runApp()` to start the app.

### Deploying to the workspace

1. Create a new mini-app in the workspace called "annotation-assistant"" and delete the folder created for it
2. Download this GitHub repo as a .ZIP file, or zip all the files
3. Upload the .ZIP file to the workspace and upzip it inside a folder called annotation-assistant"
4. Run the app in your workspace