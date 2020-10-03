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
test_contribution_from_tab() {
    fprintf(stdout, "test_contribution_from_tab()\n");
    assert(contribution_from_tab(0, 0) == 0);
    assert(contribution_from_tab(0, 8) == 8);
    assert(contribution_from_tab(1, 8) == 7);
    assert(contribution_from_tab(7, 8) == 1);
    assert(contribution_from_tab(8, 8) == 8);
}

void
test_visual_len_with_tabs() {
    fprintf(stdout, "test_visual_len_with_tabs()\n");
    assert(visual_len_with_tabs(NULL, 0) == 0);
    assert(visual_len_with_tabs("", 4) == 0);
    assert(visual_len_with_tabs("\n", 4) == 0);
    assert(visual_len_with_tabs("a", 4) == 1);
    assert(visual_len_with_tabs("\t", 1) == 1);
    assert(visual_len_with_tabs("\t", 4) == 4);
    assert(visual_len_with_tabs("\t", 8) == 8);
}

void
test_fold_string() {
    fprintf(stdout, "test_fold_string()\n");

    
    /*
     0000200    x   x   x   x   x   x   x   x   x   x   x   x   x  \n   0
     0000220            l   i   b   s   y   s   t   e   m   _   k   e   r   n
     0000240    e   l   .   d   y   l   i   b
     0000260   \t   0   x   2   5   7   2   e   c   5   c       _   _   p   t
     0000300    h   r   e   a   d   _   k   i   l   l       +       8  \n   1
     0000320                a   n   o   t   h   e   r       l   i   n   e  \n
     0000340    `   `   `  \n
     */
    char *candidate=
    "0   libsystem_kernel.dylib        \t0x2572ec5c __pthread_kill + 8\n";
    fold_string(candidate, 65, 8);
    
    fold_string(NULL, 0, 0);
}
