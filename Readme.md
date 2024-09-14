# Computer architecture course laboratory assignments(Vilnius university 2020, Autumn semester)

## Initialization
```bash
make init
```
## Dosbox
To setup dosbox you need to enter these commands:
```bash
make run PROJECT='lab1' # or some other lab name
```
## Compile Assembly code
```bash
yasm programName.asm -o programName.com
programName.com
```
## Assignments

### Laboratory work 1
Given line and 3 numbers get:
- Swap 4th and 8th symbols, and make 2nd symbol '%'.
- From given string line calculate sum of every single char 2nd, 3rd and 8th bits.
- Calculate $|a-15| + |b\%15-10| + \max(c\%10,b\%10)$ value.
### Laboratory work 2
- Enter file name and output file name:

```bash
lab2.com duom.csv
output.csv
```
and print out only those lines, where 2 field does not contain letters 'A' and 'B', and sum of 3rd, 4th and 5th digits sum is 7.
### Laboratory work 3
Write a resident program that modifies the operation of the int 21h, 3Fh function so that the file is read in bytes, i.e., instead of caching a sequence of bytes in a specified buffer, the function reads a single byte from the file (BX) and returns it to the DL register.
### Laboratory work 4
Optional laboratory assignment, working with graphics on assembly (exit the program with esc key).

- circle.asm
Draws the red circle:
![Circle](/images/Circle.png)
- elipse.asm
Given height and width parameters draws elipse:
![Ellipse](/images/Ellipse.png)
- nSides.asm
Given how many sides polygon will have draws n-sided polygon:
![NSides](/images/Nsides.png)
- triangle.asm
Given how many sides polygon have and after the vertice coordinates are entered, draws n sided polygon:
![Triangle](/images/Triangle.png)