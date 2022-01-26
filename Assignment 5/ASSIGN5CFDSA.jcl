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
ASSIGN5C CSECT
         USING ASSIGN5C,15     ESTABLISH ADDRESSABILITY ON REG 15
         L     4,40(,15)
         L     5,44(,15)
         SR    4,5
         ST    4,48(,15)
         L     6,40(,15)
         L     7,44(,15)
         AR    6,7
         ST    6,52(,15)
         XDUMP 40(15),8
         BCR   B'1111',14
*
         LTORG             LITERAL ORGANIZATION
*
         DC    F'97'       FIRST
         DC    F'33'       SECOND
         DS    F           ANSWER1
         DS    F           ANSWER2
*
         END   ASSIGN5C
/*
//