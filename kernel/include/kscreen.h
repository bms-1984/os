/*
  Architecture-agnostic kernel-level screen interface
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/5/2020
*/

#include "bootboot.h"

#ifndef KSCREEN_H
#define KSCREEN_H

extern BOOTBOOT bootboot;
void print_string(const char *s);

#endif
