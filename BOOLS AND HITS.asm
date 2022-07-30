; MULTI-SEGMENT EXECUTABLE FILE TEMPLATE.

DATA SEGMENT 
                                     ;VARIABLES:
                                     PASS_LENGTH DB 5         ;THE LENGTH OF THE COMPUTER PASSWORD AND USER GUESS   
                                     ACT_LEN DB 0             ;THE ACTUAL LENGTH OF THE COMPUTER PASSWORD 
                                     INPUT DB 5 DUP (?)       ;USER INPUT
                                     BOOL DB 0                ;BOOL CONTER
                                     HIT DB 0				  ;HIT CONTER
									 TRIES DB 0DH			  ;MAX NUMBER OF TRIES  
									 PASSWORD DB 4 DUP(0)	  ;COMPUTER RANDOM NUMBER
                                     TEN DW 0AH               ;USED FOR THE DIVISION FUNCTION  
   
 									 ;MESSAGES: 
                                     START_MSG DB "PLEASE PRESS ENTER TO START THE GAME: $",0DH,0AH  
                                     WAIT_MSG DB "PLEASE WAIT A SECOND WHILE THE COMPUTER CHOOSING NUMBERS $",0DH,0AH
                                     TRY_MSG DB "PLEASE ENTER A NUMBER WITH 4 DIGITS AS YOUR GUESS: $",0DH,0AH  
                                     MID_MSG DB "GUESES LEFT:  $",0DH,0AH 
                                     LOSE_MSG DB "SORRY, YOU LOST! $",0DH,0AH
                                     SHOW_PASSWORD_MSG DB "THE CORRECET PASSWORD WAS: $",0DH,0AH
                                     WIN_MSG DB "CONGRATULATIONS YOU WON $",0DH,0AH
                                     WIN_GUESES_MSG DW ", NUMBER OF TRIES: $",0DH,0AH
                                     WRONG_LENGTH_MSG DW "WRONG INPUT! $",0DH,0AH
                                     BOOLS_HITS_MSG1 DB "YOU HAVE $",0DH,0AH
                                     BOOLS_HITS_MSG2 DB " BOOLS AND  $",0DH,0AH  
                                     BOOLS_HITS_MSG3 DB " HITS $",0DH,0AH 
     
                                     LINE_BREAK DB 10,13,'$'
  
  
  
   
ENDS

STACK SEGMENT
    DW   128  DUP(0)
ENDS

CODE SEGMENT
START:
                                    ; SET SEGMENT REGISTERS:
                                    MOV AX, DATA
                                    MOV DS, AX
                                    MOV ES, AX      
     
                                    ; START OF THE PROGRAM:
                                    MOV DX, OFFSET START_MSG ;PRINT THE START MESSAGE
                                    MOV AH , 9H
                                    INT 21H
    
                                    MOV AH , 7H  ;WAIT FOR USER TO PRESS ENTER
                                    INT 21H
    
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ;PRINT EMPTY LINE
                                    MOV AH , 9H
                                    INT 21H 
                                     
            
                                    XOR DX,DX        
                                    MOV DX, OFFSET WAIT_MSG ;PRINT THE WAIT MESSAGE
                                    MOV AH , 9H
                                    INT 21H
             
           
       
RANDOM_AGAIN:                       MOV AH,2CH ; INSERT THE TIME OF THE COMPUTER TO CX AND DX.
                                    INT 21H 
                                    
                                    ; THIS PART MOVES THE VALUES FROM CX,DX TO THE VARIABLE "PASSWORD"
                                    MOV PASSWORD[0], CH
                                    MOV PASSWORD[1], CL
                                    MOV PASSWORD[2], DH 
                                    MOV PASSWORD[3], DL           
                      
                                    XOR AX,AX  
                                    XOR BX,BX 
MOD10:                              MOV AX, WORD PTR PASSWORD[BX]           
                                    MOV DX,0
                                    DIV TEN
                                    MOV PASSWORD [BX],DL  
                                    CMP BX,0                ;CHECK IF ITS THE FIRST DIGIT.
                                    JNE NEXT                ;IF NOT JUMP TO NEXT
                                    CMP PASSWORD[BX],0      ;CHECK IF THE FIRST DIGIT IS EQUALS TO 0.
                                    INC PASSWORD[BX]        ;AVOID AN ENDLESS LOOP 
                                    JE  MOD10               ;IF IT IS EQUALS TO 0 THEN JUMP TO MOD10.
