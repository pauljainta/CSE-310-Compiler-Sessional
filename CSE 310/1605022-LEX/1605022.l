%option noyywrap

%{
#include<iostream>
#include<string>
#include<stdio.h>
#include<sstream>
#include<fstream>
using namespace std;





	

class symbolinfo
{
    string name;
    string type;

public:
    symbolinfo *next;
    void setName(string s)
    {
        this->name=s;

    }
    void setType(string s)
    {
        this->type=s;

    }
    string getName()
    {

        return this->name;
    }
     string getType()
    {

        return this->type;
    }


};
class scopetable
{
    symbolinfo **hash_table;
    int length;


    public:
    scopetable *parentScope;
    int id=0;
    scopetable()
    {
        hash_table=new symbolinfo*[10];
        this->length=10;
	int n=10;
        for(int i=0;i<n;i++)
        {
            hash_table[i]=NULL;
        }
    }


    int hash_function(string s)
    {
        int sum=0;
        for(int i=0;i<s.length();i++)
        {

            sum+=s[i];
        }
        return sum%length;

    }
    bool insert(symbolinfo *s)
    {
        int hash_value=hash_function(s->getName());
       // printf("%d\n",hash_value);
        symbolinfo *r=look_up(s->getName());
        if(r!=NULL)
        {
           // cout<<s->getName()<<" already exists in current scopetable"<<endl;
             return false;

        }

           // printf("running1\n");

        symbolinfo *temp=hash_table[hash_value];
        if(temp==NULL)
        {
            temp=s;
            temp->next=NULL;
            hash_table[hash_value]=s;
           // cout<<"Inserted in scopetable "<<this->id<<" position "<<hash_value <<" 0"<<endl;
            return true;

        }
        int pos=1;

        while(temp->next)
        {
            temp=temp->next;
            pos++;

        }
        temp->next=s;
        s->next=NULL;
      //  cout<<"Inserted in scopetable "<<this->id<<" position "<<hash_value <<" "<<pos<<endl;


        return true;


    }
    symbolinfo* look_up(string name)
    {

       int hash_value=hash_function(name);
       symbolinfo *temp=hash_table[hash_value];
       int pos=0;

       while(temp!=NULL)
       {

           if(temp->getName()==name)
           {
              // cout<<"found in scopetable "<<this->id<<" position "<<hash_value<<" "<<pos<<endl;
               return temp;
           }

           temp=temp->next;
           pos++;
       }
        //cout<<"not found"<<endl;
       return NULL;
    }

    bool Delete(string name)
    {
      int hash_value=hash_function(name);
        symbolinfo *r=look_up(name);
        if(r==NULL)
        {
         //  printf("Not found\n");
           return false;

        }

    symbolinfo *temp=hash_table[hash_value];
    symbolinfo *prev=NULL;

    if(temp->getName()==name)
    {
      //  printf("Deleted from %d 0\n",hash_value);
        hash_table[hash_value]=temp->next;

    }

    else
    {
         int pos=1;

        while(temp!=NULL)
       {
           if(temp->getName()==name)
           {
               prev->next=temp->next;
              // printf("Deleted from %d %d\n",hash_value,pos);
               break;
           }
           prev=temp;
           temp=temp->next;
           pos++;
       }

    }

    return true;

    }
    void print(FILE *logout)
    {
		
		//logout= fopen("log.txt","w");
      fprintf(logout,"Scopetable %d\n",id);	
      for(int i=0;i<length;i++)
      {
          
          symbolinfo *temp=hash_table[i];
          if(temp)
		{
			 fprintf(logout,"%d-->",i);	
		

          while(temp)
          {
	   
	    		
           // cout<<"<"<<temp->getName()<<":"<<temp->getType()<<">"<<"-->";
	    fprintf(logout,"<%s:%s>--->",temp->getName().c_str(),temp->getType().c_str());	
            temp=temp->next;

          }
         fprintf(logout,"\n\n");
	}
	

      }

             fprintf(logout,"\n\n");

    }


   ~scopetable()
   {

      for(int i = 0; i <length; i++) {
            symbolinfo *temp=hash_table[i];
            while(temp)
            {
                symbolinfo *prev=temp;
                temp=temp->next;
                delete prev;

            }


    }

     delete[] hash_table;
  


   }



};



int line_count=1;
int error_count=0;


FILE *tokenout;
FILE *logout;
scopetable st;
      


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
FLTLIT [+-]?[0-9]*[.][0-9]+
EXPONENTS [+-]?[0-9]*([.]([0-9]+))?[E][+-][0-9]+
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
CHR['][\]([\]|[']['])[']




%%
{WHITESPACE} {}
{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE>");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}

"for"	{
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}


"while"	{
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}



"do"	{
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}




"break"	{
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}


"int"	{
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}
"char"	{
			fprintf(tokenout,"<CHAR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}

"float"	{
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}


"double"	{
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}


"void"	{
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}


"return"	{
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
	}


"switch"	{
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}


"case"	{
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
             }
	
"default"	{
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}


"CONTINUE"	{
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
 		}
	






"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
   			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("ADDOP");
			st.insert(si);
			st.print(logout);
			


			
		}

"*"    {
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
                        si->setName(string(yytext));
			si->setType("MULOP");
			st.insert(si);
			st.print(logout);



		}


"/"    {
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
                        si->setName(string(yytext));
			si->setType("MULOP");
			st.insert(si);
			st.print(logout);



		}

"%"    {
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
                        si->setName(string(yytext));
			si->setType("MULOP");
			st.insert(si);
			st.print(logout);



		}



"++"		|

"--"		{
			fprintf(tokenout,"<INCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
               		symbolinfo *si=new symbolinfo();	
			si->setName(string(yytext));
			si->setType("INCOP");
			st.insert(si);
			st.print(logout);
			
	



		}


"<"		|

"<="		|
">"             |
">="            |
"=="		|
  
"!="     {
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("RELOP");
			st.insert(si);
			st.print(logout);
			


	}		
  
"="     {
			fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("ASSIGNOP");
			st.insert(si);
			st.print(logout);
			

       }



"&&"		|
  
"||"     {
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("LOGICOP");
			st.insert(si);
			st.print(logout);
			

         }



"&"		|

"|"		|
"^"             |
">>"            |
"<<"	        {
			fprintf(tokenout,"<BITCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("BITOP");
			st.insert(si);
			st.print(logout);
			


        }


"!"	        {
			fprintf(tokenout,"<NOT,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("NOT");
			st.insert(si);
			st.print(logout);


        }

"("	        {
			fprintf(tokenout,"<LPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("LPAREN");
			st.insert(si);
			st.print(logout);


        }

")"	        {
			fprintf(tokenout,"<RPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("RPAREN");
			st.insert(si);
			st.print(logout);


        }


"{"	        {
			fprintf(tokenout,"<LCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("LCURL");
			st.insert(si);
			st.print(logout);


        }

"}"	        {
			fprintf(tokenout,"<RCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("RCURL");
			st.insert(si);
			st.print(logout);
			


        }




"["	        {
			fprintf(tokenout,"<LTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("LTHIRD");
			st.insert(si);
			st.print(logout);


        }
"]"	        {
			fprintf(tokenout,"<RTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("RTHIRD");
			st.insert(si);
			st.print(logout);
	

        }



","	        {
			fprintf(tokenout,"<COMMA,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("COMMA");
			st.insert(si);
			st.print(logout);
			


        }


";"	        {
			fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			symbolinfo *si=new symbolinfo();
			si->setName(string(yytext));
			si->setType("SEMICOLON");
			st.insert(si);
			st.print(logout);
			

        }











		
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
			        si->setName(string(yytext));
			       si->setType("CONST_INT");
			        st.insert(si);
			      st.print(logout);

			}



		
{FLTLIT} 	{
				fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName(string(yytext));
			       si->setType("CONST_FLOAT");
			       st.insert(si);
			     st.print(logout);
			}









{EXPONENTS} 	{
				fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName(string(yytext));
			       si->setType("CONST_FLOAT");
			       st.insert(si);
			     st.print(logout);
			}







'\\n' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
                                si->setName("\n");
				si->setType("CONST_CHAR");
				st.insert(si);
			        st.print(logout);
			}


'\\t' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();	
				si->setName("\t");
				si->setType("CONST_CHAR");
				st.insert(si);
			        st.print(logout);
			}







'\\a' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName("\a");
				si->setType("CONST_CHAR");
				st.insert(si);
			st.print(logout);
			}


'\\f' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
                                si->setName("\f");
				si->setType("CONST_CHAR");
				st.insert(si);
			st.print(logout);
			}


'\\r' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();	
				si->setName("\r");
				si->setType("CONST_CHAR");
				st.insert(si);
			st.print(logout);
			}



'\\b' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();	
				si->setName("\b");
				si->setType("CONST_CHAR");
				st.insert(si);
			st.print(logout);
				
			}



'\\v' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName("\v");
				si->setType("CONST_CHAR");
				st.insert(si);
			st.print(logout);
			}


'\\0' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName("\v");
				si->setType("CONST_CHAR");
				st.insert(si);
			        st.print(logout);
			}



'.' {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName(string(yytext));
				si->setType("CONST_CHAR");
				st.insert(si);
			        st.print(logout);

			}

{IDENTIFIER}    {
				fprintf(tokenout,"<ID,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
				symbolinfo *si=new symbolinfo();
				si->setName(string(yytext));
				si->setType("ID");
				st.insert(si);
			        st.print(logout);
			}

   
   		
\"([^\"\n]|(\\[\n])|(\"))*\" {
  				fprintf(tokenout,"<STRING,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_count,yytext);
				
			}

"//"((.*\\\n.*)|(.*))*  {
				
				fprintf(logout,"Line no %d: Comment found\n",line_count);
				
			}
   








\"([^\"\n]|(\\[\n]))* 				{
							
							fprintf(logout,"Error at Line No.%d:  Unfinished String found %s\n",line_count,yytext);
							error_count++;
							

						}



[0-9]+([_a-zA-Z]|[0-9])*				{
							
							fprintf(logout,"Error at Line No.%d:  Invalid Identifier %s\n",line_count,yytext);
								error_count++;

							}




"/*"([^*]|("*"[^/]))*[^"*/"]		{
								
						fprintf(logout,"Error at Line No.%d:  Unfinished Comment %s \n",line_count,yytext);
								
								error_count++;

					}

.					{
						fprintf(logout,"Error at Line No.%d:  Unrecognized character %s \n",line_count,yytext);
								error_count++;

					}



{FLTLIT}[.]([0-9])+ {
					fprintf(logout,"Error at Line No.%d:  Too many decimal points %s \n",line_count,yytext);
					 error_count++;


				}




({DIGIT}|{FLTLIT})[E]*{FLTLIT}*{DIGIT}* {

			fprintf(logout,"Error at Line No.%d:  Ill formed number %s \n",line_count,yytext);
			error_count++;


			}


'.(.)+'  {

			fprintf(logout,"Error at Line No.%d:  multiple character constant %s \n",line_count,yytext);
			error_count++;
	} 

'(.)     {

		fprintf(logout,"Error at Line No.%d: unfinished character %s \n",line_count,yytext);
			error_count++;

	}		






			

%%

int main(int argc,char *argv[]){
	
	

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}	
	
	logout= fopen("1605022_log.txt","w");
	tokenout= fopen("1605022_token.txt","w");

	yyin= fin;
	yylex();
	
	fclose(yyin);
        fprintf(logout,"End of file! number of error %d and number of lines:%d",error_count,line_count);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
