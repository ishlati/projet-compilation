# Évaluateur d'Expressions Arithmétiques

**Projet de Compilation - Utilisation de Flex et Bison**  
Isra - 2CS - USTHB

---

## 📋 Description

Ce projet implémente un évaluateur d'expressions arithmétiques complet avec support de fonctions statistiques avancées :
- **Somme** : Addition de tous les arguments
- **Produit** : Multiplication de tous les arguments  
- **Moyenne** : Moyenne arithmétique
- **Variance** : Variance statistique
- **Écart-type** : Racine carrée de la variance

### Caractéristiques
✅ Support des nombres entiers et flottants  
✅ Opérateurs arithmétiques : `+`, `-`, `*`, `/`  
✅ Parenthésage pour contrôler les priorités  
✅ Fonctions statistiques avec nombre variable d'arguments  
✅ Imbrication de fonctions  
✅ Gestion d'erreurs lexicales et syntaxiques  
✅ Messages d'erreur clairs et informatifs  

---

## 🛠️ Compilation

### Prérequis
- GCC (GNU Compiler Collection)
- Flex (Fast Lexical Analyzer)
- Bison (GNU Parser Generator)
- Make

### Installation des dépendances (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install build-essential flex bison
```

### Compilation du projet
```bash
# Compilation complète
make

# Recompilation depuis zéro
make rebuild

# Afficher l'aide
make help
```

---

## 🚀 Utilisation

### Mode Interactif
```bash
./calculateur
```
Entrez vos expressions ligne par ligne. Appuyez sur `Ctrl+D` pour terminer.

### Lecture depuis un Fichier
```bash
./calculateur tests/test_partie_b.txt
```

### Pipe depuis stdin
```bash
echo "5 + 3 * 2" | ./calculateur
```

---

## 📝 Exemples

### Expressions Arithmétiques Simples
```
5 + 3                    → 8.000000
5 + 3 * 2                → 11.000000
(5 + 3) * 2              → 16.000000
3.14 + 2.71              → 5.850000
-5 + 3                   → -2.000000
```

### Fonctions Statistiques
```
somme(1, 2, 3, 4)        → 10.000000
produit(2, 3, 4)         → 24.000000
moyenne(10, 20, 30)      → 20.000000
variance(2, 4, 6, 8)     → 5.000000
ecart_type(1, 2, 3, 4, 5) → 1.414214
```

### Fonctions Imbriquées
```
moyenne(somme(1, 2), produit(3, 4))
→ moyenne(3, 12)
→ 7.500000

5 + 3 * somme(4, somme(5,7,8), variance(1, 1+1, moyenne(2,4), 4, 6-2))
→ Évaluation récursive de l'intérieur vers l'extérieur
```

---

## 🧪 Tests

### Tests Basiques
```bash
make test
```
Lance une série de 11 tests couvrant :
- Expressions simples
- Priorités d'opérateurs
- Fonctions statistiques
- Imbrications

### Tests depuis Fichiers
```bash
make test-files
```
Exécute tous les fichiers `.txt` du dossier `tests/`

### Tests de Gestion d'Erreurs
```bash
make test-errors
```
Teste la détection et le signalement d'erreurs :
- Erreurs lexicales (caractères invalides)
- Erreurs syntaxiques (syntaxe incorrecte)
- Division par zéro

### Tous les Tests
```bash
make test-all
```

---

## 📁 Structure du Projet

```
projet-compilation/
│
├── src/
│   ├── lexical.l          # Analyseur lexical (Flex)
│   ├── syntaxique.y       # Analyseur syntaxique (Bison)
│   ├── fonctions.c        # Implémentation des fonctions stats
│   └── fonctions.h        # Headers des fonctions
│
├── tests/
│   ├── test_partie_a.txt  # Tests analyse syntaxique
│   ├── test_partie_b.txt  # Tests évaluation
│   └── test_erreurs.txt   # Tests gestion erreurs
│
├── Makefile               # Automatisation compilation
└── README.md              # Documentation
```

---

## 🔧 Architecture Technique

### Flux de Traitement
```
Expression texte
    ↓
[Analyseur Lexical - Flex]
    ↓
Tokens (NOMBRE, PLUS, SOMME, etc.)
    ↓
[Analyseur Syntaxique - Bison]
    ↓
Arbre Syntaxique + Évaluation
    ↓
[Fonctions Statistiques - C]
    ↓
Résultat (double)
```

### Composants

**lexical.l (Flex)**
- Reconnaissance des tokens
- Détection d'erreurs lexicales
- Comptage lignes/colonnes

**syntaxique.y (Bison)**
- Grammaire des expressions
- Priorités et associativité
- Évaluation récursive
- Gestion d'erreurs syntaxiques

**fonctions.c/h**
- Gestion de listes dynamiques
- Calculs statistiques
- Gestion mémoire

---

## 📚 Grammaire

```
programme   : expression

expression  : expression '+' expression
            | expression '-' expression
            | expression '*' expression
            | expression '/' expression
            | '-' expression
            | '(' expression ')'
            | fonction
            | NOMBRE

fonction    : SOMME '(' liste_args ')'
            | PRODUIT '(' liste_args ')'
            | MOYENNE '(' liste_args ')'
            | VARIANCE '(' liste_args ')'
            | ECART_TYPE '(' liste_args ')'

liste_args  : expression
            | liste_args ',' expression
```

### Priorités
1. Parenthèses : `( )`
2. Moins unaire : `-`
3. Multiplication/Division : `*`, `/`
4. Addition/Soustraction : `+`, `-`

---

## ⚠️ Gestion d'Erreurs

### Erreurs Lexicales
```
5 + @
→ ❌ Erreur lexicale ligne 1, colonne 5: caractère invalide '@'
```

### Erreurs Syntaxiques
```
5 +
→ ❌ Erreur syntaxique ligne 1: syntax error
```

### Erreurs Sémantiques
```
10 / 0
→ ❌ Erreur syntaxique ligne 1: Division par zéro
```

---

## 🧹 Nettoyage

```bash
# Supprimer les fichiers générés
make clean

# Nettoyage complet (inclut backups)
make distclean
```

---

## 📖 Documentation Complémentaire

### Formules Mathématiques

**Moyenne**
```
moyenne = (Σ xi) / n
```

**Variance**
```
variance = Σ(xi - moyenne)² / n
```

**Écart-type**
```
écart-type = √variance
```

---

## 👤 Auteur

**Isra**  
Étudiante en 2CS - AI Engineering  
USTHB - Université des Sciences et de la Technologie Houari Boumediene

---

## 📄 Licence

Projet académique - USTHB 2024-2025

---

## 🙏 Remerciements

- Équipe pédagogique du cours de Compilation
- Documentation officielle de Flex et Bison
- Communauté GNU

---

**Date de création :** Décembre 2024  
**Version :** 1.0
