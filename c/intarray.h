#ifndef INTARRAY_H
#define INTARRAY_H 1

typedef struct {
  int len;
  int cap;
  int *array;
} intarray;

void intarray_init(intarray *arr);
void intarray_append(intarray *arr, int elem);

#endif
