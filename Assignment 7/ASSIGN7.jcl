//KC03D76A JOB ,'AFIFAH ARIF',MSGCLASS=H
//JSTEP01  EXEC PGM=ASSIST
//STEPLIB  DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
******************************************************************
*                                                                *
*  CSCI 360               ASSIGNMENT 7              SPRING 2020  *
*                                                                *
*  DATE DUE:  03/27/2020                                         *
*  TIME DUE:  11:59 PM                                           *
*                                                                *
*  REGISTERS:                                                    *
*        1 -                                                     *
*        2 - EMPLOYEE AND LINE COUNTER                           *
*        3 -                                                     *
*        4 -                                                     *
*        5 -                                                     *
*        6 -                                                     *
*        7 -                                                     *
*        8 -                                                     *
*        9 -                                                     *
*       10 -                                                     *
*       11 -                                                     *
*       12 - BASE REGISTER                                       *
*       13 -                                                     *
*       14 - CALLER'S SAVE AREA                                  *
*       15 -                                                     *
*                                                                *
******************************************************************
*
*        COL. 10
*        |     COL. 16
*        |     |
*        v     v
*STANDARD ENTRY LINKAGE
PAYROLL2 CSECT
         STM   14,12,12(13)   SAVE REGS IN CALLER'S SAVE AREA
         LR    12,15          COPY CSECT ADDRESS INTO R12
         USING PAYROLL2,12    ESTABLISH R12 AS THE BASE REG
         LA    14,PR2SAVE     R14 POINTS TO THIS CSECT'S SAVE AREA
         ST    14,8(,13)      STORE ADDRESS OF THIS CSECT'S SAVE AREA
         ST    13,4(,14)      STORE ADDRESS OF THE CALLER'S SAVE AREA
         LR    13,14          POINT R13 AT THIS CSECT'S SAVE AREA
*
         LA    2,99           R2 = 99 (LINE COUNTER)
*
         XREAD RECORD,80      READ WITHHOLDING PERCENT
         PACK  PWITHPCT(3),RECORD(5) PACK AND STORE WITHHOLDING PERCENT
*
         XREAD RECORD,80      BEGIN READING RECORDS
*
*
*
*LOOP STARTS HERE
LOOP     BNZ   ENDLOOP        BRANCH TILL END IF NO MORE RECORDS
*
         AP    PEMPCTR(3),=PL1'1'     EMPLOYEE LINE COUNTER
*
*         MVI   EMPLDTL+1,C' '         RESET DETAIL LINE TO ALL SPACES
*         MVC   EMPLDTL+2(131),EMPLDTL+1
*
*
*
*EMPLOYEE ID
         PACK  PEMPLID(4),IEMPID(7)   PACK AND STORE EMPLOYEE ID
*
         MVC   OEMPID(8),=X'2020206020202120'  EDIT PATTERN
         ED    OEMPID(8),PEMPLID      EDIT OUTPUT PRINT LINE
*
*
*
*EMPLOYEE NAME
         MVC   OEMPNME(25),IEMPNME    MOVES INPUT EMPNME TO OUTPUT
*
*
*
*HOURLY PAY
         PACK  PHRPAY(3),IHRPAY(5)    PACK AND STORE HOURLY PAY
*
         LA    1,OHRPAY+3             POINT REG1 AT BYTE
         MVC   OHRPAY(7),=X'402021204B2020'    EDIT PATTERN
         EDMK  OHRPAY(7),PHRPAY       EDIT AND MARK HOURLY PAY
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*HOURS WORKED
         PACK  PHOURS(3),IHOURS(5)    PACK AND STORE HOURS WORKED
*
         LA    1,OHOURS+2             POINT REG1 AT BYTE
         MVC   OHOURS(6),=X'2020204B2020'    EDIT PATTERN
         ED    OHOURS(6),PHOURS       EDIT AND MARK HOURS WORKED
*
*
*
*DEDUCTION
         PACK  PDEDUCT(3),IDEDUCT(5)  PACK AND STORE DEDUCTION
