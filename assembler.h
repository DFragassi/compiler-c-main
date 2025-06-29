#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "tabla-simbolos.h"
#include "polaca-inversa.h"
#include "pila.h"
#include "cola.h"

#define OP_OPE 110 //Operando
/*#define OP_SUM 11
#define OP_MUL 12
#define OP_RES 13
#define OP_DIV 14*/
#define ETIQ   209
#define OP_CMP 210
#define OP_BLT 211
#define OP_BLE 212
#define OP_BGT 213
#define OP_BGE 214
#define OP_BEQ 215
#define OP_BNE 216
#define OP_BI 217



int comparar_op(char * celda){
  if (strcmp(celda,"+") == 0 ){
    return OP_SUM;
  } else if (strcmp(celda,"-") == 0 ){
    return OP_RES;
  } else if (strcmp(celda,"*") == 0 ){
    return OP_MUL;
  } else if (strcmp(celda,"/") == 0 ){
    return OP_DIV;
  } else if (strcmp(celda,":=") == 0 ){
    return OP_AS;
  } else if (strcmp(celda,"CMP") == 0 ){
    return OP_CMP;
  } else if (strcmp(celda,"BLT") == 0 ){
    return OP_BLT;
  } else if (strcmp(celda,"BLE") == 0 ){
    return OP_BLE;
  } else if (strcmp(celda,"BGT") == 0 ){
    return OP_BGT;
  } else if (strcmp(celda,"BGE") == 0 ){
    return OP_BGE;
  } else if (strcmp(celda,"BEQ") == 0 ){
    return OP_BEQ;
  } else if (strcmp(celda,"BNE") == 0 ){
    return OP_BNE;
  } else if (strcmp(celda,"BI") == 0 ){
    return OP_BI;
  } else if(strstr(celda,"etiq") != NULL && strstr(celda,":") != NULL){
    return ETIQ;
  }

  return OP_OPE;
}
/*
void replace_all_char(char* cadena, char buscar, char reemplazo) {
    for (int i = 0; cadena[i] != '\0'; i++) {
        if (cadena[i] == buscar) {
            cadena[i] = reemplazo;
        }
    }
}*/

