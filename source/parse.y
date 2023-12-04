%{
    #define _GNU_SOURCE

    // symbol table
    #include "../include/symtab/symtab.h"

    /* ------ Function and variable declaration ------ */
    int yylex(void);
    extern FILE* yyin;

    /* ------ Global variables ------ */
    FILE* fp; // pointer to the log file created each execution
    variable NULL_ARG = {"", -1};
    char* log_str;
    bool error;

    int format = 0;
%}

%union{
    variable var;
}

%token T_INT T_FLOAT T_STRING T_BOOL T_IDEN T_BIN T_HEX T_OCT

%token FORMAT_DECIMAL FORMAT_HEXAGESIMAL FORMAT_OCTAL 

%token CONST_PI CONST_E

%token SYM_OB SYM_CB

%token FUNC_SIN FUNC_COS FUNC_TAN FUNC_STRLEN

%token OP_ADD OP_SUB OP_MUL OP_DIV OP_MOD OP_POW

%token OP_LT OP_LE OP_GT OP_GE OP_EQ OP_INEQ

%token BOOL_OP_NOT BOOL_OP_AND BOOL_OP_OR

%token ASSIG

%token EOL CMD_EXIT


%type<var> T_INT T_FLOAT T_STRING T_BOOL T_IDEN CONST_PI CONST_E assignment factor unary term expr pow arith relexpr bool_not bool_and

%start start

%%

start:
    | start sentence
;

sentence: EOL                       { error = false; }
    | statement EOL                 { error = false; }
    | CMD_EXIT                      { return 0; }
;

statement: expr                     { if(!error){ print($1); } }
        | assignment                { if(!error){ print($1); } }
        | format                    {}
;

format: FORMAT_DECIMAL              { format(0); }
        | FORMAT_HEXAGESIMAL        { format(1); }
        | FORMAT_OCTAL              { format(2); }
;

assignment: T_IDEN ASSIG expr       {
                                        if(!error)
                                        {
                                            variable var;
                                            char* id = $1.string;
                                            int found = sym_lookup(id, &var);

                                            // check if identifier was found
                                            if(found)
                                            {
                                                // if identifier doesn't exist then we have to create a new entry
                                                if(found == 2)
                                                {
                                                    var = $3;
                                                    var.string = id;
                                                    sym_add(id, &var);
                                                }
                                            }
                                            else
                                            {
                                                // if types are compatible then change var value
                                                // for assignments, compatibility depends only if types
                                                // are the same for both the identifier found and the value to be saved
                                                if(var.type == $3.type)
                                                {
                                                    var = $3;
                                                    sym_enter(id, &var);
                                                }
                                                // if types aren't compatible then there's a semantic error
                                                else
                                                {
                                                    yyerror("semantic error: identifier and expression type missmatch");
                                                    log_error(fp, "semantic error: identifier and expression type missmatch");
                                                    error = true;
                                                }
                                            }

                                            // if the assignment succeeded log grammar production
                                            if(!error)
                                            {
                                                eval($1, ":", $3, log_str);
                                                log_msg(fp, log_str, error);
                                                $$ = var;
                                            }
                                        }
                                    }
;

expr: bool_and                      { $$ = $1; }
    | expr BOOL_OP_OR bool_and      { if(!error){ $$ = eval($1, "or", $3, log_str); log_msg(fp, log_str, error); } }
;

bool_and: bool_not                          { $$ = $1; }
        | bool_and BOOL_OP_AND bool_not     { if(!error){ $$ = eval($1, "and", $3, log_str); log_msg(fp, log_str, error); } }
;

bool_not: BOOL_OP_NOT relexpr       { if(!error){ $$ = eval(NULL_ARG, "not", $2, log_str); log_msg(fp, log_str, error); } }
        | relexpr                   { $$ = $1; }
;

