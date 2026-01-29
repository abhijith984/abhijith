How does the “Undo” feature work using a Stack?


#include <stdio.h>
#include <string.h>

#define MAX 5

char stack[MAX][50];
int top = -1;

void push(char action[]) {
    if (top == MAX - 1) {
        printf("Stack Overflow\n");
    } else {
        top++;
        strcpy(stack[top], action);
        printf("Action added: %s\n", action);
    }
}

void pop() {
    if (top == -1) {
        printf("No actions to undo\n");
    } else {
        printf("Undo action: %s\n", stack[top]);
        top--;
    }
}

void display() {
    int i;
    if (top == -1) {
        printf("No actions available\n");
    } else {
        printf("Current actions:\n");
        for (i = top; i >= 0; i--) {
            printf("%s\n", stack[i]);
        }
    }
}

int main() {
    push("Apply Filter");
    push("Crop Image");
    push("Add Text");

    pop();
    pop();

    display();
    return 0;
}
