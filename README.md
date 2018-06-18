# cpsm-cicsplex-name-detector
Programmatically determine the name of a CICSPlex.
This is a sample program called SM540API that accompanies a blog posted on CICSDev (   ).
The purpose of the program is to demonstrate that you do not need to hard code
a CICSPlex name into your program, and doing so means that every time you move the
source from (say) Production to Test (or vice versa) the code has to be changed to reflect
the CICSplex in use. Instead if this code is executed in a CICS region attached to the CICSPlex
the name of the CICSPlex is sniffed out and returned in variable WS-SAVED-CICSPLEXNAME. The
 program can be used stand alone or you can extend it adding in your application code after the
 comment  "At this point the API program is connected to the correct CICSPLEX and is able to
 utilise the full CPSM API, you would  code the rest of the program at this point." 
