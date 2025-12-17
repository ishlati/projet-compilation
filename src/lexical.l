/******************************************************************************
 * ANALYSEUR LEXICAL - Flex
 * Fichier: lexical.l
 * Description: Reconnaissance des tokens de l'expression arithmétique
 *****************************************************************************/

%{
/* ========== SECTION 1: DÉCLARATIONS C ========== */

#include "syntaxique.tab.h"  // Fichier généré par Bison (tokens)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Variables globales pour compter lignes/colonnes */
int ligne = 1;
int colonne = 1;

/* Fonction pour afficher les erreurs lexicales */
void erreur_lexicale(const char* caractere);
%}

/* ========== SECTION 2: DÉFINITIONS ========== */

/* Motifs réutilisables */
CHIFFRE         [0-9]
LETTRE          [a-zA-Z_]
ENTIER          {CHIFFRE}+
FLOTTANT        {CHIFFRE}+\.{CHIFFRE}+
ESPACE          [ \t]
RETOUR_LIGNE    \n

/* Options Flex */
%option noyywrap
%option yylineno

%%

"somme"         { colonne += yyleng; return SOMME; }
"produit"       { colonne += yyleng; return PRODUIT; }
"moyenne"       { colonne += yyleng; return MOYENNE; }
"variance"      { colonne += yyleng; return VARIANCE; }
"ecart_type"    { colonne += yyleng; return ECART_TYPE; }

{ENTIER}        { 
                  colonne += yyleng;
                  yylval.nombre = atof(yytext);
                  return NOMBRE; 
                }

{FLOTTANT}      { 
                  colonne += yyleng;
                  yylval.nombre = atof(yytext);
                  return NOMBRE; 
                }

"+"             { colonne += yyleng; return PLUS; }
"-"             { colonne += yyleng; return MOINS; }
"*"             { colonne += yyleng; return FOIS; }
"/"             { colonne += yyleng; return DIVISE; }

"("             { colonne += yyleng; return PAREN_G; }
")"             { colonne += yyleng; return PAREN_D; }
","             { colonne += yyleng; return VIRGULE; }

{ESPACE}+       { colonne += yyleng; }
{RETOUR_LIGNE}  { ligne++; colonne = 1; }

.               { 
                  erreur_lexicale(yytext); 
                  colonne++; 
                }

%%

/* ========== SECTION 4: CODE C ADDITIONNEL ========== */

/**
 * Affiche un message d'erreur lexicale
 */
void erreur_lexicale(const char* caractere) {
    fprintf(stderr, "❌ Erreur lexicale ligne %d, colonne %d: ", ligne, colonne);
    fprintf(stderr, "caractère invalide '%s'\n", caractere);
}
