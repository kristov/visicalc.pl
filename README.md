# `visicalc.pl`

A simple calculator where you can mix bin, hex and dec values in expressions. Do you want to know the result of `12 + 0b0100 - 0x0a`?

*DISCLAIMER*: I put zero thought into the name - at the time I was watching a nice video about how [VisiCalc](https://en.wikipedia.org/wiki/VisiCalc) came to be, so the name was in my mind. I like the name because it reminds me of the awesome history of computing, "citizen programming" and how the spreadsheet evolved into the ultimate "No Code" software that it is today. I hope it's plainly obvious that this Perl script has absolutely nothing to do with VisiCalc or spreadsheets in general. It is not an attempt to score higher in searches or anything like that. If it offends thee I am sorry. Read up about the amazing work of [Dan Bricklin](https://en.wikipedia.org/wiki/Dan_Bricklin) and [Bob Frankston](https://en.wikipedia.org/wiki/Bob_Frankston) in revolutionizing the world with VisiCalc.

This script came about because I was doing assembly programming, and I needed to be able to switch freely between binary, hexadecimal and decimal. I was using multiple browser tabs pointing to the awesome tools at [www.rapidtables.com](https://www.rapidtables.com), but I decided I wanted something more local. I could not find any decent GUI calculator that let me freely mix numbers expressed in different bases, nor one that would conveniently give me a result in all bases. So I spent all of an hour writing this.

When you run the program it presents a prompt "> ". You type in an expression and hit enter to evaluate it. The expression is in "infix" notation (eg: "3 + 1" not "+ 3 1"). There must always be one less operator than there are numbers. The evaluation proceeds from left to right, picking up an operator-number pair and performing that operation on the preceding result (or the first number) and the number. For example:

    1 + 3 - 2 + 5

Is evaluated like this:

    (1 + 3 = 4) --> (4 - 2 = 2) --> (2 + 5 = 7)
             |       |       |       |
             |__res__|       |__res__|

So normal "operator precedence" rules do not apply. It behaves a bit like a simple physical calculator would. Note: the prompt does not behave like a real shell - arrow keys do not work, Ctrl-e does not work, there is no history. Only backspace works. You can backspace over the prompt. No warranty. Very importantly the script does not have any dependencies except the Perl interpreter, and it never will. Save it to your "bin" folder and go nuts. You can probably maybe even run it in Windows somehow.

## Output

The first thing the calculator does is parse all the numbers and print what it found as a list of "values". Each value is shown in the three bases: hex, bin and dec. For example:

	> 10 + 20
	values:
	  hex: 0xa  bin: 0b1010  dec: 10
	  hex: 0x14  bin: 0b10100  dec: 20

It then prints each step in the evaluation as a list of operations, showing the intermediate results in the three bases:

	operations:
	  [ 10 + 20 ] == hex: 0x1e  bin: 0b11110  dec: 30

This makes it easy to copy intermediate and final results in whatever base representation you need. The most important feature for me was being able to freely mix different formats in input:

	> 12 + 0b0100 - 0x0a
	values:
	  hex: 0xc  bin: 0b1100  dec: 12
	  hex: 0x4  bin: 0b100  dec: 4
	  hex: 0xa  bin: 0b1010  dec: 10

	operations:
	  [ 12 + 4 ] == hex: 0x10  bin: 0b10000  dec: 16
	  [ 16 - 10 ] == hex: 0x6  bin: 0b110  dec: 6
	>

I don't know what happens with floating point numbers or negative numbers... I consider the program behavior to be "undefined". You can not input them, but they can happen as a result of evaluation.

## Input formats

The following input formats are supported:

    Example     Type            Description

    0xaF01      Hexadecimal     Anything beginning "0x" is hex
    $aF01       Hexadecimal     Numbers and letters beginning "$" is hex
    0b0101      Binary          Ones and zeros beginning "0b" is binary
    b0101       Binary          Ones and zeros beginning "b" is binary
    0101b       Binary          Ones and zeros ending in "b" is binary
    %0101       Binary          Ones and zeros beginning "%" is binary
    123         Decimal         If only numbers then decimal

Supported operators are "-", "+", "/" and "\*". As mentioned, beware of making negative numbers or floating point numbers - undefined behavior!

## Evaluation

The input string is scanned. Anything matching one of the numbers is converted into "decimal" (in Perl, a string basically) and pushed onto the "values" stack. Any operators are pushed onto the "ops" stack. For each operator we shift two values from the values stack, perform the operation and put the result back on the values stack.

After a line of input is evaluated, the values stack still contains the result of the previous operation. This means you can do this:

	> 10 + 20
	values:
	  hex: 0xa  bin: 0b1010  dec: 10
	  hex: 0x14  bin: 0b10100  dec: 20

	operations:
	  [ 10 + 20 ] == hex: 0x1e  bin: 0b11110  dec: 30
	> + 50
	values:
	  hex: 0x1e  bin: 0b11110  dec: 30
	  hex: 0x32  bin: 0b110010  dec: 50

	operations:
	  [ 30 + 50 ] == hex: 0x50  bin: 0b1010000  dec: 80

Actually, you can even do tricks like this:

	> 10
	values:
	  hex: 0xa  bin: 0b1010  dec: 10
	> 20
	values:
	  hex: 0xa  bin: 0b1010  dec: 10
	  hex: 0x14  bin: 0b10100  dec: 20
	> 30
	values:
	  hex: 0xa  bin: 0b1010  dec: 10
	  hex: 0x14  bin: 0b10100  dec: 20
	  hex: 0x1e  bin: 0b11110  dec: 30
	> +
	values:
	  hex: 0xa  bin: 0b1010  dec: 10
	  hex: 0x14  bin: 0b10100  dec: 20
	  hex: 0x1e  bin: 0b11110  dec: 30

	operations:
	  [ 10 + 20 ] == hex: 0x1e  bin: 0b11110  dec: 30
	> +
	values:
	  hex: 0x1e  bin: 0b11110  dec: 30
	  hex: 0x1e  bin: 0b11110  dec: 30

	operations:
	  [ 30 + 30 ] == hex: 0x3c  bin: 0b111100  dec: 60

If you get in a bind you can enter "r" or "R" or "c" or "C" to completely wipe the values and operations stacks (the first character in the line just needs to be and "r" in upper or lower case, so "Rabbit" also resets, as does "roundhousekick", as does "Chicken").
