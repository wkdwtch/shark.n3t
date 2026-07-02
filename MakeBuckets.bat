@echo off
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z #) do (
    mkdir "%%A" 2>nul
)
echo Master Alphabet Folders Created!
pause