#ifndef POLACA_INVERSA_H
#define POLACA_INVERSA_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "tabla-simbolos.h"
#include "pila.h"
#include "cola.h"
#define OP_COMPATIBLES 301
#define OP_NO_COMPATIBLES 300


void inicializar_polaca(t_cola *polaca) {
    inicializarCola(polaca);
}

int insertar_en_polaca(t_cola *polaca, const char *elemento){
  return encolar(polaca,elemento);
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


void avanzar_celda(t_cola *polaca){
    insertar_en_polaca(polaca, "");
}

void apilar_celda(t_cola *polaca, Pila *pila_celda){
    int nro_celda = polaca->final->nro;

    char buffer[MAX_CADENA];
    sprintf(buffer, "%d", nro_celda);

    apilar(pila_celda, buffer);
}

void actualizar_celda(t_cola *polaca, int nro_celda, char *dato){
    /*int nro_celda;
    nro_celda = atoi(desapilar(pila_celda));*/

    t_nodo_cola *actual = polaca->frente;   
    while (actual != NULL && nro_celda != actual->nro) {
        actual = actual->siguiente;
    }

    if (actual != NULL && nro_celda == actual->nro) {
        /*char buffer[MAX_CADENA];
        sprintf(buffer, "%d", polaca->final ->nro+1);*/
        actual->dato = strdup(dato);
    }
}

void complemento_op(char *op, char *comparador){
  if (strcmp(op,"BLT") == 0 ) strcpy(comparador, "BGE");
  else if (strcmp(op,"BLE") == 0 ) strcpy(comparador, "BGT");
  else if (strcmp(op,"BGT") == 0 ) strcpy(comparador, "BLE");
  else if (strcmp(op,"BGE") == 0 ) strcpy(comparador, "BLT");
  else if (strcmp(op,"BEQ") == 0 ) strcpy(comparador, "BNE");
  else if (strcmp(op,"BNE") == 0 ) strcpy(comparador, "BEQ");
}

int valida_tipos_datos(Pila *pila_tipos){
    char *op1 = desapilar(pila_tipos);
    char *op2 = desapilar(pila_tipos);
    printf("validacion de tipos %s - %s\n\n",op1,op2);
    if (strcmp(op1,"ERROR") == 0 || strcmp(op2,"ERROR") == 0 ){
        return OP_NO_COMPATIBLES;
    }

    if (strcmp(op1,"STRING") == 0 && strcmp(op2,"STRING") != 0 ){
        return OP_NO_COMPATIBLES;
    }
    else if (strcmp(op2,"STRING") == 0 && strcmp(op1,"STRING") != 0 ){
        return OP_NO_COMPATIBLES;
    }

    apilar(pila_tipos,op1);
    return OP_COMPATIBLES; //compatibles
}


#endif