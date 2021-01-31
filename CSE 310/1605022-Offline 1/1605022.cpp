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
    scopetable(int n)
    {
        hash_table=new symbolinfo*[n];
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
    bool insert(symbolinfo *s)
    {
        int hash_value=hash_function(s->getName());
       // printf("%d\n",hash_value);
        symbolinfo *r=look_up(s->getName());
        if(r!=NULL)
        {
            cout<<s->getName()<<" already exists in current scopetable"<<endl;
             return false;

        }

           // printf("running1\n");

        symbolinfo *temp=hash_table[hash_value];
        if(temp==NULL)
        {
            temp=s;
            temp->next=NULL;
            hash_table[hash_value]=s;
            cout<<"Inserted in scopetable "<<this->id<<" position "<<hash_value <<" 0"<<endl;
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
        cout<<"Inserted in scopetable "<<this->id<<" position "<<hash_value <<" "<<pos<<endl;


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
               cout<<"found in scopetable "<<this->id<<" position "<<hash_value<<" "<<pos<<endl;
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
           printf("Not found\n");
           return false;

        }

    symbolinfo *temp=hash_table[hash_value];
    symbolinfo *prev=NULL;

    if(temp->getName()==name)
    {
        printf("Deleted from %d 0\n",hash_value);
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
               printf("Deleted from %d %d\n",hash_value,pos);
               break;
           }
           prev=temp;
           temp=temp->next;
           pos++;
       }

    }

    return true;

    }
    void print()
    {
      printf("Scopetable %d\n",id);
      for(int i=0;i<length;i++)
      {
          printf("%d-->",i);
          symbolinfo *temp=hash_table[i];
          while(temp)
          {
            cout<<"<"<<temp->getName()<<":"<<temp->getType()<<">"<<"-->";
            temp=temp->next;

          }
          printf("\n\n");


      }

     printf("\n\n");

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
    // delete parentScope;


   }



};


class symboltable
{
    scopetable *curr;
public:
    symboltable()
    {

        curr=new scopetable(0);
        curr->parentScope=new scopetable(0);

    }
    void Enter_scope(int n)
    {

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

   bool insert(string n,string t)
   {
       symbolinfo *s=new symbolinfo();
       s->setName(n);
       s->setType(t);
       return  curr->insert(s);

   }
   bool remove_symbol(string name)
   {

       return curr->Delete(name);

   }
   symbolinfo* look_up(string name)
   {
       symbolinfo *s=new symbolinfo();
     scopetable *temp=curr;
     while(temp->id!=0)
     {
        s=temp->look_up(name);
        if(s) return s;
        temp=temp->parentScope;

     }
     cout<<"not found"<<endl;

     return NULL;



   }

   void printCurrScope()
   {

       curr->print();
   }
   void printAll()
   {
      scopetable *temp=curr;
      while(temp->id!=0)
      {
          temp->print();
          temp=temp->parentScope;
      }


   }



};


int main()
{

  ifstream infile("input.txt");

  string line;
  getline(infile,line);
  istringstream iss(line);
  int x;
  iss>>x;

  symboltable *st=new symboltable();
  st->Enter_scope(x);

  while (getline(infile, line))
 {
    istringstream iss(line);
    string subs;
    iss >> subs;
    if(subs=="I")
    {
        string name,type;
        iss>>name>>type;
        cout<<subs<<" "<<name<<" "<<type<<endl;

        st->insert(name,type);

    }
    else if(subs=="L")
    {
        string name;
        iss>>name;
        cout<<subs<<" "<<name<<endl;
        st->look_up(name);


    }
    else if(subs=="P")
    {
        string name;
        iss>>name;
        if(name=="A")
        {
            cout<<"P A"<<endl;
            st->printAll();
        }
        if(name=="C")
        {
                cout<<"P C"<<endl;

            st->printCurrScope();
        }

    }
    else if(subs=="D")
    {

        string name;
        iss>>name;
        cout<<"D "<<name<<endl;
        st->remove_symbol(name);


    }
    else if(subs=="S")
    {
        st->Enter_scope(x);

    }
    else if(subs=="E")
    {
        printf("E\n");

        st->Exit_scope();

    }


 }


 return 0;

}
