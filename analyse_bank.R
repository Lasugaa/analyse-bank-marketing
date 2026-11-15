# 1) Charger les données (déjà fait, à garder en haut du script)
setwd("D:/Lasu/alternance/Nouveau dossier")
bank <- read.csv("bank-additional.csv", sep = ";", stringsAsFactors = TRUE)

# 2) Installer et charger les outils (l'installation se fait une seule fois)
install.packages("tidyverse")
library(tidyverse)

# 3) Vue d'ensemble
summary(bank)

# 4) Combien de clients ont souscrit ?
table(bank$y)
round(prop.table(table(bank$y)) * 100, 1)

# 5) Valeurs manquantes : ici elles s'appellent "unknown"
colSums(bank == "unknown")

# 6) Doublons
sum(duplicated(bank))


bank_clean <- bank %>%
  filter(job != "unknown", marital != "unknown") %>%
  mutate(
    job = droplevels(job),
    marital = droplevels(marital),
    deja_contacte = factor(ifelse(pdays == 999, "non", "oui")),
    pdays = ifelse(pdays == 999, NA, pdays),
    souscrit = ifelse(y == "yes", 1, 0),
    tranche_age = cut(age,
                      breaks = c(0, 25, 35, 45, 55, 65, Inf),
                      labels = c("≤25", "26-35", "36-45", "46-55", "56-65", "65+"))
  )

dim(bank_clean)
table(bank_clean$deja_contacte)
table(bank_clean$tranche_age)

write.csv(bank_clean, "bank_clean.csv", row.names = FALSE)


dir.create("graphiques", showWarnings = FALSE)
bleu <- "#1F2A5C"

# Graphique 1 : taux de souscription par métier
g1 <- bank_clean %>%
  group_by(job) %>%
  summarise(taux = mean(souscrit) * 100) %>%
  ggplot(aes(x = reorder(job, taux), y = taux)) +
  geom_col(fill = bleu) +
  coord_flip() +
  labs(title = "Taux de souscription par métier", x = NULL, y = "Taux de souscription (%)") +
  theme_minimal()
g1
ggsave("graphiques/g1_metier.png", g1, width = 7, height = 4)

# Graphique 2 : par tranche d'âge
g2 <- bank_clean %>%
  group_by(tranche_age) %>%
  summarise(taux = mean(souscrit) * 100) %>%
  ggplot(aes(x = tranche_age, y = taux)) +
  geom_col(fill = bleu) +
  labs(title = "Taux de souscription par tranche d'âge", x = "Tranche d'âge", y = "Taux de souscription (%)") +
  theme_minimal()
g2
ggsave("graphiques/g2_age.png", g2, width = 7, height = 4)

# Graphique 3 : par mois de contact
ordre_mois <- c("mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec")
g3 <- bank_clean %>%
  mutate(month = factor(month, levels = ordre_mois)) %>%
  group_by(month) %>%
  summarise(taux = mean(souscrit) * 100, n = n()) %>%
  ggplot(aes(x = month, y = taux)) +
  geom_col(fill = bleu) +
  geom_text(aes(label = paste0("n=", n)), vjust = -0.4, size = 3) +
  labs(title = "Taux de souscription par mois", x = "Mois", y = "Taux de souscription (%)") +
  theme_minimal()
g3
ggsave("graphiques/g3_mois.png", g3, width = 7, height = 4)

# Graphique 4 : selon le résultat de la campagne précédente
g4 <- bank_clean %>%
  group_by(poutcome) %>%
  summarise(taux = mean(souscrit) * 100, n = n()) %>%
  ggplot(aes(x = poutcome, y = taux)) +
  geom_col(fill = bleu) +
  geom_text(aes(label = paste0("n=", n)), vjust = -0.4, size = 3) +
  labs(title = "Taux de souscription selon la campagne précédente", x = "Résultat précédent", y = "Taux de souscription (%)") +
  theme_minimal()
g4
ggsave("graphiques/g4_campagne_precedente.png", g4, width = 7, height = 4)


install.packages(c("FactoMineR", "factoextra"))   # une seule fois
library(FactoMineR)
library(factoextra)

# Variables quantitatives (on exclut pdays, qui contient des NA)
quanti <- bank_clean %>%
  select(age, duration, campaign, previous,
         emp.var.rate, cons.price.idx, cons.conf.idx, euribor3m, nr.employed)

res.pca <- PCA(quanti, scale.unit = TRUE, graph = FALSE)

res.pca$eig                                   # variance expliquée par axe
fviz_eig(res.pca, addlabels = TRUE)           # éboulis
fviz_pca_var(res.pca, col.var = "contrib", repel = TRUE)   # cercle des corrélations
fviz_pca_ind(res.pca, geom = "point", col.ind = bank_clean$y,
             addEllipses = TRUE, legend.title = "Souscription")

tab <- table(bank_clean$job, bank_clean$education)
tab
chisq.test(tab)                      # test d'indépendance

res.ca <- CA(tab, graph = FALSE)
res.ca$eig
fviz_screeplot(res.ca, addlabels = TRUE)
fviz_ca_biplot(res.ca, repel = TRUE)

# Tableau croisé métier x souscription
tab_jy <- table(bank_clean$job, bank_clean$y)
tab_jy

# Pourcentages par métier (chaque ligne = 100 %)
round(prop.table(tab_jy, 1) * 100, 1)

# Test d'indépendance + force du lien (V de Cramér)
test_jy <- chisq.test(tab_jy)
test_jy
n <- sum(tab_jy)
sqrt(test_jy$statistic / (n * (min(dim(tab_jy)) - 1)))

tab_py <- table(bank_clean$poutcome, bank_clean$y)
round(prop.table(tab_py, 1) * 100, 1)
chisq.test(tab_py)