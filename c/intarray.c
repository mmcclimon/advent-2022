#include <stdio.h>
#include <stdlib.h>

#include "intarray.h"

#define INTARRAY_GROW_CAP(cap) ((cap) < 8 ? 8 : (cap)*2)

void intarray_init(intarray *arr) {
  arr->len = 0;
  arr->cap = 0;
  arr->array = NULL;
}

int *intarray_grow_array(int *array, int newcap) {
  void *result = realloc(array, sizeof(int) * newcap);

  if (result == NULL) {
    perror("could not reallocate array");
    exit(1);
  }

  return (int *)result;
}

void intarray_append(intarray *arr, int elem) {
  if (arr->cap < arr->len + 1) {
    int cap = arr->cap;
    arr->cap = INTARRAY_GROW_CAP(cap);
    arr->array = intarray_grow_array(arr->array, arr->cap);
  }

  arr->array[arr->len++] = elem;
}
