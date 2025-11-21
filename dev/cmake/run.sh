#!/bin/sh



BATTALIONSCOREDIR="$(dirname "$0")"
export BATTALIONSCOREDIR

# Set AddressSanitizer suppression file
SUPP_PATH="$(pwd)/battalion.supp"
export LSAN_OPTIONS="suppressions=${SUPP_PATH}:print_suppressions=1"

# ./battalion
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes -s -- ./battalion
