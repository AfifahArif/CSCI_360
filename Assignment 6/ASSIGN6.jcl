//KC03D76A JOB ,'AFIFAH ARIF',MSGCLASS=H
//JSTEP01  EXEC PGM=ASSIST
//STEPLIB  DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
******************************************************************
*                                                                *
*  CSCI 360               ASSIGNMENT 6              SPRING 2020  *
*                                                                *
*  DATE DUE:  03/13/2020                                         *
*  TIME DUE:  11:59 PM                                           *
*                                                                *
*  REGISTERS:                                                    *
*        1 -                                                     *
*        2 - NPTOTAL                                             *
*        3 - RATE                                                *
*        4 - HOURS                                               *
*        5 - DEDUCTIONS                                          *
*        6 - BONUSES                                             *
*        7 - WITHOLD PERCENTAGE(TEMP)                            *
*        8 - ECOUNT                                              *
*        9 - GPTOTAL                                             *
*       10 - CALCULATIONS                                        *
*       11 - WITHHOLD AMOUNT                                     *
*       12 - CALCULATIONS                                        *
*       13 - GPAY(TEMP), NPAY                                    *
*       14 - RETURN REGISTER                                     *
*       15 - BASE REGISTER                                       *
******************************************************************
*
*        COL. 10
*        |     COL. 16
*        |     |
*        v     v
PAYROLL1 CSECT
         USING PAYROLL1,15     ESTABLISH ADDRESSABILITY ON REG 15
*INITIALIZE AND SET RUNNING TOTAL REGISTERS
         SR    2,2             SET R2 TO 0. PURPOSE: NPTOTAL
         SR    8,8             SET R8 TO 0. PURPOSE: EMPLOYEE COUNTER
         SR    9,9             SET R9 TO 0. PURPOSE: TOTAL GPAY
*
         XREAD BUFFER,80       READ WITHHOLDING PERCENT
         XDECI 7,BUFFER        PULL WITHHOLDING PERCENT
*
         XREAD BUFFER,80       BEGIN READING RECORDS
*
LOOP1    BC    B'0100',ENDLOOP1
         LA    8,1(,8)         ADD 1 TO ECOUNTER FOR EVERY LINE READ
*BEGIN PULLING RECORDS, CONVERTING THEM & GETTING READY FOR PRINT LINE
         MVC   NAME(25),BUFFER PULL NAME FROM RECORDS
*
         MVC   ID(6),BUFFER+25 PULL ID FROM RECORDS
*
         XDECI 3,BUFFER+31     CONVERT & MOVE RATE FROM REC TO R3
         XDECO 3,RATE          CONVERT & MOVE RATE INTO PRINT LINE
*
         XDECI 4,0(,1)         CONVERT & MOVE HOURS FROM REC TO R4
         XDECO 4,HOURS         CONVERT & MOVE HOURS INTO PRINT LINE
*
         XDECI 5,0(,1)         CONVERT & MOVE DEDUCT FROM REC TO R5
         XDECO 5,DEDUCT        CONVERT & MOVE DEDUCT INTO PRINT LINE
*
         XDECI 6,0(,1)         CONVERT & MOVE BONUS FROM REC TO R6
         XDECO 6,BONUS         CONVERT & MOVE BONUS INTO PRINT LINE
*EMPLOYEE GROSS PAY(13) = RATE(3)*HOURS(4)-DEDUCTIONS(5)+BONUSES(6)
         LR    11,3            LOAD RATE INTO R11 (TEMP)
         LR    13,4            LOAD HOURS INTO R13
         MR    12,11           MULTIPLICATION (RATE*HOURS)
         SR    13,5            SUBTRACT DEDUCTIONS FROM TOTAL SO FAR
         AR    13,6            ADD BONUS TO TOTAL SO FAR
         XDECO 13,GPAY         CONVERT AND MOVE GPAY INTO PRINT LINE
*TOTAL GROSS PAY(9) += 13
         AR    9,13            ADD INDIVIDUAL GROSS PAY TO RUNNING TOT
*WITHHOLDING AMOUNT(11) = GPAY(13) * WITHHOLDING(7) / 100
         SR    10,10           SET R10 TO 0. PURPOSE: CALCULATIONS
         SR    11,11           SET R11 TO 0. PURPOSE: CALCULATIONS
*
         LR    11,13           LOAD GPAY INTO R11
         MR    10,7            GPAY*WITHHOLDING AMT
         D     10,=F'100'      DIVIDE TOTAL BY 100
         XDECO 11,WHOLD        CONVERT AND MOVE WHOLD INTO PRINT LINE
*WTOTAL(12) += 11
         AR    12,11           ADD INDIVIDUAL WHOLD AMOUNTS
*NETPAY AMOUNT(13) = GPAY(13) - WITHHOLDING AMOUNT(11)
         SR    13,11           SUBTRACT GROSS PAY BY WITHHOLDING AMOUNT
         XDECO 13,NPAY         CONVERT AND MOVE NPAY INTO PRINT LINE
*TOTAL NETPAY (2) = NPAY(13)
         AR    2,13            ADD INDIVIDUAL NET PAY TO RUNNING TOT
