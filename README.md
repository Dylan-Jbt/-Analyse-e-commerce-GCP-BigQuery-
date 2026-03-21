# Analyse e-commerce 2023 vs 2024 — TheLook Europe (GCP / BigQuery)

## Contexte et objectifs du projet

Ce projet consiste à réaliser une **analyse de performance e-commerce** pour l'entreprise **TheLook Europe** en tant que Data Analyst. La direction e-commerce souhaite comprendre les dynamiques de chiffre d'affaires, marge, retours et comportement client, puis obtenir des enseignements clairs via un tableau de bord Power BI.

**Objectif principal** : analyser et comparer la performance de l'activité e-commerce entre **2023** et **2024** afin de produire des KPI fiables et des recommandations actionnables.

**Objectifs pédagogiques** :
1. Cadrer un sous-périmètre métier
2. Réaliser une EDA complète en Python
3. Calculer et valider des KPI en Python et en SQL (BigQuery)
4. Construire un tableau de bord convaincant dans Power BI

---

## Description du sous-périmètre

| Critère | Valeur |
|---|---|
| **Pays** | France (`users.country = 'France'`) |
| **Département produit** | Women (`products.department = 'Women'`) |
| **Période** | 01/01/2023 au 31/12/2024 |
| **Source de vérité** | `bigquery-public-data.thelook_ecommerce` (Google BigQuery) |

### Tables utilisées et clés de jointure

| Table | Description | Clé de jointure |
|---|---|---|
| `users` | Profil client et géographie | `users.id = orders.user_id` |
| `orders` | Commandes | `orders.order_id = order_items.order_id` |
| `order_items` | Lignes d'articles (prix, statut, date) | `products.id = order_items.product_id` |
| `products` | Référentiel produit (coût, marque, catégorie) | — |

### Conventions de calcul

| KPI | Définition | Statuts utilisés |
|---|---|---|
| **Chiffre d'affaires** | `SUM(sale_price)` | `Complete` uniquement |
| **Marge brute** | `SUM(sale_price - cost)` | `Complete` uniquement |
| **Panier moyen (AOV)** | `CA / COUNT(DISTINCT order_id)` | Commandes `Complete` avec `sale_price > 0` |
| **Taux de retour** | `COUNT(Returned) / COUNT(Complete + Returned)` | `Complete` + `Returned` |
| **Taux de ré-achat** | `Clients ≥ 2 commandes Complete / Total clients` | `Complete` uniquement, par année |

---

## Structure du dépôt

```
/
├── README.md                           ← Ce fichier
├── requirements.txt                    ← Dépendances Python
├── data/
│   ├── thelook_fr_women_2023_2024.csv  ← Dataset du sous-périmètre (fourni)
│   └── dataset_reconstruction.csv      ← Dataset reconstruit via requête SQL
├── notebooks/
│   ├── 01_data_exploration.ipynb       ← EDA complète + calcul des KPI Python
│   └── 02_checks_coherence.ipynb       ← Validation croisée Python ↔ SQL
├── sql/
│   ├── extract_sous_perimetre.sql      ← Requête d'extraction du sous-périmètre
│   ├── dataset_reconstruction.sql      ← Requête de reconstruction du CSV
│   ├── kpi_ca_marge_par_annee.sql      ← CA et marge par année
│   ├── kpi_aov_par_annee.sql           ← Panier moyen par année
│   ├── kpi_taux_retour_par_annee.sql   ← Taux de retour par année
│   ├── kpi_taux_reachat_par_annee.sql  ← Taux de ré-achat par année
│   └── data_answers_sql/               ← Résulats des reqêtes SQL sur Big Query
├── powerbi/
│   └── Dashboard e-commerce.pbix       ← Dashboard Power BI à partir du dataset reconstitué sur Big Query 
│   └── Dashboard_thelook_fr.ipynb      ← Visualisations interactives (Plotly)
└── utils/
    ├── data_prep.py                    ← Fonctions utilitaires (détection outliers)
    └── big_query_utils.py              ← Utilitaires BigQuery
```

---

## Instructions d'installation et d'exécution

### Prérequis

- Python 3.10+
- Accès à Google BigQuery (pour exécuter les requêtes SQL)
- Power BI Desktop (pour ouvrir le dashboard `.pbix`)

### Installation de l'environnement Python

```bash
# Cloner le dépôt
git clone https://github.com/<votre-utilisateur>/Analyse-e-commerce-GCP-BigQuery.git
cd Analyse-e-commerce-GCP-BigQuery

# Créer et activer l'environnement virtuel
python -m venv .env
# Windows
.env\Scripts\activate
# macOS/Linux
source .env/bin/activate

# Installer les dépendances
pip install -r requirements.txt
```

