%{
#define YYSTYPE variable

#include "../include/compiler.h"
#include "../gen/parse.tab.h"

%}

/* Avoid the error "undefined reference to 'yywrap'" from Flex */
%option noyywrap

%%


-?[0-9]+			            { yylval.value = strdup(yytext); yylval.type = 0; return T_INT; }
-?[0-9]+\.[0-9]+(e-?[0-9]+)?	{ yylval.value = strdup(yytext); yylval.type = 1; return T_FLOAT; }

("0b"[01]*)			{ 
                        yylval.value = strdup(yytext);//btoi(yytext + 2); // avoids first 2 chars "0b"
					    yylval.type = 0; 
                        return T_BIN; 
                    }

("0x")(0|([1-9a-f][0-9a-f]*))	{ 
                                    yylval.value = strdup(yytext);//xtoi(yytext + 2); // avoids first 2 chars "0x"
								    yylval.type = 0; 
                                    return T_HEX; 
                                }

("0c")(0|([1-7][0-7]*))	{ 
                            yylval.value = strdup(yytext);//otoi(yytext + 2); // avoids first char "0c"
						    yylval.type = 0; 
                            return T_OCT; 
                        }

\"(\\.|[^"\+])*\"		{ 
						    // remove first and last " character
						    char* temp = strdup(yytext);
						    char* result = temp + 1;

						    result[strlen(result) - 1] = '\0';
						    yylval.value = result;
                            yylval.type = 2;
						    return T_STRING; 
					    }
("true")|("false")	{
						yylval.value = strdup(yytext);//(strcmp(yytext, "true")) ? false : true;
						yylval.type = 3;
                        return T_BOOL;
					}


"decimal"           { return FORMAT_DECIMAL; }
"hexagesimal"       { return FORMAT_HEXAGESIMAL; }
"octal"             { return FORMAT_OCTAL; }


\/\/.*				            { }
#.*					            { }
"/*"([^*]|\*+[^*/])*\*+"/"		{ }


":="				{ return ASSIG; }


"("					{ return SYM_OB; }
")"					{ return SYM_CB; }


"+"					{ return OP_ADD; }
"-"					{ return OP_SUB; }
"*"					{ return OP_MUL; }
"/"					{ return OP_DIV; }
"%"					{ return OP_MOD; }
"**"				{ return OP_POW; }


"<"					{ return OP_LT; }
"<="				{ return OP_LE; }
">"					{ return OP_GT; }
">="				{ return OP_GE; }
"="					{ return OP_EQ; }
"<>"				{ return OP_INEQ; }


"not"				{ return BOOL_OP_NOT; }
"and"				{ return BOOL_OP_AND; }
"or"				{ return BOOL_OP_OR; }


("pi"|"PI")			{ yylval.value = strdup(yytext); yylval.type = 1; return CONST_PI; }
("e"|"E")			{ yylval.value = strdup(yytext); yylval.type = 1; return CONST_E; }

"sin"				{ return FUNC_SIN; }
"cos"				{ return FUNC_COS; }
"tan"				{ return FUNC_TAN; }
"strlen"			{ return FUNC_STRLEN; }


"exit"				{ return CMD_EXIT; }

[a-zA-Z]+			{ yylval.value = strdup(yytext); yylval.type = 2; return T_IDEN; }


"\n"				{ return EOL; }

" "

%%