*         AP    PTDEDUCT(4),PDEDUCT(3) ADD ALL INDIVID. DED TO TOTAL
*
         LA    1,ODEDUCT+3            POINT REG1 AT BYTE
         MVC   ODEDUCT(7),=X'402021204B2020'   EDIT PATTERN
         EDMK  ODEDUCT(7),PDEDUCT     EDIT AND MARK DEDUCTION
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*TOTAL DEDUCTIONS CALCULATION
*         AP    PTDEDUCT(4),PDEDUCT(3) ADD ALL INDIVID. DED TO TOTAL
*
*
*
*BONUS
         PACK  PBONUS(3),IBONUS(5)    PACK AND STORE BONUS
         AP    PTBONUS(4),PBONUS(3)   ADD ALL INDIVID BONUS TO TOTAL
*
         LA    1,OBONUS+3             POINT REG1 AT BYTE
         MVC   OBONUS(7),=X'402021204B2020'    EDIT PATTERN
         EDMK  OBONUS(7),PBONUS       EDIT AND MARK BONUS
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*GROSS PAY CALCULATIONS
         ZAP   PEMPGPAY(6),PHRPAY(3)  INITIALIZE AND ADD HOURLY PAY
         MP    PEMPGPAY(6),PHOURS(3)  *HOURS WORKED
         SRP   PEMPGPAY(6),64-2,5        SHIFT 2 DECIMALS TO RIGHT
         SP    PEMPGPAY(6),PDEDUCT(3) - DEDUCTION
         AP    PEMPGPAY(6),PBONUS     + BONUS
*TOTAL GROSS PAY CALCULATIONS
         AP    PTGRPAY(7),PEMPGPAY(6) ADD INDIVID. PAYS TO TOTAL
*
         LA    1,OEMPGPAY+11          POINT REG1 AT BYTE
         MVC   OEMPGPAY(16),=X'402020206B2020206B2021204B2020'
         EDMK  OEMPGPAY(16),PEMPGPAY  EDIT ANAD MARK GROSS PAY
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*EMPLOYEE WITHHOLDING
         ZAP   PCALC(10),PEMPGPAY(6)  INITIALIZE AND ADD WITHHOLD PCT
         MP    PCALC(10),PWITHPCT(3)  *WITHHOLDING PERCENT
         SRP   PCALC(10),64-4,5       SHIFT RIGHT 4 DECIMAL PLACES
         ZAP   PEMPWITH(6),PCALC+4(6) ZAP LAST 6 BYTES OF PCALC
*TOTAL WITHHOLDING CALCULATIONS
         AP    PTWITH(7),PEMPWITH(6)
*
         LA    1,OEMPWITH+11          POINT REG1 AT BYTE
         MVC   OEMPWITH(16),=X'402020206B2020206B2021204B2020'
         EDMK  OEMPWITH(16),PEMPWITH  EDIT AND MARK WITHHOLDING AMOUNT
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*NET PAY
         SP    PEMPGPAY(6),PEMPWITH(6)   SUBTRACT WITH AMT FROM GPAY
*TOTAL NET PAY CALCULATIONS
         AP    PTNETPAY(7),PEMPGPAY(6)
*
         LA    1,OEMPWITH+11          POINT REG1 AT BYTE
         MVC   OEMPNPAY(16),=X'402020206B2020206B2021204B2020'
         EDMK  OEMPNPAY(16),PEMPGPAY  EDIT AND MARK NET PAY
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*CHECK TO SEE IF ITS TIME TO PRINT HEADERS
         C     2,=F'18'               COMPARE REG2 TO 18
         BL    NOHDRS
*
         AP    PPAGECTR(2),=PL1'1'    ADD 1 TO PAGE COUNTER
         MVC   OPAGECTR(4),=X'40202120'        EDIT PATTERN
         ED    OPAGECTR(4),PPAGECTR   EDIT OUTPUT PRINT LINE
*PRINT HEADERS IF LINE COUNTER IS EQUAL TO 18
         XPRNT HEADER1,133            PRINT MAIN TITLE
         XPRNT HEADER2,133            PRINT SUBTITLE
         XPRNT HEADER3,133            PRINT COLUMN NAMES
         XPRNT HEADER4,133            PRINT COLUMN NAMES 2
         XPRNT HEADER5,133            PRINT HYPHENS
*
         SR    2,2            SET LINE COUNTER TO 0
