#include <bits/stdc++.h>
#include<string>
#include<iostream>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<sstream>
#include<fstream>
using namespace std;
class SymbolInfo
{
    string name;
    string type;

public:
    bool is_valid_token;
   SymbolInfo *next;
   string dec;
     SymbolInfo(string n,string t)
    {
        name=n;
        type=t;

    }
    SymbolInfo(string n,string t,string s)
    {
        name=n;
        type=t;
        dec=s;
        is_valid_token=true;

    }
   SymbolInfo() {};
    void setName(string n)
   {
	name=n;	
   }
   void setIs_val(bool b)
   {
       is_valid_token=b;
   }		
    string getName()
    {

        return name;
    }
     string getType()
    {

        return type;
    }
   


};
class scopetable
{
    SymbolInfo **hash_table;
    int length;


    public:
    scopetable *parentScope;
    int id=0;
    scopetable(int n)
    {
        hash_table=new SymbolInfo*[n];
        this->length=n;
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
    bool insert(SymbolInfo *s)
    {
        int hash_value=hash_function(s->getName());
       // printf("%d\n",hash_value);
        SymbolInfo *r=look_up(s->getName());
        if(r!=NULL)
        {
            //cout<<s->getName()<<" already exists in current scopetable"<<endl;
             return false;

        }

           // printf("running1\n");

        SymbolInfo *temp=hash_table[hash_value];
        if(temp==NULL)
        {
            temp=s;
            temp->next=NULL;
            hash_table[hash_value]=s;
          //  cout<<"Inserted in scopetable "<<this->id<<" position "<<hash_value <<" 0"<<endl;
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
        //cout<<"Inserted in scopetable "<<this->id<<" position "<<hash_value <<" "<<pos<<endl;


        return true;


    }
    SymbolInfo* look_up(string name)
    {

       int hash_value=hash_function(name);
       SymbolInfo *temp=hash_table[hash_value];
       int pos=0;

       while(temp!=NULL)
       {

           if(temp->getName()==name)
           {
           //    cout<<"found in scopetable "<<this->id<<" position "<<hash_value<<" "<<pos<<endl;
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
        SymbolInfo* r=look_up(name);
        if(r==NULL)
        {
         //  printf("Not found\n");
           return false;

        }

   SymbolInfo *temp=hash_table[hash_value];
   SymbolInfo *prev=NULL;

    if(temp->getName()==name)
    {
       // printf("Deleted from %d 0\n",hash_value);
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
             //  printf("Deleted from %d %d\n",hash_value,pos);
               break;
           }
           prev=temp;
           temp=temp->next;
           pos++;
       }

    }

    return true;

    }
    void print(FILE *f)
    {
      fprintf(f,"Scopetable %d\n",id);
      for(int i=0;i<length;i++)
      {
          fprintf(f,"%d-->",i);
          SymbolInfo *temp=hash_table[i];
          while(temp)
          {
           // cout<<"<"<<temp->getName()<<":"<<temp->getType()<<">"<<"-->";
	  fprintf(f,"%s:%s",temp->getName().c_str(),temp->getType().c_str());	
            temp=temp->next;

          }
          fprintf(f,"\n\n");


      }

     fprintf(f,"\n\n\n\n");

    }


   ~scopetable()
   {

      for(int i = 0; i <length; i++) {
            SymbolInfo *temp=hash_table[i];
            while(temp)
            {
                SymbolInfo *prev=temp;
                temp=temp->next;
                delete prev;

            }


    }

     delete[] hash_table;
    // delete parentScope;


   }



};


class SymbolTable
{
   
public:
     scopetable *curr;
    SymbolTable()
    {

        curr=new scopetable(10);
        curr->parentScope=new scopetable(0);

    }
    void Enter_scope()
    {
        int n=10;

        scopetable *newScope=new scopetable(n) ;
        scopetable *temp=curr;
        curr=newScope;
        curr->parentScope=temp;

        //  printf("cond 2\n");
          int x=curr->parentScope->id;
          curr->id=x+1;




    }

    void Exit_scope()
    {
        scopetable *temp=curr;

        curr=curr->parentScope;
        temp->~scopetable();




    }

   bool insert(string n,string t,string s)
   {
      SymbolInfo *si=new SymbolInfo(n,t,s);
     // cout<<"inserted\n\n"<<n<<endl;

       return  curr->insert(si);

   }
   bool remove_symbol(string name)
   {

       return curr->Delete(name);

   }
   SymbolInfo* look_up(string name)
   {
       SymbolInfo *s;
      scopetable *temp=curr;
     while(temp->id!=0)
     {
        s=temp->look_up(name);
        if(s) return s;
        temp=temp->parentScope;

     }
     
     return NULL;



   }

   void printCurrScope(FILE *f)
   {

       curr->print(f);
   }
   void printAll(FILE *f)
   {
      scopetable *temp=curr;
      while(temp->id!=0)
      {
          temp->print(f);
          temp=temp->parentScope;
      }


   }
};
