#!/bin/csh
## How to use
# ./dfn.csh initial_datafile end_datafile
# ./dfn.csh 6 63

@ i = $1
while ($i <= $2) 
  echo $i
  rman target / cmdfile dfn.rman $i
  @ i += 1
end

