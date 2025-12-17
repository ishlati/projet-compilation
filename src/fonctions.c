/******************************************************************************
 * FONCTIONS STATISTIQUES - Implémentation
 * Fichier: fonctions.c
 * Description: Implémentation des calculs statistiques
 *****************************************************************************/

#include "fonctions.h"
#include <stdio.h>
#include <string.h>

/* ========== CONSTANTES ========== */

#define CAPACITE_INITIALE 10    // Capacité initiale de la liste
#define FACTEUR_CROISSANCE 2    // Facteur de croissance du tableau

/* ========== GESTION DE LA LISTE D'ARGUMENTS ========== */

/**
 * Crée une nouvelle liste vide
 */
Liste_Args* creer_liste(void) {
    Liste_Args *liste = (Liste_Args*)malloc(sizeof(Liste_Args));
    
    if (liste == NULL) {
        fprintf(stderr, "Erreur: allocation mémoire pour la liste\n");
        exit(1);
    }
    
    liste->elements = (double*)malloc(CAPACITE_INITIALE * sizeof(double));
    
    if (liste->elements == NULL) {
        fprintf(stderr, "Erreur: allocation mémoire pour les éléments\n");
        free(liste);
        exit(1);
    }
    
    liste->taille = 0;
    liste->capacite = CAPACITE_INITIALE;
    
    return liste;
}

/**
 * Ajoute un élément à la liste (avec réallocation si nécessaire)
 */
void ajouter_element(Liste_Args *liste, double valeur) {
    if (liste == NULL) {
        fprintf(stderr, "Erreur: liste NULL dans ajouter_element\n");
        return;
    }
    
    /* Vérifier si on doit agrandir le tableau */
    if (liste->taille >= liste->capacite) {
        int nouvelle_capacite = liste->capacite * FACTEUR_CROISSANCE;
        double *nouveau_tableau = (double*)realloc(
            liste->elements, 
            nouvelle_capacite * sizeof(double)
        );
        
        if (nouveau_tableau == NULL) {
            fprintf(stderr, "Erreur: réallocation mémoire\n");
            exit(1);
        }
        
        liste->elements = nouveau_tableau;
        liste->capacite = nouvelle_capacite;
    }
    
    /* Ajouter l'élément */
    liste->elements[liste->taille] = valeur;
    liste->taille++;
}

/**
 * Libère la mémoire de la liste
 */
void liberer_liste(Liste_Args *liste) {
    if (liste != NULL) {
        if (liste->elements != NULL) {
            free(liste->elements);
        }
        free(liste);
    }
}

/* ========== FONCTIONS STATISTIQUES ========== */

/**
 * Calcule la somme
 */
double calcul_somme(Liste_Args *liste) {
    if (liste == NULL || liste->taille == 0) {
        fprintf(stderr, "Erreur: liste vide ou NULL\n");
        return 0.0;
    }
    
    double somme = 0.0;
    for (int i = 0; i < liste->taille; i++) {
        somme += liste->elements[i];
    }
    
    return somme;
}

/**
 * Calcule le produit
 */
double calcul_produit(Liste_Args *liste) {
    if (liste == NULL || liste->taille == 0) {
        fprintf(stderr, "Erreur: liste vide ou NULL\n");
        return 0.0;
    }
    
    double produit = 1.0;
    for (int i = 0; i < liste->taille; i++) {
        produit *= liste->elements[i];
    }
    
    return produit;
}

/**
 * Calcule la moyenne
 */
double calcul_moyenne(Liste_Args *liste) {
    if (liste == NULL || liste->taille == 0) {
        fprintf(stderr, "Erreur: liste vide ou NULL\n");
        return 0.0;
    }
    
    double somme = calcul_somme(liste);
    return somme / liste->taille;
}

/**
 * Calcule la variance
 * Formule: variance = Σ(xi - moyenne)² / n
 */
double calcul_variance(Liste_Args *liste) {
    if (liste == NULL || liste->taille == 0) {
        fprintf(stderr, "Erreur: liste vide ou NULL\n");
        return 0.0;
    }
    
    /* Calculer la moyenne */
    double moyenne = calcul_moyenne(liste);
    
    /* Calculer la somme des carrés des écarts */
    double somme_carres = 0.0;
    for (int i = 0; i < liste->taille; i++) {
        double ecart = liste->elements[i] - moyenne;
        somme_carres += ecart * ecart;
    }
    
    /* Variance = moyenne des carrés des écarts */
    return somme_carres / liste->taille;
}

/**
 * Calcule l'écart-type
 * Formule: écart-type = √variance
 */
double calcul_ecart_type(Liste_Args *liste) {
    if (liste == NULL || liste->taille == 0) {
        fprintf(stderr, "Erreur: liste vide ou NULL\n");
        return 0.0;
    }
    
    double variance = calcul_variance(liste);
    return sqrt(variance);
}

/* ========== FONCTIONS AUXILIAIRES ========== */

/**
 * Affiche le contenu d'une liste (pour le débogage)
 */
void afficher_liste(Liste_Args *liste) {
    if (liste == NULL) {
        printf("Liste NULL\n");
        return;
    }
    
    printf("Liste [taille=%d, capacité=%d]: ", liste->taille, liste->capacite);
    printf("[");
    for (int i = 0; i < liste->taille; i++) {
        printf("%.2f", liste->elements[i]);
        if (i < liste->taille - 1) {
            printf(", ");
        }
    }
    printf("]\n");
}