*
NOHDRS   XPRNT EMPLDTL,133
         LA    2,1(,2)        INCREMENT LINE COUNTER BY 1
*
         XREAD RECORD,80
*
         B     LOOP
*
ENDLOOP  SRP   PEMPCTR(3),2,5
         MVC   OEMPCTR(4),=X'40202120'
         ED    OEMPCTR(4),PEMPCTR
*
*
*
*TOTAL DEDUCTIONS EDIT AND PRINT
*         LA    1,OTDEDUCT+3
*         MVC   OTDEDUCT(11),=X'4020206B2021204B2020'
*         EDMK  OTDEDUCT(11),PTDEDUCT
*         BCTR  1,0
*         MVI   0(1),C'$'
*
*
*
*TOTAL BONUS EDIT AND PRINT
         LA    1,OTBONUS+7
         MVC   OTBONUS(11),=X'4020206B2021204B2020'
         EDMK  OTBONUS(11),PTBONUS
         BCTR  1,0
         MVI   0(1),C'$'
*
*
*
*TOTAL GROSS PAY EDIT AND PRINT
         SRP   PTGRPAY(7),5,5
         LA    1,OTGRPAY+7
         MVC   OTGRPAY(11),=X'402020206B2021204B2020'
         EDMK  OTGRPAY(11),PTGRPAY
         BCTR  1,0
         MVI   0(1),C'$'
*
*CALCULATE AVERAGE GROSS PAY
         ZAP   PCALC(10),PTGRPAY(7)
         SRP   PCALC(10),4,5       SHIFT RIGHT 4 DECIMAL PLACES
         DP    PCALC(10),PEMPCTR(3)
*
         LA    1,OAVGGPAY+5           POINT REG1 AT BYTE
         MVC   OAVGGPAY(9),=X'40206B2021204B2020'
         EDMK  OAVGGPAY(9),PCALC
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*TOTAL WITHHOLDING EDIT AND PRINT
         SRP   PTWITH(7),5,5
         LA    1,OTWITH+7
         MVC   OTWITH(11),=X'402020206B2021204B2020'
         EDMK  OTWITH(11),PTWITH
         BCTR  1,0
         MVI   0(1),C'$'
*CALCULATE AVERAGE WITHHOLDING PAY
         ZAP   PCALC(10),PTWITH(7)
         SRP   PCALC(10),2,5       SHIFT RIGHT 4 DECIMAL PLACES
         DP    PCALC(10),PEMPCTR(3)
*
         LA    1,OAVGWITH+7           POINT REG1 AT BYTE
         MVC   OAVGWITH(11),=X'402020206B2021204B2020'
         EDMK  OAVGWITH(11),PCALC
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*TOTAL NET PAY EDIT AND PRINT
         SRP   PTNETPAY(7),5,5
         LA    1,OTNETPAY+7
         MVC   OTNETPAY(11),=X'402020206B2021204B2020'
         EDMK  OTNETPAY(11),PTNETPAY
         BCTR  1,0
         MVI   0(1),C'$'
*CALCULATE AVERAGE NET PAY
         ZAP   PCALC(10),PTNETPAY(7)
         SRP   PCALC(10),2,5       SHIFT RIGHT 4 DECIMAL PLACES
         DP    PCALC(10),PEMPCTR(3)
*
         LA    1,OAVGNPAY+7           POINT REG1 AT BYTE
         MVC   OAVGNPAY(11),=X'402020206B2021204B2020'
         EDMK  OAVGNPAY(11),PCALC
         BCTR  1,0                    DECREMENT BY -1
         MVI   0(1),C'$'              INSERT $
*
*
*
*PRINTOUT TOTALS AND AVERAGES
         XPRNT HEADER1,133
         XPRNT HEADER2,133
         XPRNT LINE,133
         XPRNT LINE1,133
         XPRNT LINE2,133
         XPRNT LINE3,133
         XPRNT LINE4,133
         XPRNT LINE5,133
         XPRNT LINE6,133
*
*
*
*STANDARD EXIT LINKAGE
         SR    15,15          SET RETURN CODE TO ZERO
         L     13,4(,13)      POINT R13 TO CALLER'S SAVE AREA
         L     14,12(,13)     RESTORE R14
         LM    0,12,20(13)    RESTORE R0 THRU R12
         BR    14             RETURN TO CALLER
