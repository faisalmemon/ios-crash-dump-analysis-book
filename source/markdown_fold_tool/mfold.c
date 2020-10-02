#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#define TAB_LENGTH 4
#define WIDTH 66
#define BUFFER_SIZE 2048

void
usage() {
    fprintf(stdout, "Usage: mfold filename\n");
    return;
}

int
strlen_with_tabs(char *source, int tab_length) {
    int n_tabs = 0;
    char *letter = source;
    while (*letter) {
	if (*letter == '\t') {
	    n_tabs++;
	}
	letter++;
    }
    int length = strlen(source);
    
    // extra contribution from tabs
    if (tab_length > 1) {
	length += n_tabs * (tab_length - 1);
    }

    // don't count trailing newline
    length -= 1;

    return length;
}

void
fold_string(char *string, int width, int tab_length) {
    int col_pos = 0;
    char *current_char = string;
    int ws_pos = 0;

    while (*current_char) {
	if (*current_char == '\n') {
	    break;
	} else if (col_pos > width) {
	    break;
	} else if (*current_char == '\t') {
	    ws_pos = col_pos;
	    col_pos += tab_length;
	} else if (*current_char == ' ') {
	    ws_pos = col_pos;
	    col_pos++;
	} else {
	    col_pos++;
	}
    }
    char *dup = strndup(string, current_char - string);
    assert(dup);
    fprintf(stdout, "%s\n", dup);
    free(dup);
    if (*current_char != '\0') {
	fold_string(current_char, width, tab_length);
    }
}

int
parse(FILE *fin, int width, int tab_length) {
    bool inside_verbose_block = false;
    char buffer[BUFFER_SIZE];
    char *current_string = NULL;
    int line_length = 0;

    fprintf(stderr, "Read line buffer is %zu\n", sizeof(buffer));

    while ((current_string = fgets(buffer, sizeof(buffer), fin)) != NULL) {
	if (strncmp(current_string, "```", 3) == 0) {
	    fprintf(stderr, "Found verbose backticks\n");
	    inside_verbose_block = !inside_verbose_block;
	}
	if (inside_verbose_block) {
	    line_length = strlen_with_tabs(current_string, tab_length);
	    if (line_length <= width) {
		fprintf(stdout, "%s", current_string);
	    } else {
		fold_string(current_string, width, tab_length) {
	    }
	} else {
	    fprintf(stdout, "%s", current_string);
	}
    }
    return EXIT_SUCCESS;
}

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
