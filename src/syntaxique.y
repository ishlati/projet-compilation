/******************************************************************************
 * ANALYSEUR SYNTAXIQUE - Bison
 * Fichier: syntaxique.y
 * Description: Grammaire et évaluation des expressions arithmétiques
 *****************************************************************************/

%code requires {
    #include "fonctions.h"
}

%{
/* ========== SECTION 1: DÉCLARATIONS C ========== */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

/* Prototypes */
int yylex(void);
void yyerror(const char *s);
extern int ligne;
extern int colonne;
extern FILE *yyin;

/* Variable globale pour le résultat */
double resultat_final;
%}

/* ========== SECTION 2: DÉCLARATIONS BISON ========== */

/* Union pour les valeurs sémantiques */
%union {
    double nombre;              // Pour les nombres
    Liste_Args* liste;          // Pour les listes d'arguments
}

/* Déclaration des tokens */
%token <nombre> NOMBRE
%token PLUS MOINS FOIS DIVISE
%token PAREN_G PAREN_D VIRGULE
%token SOMME PRODUIT MOYENNE VARIANCE ECART_TYPE

/* Types des non-terminaux */
%type <nombre> expression fonction
%type <liste> liste_args

/* Priorités et associativité des opérateurs */
%left PLUS MOINS                // Priorité la plus basse, associativité gauche
%left FOIS DIVISE               // Priorité intermédiaire
%right UMINUS                   // Priorité haute (moins unaire)

/* Symbole de départ */
%start programme

/* Messages d'erreur détaillés */
%define parse.error detailed

%%

/* ========== SECTION 3: GRAMMAIRE ET ACTIONS SÉMANTIQUES ========== */

/* --- Règle de départ --- */
programme:
    /* Vide - permet de démarrer */
    | programme ligne
    ;

ligne:
    expression '\n' {
        resultat_final = $1;
        printf("✓ Résultat: %.6f\n", $1);
    }
    | '\n' {
        /* Ligne vide - ignore */
    }
    | error '\n' {
        /* Erreur - récupère et continue */
        yyerrok;
    }
    ;

/* --- Expressions arithmétiques --- */
expression:
    expression PLUS expression {
        $$ = $1 + $3;
    }
    | expression MOINS expression {
        $$ = $1 - $3;
    }
    | expression FOIS expression {
        $$ = $1 * $3;
    }
    | expression DIVISE expression {
        if ($3 == 0.0) {
            yyerror("Division par zéro");
            $$ = 0.0;
        } else {
            $$ = $1 / $3;
        }
    }
    | MOINS expression %prec UMINUS {
        $$ = -$2;
    }
    | PAREN_G expression PAREN_D {
        $$ = $2;
    }
    | fonction {
        $$ = $1;
    }
    | NOMBRE {
        $$ = $1;
    }
    ;

/* --- Fonctions statistiques --- */
fonction:
    SOMME PAREN_G liste_args PAREN_D {
        $$ = calcul_somme($3);
        liberer_liste($3);
    }
    | PRODUIT PAREN_G liste_args PAREN_D {
        $$ = calcul_produit($3);
        liberer_liste($3);
    }
    | MOYENNE PAREN_G liste_args PAREN_D {
        $$ = calcul_moyenne($3);
        liberer_liste($3);
    }
    | VARIANCE PAREN_G liste_args PAREN_D {
        $$ = calcul_variance($3);
        liberer_liste($3);
    }
    | ECART_TYPE PAREN_G liste_args PAREN_D {
        $$ = calcul_ecart_type($3);
        liberer_liste($3);
    }
    ;

/* --- Liste d'arguments (nombre variable) --- */
liste_args:
    expression {
        $$ = creer_liste();
        ajouter_element($$, $1);
    }
    | liste_args VIRGULE expression {
        ajouter_element($1, $3);
        $$ = $1;
    }
    ;

%%

