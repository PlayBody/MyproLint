&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win
/*------------------------------------------------------------------------

    File:       prolint/outputhandlers/logwin.w

    Copyright (C) 2001,2002 Jurjen Dijkstra

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{prolint/core/dlc-version.i}

DEFINE TEMP-TABLE tt_lint NO-UNDO
   FIELD ttDescription AS CHAR    LABEL "description":T FORMAT "x(150)":U
   FIELD ttSeverity    AS INTEGER LABEL "severity":T    FORMAT "9":U
   FIELD ttCompUnit    AS CHAR    LABEL "compilation unit":T   FORMAT "x(64)":U
   FIELD ttSource      AS CHAR    LABEL "source":T      FORMAT "x(64)":U
   FIELD ttLine        AS INTEGER LABEL "line":T        FORMAT ">>>>9":U
   FIELD ttRuleID      AS CHAR    LABEL "rule":T        FORMAT "x(15)":U
   INDEX tt1 AS PRIMARY ttCompUnit ttSource ttLine.

DEFINE VARIABLE hStatusbar     AS HANDLE    NO-UNDO.
DEFINE VARIABLE iStatusFields  AS INTEGER   NO-UNDO.
DEFINE VARIABLE numWarnings    AS INTEGER   NO-UNDO.
DEFINE VARIABLE starttime      AS INTEGER   NO-UNDO.
DEFINE VARIABLE elapsedtime    AS INTEGER   NO-UNDO.
DEFINE VARIABLE CurrentProfile AS CHARACTER NO-UNDO.

/* filters (WHERE-clause for tt_lint) */
DEFINE VARIABLE fltDesc        AS CHARACTER NO-UNDO INITIAL "*":U.
DEFINE VARIABLE fltMaxSeverity AS INTEGER   NO-UNDO INITIAL 9.
DEFINE VARIABLE fltMinSeverity AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE fltCompUnit    AS CHARACTER NO-UNDO INITIAL "*":U.
DEFINE VARIABLE fltSource      AS CHARACTER NO-UNDO INITIAL "*":U.
DEFINE VARIABLE fltRule        AS CHARACTER NO-UNDO INITIAL "*":U.

&GLOBAL-DEFINE WHERE_TT WHERE tt_lint.ttDescription MATCHES fltDesc ~
                          AND tt_lint.ttSeverity    <=      fltMaxSeverity ~
                          AND tt_lint.ttSeverity    >=      fltMinSeverity ~
                          AND tt_lint.ttCompUnit    MATCHES fltCompunit ~
                          AND tt_lint.ttSource      MATCHES fltSource ~
                          AND tt_lint.ttRuleId      MATCHES fltRule

&GLOBAL-DEFINE WHERE_TMP WHERE tmp_lint.ttDescription MATCHES fltDesc ~
                           AND tmp_lint.ttSeverity    <=      fltMaxSeverity ~
                           AND tmp_lint.ttSeverity    >=      fltMinSeverity ~
                           AND tmp_lint.ttCompUnit    MATCHES fltCompunit ~
                           AND tmp_lint.ttSource      MATCHES fltSource ~
                           AND tmp_lint.ttRuleId      MATCHES fltRule


/* how is tt_lint sorted ? */
DEFINE VARIABLE sorting        AS INTEGER NO-UNDO INITIAL 1.
DEFINE VARIABLE srtDefault     AS INTEGER NO-UNDO INITIAL 1 /* constant */.
DEFINE VARIABLE srtDescription AS INTEGER NO-UNDO INITIAL 2 /* constant */.
DEFINE VARIABLE srtSeverity    AS INTEGER NO-UNDO INITIAL 3 /* constant */.
DEFINE VARIABLE srtCompunit    AS INTEGER NO-UNDO INITIAL 4 /* constant */.
DEFINE VARIABLE srtRule        AS INTEGER NO-UNDO INITIAL 5 /* constant */.

/* external source editor: */
DEFINE VARIABLE cfgExtEditorProgram    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cfgExtEditorParameters AS CHARACTER NO-UNDO.

/* make this window ADEPersistent */
{prolint/core/_adetool.i}


/* OS-COMMAND, but better: */
PROCEDURE ShellExecuteA EXTERNAL "shell32.dll":U PERSISTENT:
   DEFINE INPUT PARAMETER HWND         AS LONG NO-UNDO.
   DEFINE INPUT PARAMETER lpOperation  AS CHAR NO-UNDO.
   DEFINE INPUT PARAMETER lpFile       AS CHAR NO-UNDO.
   DEFINE INPUT PARAMETER lpParameters AS CHAR NO-UNDO.
   DEFINE INPUT PARAMETER lpDirectory  AS CHAR NO-UNDO.
   DEFINE INPUT PARAMETER nShowCmd     AS LONG NO-UNDO.
   DEFINE RETURN PARAMETER hInstance   AS LONG NO-UNDO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME brw_results

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_lint