*
*
*
         LTORG                LITERALS STORED HERE
*
*
*
*PACKED DECIMAL VARIABLES
PWITHPCT DC    PL3'0'         PACKED WITHHOLDING PCT FROM FIRST REC
*
PEMPCTR  DC    PL3'0'         PACKED EMPLOYEE COUNTER (MAX 999)
PPAGECTR DC    PL2'0'         PACKED PAGE COUNTER (MAX 999)
*
PEMPLID  DC    PL4'0'         PACKED EMPLOYEE ID
PHRPAY   DC    PL3'0'         PACKED EMPLOYEE HOURLY PAY RATE
PHOURS   DC    PL3'0'         PACKED EMPLOYEE HOURS WORKED
PDEDUCT  DC    PL3'0'         PACKED EMPLOYEE DEDUCTION
PBONUS   DC    PL3'0'         PACKED EMPLOYEE BONUS
PEMPGPAY DC    PL6'0'         PACKED CALCULATED EMPLOYEE GROSS PAY
PEMPWITH DC    PL6'0'         PACKED CALCULATED EMPLOYEE WITHHOLDING
PEMPNPAY DC    PL6'0'         PACKED CALCULATED EMPLOYEE NET PAY
PCALC    DC    PL9'0'         USED TO CALCULATE WITHHOLDING AND AVGS
*
*
*
*PACKED TOTALS FIELDS
PTDEDUCT DC    PL4'0'         PACKED TOTAL DEDUCTIONS
PTBONUS  DC    PL4'0'         PACKED TOTAL BONUSES
PTGRPAY  DC    PL7'0'         PACKED TOTAL GROSS EMPLOYEE PAY
PTWITH   DC    PL7'0'         PACKED TOTAL WITHHOLDING
PTNETPAY DC    PL7'0'         PACKED TOTAL NET EMPLOYEE PAY
*
*
*
*INPUT RECORD STORAGE
RECORD   DS    0H
IEMPID   DS    ZL7            PACKS INTO 4 BYTES (7/2 = 3 + 1 = 4)
         DS    CL1
IHRPAY   DS    ZL5            PACKS INTO 3 BYTES (5/2 = 2 + 1 = 3)
IHOURS   DS    ZL5            PACKS INTO 3 BYTES
IDEDUCT  DS    ZL5            PACKS INTO 3 BYTES
IBONUS   DS    ZL5            PACKS INTO 3 BYTES
IEMPNME  DS    CL25
         DS    CL27
*
*
*
*OUTPUT RECORD STORAGE
EMPLDTL  DC    C'0'           EMPLOYEE DETAIL LINE
OEMPID   DS    CL8            OUTPUT EMPLOYEE ID
         DC    4C' '
OEMPNME  DS    CL25           OUTPUT EMPLOYEE NAME
         DC    3C' '
OHRPAY   DS    CL7            OUTPUT HOURLY PAY
         DC    6C' '
OHOURS   DS    CL6            OUTPUT HOURS WORKED
         DC    8C' '
ODEDUCT  DS    CL7            OUTPUT DEDUCTION AMOUNT
         DC    4C' '
OBONUS   DS    CL7            OUTPUT BONUS AMOUNT
         DC    1C' '
OEMPGPAY DS    CL15           OUTPUT EMPLOYEE GROSS PAY
         DC    1C' '
OEMPWITH DS    CL14           OUTPUT WITHHOLDING AMOUNT
         DC    1C' '
OEMPNPAY DS    CL14           OUTPUT NET PAY
         DC    1C' '
*
*
*
PR2SAVE  DC    18F'-1'        CURRENT REGISTER SAVE AREA
*
*
*
*LINE1    DC    C'0'           CARRIAGE CONTROL
*HEADER AND SUBHEADERS
HEADER1  DC    C'0'           MAIN TITLE
         DC    50C' '
         DC    C'FEELINGS MUTUAL INSURANCE COMPANY'  33
         DC    37C' '
         DC    C'PAGE:   '            8
OPAGECTR DS    CL4            OUTPUT PAGE COUNTER
         DC    5C' '
