/******************************************************************************
 * FONCTIONS STATISTIQUES - Headers
 * Fichier: fonctions.h
 * Description: Interface des fonctions de calcul
 *****************************************************************************/

#ifndef FONCTIONS_H
#define FONCTIONS_H

#include <stdlib.h>
#include <math.h>

/* ========== STRUCTURES DE DONNÉES ========== */

/**
 * Structure pour stocker une liste dynamique d'arguments
 */
typedef struct {
    double *elements;      // Tableau dynamique
    int taille;           // Nombre d'éléments actuels
    int capacite;         // Capacité allouée
} Liste_Args;

/* ========== PROTOTYPES DES FONCTIONS ========== */

/* --- Gestion de la liste d'arguments --- */

/**
 * Crée une nouvelle liste vide
 * @return Pointeur vers la liste créée
 */
Liste_Args* creer_liste(void);

/**
 * Ajoute un élément à la liste
 * @param liste Pointeur vers la liste
 * @param valeur Valeur à ajouter
 */
void ajouter_element(Liste_Args *liste, double valeur);

/**
 * Libère la mémoire de la liste
 * @param liste Pointeur vers la liste à libérer
 */
void liberer_liste(Liste_Args *liste);

/* --- Fonctions statistiques --- */

/**
 * Calcule la somme des éléments
 * @param liste Liste des valeurs
 * @return Somme de tous les éléments
 */
double calcul_somme(Liste_Args *liste);

/**
 * Calcule le produit des éléments
 * @param liste Liste des valeurs
 * @return Produit de tous les éléments
 */
double calcul_produit(Liste_Args *liste);

/**
 * Calcule la moyenne des éléments
 * @param liste Liste des valeurs
 * @return Moyenne arithmétique
 */
double calcul_moyenne(Liste_Args *liste);

/**
 * Calcule la variance des éléments
 * Formule: variance = Σ(xi - moyenne)² / n
 * @param liste Liste des valeurs
 * @return Variance
 */
double calcul_variance(Liste_Args *liste);

/**
 * Calcule l'écart-type des éléments
 * Formule: écart-type = √variance
 * @param liste Liste des valeurs
 * @return Écart-type
 */
double calcul_ecart_type(Liste_Args *liste);

/* --- Fonctions auxiliaires --- */

/**
 * Affiche le contenu d'une liste (debug)
 * @param liste Liste à afficher
 */
void afficher_liste(Liste_Args *liste);

#endif /* FONCTIONS_H */