relexpr: arith                      { $$ = $1; }
        | relexpr OP_GT arith       { if(!error){ $$ = eval($1, ">", $3, log_str); log_msg(fp, log_str, error); } }
        | relexpr OP_GE arith       { if(!error){ $$ = eval($1, ">=", $3, log_str); log_msg(fp, log_str, error); } }
        | relexpr OP_LT arith       { if(!error){ $$ = eval($1, "<", $3, log_str); log_msg(fp, log_str, error); } }
        | relexpr OP_LE arith       { if(!error){ $$ = eval($1, "<=", $3, log_str); log_msg(fp, log_str, error); } }
        | relexpr OP_EQ arith       { if(!error){ $$ = eval($1, "=", $3, log_str); log_msg(fp, log_str, error); } }
        | relexpr OP_INEQ arith     { if(!error){ $$ = eval($1, "<>", $3, log_str); log_msg(fp, log_str, error); } }
;

arith: term                     { $$ = $1; }
    | arith OP_ADD term         { if(!error){ $$ = eval($1, "+", $3, log_str); if($$.type = -1){ error = true; } log_msg(fp, log_str, error); } }
    | arith OP_SUB term         { if(!error){ $$ = eval($1, "-", $3, log_str); if($$.type = -1){ error = true; } log_msg(fp, log_str, error); } }
;

term: unary                     { $$ = $1; }
        | term OP_MUL unary     { if(!error){ $$ = eval($1, "*", $3, log_str); if($$.type = -1){ error = true; } log_msg(fp, log_str, error); } }
        | term OP_DIV unary     { if(!error){ $$ = eval($1, "/", $3, log_str); if($$.type = -1){ error = true; } log_msg(fp, log_str, error); } }
        | term OP_MOD unary     { if(!error){ $$ = eval($1, "%", $3, log_str); if($$.type = -1){ error = true; } log_msg(fp, log_str, error); } }
;

unary: OP_SUB unary             { if(!error){ $$ = eval(NULL_ARG, "-", $2, log_str); log_msg(fp, log_str, error); } }
        | pow                   { $$ = $1; }
;

pow: factor OP_POW pow          { if(!error){ $$ = eval($1, "**", $3, log_str); log_msg(fp, log_str, error); } }
    | factor                    { $$ = $1; }
;

factor: T_IDEN                              {  
                                                variable id = {-1, -1.0, "", false, -1};
                                                int found = sym_lookup($1.value, &id);

                                                if(found)
                                                {
                                                    yyerror("syntax error: undeclared identifier");
                                                    char* buffer;
                                                    asprintf(&buffer, "syntax error: undeclared identifier -> '%s'", $1.string);
                                                    
                                                    log_error(fp, buffer);
                                                    error = true;

                                                    free(buffer);
                                                }
                                                else
                                                {
                                                    $$ = id;
                                                    $$.value = $1.value;
                                                    print = true;
                                                }
                                            }
        | T_INT                             { $$ = $1; }
        | T_FLOAT                           { $$ = $1; }
        | T_STRING                          { $$ = $1; }
        | T_BOOL                            { $$ = $1; }
        | CONST_PI                          { $$ = $1; }
        | CONST_E                           { $$ = $1; }
        | SYM_OB expr SYM_CB                { $$ = ($2); }
        | FUNC_SIN SYM_OB expr SYM_CB       { if(!error) { $$ = eval(NULL_ARG, "sin", $3, log_str); log_msg(fp, log_str, error); } }
        | FUNC_COS SYM_OB expr SYM_CB       { if(!error) { $$ = eval(NULL_ARG, "cos", $3, log_str); log_msg(fp, log_str, error); } }
        | FUNC_TAN SYM_OB expr SYM_CB       { if(!error) { $$ = eval(NULL_ARG, "tan", $3, log_str); log_msg(fp, log_str, error); } }
        | FUNC_STRLEN SYM_OB expr SYM_CB    { if(!error) { $$ = eval(NULL_ARG, "strlen", $3, log_str); log_msg(fp, log_str, error); } }
;

%%

int main(int argc, char *argv[])
{
    char* filename;
    build_log_filename(filename);

    fp = fopen(filename, "w");
    free(filename);

    if(argc > 1)
    {
        fprintf(fp, "Reading from file: %s\n\n", argv[1]);
        yyin = fopen(argv[1], "r");
    }
    yyparse();

    fclose(fp);
    fclose(yyin); // might cause bugs

    return 0;
}