/* ========== SECTION 4: CODE C ADDITIONNEL ========== */

/**
 * Gestion des erreurs syntaxiques avec messages détaillés
 */
void yyerror(const char *s) {
    /* Le compteur de ligne est incrémenté avant le traitement de l'erreur,
     * donc on doit décrémenter pour afficher le bon numéro */
    int ligne_erreur = (ligne > 1) ? ligne - 1 : 1;
    
    /* Messages personnalisés selon le type d'erreur détecté */
    
    /* Erreur sémantique : Division par zéro */
    if (strstr(s, "Division par zéro")) {
        fprintf(stderr, "❌ Erreur sémantique ligne %d: Division par zéro interdite\n", ligne_erreur);
    }
    /* Erreur : Deux nombres consécutifs sans opérateur */
    else if (strstr(s, "unexpected NOMBRE")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Opérateur manquant entre les expressions\n", ligne_erreur);
    }
    /* Erreur : Parenthèse fermante manquante */
    else if (strstr(s, "expecting ')'") || strstr(s, "expecting PAREN_D")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Parenthèse fermante ')' manquante\n", ligne_erreur);
    }
    /* Erreur : Parenthèse ouvrante manquante */
    else if (strstr(s, "expecting '('") || strstr(s, "expecting PAREN_G")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Parenthèse ouvrante '(' manquante\n", ligne_erreur);
    }
    /* Erreur : Virgule manquante entre arguments */
    else if (strstr(s, "expecting ','") || strstr(s, "expecting VIRGULE")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Virgule ',' attendue entre les arguments\n", ligne_erreur);
    }
    /* Erreur : Expression attendue après un opérateur */
    else if (strstr(s, "expecting expression") || strstr(s, "unexpected end")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Expression attendue après l'opérateur\n", ligne_erreur);
    }
    /* Erreur : Fin de fichier inattendue */
    else if (strstr(s, "unexpected end of file") || strstr(s, "unexpected $end")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Fin de fichier inattendue, expression incomplète\n", ligne_erreur);
    }
    /* Erreur : Token inattendu */
    else if (strstr(s, "unexpected")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Élément inattendu dans l'expression\n", ligne_erreur);
    }
    /* Message générique pour les autres erreurs */
    else {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: %s\n", ligne_erreur, s);
    }
}

/**
 * Fonction principale
 */
int main(int argc, char **argv) {
    printf("\n");
    printf("╔════════════════════════════════════════════════════════╗\n");
    printf("║  Évaluateur d'Expressions Arithmétiques               ║\n");
    printf("║  Projet Compilation - Flex & Bison                     ║\n");
    printf("╚════════════════════════════════════════════════════════╝\n");
    printf("\n");
    
    /* Gestion de l'entrée */
    if (argc > 1) {
        // Lecture depuis un fichier
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("❌ Erreur d'ouverture du fichier");
            return 1;
        }
        printf("📁 Lecture depuis le fichier: %s\n\n", argv[1]);
    } else {
        // Lecture depuis stdin (ligne de commande ou pipe)
        printf("📝 Entrez une expression (Ctrl+D pour terminer):\n");
        printf("Exemples:\n");
        printf("  • 5 + 3 * 2\n");
        printf("  • somme(1, 2, 3, 4)\n");
        printf("  • moyenne(10, 20, 30)\n");
        printf("  • 5 + somme(1, moyenne(2, 4), 3)\n");
        printf("\n> ");
        yyin = stdin;
    }
    
    /* Analyse et évaluation */
    int resultat_parse = yyparse();
    
    /* Fermeture du fichier si nécessaire */
    if (argc > 1 && yyin) {
        fclose(yyin);
    }
    
    /* Code de retour */
    printf("\n");
    if (resultat_parse == 0) {
        printf("✓ Analyse terminée avec succès\n\n");
        return 0;
    } else {
        printf("✗ Erreur lors de l'analyse\n\n");
        return 1;
    }
}