NEXT:                               CMP PASSWORD[BX],9      ;CHECK IF THE FIRST DIGIT IS BIGGER THEN 9
                                    JA MOD10
                                    INC BX
                                    XOR AX,AX
                                    XOR DX,DX
                                    CMP BX,4
                                    JNE MOD10 
         
                                    ; THIS PART CHECK THAT THERE AREN'T ANY DUPLICATES IN THE COMPUTERS NUMBER.      
                                    XOR DI,DI                 ;RESET DI BECAUSE ITS THE MAIN LOOP COUNTER
                                    MOV BX,DI  
                                    INC BX                    ;SET BX TO START FROM DX+1
DUPLICATES_CHECK:                   MOV CL, PASSWORD[DI]
                                    CMP CL, PASSWORD[BX]      ; COMPAIR THE VALUE OF THE MAIN LOOP WITH THE SECONDARY LOOP. 
                                    JE RANDOM_AGAIN           ; IF THEY ARE EQUAL THEN JUMP TO "RANDOM AGAIN" LABEL.   
                                    CMP BX,4                  ; ELSE: CHECK IF BX EQUALS TO 4.
                                    JE COMPUTER_COUNTER_CHECK ; IF IT IS THEN JUMP TO THE "COMPUTER_COUNTER_CHECK" LABEL.
                                    INC BX                    ; ELSE: INCREASE THE VALUE OF BX.
                                    JMP DUPLICATES_CHECK      ; LOOP AGAIN WITH THE NEW VALUE OF BX.
             
             
COMPUTER_COUNTER_CHECK:             INC DI
                                    MOV BX,DI
                                    INC BX
                                    CMP DI,4
                                    JB DUPLICATES_CHECK       ; LOOP AGAIN WITH THE NEW VALUE OF BX AND DX.
                
 
 
 
           
 ATTEMPT:                           XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK      ;PRINT EMPTY LINE
                                    MOV AH , 9H
                                    INT 21H
 
                                    XOR DX,DX      
                                    MOV DX,OFFSET TRY_MSG           ;PRINT THE TRY MESSAGE
                                    MOV AH,9H
                                    INT 21H
          
                                    ; THIS PART CHECK LENGTH INPUT
                                    XOR DX,DX
                                    MOV DX, OFFSET INPUT    ;RECEIVE INPUT FROM THE USER.
                                    MOV AH , 0AH  
                                    MOV DX,OFFSET PASS_LENGTH
                                    INT 21H     
                                    MOV CL,ACT_LEN
                                    CMP CL,4
                                    JNE TRY_AGAIN           ;IF THE LENGTH OF THE INPUT ISN'T EQUALS TO 4 THEN TRY AGAIN.
              
          
                                    ; CONVERT THE STRING (USER INPUT) TO NUMBERS(ASSUMING THE USER ENTERD NUMBERS ONLY): 
                                    MOV BX,0
 CONVERT:                           SUB BYTE PTR INPUT[BX],30H   ; DECREASE THE '0' OF THE DIGIT SO IT WILL BE CONVERTED TO A NUMBER.
                                    INC BX
                                    CMP BX,3                     ; IF THE COUNTER(BX) >=3
                                    JBE  CONVERT                 ; THEN LOOP AGAIN WITH THE NEW BX VALUE.
             
             
                                    ; THIS PART CHECK THAT THERE AREN'T ANY DUPLICATES IN THE USER INPUT.
                                    XOR DI,DI                 ;RESET DI BECAUSE ITS THE MAIN LOOP COUNTER
                                    MOV BX,DI  
                                    INC BX                    ;SET BX TO START FROM DX+1
SAME_DIGIT_CHECK:                   MOV CL, INPUT[DI]
                                    CMP CL, INPUT[BX]         ; COMPAIR THE VALUE OF THE MAIN LOOP WITH THE SECONDARY LOOP.
                                    JE TRY_AGAIN              ; IF THEY ARE EQUAL THEN JUMP TO "TRY_AGAIN" LABEL.
                                    CMP BX,4                  ; ELSE: CHECK IF BX EQUALS TO 4.
                                    JE COUNTER_CHECK          ; IF IT IS THEN JUMP TO THE "COUNTER_CHECK" LABEL.
                                    INC BX                    ; ELSE: INCREASE THE VALUE OF BX.
                                    JMP SAME_DIGIT_CHECK      ; LOOP AGAIN WITH THE NEW VALUE OF BX.
             
             
COUNTER_CHECK:                      INC DI
                                    MOV BX,DI
                                    INC BX
                                    CMP DI,4
                                    JB SAME_DIGIT_CHECK       ; LOOP AGAIN WITH THE NEW VALUE OF BX AND DX.
               



             
             
START_INPUT_CHECK:                  XOR DI,DI                   ; RESET DI BECAUSE ITS THE MAIN LOOP COUNTER.
                                    XOR BX,BX                   ; RESET BX BECAUSE ITS THE SECOND LOOP COUNTER.  
                                    MOV BOOL,BL                 ; RESET BOOL COUNTER.
                                    MOV HIT,BL                  ; RESET HIT COUNTER.
