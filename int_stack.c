#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "int_stack.h"

IntStack* create_int_stack(){
  IntStack* int_stack = (IntStack *) malloc(sizeof(IntStack));

  int_stack->top = NULL; 

  return int_stack;
}

void push_int_stack(IntStack* int_stack, int data){
  IntStackNode* node = (IntStackNode *) malloc(sizeof(IntStackNode));

  node->data = data;
  node->previous = int_stack->top; 
  
  int_stack->top = node;
}

int pop_int_stack(IntStack* int_stack){
  IntStackNode* top = int_stack->top; 
  int data = top->data;

  int_stack->top = int_stack->top->previous;

  free(top);

  return data;
}

void free_int_stack(IntStack* int_stack){
  while (int_stack->top) pop_int_stack(int_stack); 
  free(int_stack);
}