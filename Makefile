################################################################################
# MAKEFILE - Projet Compilation
# Évaluateur d'expressions arithmétiques avec Flex et Bison
################################################################################

# ========== VARIABLES ==========

# Compilateur et outils
CC = gcc
FLEX = flex
BISON = bison

# Options de compilation
CFLAGS = -Wall -Wextra -g -std=c99 -I$(SRC_DIR)
LDFLAGS = -lm

# Répertoires
SRC_DIR = src
TEST_DIR = tests

# Fichiers sources
LEX_SRC = $(SRC_DIR)/lexical.l
YACC_SRC = $(SRC_DIR)/syntaxique.y
FUNC_SRC = $(SRC_DIR)/fonctions.c
FUNC_HDR = $(SRC_DIR)/fonctions.h

# Fichiers générés
LEX_GEN = lex.yy.c
YACC_GEN = syntaxique.tab.c
YACC_HDR = syntaxique.tab.h
YACC_OUT = syntaxique.output

# Fichiers objets
LEX_OBJ = lex.yy.o
YACC_OBJ = syntaxique.tab.o
FUNC_OBJ = fonctions.o

# Exécutable
TARGET = calculateur

# ========== RÈGLES ==========

# Règle par défaut
all: $(TARGET)
	@echo ""
	@echo "✓ Compilation terminée avec succès!"
	@echo ""
	@echo "📖 Usage:"
	@echo "  ./$(TARGET)              Mode interactif"
	@echo "  ./$(TARGET) fichier.txt  Lire depuis un fichier"
	@echo "  echo '5+3' | ./$(TARGET) Pipe depuis stdin"
	@echo ""

# Génération de l'analyseur lexical
$(LEX_GEN): $(LEX_SRC) $(YACC_HDR)
	@echo "→ Génération de l'analyseur lexical..."
	$(FLEX) $(LEX_SRC)

# Génération de l'analyseur syntaxique
$(YACC_GEN) $(YACC_HDR): $(YACC_SRC)
	@echo "→ Génération de l'analyseur syntaxique..."
	$(BISON) -d -v $(YACC_SRC)

# Compilation de l'analyseur lexical
$(LEX_OBJ): $(LEX_GEN)
	@echo "→ Compilation de l'analyseur lexical..."
	$(CC) $(CFLAGS) -c $(LEX_GEN) -o $(LEX_OBJ)

# Compilation de l'analyseur syntaxique
$(YACC_OBJ): $(YACC_GEN) $(FUNC_HDR)
	@echo "→ Compilation de l'analyseur syntaxique..."
	$(CC) $(CFLAGS) -c $(YACC_GEN) -o $(YACC_OBJ)

# Compilation des fonctions
$(FUNC_OBJ): $(FUNC_SRC) $(FUNC_HDR)
	@echo "→ Compilation des fonctions statistiques..."
	$(CC) $(CFLAGS) -c $(FUNC_SRC) -o $(FUNC_OBJ)

# Édition de liens
$(TARGET): $(LEX_OBJ) $(YACC_OBJ) $(FUNC_OBJ)
	@echo "→ Édition de liens..."
	$(CC) $(LEX_OBJ) $(YACC_OBJ) $(FUNC_OBJ) $(LDFLAGS) -o $(TARGET)

# ========== TESTS ==========

# Test basique
test: $(TARGET)
	@echo ""
	@echo "════════════════════════════════════════"
	@echo "         TESTS BASIQUES"
	@echo "════════════════════════════════════════"
	@echo ""
	@echo "→ Test 1: Expression simple"
	@echo "5 + 3" | ./$(TARGET)
	@echo ""
	@echo "→ Test 2: Expression avec priorités"
	@echo "5 + 3 * 2" | ./$(TARGET)
	@echo ""
	@echo "→ Test 3: Parenthèses"
	@echo "(5 + 3) * 2" | ./$(TARGET)
	@echo ""
	@echo "→ Test 4: Nombres flottants"
	@echo "3.14 + 2.71" | ./$(TARGET)
	@echo ""
	@echo "→ Test 5: Fonction somme"
	@echo "somme(1, 2, 3, 4)" | ./$(TARGET)
	@echo ""
	@echo "→ Test 6: Fonction moyenne"
	@echo "moyenne(10, 20, 30)" | ./$(TARGET)
	@echo ""
	@echo "→ Test 7: Fonction produit"
	@echo "produit(2, 3, 4)" | ./$(TARGET)
	@echo ""
	@echo "→ Test 8: Fonction variance"
	@echo "variance(2, 4, 6, 8)" | ./$(TARGET)
	@echo ""
	@echo "→ Test 9: Fonction écart-type"
	@echo "ecart_type(1, 2, 3, 4, 5)" | ./$(TARGET)
	@echo ""
	@echo "→ Test 10: Imbrication simple"
	@echo "moyenne(somme(1, 2), produit(3, 4))" | ./$(TARGET)
	@echo ""
	@echo "→ Test 11: Expression complexe du sujet"
	@echo "5 + 3 * somme(4, somme(5,7,8), variance(1, 1+1, moyenne(2,4), 4, 6-2))" | ./$(TARGET)
	@echo ""

