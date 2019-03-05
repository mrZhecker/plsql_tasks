CREATE OR REPLACE FUNCTION GSM2ASCII(INC_STRING_ARGUMENT VARCHAR2, CONCAT_OR_NOT NUMBER) RETURN VARCHAR2  --1 for concatenated type
AS 
    i number; q number; -- iterators
    chr_code number;
    to_bin_next_digit number;
    to_bin_result VARCHAR2(20);
    current_piece VARCHAR(7);
    oct_string VARCHAR(4000);
    result VARCHAR(4000);
BEGIN
    result := ''; current_piece := '';
    oct_string := '';
    FOR i in REVERSE 1..length(INC_STRING_ARGUMENT) / 2 
    LOOP 
        current_piece := substr(INC_STRING_ARGUMENT, i * 2 - 1, 2);
        q := to_number(current_piece, rpad('x', length(current_piece), 'x'));
        WHILE q > 0
        LOOP
            to_bin_next_digit := MOD(q, 2);
            to_bin_result := TO_CHAR(to_bin_next_digit) || to_bin_result;
            q := FLOOR(q / 2);
        END LOOP;
        WHILE length(to_bin_result) < 8 LOOP to_bin_result := '0' || to_bin_result; END LOOP;
        IF i = 1 THEN
            BEGIN
                IF CONCAT_OR_NOT = 1 THEN to_bin_result := substr(to_bin_result, 1, length(to_bin_result) - 1); 
                ELSE oct_string := oct_string || to_bin_result;
                END IF;
            END;
            ELSE BEGIN oct_string := oct_string || to_bin_result; to_bin_result := ''; END;
        END IF;
    END LOOP; 
    WHILE length(oct_string) > 0
    LOOP
        IF length(oct_string) > 7 THEN current_piece := substr(oct_string, length(oct_string) - 6, 7); 
        ELSE 
            BEGIN
                current_piece := oct_string;
                WHILE length(current_piece) < 7 LOOP current_piece := '0' || current_piece; END LOOP;
            END;
        END IF;
        oct_string := substr(oct_string, 1, length(oct_string) - 7);
        chr_code := 0; q := 1;
        WHILE q < 8 LOOP chr_code := (chr_code * 2) + to_number(substr(current_piece, q, 1)); q := q + 1; END LOOP;
        result := result || chr(chr_code);
    END LOOP;
    IF CONCAT_OR_NOT = 1 THEN
        BEGIN
            chr_code := 0; q := 1;
            WHILE q < 8 LOOP chr_code := (chr_code * 2) + to_number(substr(to_bin_result, q, 1)); q := q + 1; END LOOP;
            result := chr(chr_code) || result; 
        END;
    END IF;
    RETURN result; 
END; 