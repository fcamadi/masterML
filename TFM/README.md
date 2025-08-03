# Máster UNED en Machine Learning – Curso 2024-2025

(English version below)

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


Código R:

hate_speech_01.Rmd


### Fase 2 - Aplicación de SVM

i) Entrenar un SVM con cada uno de los datasets anteriores.

ii) Crear un dataset total que contenga los 3 datasets, y entrenar SVM con él.

iii) Comparar los resultados de i) y ii)


Código R:

hate_speech_02_hatemedia.Rmd
hate_speech_02_huggingface.Rmd
hate_speech_02_kaggle.Rmd
hate_speech_common.Rmd



### Fase 3 - Recolección de comentarios sin etiquetar

Mediante un módulo usando RSelenium, recolectar comentarios de algún medio digital.
Aplicar el SVM entrenado con anterioridad, y clasificar los comentarios.

Dependiendo del resultado obtenido, completar el dataset del paso 2.ii con los nuevos comentarios
y volver a comparar resultados.


Código R:

Web_scraping_RSelenium_periodicos_online
hate_speech_03_not_labelled_too_many_positives.Rmd
hate_speech_03_not_labelled.Rmd
hate_speech_03_not_labelled_ALL_100k.Rmd
hate_speech_03_not_labelled_ALL_600k.Rmd
hate_speech_03_common.Rmd



## TFM - Detection of Hate Speech in Online Media Using the SVM Algorithm

### Phase 1: Collection of Labeled Datasets

Since SVM is a supervised learning algorithm, it will require a set of input data that is already labeled to train it. 
To carry out the training, the following public datasets have been found:

i) Hatemedia Project - https://hatemedia.es/

dataset: https://doi.org/10.6084/m9.figshare.26085700.v1

ii) HuggingFace

https://huggingface.co/datasets/manueltonneau/spanish-hate-speech-superset

iii) Kaggle

https://www.kaggle.com/datasets/wajidhassanmoosa/multilingual-hatespeech-dataset

R Code:

hate_speech_01.Rmd


### Phase 2 - Application of SVM

i) Train an SVM with each of the datasets mentioned above.

ii) Create a total dataset that contains the 3 datasets, and train SVM with it.

iii) Compare the results of i) and ii)

R Code:

hate_speech_02_hatemedia.Rmd
hate_speech_02_huggingface.Rmd
hate_speech_02_kaggle.Rmd
hate_speech_common.Rmd


### Phase 3 - Collection of Unlabeled Comments

Using a module with RSelenium, collect comments from some digital media. Apply the previously trained SVM and classify the comments.

Depending on the results obtained, complete the dataset from step 2.ii with the new comments and compare the results again.

R Code:

Web_scraping_RSelenium_periodicos_online
hate_speech_03_not_labelled_too_many_positives.Rmd
hate_speech_03_not_labelled.Rmd
hate_speech_03_not_labelled_ALL_100k.Rmd
hate_speech_03_not_labelled_ALL_600k.Rmd
hate_speech_03_common.Rmd

