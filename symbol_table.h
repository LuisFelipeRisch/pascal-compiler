#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "identifier_categories.h"
#include "variable_types.h"

typedef struct SimpleVariableAttributes SimpleVariableAttributes;
typedef struct SymbolTableNode SymbolTableNode;
typedef struct SymbolTable SymbolTable;

struct SimpleVariableAttributes {
  enum VariableTypes variable_type;
  unsigned int offset;
};

struct SymbolTableNode {
  char* identifier;
  enum IdentifierCategories identifier_category;
  unsigned int lexical_level; 
  void* attributes;

  SymbolTableNode* next;
};

struct SymbolTable {
  SymbolTableNode* top;
};

SymbolTable* create_symbol_table();
void insert_in_symbol_table(SymbolTable* symbol_table, char* identifier, enum IdentifierCategories identifier_category, unsigned int lexical_level, void* attributes);
void insert_simple_variable_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, unsigned int offset);

#endif