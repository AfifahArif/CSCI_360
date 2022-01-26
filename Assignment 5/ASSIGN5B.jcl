//KC03D76A JOB ,'AFIFAH ARIF',MSGCLASS=H
//JSTEP01  EXEC PGM=ASSIST
//STEPLIB  DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR                        
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
******************************************************************
*                                                                *
*  CSCI 360               ASSIGNMENT 5              SPRING 2020  *
*                                                                *
*  DATE DUE:  02/22/2020                                         *
*  TIME DUE:  11:59 PM                                           *
*                                                                *
******************************************************************
*
*        COL. 10
*        |     COL. 16
*        |     |
*        v     v
ASSIGN5B CSECT
         USING ASSIGN5B,15     ESTABLISH ADDRESSABILITY ON REG 15
         L     4,FIRST         LOAD FIRST VAR INTO REG 4
         L     5,SECOND        LOAD SECOND VAR INTO REG 5
         SR    4,5             SUBTRACT SECOND FROM FIRST & PUT IN R4
         ST    4,ANSWER1       STORE CONTENTS OF REG 4 IN ANSWER1 VAR
         L     6,FIRST         LOAD FIRST VAR INTO REG 6
         L     7,SECOND        LOAD SECOND VAR INTO REG 7
         AR    6,7             ADD SECOND TO FIRST AND PUT IN REG 6
         ST    6,ANSWER2       STORE CONTENTS OF REG 6 IN ANSWER2 VAR
         XDUMP ANSWER1,8
         BCR   B'1111',14
*
         LTORG                 LITERAL ORGANIZATION
*
FIRST    DC    F'97'           FULLWORD VARIABLE
SECOND   DC    F'33'           FULLWORD VARIABLE
ANSWER1  DS    F               FULLWORD VARIABLE
ANSWER2  DS    F               FULLWORD VARIABLE
*
         END   ASSIGN5B        END PROGRAM
/*
//