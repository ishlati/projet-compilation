/* syntaxique.y - Analyseur syntaxique pour expressions arithmétiques */

%code requires {
    #include "fonctions.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern int ligne;
extern int colonne;
extern FILE *yyin;

double resultat_final;
%}

/* Union pour les valeurs sémantiques */
%union {
    double nombre;
    Liste_Args* liste;
}

/* Tokens */
%token <nombre> NOMBRE
%token PLUS MOINS FOIS DIVISE
%token PAREN_G PAREN_D VIRGULE
%token SOMME PRODUIT MOYENNE VARIANCE ECART_TYPE

/* Types des non-terminaux */
%type <nombre> expression fonction
%type <liste> liste_args

/* Priorités et associativité */
%left PLUS MOINS
%left FOIS DIVISE
%right UMINUS

%start programme
%define parse.error detailed

%%

/* Règle de départ */
programme:
    /* Vide */
    | programme ligne
    ;

ligne:
    expression '\n' {
        resultat_final = $1;
        printf("✓ Résultat: %.6f\n", $1);
    }
    | '\n' { /* Ligne vide */ }
    | error '\n' {
        yyerrok;
    }
    ;

/* Expressions arithmétiques */
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

/* Fonctions statistiques */
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

/* Liste d'arguments (nombre variable) */
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

/* Gestion des erreurs syntaxiques */
void yyerror(const char *s) {
    int ligne_erreur = (ligne > 1) ? ligne - 1 : 1;
    
    /* Messages personnalisés selon le type d'erreur */
    if (strstr(s, "Division par zéro")) {
        fprintf(stderr, "❌ Erreur sémantique ligne %d: Division par zéro interdite\n", ligne_erreur);
    }
    else if (strstr(s, "unexpected NOMBRE")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Opérateur manquant entre les expressions\n", ligne_erreur);
    }
    else if (strstr(s, "expecting ')'") || strstr(s, "expecting PAREN_D")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Parenthèse fermante ')' manquante\n", ligne_erreur);
    }
    else if (strstr(s, "expecting '('") || strstr(s, "expecting PAREN_G")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Parenthèse ouvrante '(' manquante\n", ligne_erreur);
    }
    else if (strstr(s, "expecting ','") || strstr(s, "expecting VIRGULE")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Virgule ',' attendue entre les arguments\n", ligne_erreur);
    }
    else if (strstr(s, "expecting expression") || strstr(s, "unexpected end")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Expression attendue après l'opérateur\n", ligne_erreur);
    }
    else if (strstr(s, "unexpected end of file") || strstr(s, "unexpected $end")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Fin de fichier inattendue, expression incomplète\n", ligne_erreur);
    }
    else if (strstr(s, "unexpected")) {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: Élément inattendu dans l'expression\n", ligne_erreur);
    }
    else {
        fprintf(stderr, "❌ Erreur syntaxique ligne %d: %s\n", ligne_erreur, s);
    }
}

/* Fonction principale */
int main(int argc, char **argv) {
    printf("\n");
    printf("╔════════════════════════════════════════════════════════╗\n");
    printf("║  Évaluateur d'Expressions Arithmétiques               ║\n");
    printf("║  Projet Compilation - Flex & Bison                     ║\n");
    printf("╚════════════════════════════════════════════════════════╝\n");
    printf("\n");
    
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("❌ Erreur d'ouverture du fichier");
            return 1;
        }
        printf("📁 Lecture depuis le fichier: %s\n\n", argv[1]);
    } else {
        printf("📝 Entrez une expression (Ctrl+D pour terminer):\n");
        printf("Exemples:\n");
        printf("  • 5 + 3 * 2\n");
        printf("  • somme(1, 2, 3, 4)\n");
        printf("  • moyenne(10, 20, 30)\n");
        printf("  • 5 + somme(1, moyenne(2, 4), 3)\n");
        printf("\n> ");
        yyin = stdin;
    }
    
    int resultat_parse = yyparse();
    
    if (argc > 1 && yyin) {
        fclose(yyin);
    }
    
    printf("\n");
    if (resultat_parse == 0) {
        printf("✓ Analyse terminée avec succès\n\n");
        return 0;
    } else {
        printf("✗ Erreur lors de l'analyse\n\n");
        return 1;
    }
}
