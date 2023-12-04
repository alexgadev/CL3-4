#define _GNU_SOURCE

#include <stdio.h>
#include "../include/compiler.h"


int form = 0;


void build_log_filename(char* output)
{
	// get current date and time 
  	time_t t = time(NULL); 
  	struct tm tm = *localtime(&t);

  	// set log file name
  	if(0 > asprintf(&output, "log/%d-%02d-%02d_%02d:%02d:%02d.log",
    	tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour,
        tm.tm_min, tm.tm_sec)) {
		fprintf(stderr, "Couldn't create log file...");
		return 1;
  	}
}

void format(int n) { form = n; }

int btoi(char *num)
{
	int n = 0;

	for(int i = 0; i < strlen(num); i++)
	{
		n = 2 * n + (num[i]) - 48;
	}
	return n;
}

int xtoi(char *num)
{
	int n = 0;

	for(int i = 0; i < strlen(num); i++)
	{
		if(num[i] < 58)
		{
			n = 16 * n + (int) (num[i]) - 48;
		}
		else
		{
			n = 16 * n + (int) (num[i] - 87);
		}
	}
	return n;
}

int otoi(char *num)
{
	int n = 0;

	for(int i = 0; i < strlen(num); i++)
	{
		n = 8 * n + (int) (num[i]) - 48;
	}
	return n;
}

int numeric_expr(variable a, char* op, variable b){
	if(a.type > 1 || b.type > 1) return -1;

	// "hardcoded" because I don't want to spend much time making this elegant
	if(strcmp(op, "+") == 0 || strcmp(op, "-") == 0 || strcmp(op, "*") == 0 || 
		strcmp(op, "/") == 0 || strcmp(op, "%") == 0 || strcmp(op, "**") == 0)
	{
		return 0;
	}
	else{
		return 1;
	}
}

variable eval_arith(variable a, char* op, variable b){
	int ai = a.type == 0 ? atoi(a.value) : null;
	float af = a.type == 0 ? atof(a.value) : null;

	int bi = b.type == 0 ? atoi(b.value) : null;
	float bf = b.type == 0 ? atof(b.value) : null;

	variable result = {"", -1};

	

	return result;
}

variable eval_rel(variable a, char* op, variable b){

}

variable eval(variable a, char* op, variable b, char* str)
{
    variable output = {"", -1}; 

	// string expressions admit at least one string and any more type
	if(a.type == 2 || b.type == 2)
	{
		if(strcmp(op, "+") != 0)
		{
			// error stuff
		}
		else
		{
			output.value = strdup(a.value);
			strcat(output.value, b.value);
			output.type = 2;
		}
	}
	else
	{	// boolean expressions admit types -> boolean
		if(a.type == 3 && b.type == 3)
		{
			if((strcmp(op, "not") == 0) && is_null(a))
			{
				output.value = strcmp(b.value, "true") == 0 ? "false" : "true";
			}
			if(strcmp(op, "or"))
			{
				output.value = (strcmp(a.value, "true") == 0) 
								|| (strcmp(b.value, "true") == 0) 
								? "true" : "false";
			}
			if(strcmp(op, "and"))
			{
				output.value = (strcmp(a.value, "true") == 0) 
								&& (strcmp(b.value, "true") == 0) 
								? "true" : "false";
			}
			output.type = 3;
		}
		else
		{
			switch(numeric_expr(a, op, b))
			{
				case 0: output = eval_arith(a, op, b);
						break;
				case 1: output = eval_rel(a, op, b);
						break;
				default: //error
						break;
			}
		}
	}
    return output; 
}

void print(variable t)
{
	
}

void halt()
{

}

void yyerror(char* error_str)
{

}

void log_grammar(FILE* fp, char* log_str, bool error)
{

}

void log_error(FILE* fp, char* error_str)
{

}