#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define EXISTE_SIMBOLO 1
#define NO_EXISTE_SIMBOLO 0


union t_valor{
                int valor_var_int;
                float valor_var_float;
                char *valor_var_str;
};

typedef struct
{
        char *nombre;
        char *tipo;
        union t_valor valor;
        int longitud;
}t_data;

typedef struct s_simbolo
{
        t_data data;
        struct s_simbolo *next;
}t_simbolo;

typedef struct
{
        t_simbolo *primero;
}t_tabla;

typedef struct{
  char cadena[40];
}t_nombresId;


/*
int buscar_simbolo(t_tabla *tabla_simbolos, const char *nombre) 
{
  t_simbolo *tabla = tabla_simbolos->primero  
  while(tabla && strcmp(tabla->data.nombre, nombre) < 0)
      tabla = tabla->next;
  if(tabla && strcmp(tabla->data.nombre, nombre) == 0)
      return DUPLICADO;
  return OK;
}*/

void replace_all_char(char* cadena, char buscar, char reemplazo) {
    for (int i = 0; cadena[i] != '\0'; i++) {
        if (cadena[i] == buscar) {
            cadena[i] = reemplazo;
        }
    }
}

t_data *crearDatos(const char *nombre, const char *tipo,
                   const char *valString, int valor_var_int,
                   float valor_var_float)
{
  t_data *data = (t_data *)calloc(1, sizeof(t_data));
  if (data == NULL)
  {
    return NULL;
  }

  data->tipo = (char *)malloc(sizeof(char) * (strlen(tipo) + 1));
  if (data->tipo == NULL)
  {
    free(data);
    return NULL;
  }
  strcpy(data->tipo, tipo);

  if (strcmp(tipo, "STRING") == 0 || strcmp(tipo, "INTEGER") == 0 || strcmp(tipo, "FLOAT") == 0)
  {
    data->nombre = (char *)malloc(sizeof(char) * (strlen(nombre) + 1));
    if (data->nombre == NULL)
    {
      free(data->tipo);
      free(data);
      return NULL;
    }
    strcpy(data->nombre, nombre);
    return data;
  }
  else
  {
    char nombreCte[100] = "_";
    strcat(nombreCte, nombre);

    data->nombre = (char *)malloc(sizeof(char) * (strlen(nombreCte) + 1));
    if (data->nombre == NULL)
    {
      free(data->tipo);
      free(data);
      return NULL;
    }
    strcpy(data->nombre, nombreCte);

    if (strcmp(tipo, "CTE_STR") == 0)
    {
      data->valor.valor_var_str = (char *)malloc(sizeof(char) * (strlen(valString) + 1));
      if (data->valor.valor_var_str == NULL)
      {
        free(data->nombre);
        free(data->tipo);
        free(data);
        return NULL;
      }
      strcpy(data->valor.valor_var_str, valString);
      data->longitud = strlen(valString) - 2;
    }
    else if (strcmp(tipo, "CTE_FLOAT") == 0)
    {
      data->valor.valor_var_float = valor_var_float;
    }
    else if (strcmp(tipo, "CTE_INT") == 0)
    {
      data->valor.valor_var_int = valor_var_int;
    }

    return data;
  }

  free(data->tipo);
  free(data);
  return NULL;
}



int insertar_tabla_simbolos(t_tabla *tabla_simbolos, const char *nombre, const char *tipo,
                            const char *valor_string, int valor_var_int,
                            float valor_var_float)
{
  t_simbolo *tabla = tabla_simbolos->primero;
  char nombreCTE[100] = "_";
  strcat(nombreCTE, nombre);

  while (tabla)
  {
    if (strcmp(tipo, "STRING") == 0 || strcmp(tipo, "INTEGER") == 0 || strcmp(tipo, "FLOAT") == 0)
    {
      if (strcmp(tabla->data.nombre, nombre) == 0)
      {
        return 1;
      }
    }
    else if (strcmp(tipo, "CTE_STR") == 0)
    {
      if (strcmp(tabla->data.tipo, "CTE_STR") == 0 &&
          strcmp(tabla->data.valor.valor_var_str, valor_string) == 0)
      {
        return 1;
      }
    }
    else if (strcmp(tipo, "CTE_INT") == 0)
    {
      if (strcmp(tabla->data.tipo, "CTE_INT") == 0 &&
          tabla->data.valor.valor_var_int == valor_var_int)
      {
        return 1;
      }
    }
    else if (strcmp(tipo, "CTE_FLOAT") == 0)
    {
      if (strcmp(tabla->data.tipo, "CTE_FLOAT") == 0 &&
          tabla->data.valor.valor_var_float == valor_var_float)
      {
        return 1;
      }
    }

    if (tabla->next == NULL)
    {
      break;
    }
    tabla = tabla->next;
  }

  t_data *data = crearDatos(nombre, tipo, valor_string, valor_var_int, valor_var_float);
  if (data == NULL)
  {
    return 1;
  }

  t_simbolo *nuevo = (t_simbolo *)malloc(sizeof(t_simbolo));
  if (nuevo == NULL)
  {
    free(data);
    return 2;
  }

  nuevo->data = *data;
  nuevo->next = NULL;

  if (tabla_simbolos->primero == NULL)
  {
    tabla_simbolos->primero = nuevo;
  }
  else
  {
    tabla->next = nuevo;
  }

  return 0;
}


