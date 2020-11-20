/*
  irq and exception handling
  Written by Ben M. Sutter
  Available since version 0.2.0
  Last edited 11/19/2020
*/

#include <stdint.h>
#include "kscreen.h"

void exc0_handler(void) {
  print_string("ERROR: Divide by zero");
}
