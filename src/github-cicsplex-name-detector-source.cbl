       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
       CBL CICS('SP,EDF,CPSM')
      *****************************************************************
      * Licensed Materials - Property of IBM                          *
      *                                                               *
      *                                                               *
      * (c) Copyright IBM Corp. 2018 All Rights Reserved              *       
      *                                                               *
      * US Government Users Restricted Rights - Use, duplication or   *
      * disclosure restricted by GSA ADP Schedule Contract with IBM   *
      * Corp                                                          *
      *                                                               *
      *****************************************************************
      * Title: SM540API - Cicsplex SM Diagnostic program at CPSM540
      *
      *
      * Description: This program sample demonstrates how to derive
      *              the CICSplex name being used in the environment.
      *              This negates the need to ever hard code the
      *              CICSplex name into the source code, and thus
      *              is particularly useful because moving code
      *              between (say) a Test and Production environment
      *              (or vice versa) used to mean having to
      *              change the hardcoded CICSplex name.
      *
      *              The derived CICSplex name is made available in
      *              variable WS-SAVED-CICSPLEXNAME
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SM540API.
       AUTHOR. JON COLLETT.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

      * SOURCE-COMPUTER.  IBM-370 WITH DEBUGGING MODE.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.


       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-CPSM-VERSION                     PIC X(4)   VALUE '0540'.

      *
      * General variables - CICSPlex SM
      *
       01 WS-CPSM-PROCESS.
          05 WS-THREAD-CMAS                    PIC S9(8) USAGE BINARY.
          05 WS-THREAD-CICSPLEX                PIC S9(8) USAGE BINARY.

       01 WS-RESPONSE                          PIC S9(8) USAGE BINARY.
       01 WS-REASON                            PIC S9(8) USAGE BINARY.

       01 WS-FAILURE.
          05 WS-FAILURE-COMMAND                PIC X(20).
          05 WS-FAILURE-RESULT-SET             PIC S9(8) USAGE BINARY.
          05 WS-FAILURE-THREAD                 PIC S9(8) USAGE BINARY.


      *
      * Temporary CPSM basetable data
      *
       01 WS-CPSM-TEMPORARY.
          05 WS-CPSM-TEMPORARY-OBJECT        PIC X(8)   VALUE SPACES.
          05 WS-CPSM-TEMPORARY-SCOPE         PIC X(8)   VALUE SPACES.
          05 WS-CPSM-TEMPORARY-LENGTH        PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMPORARY-THREAD        PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMPORARY-RESULT-SET    PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMPORARY-COUNT         PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMPORARY-COUNT-1       PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMPORARY-KEY           PIC X(12)  VALUE SPACES.
          05 WS-CPSM-TEMPORARY-FILTER-COUNT  PIC S9(8)  VALUE 5.
          05 WS-CPSM-TEMPORARY-FILTER-USE    PIC X(8)   VALUE SPACES.
          05 WS-CPSM-TEMPORARY-FILTER        PIC X(8)   OCCURS 6.
          05 WS-CPSM-TEMPORARY-CRITERIA      PIC X(256).
          05 WS-CPSM-TEMPORARY-CRITLEN       PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMPORARY-PARM          PIC X(256).
          05 WS-CPSM-TEMPORARY-PARMLEN       PIC S9(8)  BINARY VALUE 0.
          05 WS-CPSM-TEMP-LEN                PIC S9(8) COMP VALUE 0.
          05 WS-CPSM-TEMP-PARMLEN            PIC S9(8) COMP VALUE 0.


      *
      *  Environment Setup records
      *
       01 WS-CPSM-SETUP-RECORDS.
      *
      * CMASPLEX records
      *
          05 WS-CPSM-CMASPLEX.
             10 WS-CPSM-CMASPLEX-RESULT-SET  PIC S9(8)  BINARY VALUE 0.
             10 WS-CPSM-CMASPLEX-COUNT       PIC S9(8)  BINARY VALUE 0.

      *
      * CICSRGN records
      *
          05 WS-CPSM-CICSRGN.
             10 WS-CPSM-CICSRGN-RESULT-SET    PIC S9(8)  BINARY VALUE 0.
             10 WS-CPSM-CICSRGN-COUNT         PIC S9(8)  BINARY VALUE 0.

       01 WS-DISPLAY.
          05 WS-DISPLAY-RESP                  PIC X(8).
          05 WS-DISPLAY-RESP2                 PIC X(8).
          05 WS-DISPLAY-COUNT                 PIC X(4).
          05 WS-DISPLAY-COUNT-1               PIC X(8).
          05 WS-DISPLAY-COUNT-2               PIC X(8).
          05 WS-DISPLAY-LENGTH                PIC X(8).
          05 WS-DISPLAY-CRITLEN               PIC X(8).
          05 WS-DISPLAY-PARMLEN               PIC X(8).
          05 WS-DISPLAY-RESPONSE              PIC X(8).
          05 WS-DISPLAY-REASON                PIC X(8).
          05 WS-DISPLAY-RESULT-SET            PIC X(8).
          05 WS-DISPLAY-THREAD                PIC X(8).
          05 WS-DISPLAY-TEXT                  PIC X(320).

      **********

      *
      * CICSRGN Resource Table (taken from the SEYUCOB
      * library at 5.4. This would typically be pulled in as a
      * COPY book but is shown here for completeness).
      *

       01 CICSRGN.
          05 EYU-CICSNAME             PIC X(8).
          05 EYU-CICSREL              PIC X(4).
          05 EYU-RESERVED             PIC X(4).
          05 JOBNAME                  PIC X(8).
          05 APPLID                   PIC X(8).
          05 MVSSYSID                 PIC X(4).
          05 AKP                      PIC S9(8) USAGE BINARY.
          05 AMAXTASKS                PIC S9(8) USAGE BINARY.
          05 MAXTASKS                 PIC S9(8) USAGE BINARY.
          05 CICSSTATUS               PIC S9(8) USAGE BINARY.
          05 SYSDUMP-A                PIC S9(8) USAGE BINARY.
          05 EXTSEC                   PIC S9(8) USAGE BINARY.
          05 STARTUP                  PIC S9(8) USAGE BINARY.
          05 STGPROT                  PIC S9(8) USAGE BINARY.
          05 DTRPROGRAM               PIC X(8).
          05 GMMTRANID                PIC X(4).
          05 MROBATCH                 PIC S9(8) USAGE BINARY.
          05 OPREL                    PIC S9(4) USAGE BINARY.
          05 OPSYS                    PIC X(1).
          05 CICSSYS                  PIC X(1).
          05 PRTYAGING                PIC S9(8) USAGE BINARY.
          05 RELEASE-R                PIC X(4).
          05 RUNAWAY                  PIC S9(8) USAGE BINARY.
          05 SCANDELAY                PIC S9(8) USAGE BINARY.
          05 EXITTIME                 PIC S9(8) USAGE BINARY.
          05 XRFSTATUS                PIC S9(8) USAGE BINARY.
          05 AINSPROG                 PIC X(8).
          05 AINSCREQ                 PIC S9(8) USAGE BINARY.
          05 AINSMREQ                 PIC S9(8) USAGE BINARY.
          05 AINSSTAT                 PIC S9(8) USAGE BINARY.
          05 DDSOSTAT                 PIC S9(8) USAGE BINARY.
          05 DDSSSTAT                 PIC S9(8) USAGE BINARY.
          05 IRCSTAT                  PIC S9(8) USAGE BINARY.
          05 EVENTCLASS               PIC S9(8) USAGE BINARY.
          05 EXCEPTCLASS              PIC S9(8) USAGE BINARY.
          05 PERFCLASS                PIC S9(8) USAGE BINARY.
          05 MONSTAT                  PIC S9(8) USAGE BINARY.
          05 ENDOFDAY                 PIC S9(7) USAGE PACKED-DECIMAL.
          05 INTERVAL                 PIC S9(7) USAGE PACKED-DECIMAL.
          05 NEXTTIME                 PIC S9(7) USAGE PACKED-DECIMAL.
          05 RECORDING-R              PIC S9(8) USAGE BINARY.
          05 AUXSTATUS                PIC S9(8) USAGE BINARY.
          05 GTFSTATUS                PIC S9(8) USAGE BINARY.
          05 INTSTATUS                PIC S9(8) USAGE BINARY.
          05 SWITCHSTATUS             PIC S9(8) USAGE BINARY.
          05 TABLESIZE                PIC S9(8) USAGE BINARY.
          05 SINGLESTATUS             PIC S9(8) USAGE BINARY.
          05 SYSTEMSTATUS             PIC S9(8) USAGE BINARY.
          05 TCEXITSTATUS             PIC S9(8) USAGE BINARY.
          05 USERSTATUS               PIC S9(8) USAGE BINARY.
          05 PLASTRESET               PIC S9(7) USAGE PACKED-DECIMAL.
          05 PEAKTASKS                PIC S9(4) USAGE BINARY.
          05 CURRAMAX                 PIC S9(4) USAGE BINARY.
          05 PEAKAMAX                 PIC S9(4) USAGE BINARY.
          05 CUTCBCNT                 PIC S9(4) USAGE BINARY.
          05 LASTRESET                PIC S9(16) USAGE BINARY.
          05 LOADREQS                 PIC S9(8) USAGE BINARY.
          05 LOADTIME                 PIC S9(8) USAGE BINARY.
          05 PRGMUCNT                 PIC S9(8) USAGE BINARY.
          05 PRGMWAIT                 PIC S9(8) USAGE BINARY.
          05 LOADWCNT                 PIC S9(8) USAGE BINARY.
          05 LOADHWMW                 PIC S9(8) USAGE BINARY.
          05 LOADHWMC                 PIC S9(8) USAGE BINARY.
          05 LOADWAIT                 PIC S9(8) USAGE BINARY.
          05 RDEBRBLD                 PIC S9(8) USAGE BINARY.
          05 PRGMRCMP                 PIC S9(8) USAGE BINARY.
          05 LOADTNIU                 PIC S9(16) USAGE BINARY.
          05 LOADPNIU                 PIC S9(8) USAGE BINARY.
          05 LOADRNIU                 PIC S9(8) USAGE BINARY.
          05 SDMPTOTL                 PIC S9(8) USAGE BINARY.
          05 SDMPSUPP                 PIC S9(8) USAGE BINARY.
          05 TDMPTOTL                 PIC S9(8) USAGE BINARY.
          05 TDMPSUPP                 PIC S9(8) USAGE BINARY.
          05 STRTTIME                 PIC S9(16) USAGE BINARY.
          05 SYSID                    PIC X(4).
          05 EYU-RSV0075              PIC X(4).
          05 CPUTIME                  PIC S9(16) USAGE BINARY.
          05 PAGEIN                   PIC S9(8) USAGE BINARY.
          05 PAGEOUT                  PIC S9(8) USAGE BINARY.
          05 REALSTG                  PIC S9(8) USAGE BINARY.
          05 SIOREQ                   PIC S9(16) USAGE BINARY.
          05 VTMSTATUS                PIC S9(8) USAGE BINARY.
          05 VTMRPLMAX                PIC S9(7) USAGE PACKED-DECIMAL.
          05 VTMRPLPOST               PIC S9(3) USAGE PACKED-DECIMAL.
          05 VTMSOSCNT                PIC S9(4) USAGE BINARY.
          05 VTMACBDOPE               PIC S9(4) USAGE BINARY.
          05 CURRENTDDS               PIC X(1).
          05 INITIALDDS               PIC X(1).
          05 CURAUXDS                 PIC X(1).
          05 EYU-RSV0091              PIC X(3).
          05 LUCURR                   PIC S9(8) USAGE BINARY.
          05 LUHWM                    PIC S9(8) USAGE BINARY.
          05 PRSSINQCNT               PIC S9(8) USAGE BINARY.
          05 PRSSNIBCNT               PIC S9(8) USAGE BINARY.
          05 PRSSOPNCNT               PIC S9(8) USAGE BINARY.
          05 PRSSUNBNDCNT             PIC S9(8) USAGE BINARY.
          05 PRSSERRORCNT             PIC S9(8) USAGE BINARY.
          05 CONVERSEST               PIC S9(8) USAGE BINARY.
          05 FREQUENCY                PIC S9(7) USAGE PACKED-DECIMAL.
          05 SUBSYSTEMID              PIC X(4).
          05 SYNCPOINTST              PIC S9(8) USAGE BINARY.
          05 MONRPTTIME               PIC S9(8) USAGE BINARY.
          05 DFLTUSER                 PIC X(8).
          05 PROGAUTOEXIT             PIC X(8).
          05 PROGAUTOCTLG             PIC S9(8) USAGE BINARY.
          05 PROGAUTOINST             PIC S9(8) USAGE BINARY.
          05 TRANISOLATE              PIC S9(8) USAGE BINARY.
          05 STARTUPDATE              PIC S9(7) USAGE PACKED-DECIMAL.
          05 PSDINTERVAL              PIC S9(7) USAGE PACKED-DECIMAL.
          05 CURRTASKS                PIC S9(8) USAGE BINARY.
          05 MAXTRCNT                 PIC S9(8) USAGE BINARY.
          05 CURACTVUSRTR             PIC S9(8) USAGE BINARY.
          05 CURQUEDUSRTR             PIC S9(8) USAGE BINARY.
          05 PEKACTVUSRTR             PIC S9(8) USAGE BINARY.
          05 PEKQUEDUSRTR             PIC S9(8) USAGE BINARY.
          05 TOTACTVUSRTR             PIC S9(8) USAGE BINARY.
          05 TOTDELYUSRTR             PIC S9(8) USAGE BINARY.
          05 EYU-RSV0118              PIC X(4).
          05 TOTQUETIME               PIC S9(16) USAGE BINARY.
          05 CURQUETIME               PIC S9(16) USAGE BINARY.
          05 PROGAUTOATTM             PIC S9(8) USAGE BINARY.
          05 PROGAUTOXREJ             PIC S9(8) USAGE BINARY.
          05 PROGAUTOFAIL             PIC S9(8) USAGE BINARY.
          05 INITSTATUS               PIC S9(8) USAGE BINARY.
          05 SHUTSTATUS               PIC S9(8) USAGE BINARY.
          05 INTVTRANS                PIC S9(8) USAGE BINARY.
          05 GMMTEXT                  PIC X(246).
          05 GMMLENGTH                PIC S9(4) USAGE BINARY.
          05 GRNAME                   PIC X(8).
          05 GRSTATUS                 PIC S9(8) USAGE BINARY.
          05 REENTPROTECT             PIC S9(8) USAGE BINARY.
          05 CMDPROTECT               PIC S9(8) USAGE BINARY.
          05 SOSSTATUS                PIC S9(8) USAGE BINARY.
          05 TOTLTASKS                PIC S9(16) USAGE BINARY.
          05 RLSSTATUS                PIC S9(8) USAGE BINARY.
          05 DFLTREMSYS               PIC X(4).
          05 SDTRAN                   PIC X(4).
          05 DSIDLE                   PIC S9(7) USAGE PACKED-DECIMAL.
          05 DSINTERVAL               PIC S9(7) USAGE PACKED-DECIMAL.
          05 CTSLEVEL                 PIC X(6).
          05 OSLEVEL                  PIC X(6).
          05 RRMSSTAT                 PIC S9(8) USAGE BINARY.
          05 MVSSYSNAME               PIC X(8).
          05 FORCEQR                  PIC S9(8) USAGE BINARY.
          05 MAXOPENTCBS              PIC S9(8) USAGE BINARY.
          05 ACTOPENTCBS              PIC S9(8) USAGE BINARY.
          05 DSRTPROGRAM              PIC X(8).
          05 CONSOLES                 PIC S9(8) USAGE BINARY.
          05 TCPIP                    PIC S9(8) USAGE BINARY.
          05 GARBAGEINT               PIC S9(8) USAGE BINARY.
          05 TIMEOUTINT               PIC S9(8) USAGE BINARY.
          05 COLDSTATUS               PIC S9(8) USAGE BINARY.
          05 MAXHPTCBS                PIC S9(8) USAGE BINARY.
          05 ACTHPTCBS                PIC S9(8) USAGE BINARY.
          05 MAXJVMTCBS               PIC S9(8) USAGE BINARY.
          05 ACTJVMTCBS               PIC S9(8) USAGE BINARY.
          05 SUBTASKS                 PIC S9(8) USAGE BINARY.
          05 DEBUGTOOL                PIC S9(8) USAGE BINARY.
          05 MAXXPTCBS                PIC S9(8) USAGE BINARY.
          05 ACTXPTCBS                PIC S9(8) USAGE BINARY.
          05 MAXSSLTCBS               PIC S9(8) USAGE BINARY.
          05 ACTSSLTCBS               PIC S9(8) USAGE BINARY.
          05 XCFGROUP                 PIC X(8).
          05 EYU-RSV0173              PIC X(4).
          05 MEMLIMIT                 PIC S9(16) USAGE BINARY.
          05 SOSABOVEBAR              PIC S9(8) USAGE BINARY.
          05 SOSABOVELINE             PIC S9(8) USAGE BINARY.
          05 SOSBELOWLINE             PIC S9(8) USAGE BINARY.
          05 LDGLBSOU                 PIC S9(8) USAGE BINARY.
          05 LDGLWSOU                 PIC S9(8) USAGE BINARY.
          05 LDGLSORT                 PIC S9(8) USAGE BINARY.
          05 PSTYPE                   PIC S9(8) USAGE BINARY.
          05 IDNTYCLASS               PIC S9(8) USAGE BINARY.
          05 ACTTHRDTCBS              PIC S9(8) USAGE BINARY.
          05 MAXTHRDTCBS              PIC S9(8) USAGE BINARY.
          05 JOBID                    PIC X(8).
          05 XMGLSMXT                 PIC S9(16) USAGE BINARY.
          05 XMGLTAT                  PIC S9(16) USAGE BINARY.
          05 XMGLAMXT                 PIC S9(16) USAGE BINARY.
          05 XMGATMXT                 PIC S9(8) USAGE BINARY.
          05 REGIONUSERID             PIC X(8).
          05 BMSVALIDATE              PIC X(4).
          05 BMSVALIGCNT              PIC S9(8) USAGE BINARY.
          05 BMSVALLGCNT              PIC S9(8) USAGE BINARY.
          05 BMSVALABCNT              PIC S9(8) USAGE BINARY.
          05 EYU-RSV9999              PIC X(4).

       01 CICSRGN-TBL-LEN            PIC S9(4) USAGE BINARY VALUE 1056.
       01 CICSRGN-INV-CONTEXT        PIC S9(4) USAGE BINARY VALUE 12.
       01 CICSRGN-ACTNOT-SUPPORTED   PIC S9(4) USAGE BINARY VALUE 21.
       01 CICSRGN-RESOURCE-REQUIRED  PIC S9(4) USAGE BINARY VALUE 22.
       01 CICSRGN-SYSTEM-NOT-ACTIVE  PIC S9(4) USAGE BINARY VALUE 23.
       01 CICSRGN-ARM-NOT-AVAILOPSYS PIC S9(4) USAGE BINARY VALUE 24.
       01 CICSRGN-ARM-NOT-AVAILCICSREL PIC S9(4) USAGE BINARY VALUE 25.
       01 CICSRGN-ARM-NOT-REGISTERED PIC S9(4) USAGE BINARY VALUE 26.
       01 CICSRGN-ARM-NOT-ACTIVE     PIC S9(4) USAGE BINARY VALUE 27.
       01 CICSRGN-ARM-POLICY-CHECK   PIC S9(4) USAGE BINARY VALUE 28.
       01 CICSRGN-ALL-REQUIRED       PIC S9(4) USAGE BINARY VALUE 29.
       01 CICSRGN-INVALID-DUMPCODE   PIC S9(4) USAGE BINARY VALUE 30.
       01 CICSRGN-ARM-NOT-IN-SMSS    PIC S9(4) USAGE BINARY VALUE 31.

      **********

      *
      * CMASPLEX SM Resource Table (taken from the SEYUCOB
      * library at 5.4. This would typically be pulled in as a
      * COPY book but is shown here for completeness).
      *

       01 CMASPLEX.
          05 PLEXNAME                 PIC X(8).
          05 MPSTATUS                 PIC S9(8) USAGE BINARY.
          05 PERFINTVL                PIC S9(4) USAGE BINARY.
          05 TMEZONEO                 PIC X(1).
          05 TMEZONE                  PIC X(1).
          05 DAYLGHTSV                PIC S9(8) USAGE BINARY.
          05 READRS                   PIC S9(4) USAGE BINARY.
          05 UPDATERS                 PIC X(1).
          05 TOPRSUPD                 PIC X(1).
          05 BOTRSUPD                 PIC X(1).
          05 RSPOOLID                 PIC X(8).
          05 MPCMAS                   PIC X(8).
          05 EYU-RSV0019              PIC X(3).
          05 MPSTATE                  PIC S9(8) USAGE BINARY.


       01 CMASPLEX-TBL-LEN           PIC S9(4) USAGE BINARY VALUE 48.
       01 CMASPLEX-REC-NOT-FOUND     PIC S9(4) USAGE BINARY VALUE 2.
       01 CMASPLEX-INV-NAMELIST      PIC S9(4) USAGE BINARY VALUE 26.
       01 CMASPLEX-MAS-ACTIVE        PIC S9(4) USAGE BINARY VALUE 27.
       01 CMASPLEX-NOT-FOUND         PIC S9(4) USAGE BINARY VALUE 28.
       01 CMASPLEX-NOT-SUPPORTED     PIC S9(4) USAGE BINARY VALUE 29.
       01 CMASPLEX-BAD-REMOVE        PIC S9(4) USAGE BINARY VALUE 30.
       01 CMASPLEX-BAD-FRCREM        PIC S9(4) USAGE BINARY VALUE 31.
       01 CMASPLEX-BAD-ACTION        PIC S9(4) USAGE BINARY VALUE 32.

      **********


      *
      * General variables - CICS
      *
       01 WS-ASSIGN-ATTRIBUTES.
          05 WS-APPLID                        PIC X(8) VALUE SPACES.


       01 WS-SAVED-CICSPLEXNAME               PIC X(8) VALUE SPACES.
       01 WS-BINARY-ZERO                      PIC S9(8) BINARY VALUE 0.


      *
      * General Temporary variables
      *
       01 WS-TEMP.
          05 WS-TEMP-REGION                   PIC X(8)   VALUE SPACES.
          05 WS-TEMP-RECORDS-1                PIC S9(8)  VALUE 0.
          05 WS-TEMP-RECORDS-2                PIC S9(8)  VALUE 1.
          05 WS-TEMP-RECORDS-3                PIC S9(8)  VALUE 1.
          05 WS-TEMP-LENGTH                   PIC S9(8)  VALUE 0.
          05 WS-TEMP-VALUE                    PIC X(256) VALUE SPACES.


       01 WS-INPUT-CICSPLEX                   PIC X(8).
       01 WS-CICSPLEX-KNOWN                   PIC X VALUE 'N'.


      *
      * An array to store the CICSplex names found
      *
       01 WS-CICSPLEX-NAME-ARRAY.
          03 WS-CICSPLEX-NAME-ARRY-DATA OCCURS 99.
             05 WS-CICSPLEX-NAME-STORE        PIC X(8).

       01 WS-CICSPLEX-NAME-CNT                PIC 99 VALUE 0.


       PROCEDURE DIVISION.
       PREMIERE SECTION.
       A000.

      *
      *    Determine the name of the CICSplex in use in this
      *    environment.
      *

      *
      *    First determine the name of the APPLID of the region
      *    running this API program.
      *

           EXEC CICS ASSIGN
              APPLID(WS-APPLID)
           END-EXEC.


      *
      *    Connect to a CMAS using only the CPSM version number
      *    (because we don't yet know the CICSplex name).
      *

           MOVE '0540' TO WS-CPSM-VERSION.

           EXEC CPSM CONNECT
                     VERSION(WS-CPSM-VERSION)
                     THREAD(WS-THREAD-CICSPLEX)
                     RESPONSE(WS-RESPONSE)
                     REASON(WS-REASON)
           END-EXEC.

      *
      * If the CPSM CONNECT was not successful provide failure
      * information and finish. If it was successful display
      * the connection details.
      *
           IF WS-RESPONSE NOT EQUAL EYUVALUE(OK)
      D       DISPLAY 'CONNECT failed'
              MOVE 'CONNECT'          TO WS-FAILURE-COMMAND
              MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
              MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

              PERFORM GET-CPSM-COMMAND-FAILURE
              PERFORM GET-ME-OUT-OF-HERE
           ELSE
              MOVE WS-THREAD-CICSPLEX TO  WS-DISPLAY-THREAD
      D       DISPLAY 'SM540API: Connected to '
      D               'Context(' WS-INPUT-CICSPLEX ') at '
      D               'Version(' WS-CPSM-VERSION ') using '
      D               'Thread(' WS-DISPLAY-THREAD ')'
           END-IF.


      *
      * GET data from the CMASPLEX table which will return
      * all of the available CICSPlexes. NOTE it will
      * use the CMAS that it found from the CONNECT command.
      *

           INITIALIZE WS-CPSM-TEMPORARY.
           MOVE 'CMASPLEX'         TO  WS-CPSM-TEMPORARY-OBJECT.
           MOVE CMASPLEX-TBL-LEN   TO  WS-CPSM-TEMPORARY-LENGTH.
           MOVE 0                  TO  WS-CPSM-TEMPORARY-COUNT.
           MOVE SPACES             TO  WS-CPSM-TEMPORARY-CRITERIA.
           MOVE SPACES             TO  WS-CPSM-TEMPORARY-PARM.
           MOVE WS-THREAD-CICSPLEX TO  WS-CPSM-TEMPORARY-THREAD.

           PERFORM GET-RESULT-SET.

      *
      *    Check the RESPONSE from the CPSM GET command. If no data
      *    was found on the CMASPLEX table or there was an error
      *    returned on the GET then there is a serious issue
      *    and we should abandon processing.
      *
           IF WS-RESPONSE EQUAL EYUVALUE(NODATA) OR
           WS-RESPONSE NOT EQUAL EYUVALUE(OK)
      D       DISPLAY 'CMASPLEX GET failed'

              MOVE 'CMASPLEX'         TO WS-FAILURE-COMMAND
              MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
              MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

              PERFORM GET-CPSM-COMMAND-FAILURE
              PERFORM GET-ME-OUT-OF-HERE
           END-IF.

           MOVE WS-CPSM-TEMPORARY-RESULT-SET
                                        TO WS-CPSM-CMASPLEX-RESULT-SET.
           MOVE WS-CPSM-TEMPORARY-COUNT TO WS-CPSM-CMASPLEX-COUNT.

      *
      *    Initialise the array for storing the CICSPLEX names
      *    and the counter to drive the subscript.
      *
           MOVE SPACES TO WS-CICSPLEX-NAME-ARRAY.
           MOVE 0 TO WS-CICSPLEX-NAME-CNT.


      *
      *    Loop around the number of returned CMASPLEX records
      *    fetching each in turn.
      *
           PERFORM VARYING WS-TEMP-RECORDS-1
                   FROM 1 BY 1
                   UNTIL WS-TEMP-RECORDS-1 > WS-CPSM-CMASPLEX-COUNT

      *
      *       Retrieve (FETCH) the next record returned in the
      *       Result Set
      *
              MOVE CMASPLEX-TBL-LEN TO WS-CPSM-TEMPORARY-LENGTH

              MOVE WS-CPSM-TEMPORARY-LENGTH TO WS-DISPLAY-LENGTH

              EXEC CPSM FETCH INTO(CMASPLEX)
                              LENGTH(WS-CPSM-TEMPORARY-LENGTH)
                              RESULT(WS-CPSM-CMASPLEX-RESULT-SET)
                              THREAD(WS-THREAD-CICSPLEX)
                              RESPONSE(WS-RESPONSE)
                              REASON(WS-REASON)
              END-EXEC


      *
      *       If the FETCH failed ... stop now
      *
              IF  WS-RESPONSE NOT EQUAL EYUVALUE(OK)
      D          DISPLAY 'CMASPLEX FETCH failed'
                 MOVE 'FETCH'            TO WS-FAILURE-COMMAND
                 MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
                 MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

                 PERFORM GET-CPSM-COMMAND-FAILURE
                 PERFORM GET-ME-OUT-OF-HERE
              END-IF

      *
      *       If the FETCH of the CMASPLEX worked, store the
      *       CICSPlex NAME in the CPLEXNAME array.
      *
              ADD 1 TO WS-CICSPLEX-NAME-CNT

              MOVE PLEXNAME OF CMASPLEX TO
                 WS-CICSPLEX-NAME-STORE(WS-CICSPLEX-NAME-CNT)

           END-PERFORM.

      *
      *    Having stored all of the CICSPLEX names in the
      *    WS_CICSPLEX-NAME-STORE array we next need to see which
      *    CICSplex contains the CICSRGN APPLID that this API program
      *    is executing under (retrieved earlier). This is achieved
      *    by first amending the context and scope, using a
      *    QUALIFY command, to set it to the CICSplex name and then
      *    accessing the CICSRGN table.
      *    Since an APPLID can only ever belong to one CICSplex, the
      *    CICSplex containing the APPLID MUST be the CICSplex in
      *    use.
      *

           MOVE 'N' TO WS-CICSPLEX-KNOWN.

           PERFORM VARYING WS-TEMP-RECORDS-1
           FROM 1 BY 1
           UNTIL WS-TEMP-RECORDS-1 > WS-CICSPLEX-NAME-CNT OR
           WS-CICSPLEX-KNOWN = 'Y'

              MOVE 'CICSRGN'         TO WS-CPSM-TEMPORARY-OBJECT
              MOVE CICSRGN-TBL-LEN   TO WS-CPSM-TEMPORARY-LENGTH
              MOVE 0                 TO WS-CPSM-TEMPORARY-COUNT

      *
      *       Set up a CRITERIA string containing the APPLID
      *
              STRING 'APPLID=' DELIMITED BY SIZE,
                      WS-APPLID DELIMITED BY SPACE,
                      '.' DELIMITED BY SIZE
                      INTO WS-CPSM-TEMPORARY-CRITERIA

              MOVE SPACES             TO WS-CPSM-TEMPORARY-PARM
              MOVE WS-THREAD-CICSPLEX TO WS-CPSM-TEMPORARY-THREAD

              MOVE SPACES TO WS-CPSM-TEMPORARY-SCOPE

              STRING WS-CICSPLEX-NAME-STORE (WS-TEMP-RECORDS-1)
                 DELIMITED BY SPACE INTO WS-CPSM-TEMPORARY-SCOPE

              EXEC CPSM QUALIFY
                 CONTEXT(WS-CPSM-TEMPORARY-SCOPE)
                 SCOPE(WS-CPSM-TEMPORARY-SCOPE)
                 THREAD(WS-THREAD-CICSPLEX)
                 RESPONSE(WS-RESPONSE)
                 REASON(WS-REASON)
              END-EXEC

      *
      *       If the QUALIFY fails there are serious issues so
      *       abandon the processing.
      *
              IF WS-RESPONSE NOT EQUAL EYUVALUE(OK)
      D          DISPLAY 'QUALIFY failed'
                 MOVE 'QUALIFY'          TO WS-FAILURE-COMMAND
                 MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
                 MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD
                 PERFORM GET-CPSM-COMMAND-FAILURE
                 PERFORM GET-ME-OUT-OF-HERE
              END-IF


      *
      *       Issue a GET on the CICSRGN table
      *
              PERFORM GET-RESULT-SET

      *
      *       If the CICSRGN table was successfully obtained (using
      *       a CRITERIA set to the APPLID of the CICSRGN executing
      *       this API program), then store the CICSPLEX NAME used in
      *       WS-SAVED-CICSPLEXNAME and set a flag to end the PERFORM.
      *

              IF WS-RESPONSE EQUAL EYUVALUE(OK)
                 MOVE WS-CICSPLEX-NAME-STORE (WS-TEMP-RECORDS-1) TO
                    WS-SAVED-CICSPLEXNAME
                 MOVE 'Y' TO WS-CICSPLEX-KNOWN
              END-IF

      *
      *       If the APPLID is not found then carry on (processing
      *       the next CICSPLEX name in the array).
      *
              IF WS-RESPONSE EQUAL EYUVALUE(NOTAVAILABLE) AND
              WS-REASON EQUAL EYUVALUE(SCOPE)
                 CONTINUE
              END-IF

              IF WS-RESPONSE EQUAL EYUVALUE(NODATA)
                 CONTINUE
              END-IF

      *
      *       If we get an unexpected return code abandon prcoessing
      *
              IF WS-RESPONSE NOT EQUAL EYUVALUE(OK) AND
              WS-RESPONSE NOT EQUAL EYUVALUE(NOTAVAILABLE) AND
              WS-RESPONSE NOT EQUAL EYUVALUE(NODATA)
      D          DISPLAY 'CICSRGN GET failed'
                 MOVE 'GET'              TO WS-FAILURE-COMMAND
                 MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
                 MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

                 PERFORM GET-CPSM-COMMAND-FAILURE
                 PERFORM GET-ME-OUT-OF-HERE
              END-IF

           END-PERFORM.


      *
      *    Having reached here, either the CICSPLEX name will be known
      *    & stored in WS-SAVED-CICSPLEXNAME, or it will not have been
      *    found (therefore WS-SAVED-CICSPLEXNAME will contain spaces).
      *    If WS-SAVED-CICSPLEXNAME contains spaces then there
      *    is something amiss, so exit the program.
      *
           IF WS-SAVED-CICSPLEXNAME = '        '
      D       DISPLAY 'THE CICSRGN WASNT FOUND IN ANY CICSPLEX!'

              MOVE 'GET'              TO WS-FAILURE-COMMAND
              MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
              MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

              PERFORM GET-CPSM-COMMAND-FAILURE
              PERFORM GET-ME-OUT-OF-HERE
           END-IF.


      *
      *    Do a FINAL QUALIFY to set the CICSPLEX to the one matched
      *
           EXEC CPSM QUALIFY
              CONTEXT(WS-SAVED-CICSPLEXNAME)
              SCOPE(WS-SAVED-CICSPLEXNAME)
              THREAD(WS-THREAD-CICSPLEX)
              RESPONSE(WS-RESPONSE)
              REASON(WS-REASON)
           END-EXEC.

           IF WS-RESPONSE NOT EQUAL EYUVALUE(OK)
      D          DISPLAY '2nd QUALIFY failed'
                 MOVE 'QUALIFY'          TO WS-FAILURE-COMMAND
                 MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
                 MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

                 PERFORM GET-CPSM-COMMAND-FAILURE
                 PERFORM GET-ME-OUT-OF-HERE
           END-IF.

      D    DISPLAY 'The name of the CICSplex that is running this '
      D            'program is ' WS-SAVED-CICSPLEXNAME



      *
      * At this point the API program is connected to the correct
      * CICSPLEX and is able to utilise the full CPSM API, you
      * would code the rest of the program at this point.
      *









      *
      *    Terminate the CPSM CONNECTION
      *
           EXEC CPSM TERMINATE
                     RESPONSE(WS-RESPONSE)
                     REASON(WS-REASON)
           END-EXEC.

      *
      *    Finish
      *
           PERFORM GET-ME-OUT-OF-HERE.

       A999.
           EXIT.


      *
      * Connect to the CICSplex specified in the input data
      *
       CONNECT-TO-CICSPLEX SECTION.
       CTC000.

      D    DISPLAY 'SM540API: Connect-To-CICSplex '.

           INITIALIZE WS-CPSM-PROCESS.

      *
      *    Connect to the input CICSplex
      *

           EXEC CPSM CONNECT
                     VERSION(WS-CPSM-VERSION)
                     CONTEXT(WS-INPUT-CICSPLEX)
                     SCOPE(WS-INPUT-CICSPLEX)
                     THREAD(WS-THREAD-CICSPLEX)
                     RESPONSE(WS-RESPONSE)
                     REASON(WS-REASON)
           END-EXEC.

           IF WS-RESPONSE NOT EQUAL EYUVALUE(OK)
              MOVE 'CONNECT'          TO WS-FAILURE-COMMAND
              MOVE WS-BINARY-ZERO     TO WS-FAILURE-RESULT-SET
              MOVE WS-THREAD-CICSPLEX TO WS-FAILURE-THREAD

              PERFORM GET-CPSM-COMMAND-FAILURE
              PERFORM GET-ME-OUT-OF-HERE

           END-IF.


       CTC999.
           EXIT.



       GET-RESULT-SET SECTION.
       GRS000.

      *
      * Get a Result Set for the passed Object
      * Command selected. This code copes with differing scenarios
      * e.g. whether a CRITERIA &/or a PARM statement is supplied
      *

      *
      *    Get command without a CRITERIA (no filtering)
      *
           IF WS-CPSM-TEMPORARY-CRITERIA   EQUAL   SPACES

              MOVE WS-CPSM-TEMPORARY-CRITERIA  TO  WS-TEMP-VALUE

              PERFORM GET-VALUE-LENGTH

              MOVE WS-CPSM-TEMPORARY-CRITLEN   TO  WS-TEMP-LENGTH

      *
      *       GET has no CRITERIA or PARM statement
      *
              IF WS-CPSM-TEMPORARY-PARM  EQUAL SPACES

                 MOVE 0 TO WS-CPSM-TEMPORARY-COUNT

                 EXEC CPSM GET
                           OBJECT(WS-CPSM-TEMPORARY-OBJECT)
                           COUNT(WS-CPSM-TEMPORARY-COUNT)
                           RESULT(WS-CPSM-TEMPORARY-RESULT-SET)
                           THREAD(WS-CPSM-TEMPORARY-THREAD)
                           RESPONSE(WS-RESPONSE)
                           REASON(WS-REASON)
                 END-EXEC

      *
      *       GET has no CRITERIA but includes a PARM statement
      *
              ELSE

                 MOVE WS-CPSM-TEMPORARY-PARM    TO  WS-TEMP-VALUE
                 PERFORM GET-VALUE-LENGTH
                 MOVE WS-CPSM-TEMPORARY-PARMLEN TO  WS-TEMP-LENGTH

                 MOVE WS-CPSM-TEMPORARY-PARMLEN TO  WS-DISPLAY-PARMLEN


                 MOVE LENGTH OF WS-CPSM-TEMPORARY-PARM
                    TO WS-CPSM-TEMP-PARMLEN

                 MOVE 0 TO WS-CPSM-TEMPORARY-COUNT
                 EXEC CPSM GET
                           OBJECT(WS-CPSM-TEMPORARY-OBJECT)
                           COUNT(WS-CPSM-TEMPORARY-COUNT)
                           PARM(WS-CPSM-TEMPORARY-PARM)
                           PARMLEN(WS-CPSM-TEMP-PARMLEN)
                           RESULT(WS-CPSM-TEMPORARY-RESULT-SET)
                           THREAD(WS-CPSM-TEMPORARY-THREAD)
                           RESPONSE(WS-RESPONSE)
                           REASON(WS-REASON)
                 END-EXEC

              END-IF
      *
      *    Get command with CRITERIA (filtering)
      *
           ELSE

              MOVE WS-CPSM-TEMPORARY-CRITERIA  TO WS-TEMP-VALUE

              PERFORM GET-VALUE-LENGTH

              MOVE WS-CPSM-TEMPORARY-CRITLEN   TO WS-TEMP-LENGTH

              MOVE WS-CPSM-TEMPORARY-CRITLEN   TO WS-DISPLAY-CRITLEN


      *
      *       GET has a CRITERIA (filter) but no PARM statement
      *
              IF WS-CPSM-TEMPORARY-PARM  EQUAL SPACES

                 MOVE LENGTH OF WS-CPSM-TEMPORARY-CRITERIA
                    TO WS-CPSM-TEMP-LEN
                 MOVE 0 TO WS-CPSM-TEMPORARY-COUNT

                 EXEC CPSM GET OBJECT(WS-CPSM-TEMPORARY-OBJECT)
                           COUNT(WS-CPSM-TEMPORARY-COUNT)
                           CRITERIA(WS-CPSM-TEMPORARY-CRITERIA)
                           LENGTH(WS-CPSM-TEMP-LEN)
                           RESULT(WS-CPSM-TEMPORARY-RESULT-SET)
                           THREAD(WS-CPSM-TEMPORARY-THREAD)
                           RESPONSE(WS-RESPONSE)
                           REASON(WS-REASON)
                 END-EXEC

      *
      *       GET has a CRITERIA (filter) and PARM statement
      *
              ELSE

                 MOVE WS-CPSM-TEMPORARY-PARM    TO WS-TEMP-VALUE
                 PERFORM GET-VALUE-LENGTH
                 MOVE WS-CPSM-TEMPORARY-PARMLEN TO WS-TEMP-LENGTH

                 MOVE WS-CPSM-TEMPORARY-PARMLEN TO WS-DISPLAY-PARMLEN

                 MOVE LENGTH OF WS-CPSM-TEMPORARY-CRITERIA
                    TO WS-CPSM-TEMP-LEN
                 MOVE LENGTH OF WS-CPSM-TEMPORARY-PARMLEN
                    TO WS-CPSM-TEMP-PARMLEN

                 MOVE 0 TO WS-CPSM-TEMPORARY-COUNT

                 EXEC CPSM GET
                           OBJECT(WS-CPSM-TEMPORARY-OBJECT)
                           COUNT(WS-CPSM-TEMPORARY-COUNT)
                           CRITERIA(WS-CPSM-TEMP-LEN)
                           LENGTH(WS-CPSM-TEMP-LEN)
                           PARM(WS-CPSM-TEMPORARY-PARM)
                           PARMLEN(WS-CPSM-TEMP-PARMLEN)
                           RESULT(WS-CPSM-TEMPORARY-RESULT-SET)
                           THREAD(WS-CPSM-TEMPORARY-THREAD)
                           RESPONSE(WS-RESPONSE)
                           REASON(WS-REASON)
                 END-EXEC

              END-IF

           END-IF.

           MOVE WS-CPSM-TEMPORARY-RESULT-SET  TO WS-DISPLAY-RESULT-SET.
           MOVE WS-CPSM-TEMPORARY-THREAD      TO WS-DISPLAY-THREAD.
           MOVE WS-CPSM-TEMPORARY-COUNT       TO WS-DISPLAY-COUNT-1.

           MOVE WS-RESPONSE TO WS-DISPLAY-RESPONSE.
           MOVE WS-REASON   TO WS-DISPLAY-REASON.


      *
      * Deal with a NON OK/No response reply
      *
           IF WS-RESPONSE NOT EQUAL EYUVALUE(OK) AND
              WS-RESPONSE NOT EQUAL EYUVALUE(NODATA)

              MOVE 'GET'                    TO WS-FAILURE-COMMAND
              MOVE WS-CPSM-TEMPORARY-RESULT-SET
                                            TO WS-FAILURE-RESULT-SET
              MOVE WS-CPSM-TEMPORARY-THREAD TO WS-FAILURE-THREAD

              PERFORM GET-CPSM-COMMAND-FAILURE

           END-IF.

       GRS999.
           EXIT.


      *
      * Get-Result-Set-Test (START)
      *
       GET-VALUE-LENGTH SECTION.
       GVL000.

      *
      *    Get passed parameter/criteria length
      *
           MOVE LENGTH OF WS-TEMP-VALUE   TO WS-DISPLAY-LENGTH.

           PERFORM VARYING WS-TEMP-LENGTH
                   FROM LENGTH OF WS-TEMP-VALUE BY -1
                   UNTIL WS-TEMP-VALUE(WS-TEMP-LENGTH:1) NOT = ' '

              MOVE WS-TEMP-LENGTH   TO WS-DISPLAY-LENGTH

           END-PERFORM.

       GVL999.
           EXIT.


      *
      * Get-CPSM-Command-Failure
      *
       GET-CPSM-COMMAND-FAILURE SECTION.

       GCCF000.

           MOVE WS-RESPONSE TO WS-DISPLAY-RESPONSE.
           MOVE WS-REASON   TO WS-DISPLAY-REASON.

           MOVE WS-FAILURE-RESULT-SET TO WS-DISPLAY-RESULT-SET.
           MOVE WS-FAILURE-THREAD     TO WS-DISPLAY-THREAD.


           DISPLAY 'SM540API: ' WS-FAILURE-COMMAND ' failed with '
                   'RESPONSE(' WS-DISPLAY-RESPONSE ') '
                   'REASON(' WS-DISPLAY-REASON ')'.

           IF WS-FAILURE-RESULT-SET EQUAL WS-BINARY-ZERO

              DISPLAY 'SM540API: Sorry no Feedback for '
                      WS-FAILURE-COMMAND ' with '
                      'Thread(' WS-DISPLAY-THREAD ')'
           ELSE

              DISPLAY 'SM540API: Sorry no Feedback for '
                      WS-FAILURE-COMMAND ' with '
                      'Result Set(' WS-DISPLAY-RESULT-SET ') '
                      'Thread(' WS-DISPLAY-THREAD ')'

           END-IF.

       GCCF999.
           EXIT.


      *
      * Finish processing
      *
       GET-ME-OUT-OF-HERE SECTION.
       GMOFH010.

           EXEC CICS
              RETURN
           END-EXEC.

           GOBACK.

       GMOFH999.
           EXIT.

