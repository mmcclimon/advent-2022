#include <stdio.h>
#include <stdlib.h>

#include "intarray.h"

int compare(const void *a, const void *b) { return *(int *)b - *(int *)a; }

FILE* open_file(char *filename) {
  FILE *fp = fopen(filename, "r");
  if (fp == NULL) {
    perror("could not open input");
    exit(1);
  }

  return fp;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    char *progname = argv[0];
    fprintf(stderr, "usage: %s <input-file>\n", progname);
    exit(1);
  }

  FILE* fp = open_file(argv[1]);
  ssize_t read;
  char *line = NULL;
  size_t line_len = 0;

  int this_elf = 0;
  intarray elves;
  intarray_init(&elves);

  while ((read = getline(&line, &line_len, fp)) != -1) {
    if (read == 1) {
      intarray_append(&elves, this_elf);
      this_elf = 0;
      continue;
    }

    int n = atoi(line);
    this_elf += n;
  }

  // pick up the last elf
  intarray_append(&elves, this_elf);

  qsort(elves.array, elves.len, sizeof(int), compare);

  printf("part 1: %d\n", elves.array[0]);
  printf("part 2: %d\n", elves.array[0] + elves.array[1] + elves.array[2]);
}