/* Definitions for BROWSE brw_results                                   */
&Scoped-define FIELDS-IN-QUERY-brw_results tt_lint.ttDescription tt_lint.ttSeverity tt_lint.ttCompUnit tt_lint.ttSource tt_lint.ttLine tt_lint.ttRuleID
&Scoped-define ENABLED-FIELDS-IN-QUERY-brw_results tt_lint.ttDescription /* to enable start-search event */
&Scoped-define ENABLED-TABLES-IN-QUERY-brw_results tt_lint
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brw_results tt_lint
&Scoped-define SELF-NAME brw_results
&Scoped-define OPEN-QUERY-brw_results /* open query {&self-name} for each tt_lint. */ /* comment has to stay there or AppBuilder will get confused */ RUN SortBrowse.
&Scoped-define TABLES-IN-QUERY-brw_results tt_lint
&Scoped-define FIRST-TABLE-IN-QUERY-brw_results tt_lint


/* Definitions for FRAME DEFAULT-FRAME                                  */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btn_desktop btn_more Btn_save Btn_Import ~
Btn_Filter Btn_Delete Btn_Help tg_top brw_results
&Scoped-Define DISPLAYED-OBJECTS tg_top

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brw_results
       MENU-ITEM m_Open_source_in_external_edi LABEL "Open source in external editor":T
       MENU-ITEM m_Lint_this_source_again LABEL "Lint this source again":T
       MENU-ITEM m_Delete_this_row LABEL "Delete this row":T
       MENU-ITEM m_Help_on_this_rule LABEL "Help on this rule":T.


/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Delete
     LABEL "&Delete":T
     SIZE 15 BY 1.14.

DEFINE BUTTON btn_desktop
     LABEL "Desk&Top":T
     SIZE 15 BY 1.14.

DEFINE BUTTON Btn_Filter
     LABEL "&Filter":T
     SIZE 15 BY 1.14.

DEFINE BUTTON Btn_Help
     LABEL "&Help":T
     SIZE 15 BY 1.14.

DEFINE BUTTON Btn_Import
     LABEL "&Import log":T
     SIZE 15 BY 1.14.

DEFINE BUTTON btn_more
     LABEL "&Lint Files":T
     SIZE 15 BY 1.14.

DEFINE BUTTON Btn_save
     LABEL "&Save log As":T
     SIZE 15 BY 1.14.

DEFINE VARIABLE tg_top AS LOGICAL INITIAL no
     LABEL "Top&Only":T
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .81 NO-UNDO.

DEFINE BUTTON btn_again2
     LABEL "Lint this c.u. &Again":T
     SIZE 28 BY 1.

DEFINE BUTTON btn_edit
     LABEL "Open sourcefile in &Editor":T
     SIZE 28 BY 1.

DEFINE BUTTON btn_helprule
     LABEL "Help on this &Rule":T
     SIZE 28 BY 1.

DEFINE VARIABLE ed_compunit AS CHARACTER FORMAT "X(256)":U
     LABEL "Compilation unit":T
     VIEW-AS FILL-IN
     SIZE 66 BY 1 NO-UNDO.

DEFINE VARIABLE ed_description AS CHARACTER FORMAT "X(256)":U
     LABEL "Description":T
     VIEW-AS FILL-IN
     SIZE 95 BY 1 NO-UNDO.

DEFINE VARIABLE ed_rule AS CHARACTER FORMAT "X(256)":U
     LABEL "Rule":T
     VIEW-AS FILL-IN
     SIZE 41 BY 1 NO-UNDO.

DEFINE VARIABLE ed_severity AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Severity":T
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE ed_sourcefile AS CHARACTER FORMAT "X(256)":U
     LABEL "Sourcefile":T
     VIEW-AS FILL-IN
     SIZE 66 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brw_results FOR
      tt_lint SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brw_results
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brw_results C-Win _FREEFORM
  QUERY brw_results DISPLAY
      tt_lint.ttDescription LABEL "description":T FORMAT "x(150)":U  WIDTH-CHARS 45
      tt_lint.ttSeverity    LABEL "severity":T    FORMAT "9":U       WIDTH-CHARS 8
      tt_lint.ttCompUnit    LABEL "compilation unit":T   FORMAT "x(64)":U WIDTH-CHARS 30
      tt_lint.ttSource      LABEL "source":T      FORMAT "x(64)":U   WIDTH-CHARS 30
      tt_lint.ttLine        LABEL "line":T        FORMAT ">>>>9":U   WIDTH-CHARS 5
      tt_lint.ttRuleID      LABEL "rule":T        FORMAT "x(15)":U

ENABLE tt_lint.ttDescription /* to enable start-search event */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 140 BY 10.71 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frm_Info
     ed_description AT ROW 1.24 COL 19 COLON-ALIGNED WIDGET-ID 2
     ed_compunit AT ROW 2.43 COL 19 COLON-ALIGNED WIDGET-ID 4
     btn_again2 AT ROW 2.43 COL 88 WIDGET-ID 10
     ed_sourcefile AT ROW 3.62 COL 19 COLON-ALIGNED WIDGET-ID 6
     btn_edit AT ROW 3.62 COL 88 WIDGET-ID 12
     ed_rule AT ROW 4.81 COL 19 COLON-ALIGNED WIDGET-ID 8
     ed_severity AT ROW 4.81 COL 71 COLON-ALIGNED WIDGET-ID 16
     btn_helprule AT ROW 4.81 COL 88 WIDGET-ID 14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 8 ROW 13.43
         SIZE 115.2 BY 4.86 WIDGET-ID 100.

