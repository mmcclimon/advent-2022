#ifndef INTARRAY_H
#define INTARRAY_H 1

typedef struct {
  int len;
  int cap;
  int *data;
} intarray;

void intarray_init(intarray *ia);
void intarray_append(intarray *ia, int elem);
void intarray_sort_descending(intarray *ia);

#endif
