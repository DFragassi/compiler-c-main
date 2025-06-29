#ifndef PILA_H
#define PILA_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CADENA 100

typedef struct Nodo {
    char dato[MAX_CADENA];
    struct Nodo* siguiente;
} Nodo;

typedef struct {
    Nodo* tope;
} Pila;

// Crear pila
Pila* crear_pila() {
    Pila* pila = malloc(sizeof(Pila));
    if (pila) pila->tope = NULL;
    return pila;
}

// Verifica si está vacía
int es_pila_vacia(Pila* pila) {
    return pila->tope == NULL;
}

// Apilar cadena
int apilar(Pila* pila, const char* cadena) {
    Nodo* nuevo = malloc(sizeof(Nodo));
    if (!nuevo) return 0;

    strncpy(nuevo->dato, cadena, MAX_CADENA - 1);
    nuevo->dato[MAX_CADENA - 1] = '\0';  // Asegura el null terminator

    nuevo->siguiente = pila->tope;
    pila->tope = nuevo;
    return 1;
}

// Desapilar y devolver cadena (debe liberarse después)
char* desapilar(Pila* pila) {
    if (es_pila_vacia(pila)) return NULL;

    Nodo* nodo = pila->tope;
    pila->tope = nodo->siguiente;

    char* resultado = malloc(strlen(nodo->dato) + 1);
    if (resultado) strcpy(resultado, nodo->dato);

    free(nodo);
    return resultado;  // ¡No olvidar liberar luego!
}

// Liberar toda la pila
void vaciar_pila(Pila* pila) {
    while (!es_pila_vacia(pila)) {
        free(desapilar(pila));
    }
    free(pila);
}

void ver_pila(Pila* pila) {
    printf("*************************** Viendo pila ");
    Nodo* nodo = pila->tope;
    while (nodo) {
        printf("%s - ",nodo->dato);
        nodo = nodo->siguiente;
    }
    printf("***************************\n");
}

#endif