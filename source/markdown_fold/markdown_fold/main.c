//
//  main.c
//  markdown_fold
//
//  Created by Faisal Memon on 02/10/2020.
//

#include <stdio.h>
#include <stdlib.h>

#include "mfold.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        usage();
        return EXIT_SUCCESS;
    }
    char *filename = argv[1];
    FILE *fin = fopen(filename, "r");
    if (fin == NULL) {
        perror(filename);
        return EXIT_FAILURE;
    }
    int result = parse(fin, WIDTH, TAB_LENGTH);
    return result;
}
