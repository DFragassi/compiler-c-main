#ifndef PILA_H
#define PILA_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

typedef struct nodo_pila {
    int nro_celda;
    struct nodo_pila *siguiente;
} t_nodo_pila;

typedef struct {
    t_nodo_pila *tope;
} t_pila;


void inicializar_pila(t_pila *pila) {
    pila->tope = NULL;
}

int pila_vacia(t_pila *pila) {
    return pila->tope == NULL;
}

void apilar(t_pila *pila, int elemento) {
  t_nodo_pila *nuevo = (t_nodo_pila*)malloc(sizeof(t_nodo_pila));

  /*nuevo->dato = (char *)malloc(sizeof(char) * (strlen(elemento) + 1));
  if (nuevo->dato == NULL)
  {
    free(nuevo);
    return ;
  }
  strcpy(nuevo->dato, elemento);*/
  nuevo->nro_celda = elemento;
  nuevo->siguiente = pila->tope;
  pila->tope = nuevo;
}

int desapilar(t_pila *pila) {
    if (pila_vacia(pila)) return -1;
    
    t_nodo_pila *temp = pila->tope;

    /*char *resultado;
    resultado = (char *)malloc(sizeof(char) * (strlen(temp->dato) + 1));
    if (resultado == NULL)
    {
      return NULL;
    }
    strcpy(resultado, temp->dato);*/
    int resultado;
    resultado = temp->nro_celda;
    pila->tope = temp->siguiente;
    free(temp);
    return resultado;
}



void liberar_pila(t_pila *pila) {
    while (!pila_vacia(pila)) {
        desapilar(pila);
    }
}

#endif