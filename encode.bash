#!/bin/bash

sed -e 's/%\([A-Fa-f0-9]\{2\}\)/\\x\1/g'