DEFINE FRAME DEFAULT-FRAME
     btn_desktop AT ROW 1 COL 1
     btn_more AT ROW 1 COL 16
     Btn_save AT ROW 1 COL 31
     Btn_Import AT ROW 1 COL 46
     Btn_Filter AT ROW 1 COL 61
     Btn_Delete AT ROW 1 COL 76
     Btn_Help AT ROW 1 COL 91
     tg_top AT ROW 1.24 COL 116
     brw_results AT ROW 2.19 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Prolint results":T
         HEIGHT             = 18.48
         WIDTH              = 140.4
         MAX-HEIGHT         = 52.86
         MAX-WIDTH          = 320
         VIRTUAL-HEIGHT     = 52.86
         VIRTUAL-WIDTH      = 320
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,T,RUN-PERSISTENT                                              */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME Size-to-Fit                                               */
/* BROWSE-TAB brw_results tg_top DEFAULT-FRAME */
ASSIGN
       FRAME DEFAULT-FRAME:SCROLLABLE       = FALSE.

ASSIGN
       brw_results:POPUP-MENU IN FRAME DEFAULT-FRAME             = MENU POPUP-MENU-brw_results:HANDLE.

/* SETTINGS FOR FRAME frm_Info
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brw_results
/* Query rebuild information for BROWSE brw_results
     _START_FREEFORM
/* open query {&self-name} for each tt_lint. */
/* comment has to stay there or AppBuilder will get confused */
RUN SortBrowse.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brw_results */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Prolint results */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Prolint results */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Prolint results */
DO:
  if c-win:width-pixels < 702
  then
    assign c-win:width-pixels = 702.
  if c-win:height-pixels < 388
  then
    assign c-win:height-pixels = 388.

  assign frame DEFAULT-FRAME:width-pixels = C-Win:width-pixels
         frame DEFAULT-FRAME:height-pixels = C-Win:height-pixels
         brw_results:width-pixels in frame DEFAULT-FRAME = C-Win:width-pixels
         hStatusBar:y = C-Win:height-pixels - 22
         frame frm_Info:y = C-Win:height-pixels - 127
         brw_results:height-pixels = c-win:height-pixels - 163 no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brw_results
&Scoped-define SELF-NAME brw_results
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brw_results C-Win
ON MOUSE-SELECT-DBLCLICK OF brw_results IN FRAME DEFAULT-FRAME
DO:
   RUN BrowseDoubleClick.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brw_results C-Win
ON START-SEARCH OF brw_results IN FRAME DEFAULT-FRAME
DO:
   run SortBrowse.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brw_results C-Win
ON VALUE-CHANGED OF brw_results IN FRAME DEFAULT-FRAME
DO:
  IF AVAILABLE tt_lint THEN
  ASSIGN
      ed_description = tt_lint.ttDescription
      ed_compunit    = tt_lint.ttCompUnit
      ed_sourcefile  = SUBSTITUTE("&2 (line &1)":T, STRING(tt_lint.ttLine),tt_lint.ttSource)
      ed_rule        = tt_lint.ttRuleID
      ed_severity    = tt_lint.ttSeverity.
  ELSE
  ASSIGN
      ed_description = ""
      ed_compunit    = ""
      ed_sourcefile  = ""
      ed_rule        = ""
      ed_severity    = 0.

  DISPLAY
      ed_description
      ed_compunit
      ed_sourcefile
      ed_rule
      ed_severity
  WITH FRAME frm_Info.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm_Info
&Scoped-define SELF-NAME btn_again2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_again2 C-Win
ON CHOOSE OF btn_again2 IN FRAME frm_Info /* Lint this c.u. Again */
DO:
    RUN BrowseLintCurrent.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define SELF-NAME Btn_Delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Delete C-Win
ON CHOOSE OF Btn_Delete IN FRAME DEFAULT-FRAME /* Delete */
DO:
   DEFINE VARIABLE answer AS LOGICAL NO-UNDO INITIAL NO.

   MESSAGE "Do you really want to delete all the results" SKIP
           "that match the current filter, i.e. all visible results?"
           VIEW-AS ALERT-BOX QUESTION
           BUTTONS YES-NO
           UPDATE answer.

   IF answer = YES THEN DO:

       FOR EACH tt_lint {&WHERE_TT} :
           DELETE tt_lint.
       END.

       /* reset filter and show remaining records: */
       RUN ClearFilter.
       RUN SortBrowse.

       /* how many records left? */
       numWarnings = 0.
       FOR EACH tt_lint :
           numWarnings = numWarnings + 1.
       END.
       RUN adecomm/_statdsp.p (hStatusBar, 3, STRING(numWarnings) + " warnings":U).

   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_desktop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_desktop C-Win
ON CHOOSE OF btn_desktop IN FRAME DEFAULT-FRAME /* DeskTop */
DO:
  RUN prolint/desktop.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm_Info
