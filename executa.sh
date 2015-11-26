#!/bin/bash

flex -t lexico.l > lexico.c
bison -g -d -v sintatico.y -o sintatico.c
gcc sintatico.c -o simples