### Dépendances principales

| Package | Usage |
|---|---|
| `pandas`, `numpy` | Manipulation de données |
| `plotly`, `matplotlib`, `seaborn` | Visualisation |
| `scipy`, `scikit-learn` | Analyses statistiques |

---

## Cheminement pour reproduire les résultats

### Étape 1 — Analyse exploratoire en Python

Ouvrir et exécuter le notebook **`notebooks/01_data_exploration.ipynb`** :
1. Chargement du CSV `data/thelook_fr_women_2023_2024.csv`
2. Contrôles qualité (doublons, types, valeurs manquantes, bornes temporelles)
3. Explorations descriptives (distributions prix/coût, contributions marque/catégorie/ville)
4. Comparaison 2023 vs 2024 (séries mensuelles, écarts absolus et relatifs)
5. Calcul des 5 KPI métier (CA, marge, panier moyen, taux de retour, taux de ré-achat)

### Étape 2 — Requêtes SQL sur BigQuery

Exécuter les requêtes SQL du dossier `sql/` directement sur la console BigQuery :
- **`extract_sous_perimetre.sql`** : Requête de reconstruction du fichier CSV (étape 2.2 du projet). Elle applique les filtres `France × Women × 2023-2024` sur les tables jointes et expose les colonnes nécessaires.
- **`kpi_ca_marge_par_annee.sql`** : CA et marge brute par année
- **`kpi_aov_par_annee.sql`** : Panier moyen par année
- **`kpi_taux_retour_par_annee.sql`** : Taux de retour par année
- **`kpi_taux_reachat_par_annee.sql`** : Taux de ré-achat par année

Les résultats des requêtes sont archivés dans `sql/data_answers_sql/`.

### Étape 3 — Validation croisée Python ↔ SQL

Ouvrir et exécuter **`notebooks/02_checks_coherence.ipynb`** :
1. Chargement du CSV EDA et du CSV reconstruit par SQL
2. Comparaison des volumes par statut et du CA mensuel
3. Calcul des KPI sur les deux sources
4. Confrontation avec les résultats SQL officiels BigQuery
5. Validation avec seuil de tolérance à 1 %

### Étape 4 — Dashboard Power BI

Le fichier Power BI (`.pbix`) est alimenté par le CSV du sous-périmètre. Les visualisations interactives sont également disponibles dans **`powerbi/Dashboard_thelook_fr.ipynb`** (Plotly).

---

## Décisions de design Power BI et principaux enseignements

### Choix de design

- **Modèle de données simple** : table de faits unique (CSV du sous-périmètre) enrichie de dimensions dérivées (Date, Produit, Client).
- **Visuels retenus** :
  - Séries temporelles indexées (2023 = 100) pour la comparaison mensuelle
  - Barres horizontales pour les Top N marques/catégories (lisibilité)
  - Nuage de points CA ↔ taux de retour (détection des marques à risque)
  - Histogramme du nombre d'articles par commande (décomposition du panier)

### Principaux enseignements

1. **Croissance confirmée** : Le CA 2024 dépasse celui de 2023 sur la majorité des mois, avec un CA total en hausse significative (+53 % environ).
2. **Concentration du CA** : Un petit nombre de marques et de catégories (Intimates, Jeans) représente une part importante du chiffre d'affaires.
3. **Taux de retour maîtrisé** : Autour de 9-10 %, dans la norme du e-commerce textile. Certaines marques présentent toutefois des taux plus élevés.
4. **Ré-achat très faible** : Seulement ~4 % de clients récurrents en 2024 (0 % en 2023). La fidélisation est le **premier levier d'amélioration** (CRM, programmes de fidélité, personnalisation).
5. **Panier moyen en baisse** : L'AOV passe de ~103 € (2023) à ~78 € (2024), suggérant que la croissance du CA est portée par le volume de commandes plutôt que par la valeur unitaire.

### Recommandations pour la direction e-commerce

- **Fidélisation** : Mettre en place un programme de fidélité et des campagnes de relance ciblées pour augmenter le taux de ré-achat.
- **Panier moyen** : Développer le cross-selling et les offres groupées pour remonter l'AOV.
- **Qualité** : Investiguer les marques à fort taux de retour et travailler avec les fournisseurs sur la qualité ou le descriptif produit.
- **Diversification** : Réduire la dépendance aux Top marques en développant de nouvelles marques complémentaires.