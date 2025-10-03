# Máster UNED en Machine Learning – Curso 2024-2025

- English version below: <BR>
https://github.com/fcamadi/masterML/tree/main/TFM#tfm---hate-speech-detection-in-online-media-using-the-svm-algorithm
- Deutsche Version unten: <BR>
https://github.com/fcamadi/masterML/tree/main/TFM#tfm---erkennung-von-hassrede-in-online-medien-mithilfe-des-svm-algorithmus


## TFM - Detección de lenguaje de odio en los medios online mediante el algoritmo SVM

### Fase 1: recolección de datasets etiquetados

Dado que SVM es un algoritmo de aprendizaje supervisado, para entrenarlo se necesitará un
conjunto de datos de entrada que ya estén etiquetados. Se han encontrado los siguientes 
datasets públicos:

i) Proyecto Hatemedia - https://hatemedia.es/

dataset: https://doi.org/10.6084/m9.figshare.26085700.v1

ii) HuggingFace

https://huggingface.co/datasets/manueltonneau/spanish-hate-speech-superset

iii) Kaggle

https://www.kaggle.com/datasets/wajidhassanmoosa/multilingual-hatespeech-dataset


- Código R:

hate_speech_01.Rmd


### Fase 2 - Aplicación de SVM

i) Entrenar un SVM con cada uno de los datasets anteriores.

ii) Crear un dataset total que contenga los 3 datasets, y entrenar SVM con él.

iii) Comparar los resultados de i) y ii)


- Código R:

hate_speech_02_hatemedia.Rmd<br>
hate_speech_02_huggingface.Rmd<br>
hate_speech_02_kaggle.Rmd<br>
hate_speech_02_all_datasets.Rmd<br>
hate_speech_02_all_datasets_100K.Rmd<br>
hate_speech_common.Rmd<br>


### Fase 3 - Clasificación de comentarios nuevos no etiquetados

Mediante un módulo usando RSelenium, recolectar comentarios de algún medio digital.
Aplicar el SVM entrenado con anterioridad, y clasificar los comentarios.

Dependiendo del resultado obtenido, completar el dataset del paso 2.ii con los nuevos comentarios
y volver a comparar resultados.


- Código R:

Web_scraping_RSelenium_periodicos_online<br>
hate_speech_03_not_labelled_too_many_positives.Rmd<br>
hate_speech_03_not_labelled.Rmd<br>
hate_speech_03_not_labelled_ALL_100k.Rmd<br>
hate_speech_03_not_labelled_ALL_600k.Rmd<br>
hate_speech_03_common.Rmd<br>


### Documento

TFM_detección_lenguaje_odio_medios_online_SVM.pdf:

TFM/PDF/TFM_detección_lenguaje_odio_medios_online_SVM.pdf
<BR>

## TFM - Hate Speech Detection in Online Media Using the SVM Algorithm

### Phase 1: Collection of Labeled Datasets

Since SVM is a supervised learning algorithm, it will require a set of input data that is already labeled to train it. 
To carry out the training, the following public datasets have been found:

i) Hatemedia Project - https://hatemedia.es/

dataset: https://doi.org/10.6084/m9.figshare.26085700.v1

ii) HuggingFace

https://huggingface.co/datasets/manueltonneau/spanish-hate-speech-superset

iii) Kaggle

https://www.kaggle.com/datasets/wajidhassanmoosa/multilingual-hatespeech-dataset


- R Code:

hate_speech_01.Rmd


### Phase 2 - Application of SVM

i) Train an SVM with each of the datasets mentioned above.

ii) Create a total dataset that contains the 3 datasets, and train SVM with it.

iii) Compare the results of i) and ii)

- R Code:

hate_speech_02_hatemedia.Rmd<br>
hate_speech_02_huggingface.Rmd<br>
hate_speech_02_kaggle.Rmd<br>
hate_speech_02_all_datasets.Rmd<br>
hate_speech_02_all_datasets_100K.Rmd<br>
hate_speech_common.Rmd<br>


### Phase 3 - Classification of new unlabeled comments

Using a module with RSelenium, collect comments of readers from some digital media. Apply the previously trained SVM and classify the comments.

Depending on the results obtained, complete the dataset from step 2.ii with the new comments and compare the results again.

- R Code:

Web_scraping_RSelenium_periodicos_online<br>
hate_speech_03_not_labelled_too_many_positives.Rmd<br>
hate_speech_03_not_labelled.Rmd<br>
hate_speech_03_not_labelled_ALL_100k.Rmd<br>
hate_speech_03_not_labelled_ALL_600k.Rmd<br>
hate_speech_03_common.Rmd<br>


### Document

TFM_Hate_Speech_Detection_in_Online_Media_Using_SVM_EN-UK.pdf:

TFM/PDF/TFM_Hate_Speech_Detection_in_Online_Media_Using_SVM_EN-UK.pdf
<BR>

## TFM - Erkennung von Hassrede in Online-Medien mithilfe des SVM Algorithmus

### Phase 1: Sammlung beschrifteter Datensätze

Da SVM ein überwachter Lernalgorithmus ist, benötigt er einen Satz von Eingabedaten, die bereits beschriftet sind,
um trainiert zu werden. Dafür wurden die folgenden öffentlichen Datensätze gefunden:

i) Hatemedia Project - https://hatemedia.es/

dataset: https://doi.org/10.6084/m9.figshare.26085700.v1

ii) HuggingFace

https://huggingface.co/datasets/manueltonneau/spanish-hate-speech-superset

iii) Kaggle

https://www.kaggle.com/datasets/wajidhassanmoosa/multilingual-hatespeech-dataset


- R Quellcode:

hate_speech_01.Rmd


### Phase 2 - Anwendung von SVM

i) Training SVM mit jedem der oben genannten Datensätze.

ii) Erstellung eines Gesamtdatensatzes, der die 3 Datensätze enthält, und Training der SVM damit.

iii) Vergleich der Ergebnisse von i) und ii).

- R Quellcode:

hate_speech_02_hatemedia.Rmd<br>
hate_speech_02_huggingface.Rmd<br>
hate_speech_02_kaggle.Rmd<br>
hate_speech_02_all_datasets.Rmd<br>
hate_speech_02_all_datasets_100K.Rmd<br>
hate_speech_common.Rmd<br>


### Phase 3 - Klassifizierung neuer unbeschrifteter Kommentare

Mit einem Modul von RSelenium werden Kommentare von Lesern aus einigen digitalen Medien gesammelt. 
Die zuvor trainierte SVM wird angewendet, um die neue Kommentare zu klassifizieren.

Je nach den erhaltenen Ergebnissen wird der Datensatz aus Schritt 2.ii) mit den neuen Kommentaren vervollständigt,
und die Ergebnisse werden erneut verglichen.

- R Quellcode:

Web_scraping_RSelenium_periodicos_online<br>
hate_speech_03_not_labelled_too_many_positives.Rmd<br>
hate_speech_03_not_labelled.Rmd<br>
hate_speech_03_not_labelled_ALL_100k.Rmd<br>
hate_speech_03_not_labelled_ALL_600k.Rmd<br>
hate_speech_03_common.Rmd<br>


### Dokument

TFM_Hassredeerkennung_in_online_Medien_mit_SVM_DE-DE.pdf:

TFM/PDF/TFM_Hassredeerkennung_in_online_Medien_mit_SVM_DE-DE.pdf