# Test depuis fichiers
test-files: $(TARGET)
	@echo ""
	@echo "════════════════════════════════════════"
	@echo "      TESTS DEPUIS FICHIERS"
	@echo "════════════════════════════════════════"
	@if [ -d $(TEST_DIR) ] && [ -n "$$(ls -A $(TEST_DIR)/*.txt 2>/dev/null)" ]; then \
		for file in $(TEST_DIR)/*.txt; do \
			echo ""; \
			echo "→ Test: $$file"; \
			./$(TARGET) $$file; \
		done; \
	else \
		echo "Aucun fichier de test trouvé dans $(TEST_DIR)/"; \
	fi
	@echo ""

# Test d'erreurs
test-errors: $(TARGET)
	@echo ""
	@echo "════════════════════════════════════════"
	@echo "     TESTS DE GESTION D'ERREURS"
	@echo "════════════════════════════════════════"
	@echo ""
	@echo "→ Erreur lexicale (caractère invalide):"
	@echo "5 + @" | ./$(TARGET) 2>&1 || true
	@echo ""
	@echo "→ Erreur syntaxique (opérateur manquant):"
	@echo "5 3" | ./$(TARGET) 2>&1 || true
	@echo ""
	@echo "→ Erreur syntaxique (parenthèse manquante):"
	@echo "(5 + 3" | ./$(TARGET) 2>&1 || true
	@echo ""
	@echo "→ Division par zéro:"
	@echo "10 / 0" | ./$(TARGET) 2>&1 || true
	@echo ""

# Test interactif
test-interactive: $(TARGET)
	@echo "════════════════════════════════════════"
	@echo "          MODE INTERACTIF"
	@echo "════════════════════════════════════════"
	./$(TARGET)

# Tous les tests
test-all: test test-errors
	@echo "════════════════════════════════════════"
	@echo "     TOUS LES TESTS TERMINÉS"
	@echo "════════════════════════════════════════"
	@echo ""

# ========== NETTOYAGE ==========

# Nettoyage des fichiers générés
clean:
	@echo "→ Nettoyage des fichiers générés..."
	@rm -f $(LEX_GEN) $(LEX_OBJ)
	@rm -f $(YACC_GEN) $(YACC_HDR) $(YACC_OUT) $(YACC_OBJ)
	@rm -f $(FUNC_OBJ)
	@rm -f $(TARGET)
	@echo "✓ Nettoyage terminé"

# Nettoyage complet (inclut les backups)
distclean: clean
	@rm -f *~ $(SRC_DIR)/*~ $(TEST_DIR)/*~
	@rm -f *.output

# ========== AUTRES RÈGLES ==========

# Recompilation complète
rebuild: clean all

# Affichage de l'aide
help:
	@echo ""
	@echo "════════════════════════════════════════════════════════════════"
	@echo "  Makefile - Évaluateur d'Expressions Arithmétiques"
	@echo "════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Cibles disponibles:"
	@echo "  all              - Compile le projet (défaut)"
	@echo "  test             - Lance les tests basiques"
	@echo "  test-files       - Teste avec les fichiers du dossier tests/"
	@echo "  test-errors      - Teste la gestion d'erreurs"
	@echo "  test-all         - Lance tous les tests"
	@echo "  test-interactive - Lance le mode interactif"
	@echo "  clean            - Supprime les fichiers générés"
	@echo "  distclean        - Nettoyage complet"
	@echo "  rebuild          - Recompile tout depuis zéro"
	@echo "  help             - Affiche cette aide"
	@echo ""
	@echo "Exemples d'utilisation:"
	@echo "  make                       # Compile le projet"
	@echo "  make test                  # Lance les tests"
	@echo "  ./calculateur              # Mode interactif"
	@echo "  ./calculateur test.txt     # Lit depuis un fichier"
	@echo "  echo '5+3' | ./calculateur # Depuis stdin"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════"
	@echo ""

# Déclaration des cibles qui ne sont pas des fichiers
.PHONY: all test test-files test-errors test-interactive test-all clean distclean rebuild help