INPUT_CHECK:                        MOV CL, PASSWORD[DI]        ; MOVE THE DIGIT IN "PASSWORD" IN PLACE DI.
                                    CMP CL, INPUT[BX]           ; MOVE THE DIGIT IN "INPUT" IN PLACE BX.
                                    JNE NEXTLOOP                ; IF THE DIGITS ARE DIFFERNT THEN JUMP TO "NEXTLOOP" LABEL.
                                    CMP BX,DI                   
                                    JE BOOL_INC                 ; IF THE LOOP COUNTERS (BX,DX) ARE THE SAME JUMP TO "BOOL_INC" LABEL.
                                    INC HIT                     ; ELSE: INCREASE THE HIT VALUE.
                                    JMP NEXTLOOP                ; JUMP TO "NEXTLOOP" LABEL.
BOOL_INC:                           INC BOOL                    ; INCREASE THE BOOL VALUE.
      
NEXTLOOP:                           INC BX  
                                    CMP BX,4
                                    JB INPUT_CHECK              ; IF BX IS SMALLER THEN 4 JUMP TO "INPUT_CHECK" LABEL WITH THE NEW VALUE OF BX.
         
      
SECOND_LOOP_CHECK:                  INC DI
                                    XOR BX,BX 
                                    CMP DI,4
                                    JB INPUT_CHECK              ; IF DI IS SMALLER THEN 4 JUMP TO "INPUT_CHECK" LABEL WITH THE NEW VALUE OF BX AND DI.
                   
      
      
      
      
FINISH:                             CMP TRIES,1                 
                                    JE LOSE                      ; IF THE ARE EQUALS TO 0 THEN JUMP TO "LOSE" LABEL.

                                    CMP BOOL,4                  
                                    JE WIN                       ; IF THERE ARE MORE TRIES AND THE USER GUESED ALL THE DIGITS IN THE CORRECT POSITION THEN JUMP TO "WIN" LABEL.


                                                               
                                    DEC  TRIES                   ; IF THERE ARE MORE TRIES AND THE USER DIDNT WIN THEN DECREASE TRIES VALUE.
                                   
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK   ;PRINT EMPTY LINE
                                    MOV AH , 9H
                                    INT 21H  
     
                                    XOR DX,DX
                                    MOV DX,OFFSET  BOOLS_HITS_MSG1 ; PRINT THE FIRST PART OF BOOL AND HITS MESSAGE.
                                    MOV AH,9H
                                    INT 21H
      
                                    XOR DX,DX                      ; THIS PART CONVER TO STRING AND PRINTS THE BOOL VALUE
                                    MOV CL,BOOL
                                    ADD CL,30H
                                    MOV DL,CL
                                    MOV AH,2H
                                    INT 21H
      
                                    XOR DX,DX
                                    MOV DX,OFFSET  BOOLS_HITS_MSG2   ; PRINT THE SECOND PART OF BOOL AND HITS MESSAGE.
                                    MOV AH,9H
                                    INT 21H
           
                                    XOR DX,DX                        ; THIS PART CONVER TO STRING AND PRINTS THE HIT VALUE
                                    MOV DL,HIT                   
                                    ADD DL,30H
                                    MOV AH,2H
                                    INT 21H 
           
                                    XOR DX,DX
                                    MOV DX,OFFSET  BOOLS_HITS_MSG3   ; PRINT THE THIRD PART OF BOOL AND HITS MESSAGE.
                                    MOV AH,9H
                                    INT 21H
           
TRIES_MSG:                          XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ;PRINT EMPTY LINE
                                    MOV AH , 9H
                                    INT 21H 
           
                                    XOR DX,DX 
                                    MOV DL,OFFSET MID_MSG      ; PRINT THE GUESES LEFT MESSAGE.
                                    MOV AH,9H
                                    INT 21H 
           
                                    XOR DX,DX                  ; THIS PART CONVER TO STRING AND PRINTS THE TRIES VALUE
                                    JMP HEX_TO_DEC
RESUME:                             MOV DL,BL 
                                    MOV AH,2H
                                    INT 21H
                    
                    
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ;PRINT EMPTY LINE
                                    MOV AH , 9
                                    INT 21H         
                    
                                    JMP ATTEMPT                ;JUMP TO "ATTEMPT" LABEL.
      
      
                                    ; THIS PART IS CALLED ONLY IF THERE ARE 4 BOOLS: 
