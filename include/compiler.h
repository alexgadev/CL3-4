#include <stdio.h>
#include <stdlib.h>

#include <stdbool.h>
#include <string.h>
#include <math.h>

typedef struct
{
    char* value;
    int type; // 0 -> int, 1 -> float, 2 -> string, 3 -> boolean, -1 -> null/error
} variable;

void build_log_filename(char*);

void format(int);

void yyerror(char*);
void log_grammar(FILE*, char*, bool);
void log_error(FILE*, char*);
void print(variable);

int btoi(char* num);
int xtoi(char* num);
int otoi(char* num);

variable eval(variable a, char* op, variable b, char* str);