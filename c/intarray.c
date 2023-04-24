#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "intarray.h"

#define INTARRAY_GROW_CAP(cap) ((cap) < 8 ? 8 : (cap)*2)

void intarray_init(intarray *ia) {
  ia->len = 0;
  ia->cap = 0;
  ia->data = NULL;
}

int *intarray_grow_array(int *ia, int newcap) {
  void *result = realloc(ia, sizeof(int) * newcap);

  if (result == NULL) {
    perror("could not reallocate array");
    exit(1);
  }

  return (int *)result;
}

void intarray_append(intarray *ia, int elem) {
  if (ia->len == INT_MAX) {
    fprintf(stderr, "uhh, how did you make such a long array, yo?");
    exit(2);
  }

  if (ia->cap < ia->len + 1) {
    int cap = ia->cap;
    ia->cap = INTARRAY_GROW_CAP(cap);
    ia->data = intarray_grow_array(ia->data, ia->cap);
  }

  ia->data[ia->len++] = elem;
}

static int intarray_compare_reverse(const void *a, const void *b) {
  return *(int *)b - *(int *)a;
}

void intarray_sort_descending(intarray *ia) {
  qsort(ia->data, ia->len, sizeof(int), intarray_compare_reverse);
}
