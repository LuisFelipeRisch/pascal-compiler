#ifndef INT_STACK_H
#define INT_STACK_H

typedef struct IntStackNode IntStackNode;
typedef struct IntStack IntStack;

struct IntStackNode {
  int data; 

  IntStackNode* previous;
};

struct IntStack {
  IntStackNode* top;
};

IntStack* create_int_stack(); 
void push_int_stack(IntStack* int_stack, int data); 
int pop_int_stack(IntStack* int_stack); 
void free_int_stack(IntStack* int_stack);

#endif