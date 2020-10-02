//
//  test_mfold.c
//  markdown_fold_test
//
//  Created by Faisal Memon on 02/10/2020.
//

#include <assert.h>

#include "mfold.h"
#include "test_mfold.h"

void
test_strlen_with_tabs() {
    fprintf(stdout, "test_strlen_with_tabs()\n");
    assert(strlen_with_tabs(NULL, 0) == 0);
    assert(strlen_with_tabs("", 4) == 0);
    assert(strlen_with_tabs("\n", 4) == 0);
    assert(strlen_with_tabs("a", 4) == 1);
    assert(strlen_with_tabs("\t", 1) == 1);
    assert(strlen_with_tabs("\t", 4) == 4);
    assert(strlen_with_tabs("\t", 8) == 8);
}

void
test_fold_string() {
    fprintf(stdout, "test_fold_string()\n");
    fold_string(NULL, 0, 0);
}
