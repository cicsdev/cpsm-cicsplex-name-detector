# cpsm-cicsplex-name-detector
## CPSM CICSPlex Name Detector Sample:
The CICSPlex Name Detector Sample program is written in `cobol` utilising the `CPSM API`.

### Purpose:
This is a sample program called SM540API. This program is best used in conjunction with an accompanying 
blog post on [CICSDev](https://developer.ibm.com/cics/2018/06/27/cicsplex-name-detector/). 

The program demonstrates a way of detecting the CICSPlex in use in the CICS region where the program is executed. 
This can be very useful because it negates the need to know what the CICSPlex is called. It means that the days of 
hard coding the CICSPlex name into the program source code, specifically on the CONNECT API command, are now gone. 
Hard coding CICSPlex names is never ideal, and where this was done customers used to have to change the 
source code (to change the CICSPlex name) when moving the code around between Production and Test environments 
and vice versa. This issue is compounded at sites where a multitude of different CICSPlexes are in use.

### Usage:
The program sniffs out the CICSPlex name and returns it in the variable WS-SAVED-CICSPLEXNAME. The program can 
be used stand alone or you can extend it, adding in your own application code to it, after the comment  
"At this point the API program is connected to the correct CICSPLEX and is able to utilise the full CPSM API, you would  
code the rest of the program at this point." 
