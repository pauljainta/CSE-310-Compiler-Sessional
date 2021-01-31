%option noyywrap

%{

#include "1605022_table.h"
#include"y.tab.h"


int line_count = 1, error_count = 0;

%}

DELIM		[ \t\f\r\v]+
NEWLINE		[\n]




DOT		{\.}
DIGIT		[0-9]
INTEGER		[0-9]+

FLOAT1		[0-9]+(\.[0-9]+)?(E[+-]?[0-9]+)?
FLOAT2		(\.[0-9]+)(E[+-]?[0-9]+)?





IDENTIFIER	[a-zA-Z_][a-zA-Z_0-9]*



%%

{DELIM} 		{

	
}

{INTEGER}       {
			
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_INT");
			yylval.si= s;
			return CONST_INT;
		}

{FLOAT1}|{FLOAT2}  {
			
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_FLOAT");
			yylval.si = s;
			return CONST_FLOAT;
		}




{NEWLINE}	line_count++;







"println" {return PRINTLN;}

"if"		{ 
			
			return IF;
 		}

"for" 	   	{ 
		
			return FOR;
		}

"do"	   	{ 
		
			return DO;
		}

"int" 	   	{ 
		
			return INT;
		}

"float"    	{ 
		
			return FLOAT;
		}

"void"     	{ 
		
			return VOID;
		}



"else"     	{ 
			
			return ELSE;
		}

"while"    	{ 
			
			return WHILE;
		}




"return"   	{ 
		
			return RETURN;
		}





{IDENTIFIER}	{
			
			SymbolInfo* s =new  SymbolInfo(yytext, "ID");
			yylval.si= s;
			return ID;
		}


("++") 	{
			 
			return INCOP;
		}

("--")  {return DECOP;}


("+"|"-")   	{
			 
			SymbolInfo * s = new SymbolInfo(yytext, "ADDOP");
			yylval.si = s;
			return ADDOP;
		}
	
("*"|"/"|"%") 	{
		 
			SymbolInfo* s = new SymbolInfo(yytext,"MULOP");
			yylval.si = s;			
			return MULOP;
		}
	
("<="|">="|"=="|"!=") {
			
			SymbolInfo* s = new SymbolInfo(yytext, "RELOP");
			yylval.si = s; 
			return RELOP;
		}

("<"|">")	{
		
			SymbolInfo* s = new SymbolInfo(yytext, "RELOP");
			yylval.si = s; 			
			return RELOP;
		}

("=") 		{ 
			
			return ASSIGNOP;
		}

("&&"|"||") {
			 
			SymbolInfo* s = new SymbolInfo(yytext, "LOGICOP");
			yylval.si = s; 			
			return LOGICOP;
		}

"(" 		{	
		 
			return LPAREN;
		}

")" 		{		
			
			return RPAREN;
		}

("{") 		{
			
			return LCURL;
		}

("}") 		{
		 
			return RCURL;
		}

("[") 		{	
			
			return LTHIRD;
		}


("]") 		{	
			 
			return RTHIRD;
		}

(";") 		{
			
			return SEMICOLON;
		}

(",") 		{
			
			return COMMA;		
			}
("!")		{return NOT;}






%%

	
