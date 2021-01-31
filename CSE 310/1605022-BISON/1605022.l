
%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
#include<string>
#include "1605022_table.h"
#include "y.tab.h"


//extern YYSTYPE yylval;
void yyerror(char *);


int line_count=1;
int error_count=0;
extern SymbolTable symboltable;

extern FILE *logtext;
extern FILE *errortext;





%}



digit [0-9]
letter [A-Za-z]
delim [ \t\r\f\v]
newline \n
ws [delim]+
id (_|{letter})(_|{letter}|{digit})*
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
ADDOP [+-] 
MULOP [*/%]
FLTLIT [+-]?[0-9]*[.][0-9]+

%%

{delim}+	{}
{newline} {line_count++;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"void" {return VOID;}

"println"	{return PRINTLN;}

{ADDOP} { 
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP","");
	              yylval.si=s;
				return ADDOP;
		}



{MULOP}	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP","");
	              yylval.si=s;
				return MULOP;
		}


"=" 	{return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP","");
              yylval.si=s;
		return RELOP;
	}

"&&"	|
"||"	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP","");
	              yylval.si=s;
				return LOGICOP;
		}
"!"		{	return NOT; }


";" 	{ return SEMICOLON;}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{
		//symboltable.Enter_scope();
		return LCURL;
		}
"}" 	{
		return RCURL;
		//symboltable.Exit_scope();
		}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}



{integer}	{
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_INT","");
 yylval.si=s;
				return CONST_INT;
			}
{number} 	{	
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT","");
		              yylval.si=s;
						return CONST_FLOAT; 
			}
{id} {	 
                  SymbolInfo *s= new SymbolInfo(yytext, (char *)"ID","");
				 
			 

               	 yylval.si=s;			
				return ID;
	}





\"([^\"\n]|(\\[\n]))* 				{
							
				fprintf(logtext,"Error at Line No.%d:  Unfinished String found %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  Unfinished String found %s\n\n",line_count,yytext);

							error_count++;
							

						}



[0-9]+([_a-zA-Z]|[0-9])*				{
							
					fprintf(logtext,"Error at Line No.%d:  Invalid Identifier %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  Invalid Identifier %s\n\n",line_count,yytext);

							error_count++;

							}




"/*"([^*]|("*"[^/]))*[^"*/"]		{
								
						fprintf(logtext,"Error at Line No.%d:  Unfinished comment %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  Unfinished comment %s\n\n",line_count,yytext);

							error_count++;

					}

.					{
						fprintf(logtext,"Error at Line No.%d:  Unrecognized character %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  Unrecognized character %s\n\n",line_count,yytext);

							error_count++;

					}



{FLTLIT}[.]([0-9])+ {
					
				fprintf(logtext,"Error at Line No.%d:  too many decimal points %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  too many decimal points %s\n\n",line_count,yytext);

							error_count++;


				}




({digit}|{FLTLIT})[E]*{FLTLIT}+ {

		fprintf(logtext,"Error at Line No.%d:  Ill formed number %s\n\n",line_count,yytext);
		fprintf(errortext,"Error at Line No.%d:  Ill formed number %s\n\n",line_count,yytext);

							error_count++;

			}


'.(.)+'  {

			fprintf(logtext,"Error at Line No.%d: Multiple character constant %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  Multiple character constant %s\n\n",line_count,yytext);

							error_count++;
	} 

'(.)     {
fprintf(logtext,"Error at Line No.%d: Unfinished character %s\n\n",line_count,yytext);
			fprintf(errortext,"Error at Line No.%d:  Unfinished character %s\n\n",line_count,yytext);

							error_count++;
		

	}		








%%

int yywrap()
{
        
	return 1;
}






