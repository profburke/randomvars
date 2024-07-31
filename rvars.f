\
\ Rvars.fs
\
\ Generate random numbers with various distributions.
\
\ For more details, see the article
\ "Random Variables in Forth", SIGFORTH Newsletter, Vol 3, No 3, December 1991
\
\ This code has been adapted to run in gforth (0.7.3)
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

require random.fs



\ Generate a uniformly distributed floating point number in the range [0, 1].
\ From:  http://rosettacode.org/wiki/Random_numbers#Forth
here seed !
-1. 1 rshift 2constant MAX-D


: uniform ( -- r )
    rnd rnd dabs d>f 
    MAX-D d>f f/ ;



8 constant F#BYTES 


\
\ Random number generators with various distributions.
\
\ NOTE: the quality of the random numbers depends on the
\ quality of the uniform generator as well as other factors.
\ Consult your local statistician or similarly-qualifed expert
\ before using this code for anything of any consequence!
\


\ stack holds parameter of the exponential distribution
: exponential ( F: r1 -- F: r2 )
    uniform fln fnegate fswap f/ ;


\ stack holds the Poisson parameter; it should be negative
: poisson ( F: r1 -- F: r2 )
    0 fexp 1.0
    begin 
        uniform f* fover fover f<
    while 1+ repeat 
    fdrop fdrop ;


\ (fp) stack holds the percent chance of success in a single trial
\ stack holds the number of trials
: binomial ( F: r; n1 -- n )
    0 swap 
    0 do 
        uniform fover f< if 1+ then
    loop 
    fdrop ;


\ stack holds the mean and the standard deviation
: normal ( F: r1 r2 -- F: r )
    0.0 
    12 0 do 
        uniform f+
    loop 
    6.0 f- f* f+ ;


\ This defining word creates a word which
\ maps a float from [0, 1] to [a, b]
: scale ( F: a b-a -- )
    create f, f,
  does> dup f@ f*  F#BYTES + f@ f+ ;


\ stack holds the execution token of the scaling word
\ and the execution token of a word that computers g(x)/m
\ (i.e. computes a scaled value from the desired distribution)
: rejection ( x1 x2 -- F: r )
    begin
        uniform uniform
        over execute fswap fover dup execute f>=
    while fdrop repeat 2drop ;




\
\ Defining words for creating random variables with
\ various distributions.
\
\ Each of these defining words take the same parameters as
\ their corresponding generator. The parameters are stored in
\ the dictionary entry of the word being created.
\
\ The action performed by the newly created word is to put
\ its paramters on the stack and invoke the appropriate
\ generator.
\


: exponential-var
    create f,
  does> f@ exponential ;


: poisson-var
    create f,
  does> f@ poisson ;


: binomial-var
    create f, ,
  does> dup f@ F#BYTES + @ binomial ;


: normal-var
    create f, f,
  does> dup f@ F#BYTES + f@ normal ;


\ TODO: why do I swap the parameters? why not
\ just put them on the stack in the correct order?
: rejection-var
    create , ,
  does> dup @ >r 2 + @ r> rejection ;