&Scoped-define SELF-NAME btn_edit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_edit C-Win
ON CHOOSE OF btn_edit IN FRAME frm_Info /* Open sourcefile in Editor */
DO:
    RUN BrowseDoubleClick.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define SELF-NAME Btn_Filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Filter C-Win
ON CHOOSE OF Btn_Filter IN FRAME DEFAULT-FRAME /* Filter */
DO:
   DEFINE VARIABLE numVisible AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE fltPersistent AS LOGICAL NO-UNDO INITIAL FALSE.

   RUN prolint/outputhandlers/dlgfilter.w (INPUT-OUTPUT fltDesc,
                                           INPUT-OUTPUT fltMaxSeverity,
                                           INPUT-OUTPUT fltMinSeverity,
                                           INPUT-OUTPUT fltCompunit,
                                           INPUT-OUTPUT fltSource,
                                           INPUT-OUTPUT fltRule,
                                           INPUT-OUTPUT fltPersistent).

   /* show number of visible warnings in the status bar */
   IF fltDesc        = "*":U AND
      fltMaxSeverity = 9     AND
      fltMinSeverity = 0     AND
      fltCompunit    = "*":U AND
      fltSource      = "*":U AND
      fltRule        = "*":U
   THEN
       RUN adecomm/_statdsp.p (hStatusBar, 3, STRING(numWarnings) + " warnings":U).
   ELSE DO:
       FOR EACH tt_lint {&WHERE_TT} :
           numVisible = numVisible + 1.
       END.
       RUN adecomm/_statdsp.p (hStatusBar, 3, STRING(numVisible) + " / " + STRING(numWarnings)).
   END.

   RUN SortBrowse.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Help C-Win