*
*
*
HEADER2  DC    C'0'           SUBTITLE
         DC    49C' '
         DC    C'SEMI-MONTHLY EMPLOYEE PAYROLL REPORT'
         DC    48C' '
*
*
*
HEADER3  DC    C'0'           COLUMN NAMES
         DC    C'EMPLOYEE'
         DC    4C' '
         DC    C'EMPLOYEE'
         DC    21C' '
         DC    C'HOURLY'
         DC    6C' '
         DC    C'HOURS'
         DC    6C' '
         DC    C'DEDUCTION'
         DC    6C' '
         DC    C'BONUS'
         DC    8C' '
         DC    C'EMPLOYEE'
         DC    8C' '
         DC    C'EMPLOYEE'
         DC    8C' '
         DC    C'EMPLOYEE'
         DC    1C' '
*
*
*
HEADER4  DC    C'0'           COLUMN NAMES 2
         DC    C'ID'
         DC    10C' '
         DC    C'NAME'
         DC    28C' '
         DC    C'PAY'
         DC    5C' '
         DC    C'WORKED'
         DC    9C' '
         DC    C'AMOUNT'
         DC    5C' '
         DC    C'AMOUNT'
         DC    7C' '
         DC    C'GROSS PAY'
         DC    5C' '
         DC    C'WITHHOLDING'
         DC    9C' '
         DC    C'NET PAY'
         DC    1C' '
*
*
*
HEADER5  DC    C'0'           HYPHENS
         DC    C'--------'
         DC    4C' '
         DC    C'-------------------------'
         DC    3C' '
         DC    C'-------'
         DC    4C' '
         DC    C'-------'
         DC    5C' '
         DC    C'----------'
         DC    4C' '
         DC    C'-------'
         DC    3C' '
         DC    C'-------------'
         DC    3C' '
         DC    C'-------------'
         DC    3C' '
         DC    C'-------------'
         DC    1C' '
*
*
*
LINE     DC    C'0'           CARRIAGE CONTROL
         DC    62C' '         SPACES
         DC    C' TOTALS '    8
         DC    63C' '         SPACES
LINE1    DC    C'0'           CARRIAGE CONTROL
         DC    1C' '          SPACES
         DC    C'NUMBER OF EMPLOYEES:      '    26
OEMPCTR  DS    CL4            EMPLOYEE COUNTER STORAGE
         DC    102C' '        SPACES
*
*
*
LINE2    DC    C'0'           CARRIAGE CONTROL
         DC    1C' '          SPACES
         DC    C'   TOTAL DEDUCTIONS: '  21
OTDEDUCT DS    CL7
         DC    105C' '
*
*
*
LINE3    DC    C'0'           CARRIAGE CONTROL
         DC    1C' '         SPACES
         DC    C'      TOTAL BONUSES: '  21
         DC    2C' '
OTBONUS  DS    CL4
         DC    104C' '
*
*
*
LINE4    DC    C'0'           CARRIAGE CONTROL
         DC    1C' '         SPACES
         DC    C'    TOTAL GROSS PAY: '  21
         DC    1C' '
OTGRPAY  DS    CL11
         DC    5C' '
         DC    C'    AVERAGE GROSS PAY:   '   23
OAVGGPAY DS    CL9
         DC    60C' '
*
*
*
LINE5    DC    C'0'           CARRIAGE CONTROL
         DC    1C' '         SPACES
         DC    C'  TOTAL WITHHOLDING: '  21
         DC    1C' '
OTWITH   DS    CL11
         DC    5C' '
         DC    C'  AVERAGE WITHHOLDING: ' 23
OAVGWITH DS    CL11
         DC    62C' '
*
*
*
LINE6    DC    C'0'           CARRIAGE CONTROL
         DC    1C' '         SPACES
         DC    C'      TOTAL NET PAY:  '  22
OTNETPAY DS    CL11
         DC    10C' '
         DC    C' AVERAGE NET PAY: ' 18
OAVGNPAY DS    CL11
         DC    60C' '
*
*
*
         END   PAYROLL2       END PROGRAM
/*
//*
//FT05F001 DD DSN=KC02322.CSCI360.DATASU20(DATA6),DISP=SHR
//*
//FT06F001 DD SYSOUT=*
//*
//SYSPRINT DD SYSOUT=*
//