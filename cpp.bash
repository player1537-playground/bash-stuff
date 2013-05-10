#!/bin/bash
#define cpp #
cpp $0 2>/dev/null | /bin/bash; exit $?
#undef cpp
#define HELLO_WORLD echo "hello, world"
HELLO_WORLD | tr a-z A-Z
#include "blah.bash"
