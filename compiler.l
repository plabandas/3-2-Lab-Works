%{
#include <stdio.h>
#include <string.h>

int total_keywords = 0;
int total_identifiers = 0;
int total_numbers = 0;
int total_special_chars = 0;
int current_line = 1;
int total_comments = 0;
int total_integers = 0;
int total_floats = 0;
int total_operators = 0;
int total_datatypes = 0;
int total_delimiters = 0;
int total_strings = 0;
int total_errors = 0;

FILE *output_file;
%}

%option noyywrap

DIGIT          [0-9]
LETTER         [A-Za-z_]
STRING         \"[^\"]*\"
IDENTIFIER     {LETTER}({LETTER}|{DIGIT})*
FLOAT          {DIGIT}+"."{DIGIT}+
INTEGER        {DIGIT}+
OPERATOR       [+\-*/=<>!&|]
DELIMITER      [,\(\)\[\]\{\}]
SPECIAL_CHAR   [\*;:\%\'\?]
DATATYPE       whole|decimal|character|text
KEYWORD        loop|begin|condition|change|if|write|read|return|stop|start|end|add|subtract|multiply|divide|modulus|true|false|again|then|otherwise|not|sin|cos|tan|max|min
SLC            "//".*
MLC            "/\*"([^*]|\*+[^*/])*\*+"/"

%%

\n                  { current_line++; }
[ \t\r]+             { }

{KEYWORD}           {
                          total_keywords++;
                          fprintf(output_file, "[line %3d] => Keyword          : %s\n", current_line, yytext);
                        }

{DATATYPE}          {
                          total_datatypes++;
                          fprintf(output_file, "[line %3d] => Data Type        : %s\n", current_line, yytext);
                        }

{SLC}              {
                          total_comments++;
                          fprintf(output_file, "[line %3d] => Single-line Comment : %s\n", current_line, yytext);
                        }

{MLC}              {
                          total_comments++;
                          fprintf(output_file, "[line %3d] => Multi-line Comment  : %s\n", current_line, yytext);
                        }

{IDENTIFIER}          {
                          total_identifiers++;
                          fprintf(output_file, "[line %3d] => Identifier       : %s\n", current_line, yytext);
                        }

{STRING}           {
                          total_strings++;
                          fprintf(output_file, "[line %3d] => String Literal   : %s\n", current_line, yytext);
                        }

{FLOAT}         {
                          total_numbers++;
                          total_floats++;
                          fprintf(output_file, "[line %3d] => Floating Number  : %s\n", current_line, yytext);
                        }

{INTEGER}          {
                          total_numbers++;
                          total_integers++;
                          fprintf(output_file, "[line %3d] => Integer Number   : %s\n", current_line, yytext);
                        }

'[^']'              {
                          fprintf(output_file, "[line %3d] => Character Literal : %s\n", current_line, yytext);
                        }

{SPECIAL_CHAR}       {
                          total_special_chars++;
                          fprintf(output_file, "[line %3d] => Special Character : %s\n", current_line, yytext);
                        }

{DELIMITER}         {
                          total_delimiters++;
                          fprintf(output_file, "[line %3d] => Delimiter        : %s\n", current_line, yytext);
                        }

{OPERATOR}     {
                          total_operators++;
                          fprintf(output_file, "[line %3d] => Operator         : %s\n", current_line, yytext);
                        }

.                       {
                          total_errors++;
                          fprintf(output_file, "ERROR: Unrecognized token '%s'\n", yytext);
                        }


%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <source_file>\n", argv[0]);
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        printf("Error: Cannot open input file %s\n", argv[1]);
        return 1;
    }

    output_file = fopen("analysis_output.txt", "w");
    if (!output_file) {
        printf("Error: Cannot open output file analysis_output.txt\n");
        fclose(input_file);
        return 1;
    }

    yyin = input_file;
    yylex();

    fprintf(output_file, "\nMy Lexical Analysis:\n");
    fprintf(output_file, "------------------------------------\n");
    fprintf(output_file, "Total Lines Processed: %d\n", current_line);
    fprintf(output_file, "------------------------------------\n");
    fprintf(output_file, "Total Errors Found   : %d\n", total_errors);
    fprintf(output_file, "Total Keywords       : %d\n", total_keywords);
    fprintf(output_file, "Total Identifiers    : %d\n", total_identifiers);
    fprintf(output_file, "Total Numbers        : %d\n", total_numbers);
    fprintf(output_file, "   -> Integers       : %d\n", total_integers);
    fprintf(output_file, "   -> Floats         : %d\n", total_floats);
    fprintf(output_file, "Total Strings        : %d\n", total_strings);
    fprintf(output_file, "Total Operators      : %d\n", total_operators);
    fprintf(output_file, "Total Delimiters     : %d\n", total_delimiters);
    fprintf(output_file, "Total Special Chars  : %d\n", total_special_chars);
    fprintf(output_file, "Total Datatypes      : %d\n", total_datatypes);
    fprintf(output_file, "Total Comments       : %d\n", total_comments);
    fprintf(output_file, "------------------------------------\n");

    fclose(input_file);
    fclose(output_file);
    return 0;
}
