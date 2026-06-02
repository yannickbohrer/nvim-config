#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char name[64];
    int age;
} Animal;

Animal *animal_new(const char *name, int age) {
    Animal *a = malloc(sizeof(Animal));
    strncpy(a->name, name, sizeof(a->name) - 1);
    a->name[sizeof(a->name) - 1] = '\0';
    a->age = age;
    return a;
}

void animal_greet(const Animal *a) {
    printf("%s (age %d) says hello!\n", a->name, a->age);
}

int main(void) {
    Animal *animals[] = {
        animal_new("Rex", 3),
        animal_new("Buddy", 5),
    };
    size_t n = sizeof(animals) / sizeof(animals[0]);
    for (size_t i = 0; i < n; i++) {
        animal_greet(animals[i]);
        free(animals[i]);
    }
    return 0;
}