*
         XPRNT LINE1,133       PRINT OUTPUT FROM RECORDS
         XREAD BUFFER,80       READ NEXT RECORD
         BC    B'1111',LOOP1   IF MORE RECORDS, BEGIN LOOP
ENDLOOP1 XDECO 8,ECOUNT        COUNT EVERY RECORD AS ONE EMPLOYEE
         XPRNT LINE2,133       PRINT EMPLOYEE OUTPUT
*PRINT DTOTAL
         XDECO 3,DTOTAL       CONVERT AND MOVE GPAY TOT INTO PRNTLINE
         XPRNT LINE3,133       PRINT GROSS TOTAL OUTPUT
*PRINT BTOTAL
         XDECO 3,BTOTAL       CONVERT AND MOVE GPAY TOT INTO PRNTLINE
         XPRNT LINE4,133       PRINT GROSS TOTAL OUTPUT
*PRINT GPTOTAL
         XDECO 9,GPTOTAL       CONVERT AND MOVE GPAY TOT INTO PRNTLINE
         XPRNT LINE5,133       PRINT GROSS TOTAL OUTPUT
*PRINT WTOTAL
         XDECO 12,WTOTAL       CONVERT AND MOVE WHOLD TOT INTO PRNTLINE
         XPRNT LINE6,133       PRINT WHOLD TOTAL OUTPUT
*PRINT NPTOTAL
         XDECO 2,NPTOTAL      CONVERT AND MOVE WHOLD TOT INTO PRNTLINE
         XPRNT LINE7,133       PRINT WHOLD TOTAL OUTPUT
*
         BR    14              RETURN TO PROGRAM
*
         LTORG                 LITERAL ORGANIZATION
*INPUT STORAGE
BUFFER   DS    CL80            RECORD BUFFER
*OUTPUT STORAGE
LINE1    DC    C'0'            CARRIAGE CONTROL
         DC    4C' '           SPACES
NAME     DS    CL25            NAME STORAGE
         DC    4C' '           SPACES
ID       DS    CL6             ID STORAGE
         DC    4C' '           SPACES
RATE     DS    CL8             RATE STORAGE
         DC    4C' '           SPACES
HOURS    DS    CL8             HOURS STORAGE
         DC    4C' '           SPACES
DEDUCT   DS    CL8             DEDUCTION STORAGE
         DC    4C' '           SPACES
BONUS    DS    CL8             BONUS STORAGE
         DC    4C' '           SPACES
GPAY     DS    CL8             GROSS PAY STORAGE
         DC    4C' '           SPACES
WHOLD    DS    CL10            WITHHOLDING AMOUNT STORAGE
         DC    7C' '           SPACES
NPAY     DS    CL8             NET PAY STORAGE
         DS    4C' '           SPACES
*
LINE2    DC    C'0'            CARRIAGE CONTROL
         DC    26C' '          SPACES
         DC    C'TOTAL EMPLOYEE COUNT: '    EMPLOYEE COUNT WILL GO HERE
ECOUNT   DS    CL10            EMPLOYEE COUNTER STORAGE
         DC    97C' '          SPACES
*
LINE3    DC    C'0'            CARRIAGE CONTROL
         DC    26C' '          SPACES
         DC    C'TOTAL DEDUCTIONS: '    TOTAL DEDUCTIONS WILL GO HERE
DTOTAL   DS    CL12            TOTAL DEDUCTION STORAGE
         DC    95C' '          SPACES
*
LINE4    DC    C'0'            CARRIAGE CONTROL
         DC    26C' '          SPACES
         DC    C'TOTAL BONUSES: '    TOTAL BONUSES WILL GO HERE
BTOTAL   DS    CL12            TOTAL BONUSES STORAGE
         DC    95C' '          SPACES
*
LINE5    DC    C'0'            CARRIAGE CONTROL
         DC    26C' '          SPACES
         DC    C'TOTAL GROSS PAY: '    TOTAL GROSS PAY WILL GO HERE
GPTOTAL  DS    CL10            TOTAL GROSS PAY STORAGE
         DC    97C' '          SPACES
*
LINE6    DC    C'0'            CARRIAGE CONTROL
         DC    26C' '          SPACES
         DC    C'TOTAL WITHHOLDING: '    TOTAL WITHHOLDING WILL GO HERE
WTOTAL   DS    CL12            TOTAL WITHHOLDING STORAGE
         DC    95C' '          SPACES
*
LINE7    DC    C'0'            CARRIAGE CONTROL
         DC    26C' '          SPACES
         DC    C'TOTAL NET PAY: '    TOTAL NET PAY WILL GO HERE
NPTOTAL  DS    CL12            TOTAL NET PAY STORAGE
         DC    95C' '          SPACES
*
         END   PAYROLL1        END PROGRAM
/*
//*
//FT05F001 DD DSN=KC02293.CSCI360.DATASU20(DATA5),DISP=SHR
//*
//FT065001 DD SYSOUT=*
//*
//SYSPRINT DD SYSOUT=*
//