WIN:                                XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO START THE MESSAGE IN A NEW LINE
                                    MOV AH , 9h
                                    INT 21H
            
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO CREATE AN EMPTY LINE BETWEEN THE WIN MESSAGE AND THE REST OF THE LINES.
                                    MOV AH , 9h
                                    INT 21H  
                                   
                                    XOR DX,DX
                                    MOV DL,OFFSET WIN_MSG      ; PRINT THE WIN MESSAGE.
                                    MOV AH,09H
                                    INT 21H
                                   
                                    XOR DX,DX
                                    MOV DX,OFFSET WIN_GUESES_MSG ; PRINT THE NUMBER OF GUESES UNTILL WIN MESSAGE.
                                    MOV AH,09H
                                    INT 21H 
                                    
                                    ; THIS PART CALCULATE THE NUMBER OF GUESES THE USER TRIED.
                                    XOR DX,DX
                                    MOV DL,0DH           
                                    SUB DL, TRIES
                                    ADD DL,31H
                                    MOV AH,02H
                                    INT 21H 
                                    
                                    JMP EXIT                    ; JUMP TO THE END OF THE PROGRAM.
              

      
LOSE:                               XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO START THE MESSAGE IN A NEW LINE.
                                    MOV AH , 9h
                                    INT 21H 
                                   
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO CREATE AN EMPTY LINE BETWEEN THE LOSE MESSAGE AND THE REST OF THE LINES.
                                    MOV AH , 9h
                                    INT 21H
                        
                                    XOR DX,DX
                                    MOV DL,OFFSET LOSE_MSG     ; PRINT THE LOSE MESSAGE.
                                    MOV AH,09H
                                    INT 21H
                                    
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO START THE MESSAGE IN A NEW LINE.
                                    MOV AH , 9h
                                    INT 21H
                                     
                                    XOR DX,DX
                                    MOV DL,OFFSET SHOW_PASSWORD_MSG ; PRINT THE CORRECT PASSWORD MESSAGE.
                                    MOV AH,09H
                                    INT 21H
                                    
                                    XOR DX,DX  
                                    XOR BX,BX
PRINT:                              MOV DL,PASSWORD[BX]             ; INSERT THE DIGIT THAT LOCATES IN PASSWORD ACCORDING TO BX VALUE.
                                    ADD DL,30H                      ; CONVERT THE DIGIT TO CHAR AND PRINT IT.
                                    MOV AH,02H
                                    INT 21H
                                    INC BX
                                    CMP BX,4                        ; IF BX VALUE IS SMALLER THEN 4
                                    JB PRINT                        ; THEN LOOP AGAIN WITH THE NEW VALUE OF BX.
                                           
                                    JMP EXIT                        ; JUMP TO THE END OF THE PROGRAM.
                    
TRY_AGAIN:                          CMP TRIES,1  ;  IF THERE ARE NO MORE TRIES THEN THE USER LOSE.
                                    JE LOSE
                                    
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO START THE MESSAGE IN A NEW LINE
                                    MOV AH , 9h
                                    INT 21H
                                    
                                    XOR DX,DX
                                    MOV DX,OFFSET WRONG_LENGTH_MSG     ; PRINT THE WRONG_LENGTH MESSAGE.
                                    MOV AH,09H
                                    INT 21H
                                    
                                    XOR DX,DX        
                                    MOV DX, OFFSET  LINE_BREAK ; PRINT EMPTY LINE TO START THE MESSAGE IN A NEW LINE
                                    MOV AH , 9h
                                    INT 21H
                                                                      
                                    JMP ATTEMPT 
           
           
            
                                    ; THIS PART CONVERT HEXADECIMAL DIGITS TO DECIMAL DIGITS.
HEX_TO_DEC:                         MOV BL, TRIES
                                    CMP BL, 0H
                                    JBE  LOSE
                                    CMP BL, 9H
                                    JA A_9              ; JUMPS ONLY IF NOT 0 TO 9.
                                    ADD BL, 30H         ; ADD 30H TO THE NUMERIC VALUE 0 TO 9 SO IT WILL BE PRINTED OUT AS A DIGIT.
                                    JMP RESUME

                                    ; GETS HERE IF IT'S A TO F CASE:
A_9:                                XOR DX,DX
                                    MOV DL,31H  ;INSERT '1' TO DX AND PRINT IT.
                                    MOV AH,02H
                                    INT 21H 
                                    
                                    ; THIS PART CONVERT CHAR 'A' TO 'F' TO NUMERIC VALUE MINUS 10.
                                    SUB BL, 0AH    ; SUBSTRUCT THE A TO F VALUE BY A.
                                    ADD BL,30H     ; ADD 30H TO THE RESULT SO IT WILL BE PRINTED OUT AS A DIGIT.     
                                    JMP RESUME     ; JUMP TO "RESUME" LABEL.       
                           
                         

    
EXIT:  MOV AX, 4C00H ; EXIT TO OPERATING SYSTEM.
    INT 21H    
ENDS

END START ; SET ENTRY POINT AND STOP THE ASSEMBLER.
