* Dictionary containing single items can be converted to table using enlist.
    enlist `s1`v`s2!(`f;60;`t);
  It's long form will be:
    flip enlist each `s1`v`s2!(`f;60;`t);

* flip can be used to convert a mixed list into a list based on index.
    flip ((`g;70;`r);(`h;80;`s);(`i;90;`t)) /- (`g`h`i;70 80 90j;`r`s`t)