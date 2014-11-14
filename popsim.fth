\
\ Popsim.fs
\
\ Example application using random variables.
\
\ For more details, see the article
\ "Random Variables in Forth", SIGFORTH Newsletter, Vol 3, No 3, December 1991
\
\ NOTE: the formatting and typography in the article don't make the code any
\ easier to understand.
\
\ This code has been adapted to run in gforth (0.7.3) and has been refactored
\ from the version listed in the article.
\
\ Copyright (c) 1991, 2014 Matthew M. Burke <matthew@bluedino.net>

\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:

\ The above copyright notice and this permission notice shall be included in all
\ copies or substantial portions of the Software.

\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.

require rvars.fs


: f+! ( a; F: r -- )
  dup f@ f+ f! ;





5e0              fconstant MAXTIME
6.9e0            fconstant BIRTHS \ per unit time
2.4e0            fconstant DEATHS \ per unit time
BIRTHS DEATHS f+ fconstant LAMBDA \ events/time (Poisson parameter)
BIRTHS LAMBDA f/ fconstant SUCCESS%
10                constant POPULATION0 \ initial population


fvariable time
variable population


\ Posisson parameter for a more realistic (i.e. complicated) model
: LAMBDA' ( -- F: r )
  BIRTHS population @ s>f f*
  DEATHS population @ s>f f* f+ ;


LAMBDA     exponential-var nextevent-simple \ time until next birth/death
SUCCESS% 1 binomial-var eventtype \ 1 = birth, 0 = death

: nextevent-complex ( -- F: r )
    LAMBDA' exponential ;


variable _nextevent

' nextevent-simple _nextevent !

: nextevent ( -- F: r )  _nextevent @ execute ;






\ Only change population if it's non-zero

: adjust-population ( n -- )
    population @ 0> if population +! else drop then ;

: +pop     1 adjust-population ;
: -pop    -1 adjust-population ;




\ Output

\ TODO: gforth doesn't have f.r, figure out alternative
: .report
  time f@ ( 3 9 f.r ) f. population @ 13 .r cr ;


: .heading
  page cr 
  5 spaces ." Time" 3 spaces ." Population" cr 
  5 spaces ." ----" 3 spaces ." ----------" cr ;






: initialize-simulation ( -- )
  POPULATION0 population !
  0e0 time f! 
  .heading .report ;


: advance-time ( -- )
  nextevent time f+! ;


: simulation-ongoing? ( -- f )
  time f@ MAXTIME f< ;



: (sim) ( -- )
    initialize-simulation
    begin 
        advance-time
    simulation-ongoing? while 
            eventtype if +pop else -pop then
            .report
    repeat 
    .report ;




: sim ( -- )
    ['] nextevent-simple _nextevent !
    (sim) ;



: sim' ( -- )
    ['] nextevent-complex _nextevent !
    (sim) ;




