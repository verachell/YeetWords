# YeetWords
## a domain-specific language for text substitution

YeetWords is a domain-specific language for text substitution, and is suitable for programming generative fiction such as NaNoGenMo projects. It is aimed at complete beginners and up.

It is implemented in Ruby, although the YeetWords syntax does not resemble Ruby, nor is any Ruby knowledge necessary for use.

Here is the [Quickstart Tutorial](https://github.com/verachell/YeetWords/wiki/QuickStart-Tutorial) and here is the [full Wiki](https://github.com/verachell/YeetWords/wiki)

YeetWords takes your YeetWords code and outputs a text file in Markdown format.

## Contents

[Installation and usage](https://github.com/verachell/YeetWords/blob/main/README.md#installation-and-usage)  
[Overview](https://github.com/verachell/YeetWords/blob/main/README.md#overview)  
[Features](https://github.com/verachell/YeetWords/blob/main/README.md#features)  
[Restrictions](https://github.com/verachell/YeetWords/blob/main/README.md#restrictions)  
[Credits](https://github.com/verachell/YeetWords/blob/main/README.md#credits)  
[License & development info](https://github.com/verachell/YeetWords/blob/main/README.md#license--development-info)  

## Installation and usage

Usage is covered in the tutorial and wiki mentioned above, but the basic approach is:

1. If you don't already have it, install Ruby on your machine (this is covered in the [quickstart tutorial](https://github.com/verachell/YeetWords/wiki/QuickStart-Tutorial))

2. Make sure you have downloaded the ```yeetwords.rb``` file from this repository in your working directory on your computer.

3. (optional) In your working directory, create folders called ```words``` and ```sentences``` which contain your files of words and sentences respectively.

4. Create a file with your YeetWords code

5. Run ```ruby yeetwords.rb yourcodefile.txt``` - it will output a file in Markdown format.

## Overview

Build sentences such as this and have it randomly substitute the words for you:

Feeling \_EMOTION\_, \_PERSON.NAME\_ went to the \_BUILDINGTYPE\_

Make your own data structures - people, cities, or other things.

Create loops, change your vocabulary, kill off characters, add or subtract items to their inventory, and more.

### Features

- Ease of use - designed for complete beginners and up

- Very easy syntax to learn - the format for each line is a command followed by its parameters, which may take the form of a statement. No brackets, braces, or parentheses.

- Loop parameters have some flexibility - user can opt to loop until a certain number of words is reached, or a certain number of cycles

- Strong built-in support for randomization of word selections - your program can create a new story every time!

- Allows user to define their own code blocks

- Automatically reads in words and sentences from certain directories from the user - no need to manually type in desired words within the program

- On the other hand, user is not obligated to provide word and sentence files - the user may instead opt to specify words and sentences entirely within their program (this may be desirable in the case of a user program with a very small vocabulary).

- Good gender support - handles male, female, and non-binary humans, plus genderless robots.

### Restrictions

- Limited to a narrow domain - this is not a general-purpose language

- No math - no ability to use variables which correspond to a number, or for the user to do any type of math

- No conditional logic - no if/then, etc.

## Credits

1.  Nonbinary names - The majority of nonbinary names hard-coded into the program come from [The Blunt Rose](https://bluntrose.com/nonbinary-name-list/).

2.  Male and female names - The male and female names card-coded into the program come from the most popular 1000 names in 2019 from [Popular baby names - Social Security Administration of the United States of America](https://www.ssa.gov/cgi-bin/popularnames.cgi). From this list, less common names were selected for use in this program (from within the 500 - 1000 most common names).

## License & development info
YeetWords is licensed under the GNU GPL 3.0 license. This software was developed and tested by Veronique Chellgren using Ruby v 2.7.0 in a Linux environment. It has also been tested on Ruby v 2.7.2 in a Windows 10 environment.