void guardar_tabla_simbolos(t_tabla *tabla_simbolos)
{
  FILE *arch;
  if ((arch = fopen("symbol-table.txt", "wt")) == NULL)
  {
    printf("\nNo se pudo crear la tabla de simbolos.\n\n");
    return;
  }
  else if (tabla_simbolos->primero == NULL)
  {
    printf("\nLa tabla de simbolos está vacía.\n\n");
    fclose(arch);
    return;
  }

  fprintf(arch, "%-30s%-30s%-40s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

  t_simbolo *tabla = tabla_simbolos->primero;
  char valor[100];
  char longitud[20];

  while (tabla)
  {
    strcpy(valor, "--");
    strcpy(longitud, "--");

    if (strcmp(tabla->data.tipo, "INTEGER") == 0 ||
        strcmp(tabla->data.tipo, "FLOAT") == 0 ||
        strcmp(tabla->data.tipo, "STRING") == 0)
    {
      fprintf(arch, "%-30s%-30s%-40s%-30s\n",
              tabla->data.nombre,
              tabla->data.tipo,
              "--",
              "--");
    }
    else if (strcmp(tabla->data.tipo, "CTE_INT") == 0)
    {
      sprintf(valor, "%d", tabla->data.valor.valor_var_int);
      fprintf(arch, "%-30s%-30s%-40s%-30s\n",
              tabla->data.nombre,
              "CTE_INT",
              valor,
              "--");
    }
    else if (strcmp(tabla->data.tipo, "CTE_FLOAT") == 0)
    {
      sprintf(valor, "%f", tabla->data.valor.valor_var_float);
      fprintf(arch, "%-30s%-30s%-40s%-30s\n",
              tabla->data.nombre,
              "CTE_FLOAT",
              valor,
              "--");
    }
    else if (strcmp(tabla->data.tipo, "CTE_STR") == 0)
    {
      char aux_string[100];
      if (strlen(tabla->data.valor.valor_var_str) >= 2)
      {
        strncpy(aux_string, tabla->data.valor.valor_var_str + 1,
                strlen(tabla->data.valor.valor_var_str) - 2);
        aux_string[strlen(tabla->data.valor.valor_var_str) - 2] = '\0';

        sprintf(longitud, "%d", (int)strlen(aux_string));

        fprintf(arch, "%-30s%-30s%-40s%-30s\n",
                tabla->data.nombre,
                "CTE_STR",
                aux_string,
                longitud);
      }
      else
      {
        fprintf(arch, "%-30s%-30s%-40s%-30s\n",
                tabla->data.nombre,
                "CTE_STR",
                tabla->data.valor.valor_var_str,
                "0");
      }
    }

    t_simbolo *temp = tabla;
    tabla = tabla->next;
  }

  fclose(arch);
  printf("\nTabla de simbolos guardada correctamente.\n");
}

void crear_tabla_simbolos(t_tabla *tabla_simbolos)
{
    tabla_simbolos->primero = NULL;
}

int buscar_simbolo(t_tabla *tabla_simbolos, const char *nombre) {
    t_simbolo *actual = tabla_simbolos->primero;

    while (actual != NULL) {
        if (actual->data.nombre != NULL && strcmp(actual->data.nombre, nombre) == 0) {
            return EXISTE_SIMBOLO; 
        }
        actual = actual->next;
    }

    return NO_EXISTE_SIMBOLO; 
}

void insertar_aux_TS(t_tabla *tabla_simbolos, int *cant_aux){

  char nombre_aux[100] = "@aux";
  char buffer[100];
  sprintf(buffer, "%d", *cant_aux);
  strcat(nombre_aux,buffer); 
  insertar_tabla_simbolos(tabla_simbolos, nombre_aux, "FLOAT", "", 0, 0);
  *cant_aux = *cant_aux +1;
}

char * buscar_tipo_simbolo(t_tabla *tabla_simbolos, const char *nombre) {
    t_simbolo *actual = tabla_simbolos->primero;

    while (actual != NULL) {
        if (actual->data.nombre != NULL && strcmp(actual->data.nombre, nombre) == 0) {
            return strdup(actual->data.tipo);
        }
        actual = actual->next;
    }

    return strdup("ERROR"); // No se encontró simbolo
}

#endif