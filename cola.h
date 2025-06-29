#ifndef COLA_H
#define COLA_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define SUCCESS 1
#define ERROR -1

typedef struct nodo_cola {
    int nro;
    char* dato;
    struct nodo_cola* siguiente;
} t_nodo_cola;

typedef struct {
    t_nodo_cola* frente;
    t_nodo_cola* final;
    int cant_celdas;
} t_cola;

void inicializarCola(t_cola* cola) {
    cola->frente = NULL;
    cola->final = NULL;
    cola->cant_celdas = 0;
}

int encolar(t_cola* cola, const char* texto) {
    t_nodo_cola* nuevo = (t_nodo_cola*)malloc(sizeof(t_nodo_cola));
    if (!nuevo) {
        return ERROR;
    }

    nuevo->nro = cola->cant_celdas;
    nuevo->dato = strdup(texto);
    if (!nuevo->dato) {
        free(nuevo);
        return ERROR;
    }

    nuevo->siguiente = NULL;

    if (cola->final == NULL) {
        cola->frente = nuevo;
        cola->final = nuevo;
    } else {
        cola->final->siguiente = nuevo;
        cola->final = nuevo;
    }
    
    cola->cant_celdas++;

    return nuevo->nro;
}

char* desencolar(t_cola* cola) {
    if (cola->frente == NULL) {
        return NULL;
    }

    t_nodo_cola* temp = cola->frente;
    char* texto = temp->dato;

    cola->frente = temp->siguiente;
    if (cola->frente == NULL) {
        cola->final = NULL;
    }
    cola->cant_celdas--;
    free(temp);
    return texto;  // el usuario debe liberar el string después
}

int estaVacia(const t_cola* cola) {
    return cola->frente == NULL;
}

void actualizar_final(t_cola* cola){
    cola->final->nro = 999;
}

#endif