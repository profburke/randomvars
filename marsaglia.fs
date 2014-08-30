/* *********************************************** */
/* Program: shuffle.c                              */
/* Date:    091425PST Jan 1997                     */
/* Name:    Alfred A. Aburto Jr.                   */
/* Email:   aburto@nosc.mil, aburto@cts.com        */
/* Place:   San Diego, CA, USA                     */
/* *********************************************** */


\ ************************************
\ Parameters for the mother of random 
\ number generation programs: Mother()
\ ************************************
#65536		=:	m16Long		\ 2^16
$FFFF		=:	m16Mask		\ mask for lower 16 bits
$7FFF        	=:	m15Mask		\ mask for lower 15 bits
$7FFFFFFF	=:	m31Mask		\ mask for 31 bits
4294967295e FCONSTANT	m32Double	\ 2^32-1
#3141592 	=: 	kr

CREATE  mother1 #10 CELLS ALLOT
CREATE  mother2 #10 CELLS ALLOT
1 VALUE mStart 




/* Mother *************************************************************
|  George Marsaglia's The mother of all random number generators
|   producing uniformly distributed pseudo random 32 bit values
|   with period about 2^250.
|  The text of Marsaglia's posting is provided in the file mother.txt
|
|  The arrays mother1 and mother2 store carry values in their
|   first element, and random 16 bit numbers in elements 1 to 8.
|   These random numbers are moved to elements 2 to 9 and a new
|   carry and number are generated and placed in elements 0 and 1.
|  The arrays mother1 and mother2 are filled with random 16 bit
|   values on first call of Mother by another generator.  mStart
|   is the switch.
|
|  Returns:
|   A 32 bit random number is obtained by combining the output of the
|   two generators and returned in *pSeed.  It is also scaled by
|   2^32-1 and returned as a double between 0 and 1
|
|  SEED:
|   The inital value of *pSeed may be any long value
|   In the Forth version Seed is passed in but not passed out.
|
|   Bob Wheeler 8/8/94
*/

-- Here only a double is returned. Seed is not modified.
: Mother ( Seed -- ) ( F: -- r )
	0 0 0 0 0 LOCALS| number number1 number2 'p sNumber Seed |
 	
	mStart /* Initialize motheri with 9 random values the first time */
	   IF	Seed m16Mask AND TO sNumber	/* The low 16 bits */
    		Seed m31Mask AND TO number	/* Only want 31 bits */
		mother1 TO 'p
    		1 #18 DO  number #16 RSHIFT  sNumber #30903 * + DUP TO number
		  	  m16Mask AND DUP TO sNumber 
		  	  'p !  =CELL +TO 'p
		  	  I 9 = IF  mother2 TO 'p  ENDIF
		-1 +LOOP

		/* make carry 15 bits */
    		mother1 DUP  @ m15Mask AND SWAP !
    		mother2 DUP  @ m15Mask AND SWAP !
    		CLEAR mStart
	ENDIF

	/* Move elements 1 to 8 to 2 to 9 */
	mother1 CELL+  mother1 2 CELL[]  8 CELLS MOVE
	mother2 CELL+  mother2 2 CELL[]  8 CELLS MOVE

	/* Put the carry values in numberi */
 	mother1 @ TO number1 
 	mother2 @ TO number2 

	/* Form the linear combinations */
	mother1 2 CELL[] 
	@+ #1941 * +TO number1
	@+ #1860 * +TO number1
	@+ #1812 * +TO number1
	@+ #1776 * +TO number1
	@+ #1492 * +TO number1
	@+ #1215 * +TO number1
	@+ #1066 * +TO number1
	@ #12013 * +TO number1
	
	mother2 2 CELL[] 
	@+ #1111 * +TO number2
	@+ #2222 * +TO number2
	@+ #3333 * +TO number2
	@+ #4444 * +TO number2
	@+ #5555 * +TO number2
	@+ #6666 * +TO number2
	@+ #7777 * +TO number2
	@  #9272 * +TO number2

	/* Save the high bits of numberi as the new carry */
	number1 m16Long / mother1 !
	number2 m16Long / mother2 !
		
	/* Put the low bits of numberi into motheri[1] */
	/* Combine the two 16 bit random numbers into one 32 bit */
 	number1 m16Mask AND DUP mother1 CELL+ ! ( mother1[1] ) #16 LSHIFT
 	number2 m16Mask AND DUP mother2 CELL+ ! ( mother2[1] ) OR ( Seed )

	/* Return a double value between 0 and 1 */
	U>D D>F m32Double F/ ;

