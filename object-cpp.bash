#!./objects-parser.bash

source objects.bash
init

NEW_CLASS(testing)
function init():

function foo(a=5):
echo $a
END_CLASS

x=$(allocate_object testing)
call_method $x foo
call_method $x foo 20
