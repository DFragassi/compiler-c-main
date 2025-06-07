#ifndef POLACA_INVERSA_H
#define POLACA_INVERSA_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "tabla-simbolos.h"
#include "pila.h"
#include "cola.h"


void inicializar_codigo_intermedio(t_cola *polaca) {
    inicializarCola(polaca);
}

void insertar_en_polaca(t_cola *polaca, const char *elemento){
  encolar(polaca,elemento);
}


void guardar_codigo_intermedio(t_cola *polaca) {
    FILE *archivo = fopen("intermediate-code.txt", "w");
    if (!archivo) {
        printf("Error: No se pudo crear el archivo intermediate-code.txt\n");
        return;
    }
    
    t_nodo_cola *actual = polaca->frente;
    int num = 1;
    
    while (actual != NULL) {
        fprintf(archivo, "%d\t", actual->nro);
        actual = actual->siguiente;
    }
    fprintf(archivo, "\n");
    actual = polaca->frente;
    while (actual != NULL) {
        fprintf(archivo, "%s\t", actual->dato);
        actual = actual->siguiente;
    }

    fclose(archivo);
    printf("Codigo intermedio guardado en 'intermediate-code.txt'\n");
}

#endif