void generar_assembler( t_cola *polaca,t_tabla *tabla_sim){
    FILE* file_assembler;
    file_assembler = fopen("final.asm","wt");

    if(!file_assembler)
    {
        printf("Error en el archivo de assembler");
        return;
    }

    fprintf(file_assembler,  "include macros2.asm\n");
    fprintf(file_assembler,  "include number.asm\n");
    fprintf(file_assembler, ".MODEL LARGE\n.STACK 200h\n.386\n.DATA\n\n");

    t_simbolo *tabla = tabla_sim->primero;
    char nombre[100];
    char valor[100];

    while (tabla)
    {
      strcpy(nombre, tabla->data.nombre);  
      if(strstr(tabla->data.tipo,"STR") != NULL){

          if(strstr(tabla->data.tipo,"CTE") == NULL)
          {
              valor[0] = '?';
              valor[1] = '\0';   
          } else{
            strcpy(valor, tabla->data.valor.valor_var_str);  
          }
          fprintf(file_assembler,"%-20s db\t\t %-30s, \'$\', %s dup (?)\n",nombre,valor,"14");

      }
      else if(strstr(tabla->data.tipo,"INT") != NULL){

          if(strstr(tabla->data.tipo,"CTE") == NULL)
          {
              valor[0] = '?';
              valor[1] = '\0';   
          } else{
            char buffer[100];
            sprintf(buffer, "%d", tabla->data.valor.valor_var_int);
            strcpy(valor, buffer);  
          }
          fprintf(file_assembler,"%-20s dd\t\t %-30s\n",nombre,valor);
      }
      else if(strstr(tabla->data.tipo,"FLOAT") != NULL){

          if(strstr(tabla->data.tipo,"CTE") == NULL)
          {
              valor[0] = '?';
              valor[1] = '\0';   
          } else{
            char buffer[100];
            sprintf(buffer, "%f", tabla->data.valor.valor_var_float);
            strcpy(valor, buffer);  
          }
          fprintf(file_assembler,"%-20s dd\t\t %-30s\n",nombre,valor);
      }      

      if (tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
    }

    fprintf(file_assembler,  "\n.CODE");
    fprintf(file_assembler,  "\nMOV EAX,@DATA");
    fprintf(file_assembler,  "\nMOV DS,EAX");
    fprintf(file_assembler,  "\nMOV ES,EAX;\n\n");

    Pila *pila_op = crear_pila();
    t_nodo_cola *actual = polaca->frente;
    char *operador1, *operador2, c_aux [10];
    int aux = 1, f_jump = 0;
    while (actual != NULL) {
        switch (comparar_op(actual->dato)) {
            case OP_OPE:
                apilar(pila_op,actual->dato);
            break;
            case OP_SUM:
                operador2 = desapilar(pila_op);
                operador1 = desapilar(pila_op);
                sprintf(c_aux, "@aux%d", aux);

                fprintf(file_assembler,  "\nFLD %s\n",operador1);
                fprintf(file_assembler,  "FLD %s\n",operador2);
                fprintf(file_assembler,  "FADD\n");
                fprintf(file_assembler,  "FSTP %s\n",c_aux);

                apilar(pila_op,c_aux);
                aux++;
                break;
                
            case OP_MUL:
                operador2 = desapilar(pila_op);
                operador1 = desapilar(pila_op);
                sprintf(c_aux, "@aux%d", aux);

                fprintf(file_assembler,  "\nFLD %s\n",operador1);
                fprintf(file_assembler,  "FLD %s\n",operador2);
                fprintf(file_assembler,  "FMUL\n");
                fprintf(file_assembler,  "FSTP %s\n",c_aux);

                apilar(pila_op,c_aux);
                aux++;
                break;

            case OP_RES:
                operador2 = desapilar(pila_op);
                operador1 = desapilar(pila_op);
                sprintf(c_aux, "@aux%d", aux);

                fprintf(file_assembler,  "\nFLD %s\n",operador1);
                fprintf(file_assembler,  "FLD %s\n",operador2);
                fprintf(file_assembler,  "FSUB\n");
                fprintf(file_assembler,  "FSTP %s\n",c_aux);

                apilar(pila_op,c_aux);
                aux++;
                break;

            case OP_DIV: 
                operador2 = desapilar(pila_op);
                operador1 = desapilar(pila_op);
                sprintf(c_aux, "@aux%d", aux);

                fprintf(file_assembler,  "\nFLD %s\n",operador1);
                fprintf(file_assembler,  "FLD %s\n",operador2);
                fprintf(file_assembler,  "FDIV\n");
                fprintf(file_assembler,  "FSTP %s\n",c_aux);

                apilar(pila_op,c_aux);
                aux++;
                break;

            case OP_AS: 
                operador2 = desapilar(pila_op);
                operador1 = desapilar(pila_op);

                fprintf(file_assembler,  "\nFLD %s\n",operador1);
                fprintf(file_assembler,  "FSTP %s\n",operador2);
                break;

            case OP_CMP:
                operador2 = desapilar(pila_op);
                operador1 = desapilar(pila_op);

                fprintf(file_assembler,  "\nFLD %s\n",operador1);
                fprintf(file_assembler,  "FLD %s\n",operador2);
                fprintf(file_assembler,  "FXCH\n");
                fprintf(file_assembler,  "FCOM\n");
                fprintf(file_assembler,  "FSTSW AX\n");
                fprintf(file_assembler,  "SAHF\n");
                break;
            case OP_BLT:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JNAE %s\n",actual->dato);
                }
                break;
            case OP_BLE:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JNA %s\n",actual->dato);
                }
                break;
            case OP_BGT:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JA %s\n",actual->dato);
                }
                break;
            case OP_BGE:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JAE %s\n",actual->dato);
                }
                break;
            case OP_BEQ:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JE %s\n",actual->dato);
                }
                break;
            case OP_BNE:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JNE %s\n",actual->dato);
                }
                break;
            case OP_BI:
                actual = actual->siguiente;
                if (actual != NULL){
                    replace_all_char(actual->dato,':',' ');
                    fprintf(file_assembler,  "JMP %s\n",actual->dato);
                }
                break;
            case ETIQ:
                fprintf(file_assembler,  "\n%s",actual->dato);
                break;
            default:
                printf("Operador no definido %s\n",actual->dato);
                break;
        }

        actual = actual->siguiente;
    }

    fprintf(file_assembler, "\nFFREE");
    fprintf(file_assembler,  "\nmov ax,4c00h");
    fprintf(file_assembler,  "\nint 21h");
    fprintf(file_assembler,  "\nEnd");

}

#endif