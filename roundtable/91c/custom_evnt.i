/* =============================================================================
   file    : prolint/roundtable/91c/custom_evnt.i
   purpose : (to be included in roundtable/rtb_evnt.p)
             setup integration between Prolint and Roundtable
   -----------------------------------------------------------------------------
   Copyright (C) 2001,2002,2003 Jurjen Dijkstra /
                                Gerry Winning /
                                Ildefonzo Arocha

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
   ========================================================================== */

DEFINE NEW GLOBAL SHARED VARIABLE vhRtbCustFunc AS HANDLE NO-UNDO.
&IF (DEFINED(prolint_rtb_custom_evnt_i)=0) &THEN
  &GLOBAL-DEFINE prolint_rtb_custom_evnt_i FOO

  /* Start prolint only if RoundTable is not run using the RTB API */
  DEFINE VARIABLE iCountStack AS INTEGER NO-UNDO INITIAL 1.
  DEFINE VARIABLE lFound_rtb  AS LOGICAL NO-UNDO INITIAL FALSE.
  DEFINE NEW GLOBAL SHARED VARIABLE glob_completingtask AS INTEGER NO-UNDO INITIAL 0.
  DEFINE VARIABLE lintresult AS LOGICAL NO-UNDO.

  DO WHILE PROGRAM-NAME( iCountStack ) <> ?:
    IF INDEX( PROGRAM-NAME( iCountStack ) , "_rtb.p" ) <> 0 OR
       INDEX( PROGRAM-NAME( iCountStack ) , "_rtb.r" ) <> 0 or
       INDEX( PROGRAM-NAME( iCountStack ) , "rtbstart.p" ) <> 0 OR
       index( PROGRAM-NAME( iCountStack ) , "rtbstart.r" ) <> 0 
       THEN
         lFound_rtb = TRUE.
    iCountStack = iCountStack + 1.
  END.

  IF lFound_rtb THEN DO:
    /* this defines function fnMoveHtmlW, among other functions: */
    {prolint/roundtable/91c/rt_customfunc.i}

    /* Add Prolint button and menu-options to Roundtable desktop:
       choose an event, based on the following criteria:
         - event must occur before you can select an object or a task
         - must not occur very often so this doesn't take much performance overhead
       I guess event "BEFORE-CHANGE-WORKSPACE" is the best available candidate.
    */
    IF p_event = "BEFORE-CHANGE-WORKSPACE":U THEN
       RUN prolint/roundtable/91c/addmenu.p.

    /* In case the object is a (webspeed) *.html file:
       This moves the generated .w next to the .html off of either the workspace
       or task directory.  */
    IF p_event = "OBJECT-COMPILE":U THEN
      IF p_other matches "*~~.htm*":U THEN
       DYNAMIC-FUNCTION("fnRtbMoveHtmlW":U, p_context).


    /* the following events prevent an object to be checked-in if Prolint
       finds too many issues. Prolint uses profile "roundtable check-in" for this.
       If you don't agree, just clear this profile (e.g. disable every rule in that
       profile) */

    IF p_product="Roundtable":U AND p_event = "TASK-COMPLETE-BEFORE":U AND p_ok=TRUE THEN DO:
       glob_completingtask = INTEGER(p_other).
       /* Lint every object in this task.
          Cancel task-completion when prolint finds too many issues */
       RUN prolint/roundtable/91c/checkin-event.p (NO, INPUT glob_completingtask, INPUT ?, OUTPUT lintresult).
       IF lintresult=YES THEN
          p_ok = TRUE.
       ELSE DO:
          p_ok = FALSE.
          glob_completingtask = 0.
          RETURN.  /* return before some other hook, like Dynamics, says p_ok=TRUE */
       END.
    END.

    IF p_product="Roundtable":U AND p_event = "OBJECT-CHECK-IN-BEFORE":U AND p_ok=TRUE THEN DO:
       /* don't lint objects while you are completing a task, because
          this is already done during TASK-COMPLETE-BEFORE */
       IF glob_completingtask<>0 THEN
          p_ok = TRUE.
       ELSE DO:
          /* if you are not completing a task, then lint this object. */
          RUN prolint/roundtable/91c/checkin-event.p (NO, INPUT ?, INPUT INTEGER(p_context), OUTPUT lintresult).
          p_ok = lintresult.
          IF NOT p_ok THEN
             RETURN.  /* return before some other hook, like Dynamics, says p_ok=TRUE */
       END.
    END.

    IF p_product="Roundtable":U AND p_event = "TASK-COMPLETE":U THEN
       glob_completingtask = 0.

  END.
&ENDIF
                                   