ON CHOOSE OF Btn_Help IN FRAME DEFAULT-FRAME /* Help */
DO:
   RUN ShowHelp ("../logwin":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm_Info
&Scoped-define SELF-NAME btn_helprule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_helprule C-Win
ON CHOOSE OF btn_helprule IN FRAME frm_Info /* Help on this Rule */
DO:
    RUN BrowseHelp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define SELF-NAME Btn_Import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Import C-Win
ON CHOOSE OF Btn_Import IN FRAME DEFAULT-FRAME /* Import log */
DO:
  RUN Import-tabfile.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_more
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_more C-Win
ON CHOOSE OF btn_more IN FRAME DEFAULT-FRAME /* Lint Files */
DO:
   RUN prolint/launch/start.p.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_save C-Win
ON CHOOSE OF Btn_save IN FRAME DEFAULT-FRAME /* Save log As */
DO:
  RUN export-tabfile.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Delete_this_row
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Delete_this_row C-Win
ON CHOOSE OF MENU-ITEM m_Delete_this_row /* Delete this row */
DO:
  RUN BrowseDeleteRow.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Help_on_this_rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Help_on_this_rule C-Win
ON CHOOSE OF MENU-ITEM m_Help_on_this_rule /* Help on this rule */
DO:
  RUN BrowseHelp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Lint_this_source_again
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Lint_this_source_again C-Win
ON CHOOSE OF MENU-ITEM m_Lint_this_source_again /* Lint this source again */
DO:
  RUN BrowseLintCurrent.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Open_source_in_external_edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Open_source_in_external_edi C-Win
ON CHOOSE OF MENU-ITEM m_Open_source_in_external_edi /* Open source in external editor */
DO:
  RUN BrowseDoubleClick.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg_top
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg_top C-Win
ON VALUE-CHANGED OF tg_top IN FRAME DEFAULT-FRAME /* TopOnly */
DO:
  ASSIGN tg_top.
  c-win:TOP-ONLY = tg_top.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

  /* must be done before enable_UI, else buttons are already realized */
      ASSIGN
         btn_more:FLAT-BUTTON = TRUE
         btn_desktop:FLAT-BUTTON = TRUE
         btn_save:FLAT-BUTTON = TRUE
         btn_import:FLAT-BUTTON = TRUE
         btn_filter:FLAT-BUTTON = TRUE
         btn_delete:FLAT-BUTTON = TRUE
         btn_help:FLAT-BUTTON = TRUE.
      ASSIGN
         brw_results:COLUMN-RESIZABLE = TRUE
         brw_results:COLUMN-MOVABLE = FALSE /* it disables start-search event! */
         brw_results:EXPANDABLE = TRUE.
      ASSIGN
         ed_description:READ-ONLY = TRUE
         ed_compunit:READ-ONLY = TRUE
         ed_sourcefile:READ-ONLY = TRUE
         ed_rule:READ-ONLY = TRUE
         ed_severity:READ-ONLY = TRUE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   RUN enable_UI.

   /* one column was enabled because the START-SEARCH wouldn't fire.
      now make this column read-only again! */
   tt_lint.ttDescription:read-only in browse brw_results = true.

  /* set private-data to a unique value, so Prolint can determine if this window is already running.
     if prolint can't find a window with this private data, it will lauch one. */
  c-win:PRIVATE-DATA = "prolint_outputhandler_logwin.w":U.

  RUN adecomm/_status.p (c-win:HANDLE, "50,30,10,20,5":U, FALSE, ?, OUTPUT hStatusbar, OUTPUT iStatusFields).
  hStatusBar:VISIBLE = YES.

  SUBSCRIBE TO "Prolint_InitializeResults" ANYWHERE.
  SUBSCRIBE TO "Prolint_AddResult" ANYWHERE.
  SUBSCRIBE TO "Prolint_FinalizeResults" ANYWHERE.
  SUBSCRIBE TO "Prolint_Status_action" ANYWHERE.
  SUBSCRIBE TO "Prolint_Status_FileStart" ANYWHERE.
  SUBSCRIBE TO "Prolint_Status_Profile" ANYWHERE.
  SUBSCRIBE TO "Prolint_Status_Progress" ANYWHERE.

  SUBSCRIBE TO "Prolint_Status_StartTimer" ANYWHERE.
  SUBSCRIBE TO "Prolint_Status_StopTimer" ANYWHERE.

  SUBSCRIBE TO "Prolint_SendLogWin_Ed4Win":U ANYWHERE.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BrowseDeleteRow C-Win
PROCEDURE BrowseDeleteRow :
/*------------------------------------------------------------------------------
  Purpose:     delete the current row
------------------------------------------------------------------------------*/
  IF NOT AVAILABLE tt_lint THEN RETURN.

  IF brw_results:DELETE-CURRENT-ROW() IN FRAME {&FRAME-NAME} THEN
     DELETE tt_lint.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BrowseDoubleClick C-Win
PROCEDURE BrowseDoubleClick :
/*------------------------------------------------------------------------------
  Purpose:     open sourcefile in external editor
               for example in UltraEdit-32 or Ed4Win
  Parameters:  <none>
------------------------------------------------------------------------------*/
DEFINE VARIABLE hInstance              AS INTEGER   NO-UNDO.

  IF cfgExtEditorProgram="" THEN
     RUN ReadCfgEditor.

  IF cfgExtEditorProgram="" THEN DO:
     {&_proparse_ prolint-nowarn(message)}
     MESSAGE "No external editor specified. See help for prolint/settings/exteditor.cfg":T
             VIEW-AS ALERT-BOX.
     RETURN.
  END.

  IF AVAILABLE tt_lint THEN DO:
     FILE-INFO:FILE-NAME = tt_lint.ttSource.
     RUN ShellExecuteA (0,
                        "open":U,
                        SUBSTITUTE(cfgExtEditorProgram,FILE-INFO:FULL-PATHNAME,STRING(tt_lint.ttLine)),
                        SUBSTITUTE(cfgExtEditorParameters,FILE-INFO:FULL-PATHNAME,STRING(tt_lint.ttLine)),
                        "",
                        1,
                        OUTPUT hInstance).
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BrowseHelp C-Win
PROCEDURE BrowseHelp :
/*------------------------------------------------------------------------------
  Purpose:     show help for the current browse row
------------------------------------------------------------------------------*/

  IF NOT AVAILABLE tt_lint THEN
     RUN ShowHelp ("../logwin":U).
  ELSE
     RUN ShowHelp (tt_lint.ttRuleID).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BrowseLintCurrent C-Win
PROCEDURE BrowseLintCurrent :
/*------------------------------------------------------------------------------
  Purpose:     lint the compilation unit on the current browse row again
------------------------------------------------------------------------------*/
  IF AVAILABLE tt_lint THEN
     RUN prolint/core/prolint.p (tt_lint.ttCompUnit, ?, CurrentProfile, FALSE).
  ELSE
     RUN prolint/launch/start.p.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ClearFilter C-Win
PROCEDURE ClearFilter :
/*------------------------------------------------------------------------------
  Purpose:     Reset the WHERE-clause; show all warnings
------------------------------------------------------------------------------*/

   ASSIGN
      fltDesc        = "*":U
      fltMaxSeverity = 9
      fltMinSeverity = 0
      fltCompUnit    = "*":U
      fltSource      = "*":U
      fltRule        = "*":U.

   RUN adecomm/_statdsp.p (hStatusBar, 3, STRING(numWarnings) + " warnings":U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY tg_top
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE btn_desktop btn_more Btn_save Btn_Import Btn_Filter Btn_Delete
         Btn_Help tg_top brw_results
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  DISPLAY ed_description ed_compunit ed_sourcefile ed_rule ed_severity
      WITH FRAME frm_Info IN WINDOW C-Win.
  ENABLE ed_description ed_compunit btn_again2 ed_sourcefile btn_edit ed_rule
         ed_severity btn_helprule
      WITH FRAME frm_Info IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frm_Info}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Export-tabfile C-Win
PROCEDURE Export-tabfile :
/*------------------------------------------------------------------------------
  Purpose:   export tt_lint to a tab-delimited file
------------------------------------------------------------------------------*/
  define variable tabfilename as character no-undo.
  define variable hTabfile    as handle    no-undo.
  define variable dlgOk       as logical   no-undo.

  tabfilename = "prolint.tab":U.
  system-dialog get-file tabfilename
       filters "tab-delimited":U "*.tab":U
       ask-overwrite
       return-to-start-dir
       save-as
       use-filename
       update dlgOk.

  if not dlgOk then return.


  run prolint/outputhandlers/tabfile.p persistent set hTabfile.
  run SetLogfilename in hTabfile (tabfilename).

  DEFINE BUFFER tmp_lint FOR tt_lint.
  DEFINE QUERY  qtmp FOR tmp_lint.

  CASE sorting :
      WHEN srtDefault     THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttSource BY ttLine BY ttCompUnit.
      WHEN srtDescription THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttDescription BY ttSource BY ttLine.
      WHEN srtSeverity    THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttSeverity DESCENDING BY ttSource BY ttLine.
      WHEN srtCompUnit    THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttCompUnit BY ttSource BY ttLine.
      WHEN srtRule        THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttRuleID BY ttSource BY ttLine.
  END.

  GET FIRST qtmp.
  DO WHILE AVAILABLE tmp_lint :
      RUN Prolint_AddResult IN hTabfile ( tmp_lint.ttCompUnit,
                                          tmp_lint.ttSource,
                                          tmp_lint.ttLine,
                                          tmp_lint.ttDescription,
                                          tmp_lint.ttruleID,
                                          tmp_lint.ttSeverity ).
      GET NEXT qtmp.
  END.

  RUN Prolint_FinalizeResults in hTabfile.
  MESSAGE "export completed":U view-as alert-box.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Import-tabfile C-Win
PROCEDURE Import-tabfile :
/*------------------------------------------------------------------------------
  Purpose:   import a previously saved tabfile
------------------------------------------------------------------------------*/
  define variable tabfilename as character no-undo.
  define variable cLine       as character no-undo.
  define variable delim       as character no-undo.
  define variable dlgOk       as logical   no-undo.

  define variable iSourcefile  as integer   no-undo.
  define variable iLinenumber  as integer   no-undo.
  define variable iDescription as integer   no-undo.
  define variable iRule        as integer   no-undo.
  define variable iCompunit    as integer   no-undo.
  define variable iSeverity    as integer   no-undo.


  delim = CHR(9). /* keep in sync with outputhandlers/tabfile.p! */

  /* ask for name/location of tabfile. */
  tabfilename = "prolint.tab":U.
  system-dialog get-file tabfilename
       filters "tab-delimited (*.tab)":U "*.tab":U
       return-to-start-dir
       use-filename
       update dlgOk.

  if not dlgOk then return.

  /* verify if tabfile exists */
  file-info:file-name = tabfilename.
  if file-info:full-pathname = ? then do:
     message substitute("file &1 not found":U, tabfilename) view-as alert-box.
     return.
  end.

  /* clear all current results */
  FOR EACH tt_lint :
      DELETE tt_lint.
  END.
  numWarnings = ?.

  RUN ClearFilter.

  /* import the file */
  INPUT FROM value(file-info:full-pathname).
  REPEAT :
     import unformatted cLine no-error.
     if numWarnings=? then
        assign
           iSourcefile  = lookup("sourcefile":U,cLine,delim)
           iLineNumber  = lookup("linenumber":U,cLine,delim)
           iDescription = lookup("description":U,cLine,delim)
           iRule        = lookup("rule":U,cLine,delim)
           iCompUnit    = lookup("comp.unit":U,cLine,delim)
           iSeverity    = lookup("severity":U,cLine,delim)
           numWarnings  = 0
           .
     else do:
        numWarnings = numWarnings + 1.
        create tt_lint.
        assign tt_lint.ttCompUnit    = entry(iCompUnit,cLine,delim)
               tt_lint.ttSource      = entry(iSourcefile,cLine,delim)
               tt_lint.ttLine        = integer(entry(iLineNumber,cLine,delim))
               tt_lint.ttDescription = entry(iDescription,cLine,delim)
               tt_lint.ttruleID      = entry(iRule,cLine,delim)
               tt_lint.ttSeverity    = integer(entry(iSeverity,cLine,delim)).
     end.
  END.
  INPUT CLOSE.

  RUN adecomm/_statdsp.p (hStatusBar, 3, STRING(numWarnings) + " warnings":U).

  {&OPEN-QUERY-brw_results}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_AddResult C-Win
PROCEDURE Prolint_AddResult :
/*------------------------------------------------------------------------------
  Purpose:     create a new record tt_lint
------------------------------------------------------------------------------*/
   DEFINE INPUT PARAMETER pCompilationUnit  AS CHAR    NO-UNDO.  /* the sourcefile we're parsing          */
   DEFINE INPUT PARAMETER pSourcefile       AS CHAR    NO-UNDO.  /* may be an includefile                 */
   DEFINE INPUT PARAMETER pLineNumber       AS INTEGER NO-UNDO.  /* line number in pSourceFile            */
   DEFINE INPUT PARAMETER pDescription      AS CHAR    NO-UNDO.  /* human-readable hint                   */
   DEFINE INPUT PARAMETER pRuleID           AS CHAR    NO-UNDO.  /* defines rule-program and maps to help */
   DEFINE INPUT PARAMETER pSeverity         AS INTEGER NO-UNDO.  /* importance of this rule, scale 0-9    */

   CREATE tt_lint.
   ASSIGN tt_lint.ttCompUnit    = pCompilationUnit
          tt_lint.ttSource      = pSourcefile
          tt_lint.ttLine        = pLineNumber
          tt_lint.ttDescription = pDescription
          tt_lint.ttruleID      = pRuleID
          tt_lint.ttSeverity    = pSeverity.

   numWarnings = numWarnings + 1.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_FinalizeResults C-Win
PROCEDURE Prolint_FinalizeResults :
/*------------------------------------------------------------------------------
  Purpose:     Prolint is ready. Show tt_lint in the browse widget.
               Display status=ready in statusbar
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  RUN adecomm/_statdsp.p (hStatusBar, 1, SUBSTITUTE("total time: &1 msec":T, TRIM(STRING(elapsedtime +  ETIME(NO) - starttime , ">>>,>>>,>>>,>>9":U)))).
  RUN adecomm/_statdsp.p (hStatusBar, 2, "").
  RUN adecomm/_statdsp.p (hStatusBar, 3, STRING(numWarnings) + " warnings":U).
  RUN adecomm/_statdsp.p (hStatusBar, 5, "").


  /* move the window to top */
  DO WITH FRAME {&FRAME-NAME} :
     tg_top = TRUE.
     DISPLAY tg_top.
     APPLY "value-changed":U TO tg_top.
  END.

  {&OPEN-QUERY-brw_results}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_InitializeResults C-Win
PROCEDURE Prolint_InitializeResults :
/*------------------------------------------------------------------------------
  Purpose:     start with an empty logfile.
               show in statusbar that prolint is busy
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pClearOutput AS LOGICAL NO-UNDO.

  elapsedtime = 0.
  starttime = ETIME(NO).

  RUN ClearFilter.

  IF pClearOutput THEN DO:
     FOR EACH tt_lint :
         DELETE tt_lint.
     END.
     numWarnings = 0.
     OPEN QUERY hQuery FOR EACH tt_lint NO-LOCK.
  END.

  RUN adecomm/_statdsp.p (hStatusBAr, 1, "working...":T).
  RUN adecomm/_statdsp.p (hStatusBAr, 3, STRING(numWarnings) + " warnings":U).

END PROCEDURE.


PROCEDURE Prolint_Status_StartTimer :
  starttime = ETIME(NO).
END PROCEDURE.

PROCEDURE Prolint_Status_StopTimer :
  elapsedtime = ETIME(NO) - starttime.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_SendLogWin_Ed4Win C-Win
PROCEDURE Prolint_SendLogWin_Ed4Win :
/*------------------------------------------------------------------------------
  Purpose:  send all currently selected records to "Ed for Windows"
            (using the current filter and current sorting)
------------------------------------------------------------------------------*/

  DEFINE VARIABLE hEd4win AS HANDLE NO-UNDO.

  RUN prolint/outputhandlers/ed4win.p PERSISTENT SET hEd4win.

  DEFINE BUFFER tmp_lint FOR tt_lint.
  DEFINE QUERY  qtmp FOR tmp_lint.

  CASE sorting :
      WHEN srtDefault     THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttSource BY ttLine.
      WHEN srtDescription THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttDescription.
      WHEN srtSeverity    THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttSeverity DESCENDING BY ttSource BY ttLine.
      WHEN srtCompUnit    THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttCompUnit BY ttSource BY ttLine.
      WHEN srtRule        THEN OPEN QUERY qtmp FOR EACH tmp_lint NO-LOCK {&WHERE_TMP} BY ttRuleID BY ttSource BY ttLine.
  END.

  GET FIRST qtmp.
  DO WHILE AVAILABLE tmp_lint :
      RUN Prolint_AddResult IN hEd4win ( tmp_lint.ttCompUnit,
                                         tmp_lint.ttSource,
                                         tmp_lint.ttLine,
                                         tmp_lint.ttDescription,
                                         tmp_lint.ttruleID,
                                         tmp_lint.ttSeverity ).
      GET NEXT qtmp.
  END.

  RUN Prolint_FinalizeResults IN hEd4win.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_Status_action C-Win
PROCEDURE Prolint_Status_action :
/*------------------------------------------------------------------------------
  Purpose:     show what prolint is doing, in second status panel
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pAction AS CHAR NO-UNDO.

  RUN adecomm/_statdsp.p (hStatusBAr, 2, pAction).
  RUN adecomm/_statdsp.p (hStatusBAr, 3, STRING(numWarnings) + " warnings":U).
  PROCESS EVENTS.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_Status_FileStart C-Win
PROCEDURE Prolint_Status_FileStart :
/*------------------------------------------------------------------------------
  Purpose:     show status in first status panel
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pSourceFile AS CHAR NO-UNDO.

  RUN adecomm/_statdsp.p (hStatusBar, 1, pSourceFile).

  /* in case this sourcefile was already linted earlier, delete its existing results */
  FOR EACH tt_lint WHERE tt_lint.ttCompUnit = pSourceFile :
      numWarnings = numWarnings - 1.
      DELETE tt_lint.
  END.

  PROCESS EVENTS.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_Status_Profile C-Win
PROCEDURE Prolint_Status_Profile :
/*------------------------------------------------------------------------------
  Purpose:     show profile in statusbar
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pProfile AS CHAR NO-UNDO.

  ASSIGN
     CurrentProfile = pProfile.
  RUN adecomm/_statdsp.p (hStatusBar, 4, CurrentProfile).
  PROCESS EVENTS.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prolint_Status_Progress C-Win
PROCEDURE Prolint_Status_Progress :
/*------------------------------------------------------------------------------
  Purpose:     show what prolint is doing, in second status panel
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pProgress AS CHAR NO-UNDO.

  RUN adecomm/_statdsp.p (hStatusBAr, 5, pProgress).
  PROCESS EVENTS.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ReadCfgEditor C-Win
PROCEDURE ReadCfgEditor :
/*------------------------------------------------------------------------------
  Purpose:     find out how to open a sourcefile in an external editor,
               like (for example) Ed4win or UltraEdit
  Parameters:  <none>
  Notes:       read cfgEditorProgram and cfgEditorParameters from
               a configuration file or registry
------------------------------------------------------------------------------*/

  file-info:FILE-NAME = "prolint/settings/exteditor.cfg":U.
  IF file-info:full-pathname<>? THEN DO:
     INPUT FROM VALUE(file-info:FULL-PATHNAME).
       IMPORT UNFORMATTED cfgExtEditorProgram.
       IMPORT UNFORMATTED cfgExtEditorParameters.
     INPUT CLOSE.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ShowHelp C-Win
PROCEDURE ShowHelp :
/*------------------------------------------------------------------------------
  Purpose:     show help. For easy maintenance we will use separate HTM files
               instead of a compiled helpfile
  Parameters:  pContext = ruleid
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pContext AS CHAR NO-UNDO.

  DEF VAR ReturnValue AS INTEGER NO-UNDO.
  DEF VAR fullpath    AS CHARACTER NO-UNDO.

  /* try to locate custom help.
     If not found, then try to locate default help */
  FILE-INFO:FILE-NAME = "prolint/custom/help/rules/":U + pContext + ".htm":U.
  IF FILE-INFO:FULL-PATHNAME<>? THEN
     fullpath = file-info:FULL-PATHNAME.
  ELSE
     fullpath = "http://oehive.org/prolint/rules/":U + pContext.

  RUN prolint/core/openhtml.p(fullpath).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SortBrowse C-Win
PROCEDURE SortBrowse :
/*------------------------------------------------------------------------------
  Purpose:     reopen query, sorted according to clicked browse column
------------------------------------------------------------------------------*/
  DEFINE VARIABLE hColumn AS HANDLE NO-UNDO.
  hColumn = brw_results:CURRENT-COLUMN in frame {&frame-name}.

  IF VALID-HANDLE(hColumn) THEN
     CASE hColumn:NAME :
         WHEN "ttDescription":U THEN  sorting = srtDescription.
         WHEN "ttSeverity":U    THEN  sorting = srtSeverity.
         WHEN "ttCompUnit":U    THEN  sorting = srtCompunit.
         WHEN "ttSource":U      THEN  sorting = srtDefault.
         WHEN "ttLine":U        THEN  sorting = srtDefault.
         WHEN "ttRuleID":U      THEN  sorting = srtRule.
         OTHERWISE                    sorting = srtDefault.
     END CASE.

  CASE sorting :
      WHEN srtDefault     THEN OPEN QUERY  brw_results FOR EACH tt_lint NO-LOCK {&WHERE_TT} BY ttSource BY ttLine BY ttCompUnit.
      WHEN srtDescription THEN OPEN QUERY  brw_results FOR EACH tt_lint NO-LOCK {&WHERE_TT} BY ttDescription BY ttSource BY ttLine.
      WHEN srtSeverity    THEN OPEN QUERY  brw_results FOR EACH tt_lint NO-LOCK {&WHERE_TT} BY ttSeverity DESCENDING BY ttSource BY ttLine.
      WHEN srtCompUnit    THEN OPEN QUERY  brw_results FOR EACH tt_lint NO-LOCK {&WHERE_TT} BY ttCompUnit BY ttSource BY ttLine.
      WHEN srtRule        THEN OPEN QUERY  brw_results FOR EACH tt_lint NO-LOCK {&WHERE_TT} BY ttRuleID BY ttSource BY ttLine.
  END.

  /* show in statusbar if there is an active filter */
  IF fltDesc="*":U AND
     fltMaxSeverity=9 AND
     fltMinSeverity=0 AND
     fltCompunit="*":U AND
     fltSource="*":U AND
     fltRule="*":U
  THEN
     RUN adecomm/_statdsp.p (hStatusBAr, 5, "").
  ELSE
     RUN adecomm/_statdsp.p (hStatusBAr, 5, "filtered").

  APPLY "value-changed":U TO brw_results IN FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
