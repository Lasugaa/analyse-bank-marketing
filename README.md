# analyse-bank-marketing

# Analyse exploratoire d'une campagne de marketing bancaire

Analyse en R des appels d'une banque portugaise pour vendre un dépôt à terme.

## Objectif
Identifier les profils de clients et les conditions de campagne qui favorisent la souscription.

## Données
- Source : UCI Machine Learning Repository, *Bank Marketing* (fichier `bank-additional.csv`).
- 4 119 clients, 21 variables, dont 451 souscripteurs (10,9 %).

## Méthode
1. Nettoyage : valeurs « unknown », recodage de `pdays`, création de tranches d'âge.
2. Analyse descriptive : taux de souscription par métier, âge, mois, campagne précédente.
3. ACP sur 9 variables quantitatives.
4. AFC entre métier et niveau d'études.
5. Tests du χ² entre variables qualitatives et souscription.

## Résultats principaux
- Les retraités et les étudiants souscrivent le plus (environ 23 %).
- Les clients ayant déjà souscrit lors d'une campagne précédente : environ 66 % de souscription.
- ACP : le premier axe (41 %) correspond au contexte économique (Euribor, emploi).
- AFC : le premier axe (48 %) oppose niveaux d'études bas et élevés.
- [Ton résultat du χ² métier x souscription : p-value, V de Cramér]

## Limites
Petits effectifs pour certains mois et tranches d'âge. Les liens observés ne sont pas des relations de cause à effet.

## Outils
R, RStudio, tidyverse, FactoMineR, factoextra, ggplot2.
