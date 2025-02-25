%let pgm=utl-union-tables-when-one-or-more-table-do-not-exist;

%stop_submission;

Union tables when one or more tables do not exist

        SOLUTIONS (note it appears that sql will not union a 'null' table)

            1 sas sql without macro arrays
            2 sas sql with macro arrays
            3 ksharp option nodsnferr
              https://tinyurl.com/3kjknp2m

Nice example of %if %then %do in open code and null sas tables.

For this solution I use the empty table

   empty_0_ob_1_variables.sas7bdat

data interim;
retain empty .;
run;quit;

data empty_0_ob_1_variables;
 set interim(obs=0);
run;quit;

github
https://tinyurl.com/w5au33za
https://github.com/rogerjdeangelis/utl-union-tables-when-one-or-more-table-do-not-exist

sas communities
https://tinyurl.com/4xrxvear
https://communities.sas.com/t5/SAS-Programming/one-file-or-more-of-union-not-there/m-p/958793#M374188

ksharp (datastep solution)
https://tinyurl.com/3kjknp2m
https://communities.sas.com/t5/user/viewprofilepage/user-id/18408

related repos
https://github.com/rogerjdeangelis/utl-the-six-types-of-empty-sas-datasets
deprecated
https://github.com/rogerjdeangelis/utl-the-four-types-of-empty-sas-tables

/*                 _
  ___  _ __  ___  (_)___ ___ _   _  ___
 / _ \| `_ \/ __| | / __/ __| | | |/ _ \
| (_) | |_) \__ \ | \__ \__ \ |_| |  __/
 \___/| .__/|___/ |_|___/___/\__,_|\___|
      |_|
*/

This following nion fails when a table is missing

* just in case it exists;
proc datasets lib=sd1;
  delete table2;
run;quit;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.table1 sd1.table3;
  set sashelp.class(obs=3);
run;

This fails when a table is missing

proc sql;
   create
      table want as
   select
      *
   from
      sd1.table1
   union
      all
   select
      *
   from
      sd1.table2
    union
      all
  select
      *
  from
     sd1.table3;
quit;

ERROR: Table SD1.TABLE2 doesn't have any columns.
PROC SQL requires each of its tables to have at least 1 column

/*         _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| `_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

*/

/**************************************************************************************************************************/
/*                                       |                                                  |                             */
/*                   INPUT               |                PROCESS                           |               OUTPUT        */
/*                   =====               |           (self explanatory )                    |               ======        */
/*                                       |           ===================                    |                             */
/*                                       |                                                  |                             */
/*  SD1.TABLE1                           |                                                  |                             */
/*  ==========                           | 1 SAS SQL WITHOUT MACRO ARRAYS                   |                             */
/*                                       | ==============================                   |                             */
/*    NAME      SEX    AGE               |                                                  |                             */
/*                                       | proc sql;                                        |  TABLE   NAME   SEX AGE     */
/*   Alfred      M      14               |   create                                         |                             */
/*   Alice       F      13               |     table want as                                |  table1 Alfred   M   14     */
/*   Barbara     F      13               |   %if %sysfunc(exist(sd1.table1)) %then %do;     |  table1 Alice    F   13     */
/*                                       |     select                                       |  table1 Barbara  F   13     */
/*  SD1.TABLE2 (DOES NOT EXIST)          |       'table1' as table                          |                             */
/*  ===========================          |       ,*                                         |  table3 Ronald   M   15     */
/*                                       |     from                                         |  table3 Thomas   M   11     */
/*  SD1.TABLE3                           |       sd1.table1                                 |  table3 William  M   15     */
/*  ==========                           |     union                                        |                             */
/*                                       |       all                                        |                             */
/*    NAME      SEX    AGE               |   %end;                                          |                             */
/*                                       |   %if %sysfunc(exist(sd1.table2)) %then %do;     |                             */
/*   Ronald      M      15               |   select                                         |                             */
/*   Thomas      M      11               |       'table2'  as table                         |                             */
/*   William     M      15               |       ,*                                         |                             */
/*                                       |   from                                           |                             */
/*                                       |     sd1.table2                                   |                             */
/*  * JUST IN CASE TABLE2 EXISTS         |   union                                          |                             */
/*                                       |     all                                          |                             */
/*  proc datasets lib=sd1;               |   %end;                                          |                             */
/*    delete table2;                     |   %if %sysfunc(exist(sd1.table3)) %then %do;     |                             */
/*  run;quit;                            |   select                                         |                             */
/*                                       |       'table3'  as table                         |                             */
/*  * CREATE INPUT D NOTE NO TABLE2;     |       ,*                                         |                             */
/*                                       |   from                                           |                             */
/*  options validvarname=upcase;         |     sd1.table3                                   |                             */
/*  libname sd1 "d:/sd1";                |   union                                          |                             */
/*  data sd1.table1 sd1.table3;          |      all                                         |                             */
/*    set sashelp.class                  |   %end;                                          |                             */
/*        (keep=name age sex);           |   select                                         |                             */
/*    if _n_ < 4 then output sd1.table1; |     'empty' as dummy                             |                             */
/*    if _n_ >16 then output sd1.table3; |   from                                           |                             */
/*  run;                                 |      empty_0_ob_1_variables                      |                             */
/*                                       |   ;quit;                                         |                             */
/*  NULL SAS DATSET                      | ;quit;                                           |                             */
/*  ===============                      |                                                  |                             */
/*                                       |--------------------------------------------------------------------------------*/
/*  data interim;                        |                                                  |                             */
/*  retain NULL .;                       | 2 SAS SQL WITH MACRO ARRAYS                      |                             */
/*  run;quit;                            | ===========================                      |                             */
/*                                       |                                                  |                             */
/*  data empty_0_ob_1_variables;         | IF YOU HAVE MANY TABLES                          |                             */
/*   set interim(obs=0);                 |                                                  |                             */
/*  run;quit;                            | %array(_un,values=1-3);                          |                             */
/*                                       |                                                  |                             */
/*  /*                      var  value   | proc sql;                                        |                             */
/*  Observations         0  NULL   .     |   create                                         |                             */
/*  Variables            1               |      table want as                               |                             */
/*  Indexes              0               |   %do_over(_un,phrase=%nrstr(                    |                             */
/*  Observation Length   8               |     %if %sysfunc(exist(work.table?)) %then %do;  |                             */
/*  Deleted Observations 0               |       select                                     |                             */
/*  */                                   |         "table?" as table                        |                             */
/*                                       |         ,*                                       |                             */
/*                                       |       from                                       |                             */
/*                                       |         sd1.table?                               |                             */
/*                                       |       union                                      |                             */
/*                                       |         all                                      |                             */
/*                                       |     %end;                                        |                             */
/*                                       |     ))                                           |                             */
/*                                       |       select                                     |                             */
/*                                       |         "empty" as table                         |                             */
/*                                       |       from                                       |                             */
/*                                       |         empty_0_ob_1_variables                   |                             */
/*                                       | ;quit;                                           |                             */
/*                                       |                                                  |                             */
/*                                       |                                                  |                             */
/*                                       | LOG WILL HAVE GENERATED CODE(options mprint)     |                             */
/*                                       |                                                  |                             */
/*                                       |  select "table1" as table ,*                     |                             */
/*                                       |    from sd1.table1 union all                     |                             */
/*                                       | select "table3" as table ,*                      |                             */
/*                                       |    from sd1.table3 union all                     |                             */
/*                                       | select "empty" as table                          |                             */
/*                                       | from  empty_0_ob_1_variables                     |                             */
/*                                       |                                                  |                             */
/*                                       |                                                  |                             */
/*                                       |--------------------------------------------------------------------------------*/
/*                                       |                                                  |                             */
/*                                       | 2 KSHARP OPTION NODSNFERR                        |  NAME   SEX AGE             */
/*                                       | ==========================                       |                             */
/*                                       |                                                  | Alfred   M   14             */
/*                                       | options nodsnferr;                               | Alice    F   13             */
/*                                       |                                                  | Barbara  F   13             */
/*                                       | options nodsnferr;                               |                             */
/*                                       | data want ;                                      | Ronald   M   15             */
/*                                       |   set sd1.table1 sd1.table2 sd1.table3;          | Thomas   M   11             */
/*                                       | run;                                             | William  M   15             */
/*                                       |                                                  |                             */
/*                                       | options dsnferr;                                 |                             */
/*                                       |                                                  |                             */
/*************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

proc datasets lib=sd1 nodetails nolist;
  delete table2;
run;quit;

* CREATE INPUT D NOTE NO TABLE2;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.table1 sd1.table3;
  set sashelp.class
      (keep=name age sex);
  if _n_ < 4 then output sd1.table1;
  if _n_ >16 then output sd1.table3;
run;quit;

data interim;
retain NULL .;
run;quit;

data empty_0_ob_1_variables;
 set interim(obs=0);
run;quit;


/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.TABLE1                                                                                                             */
/* ==========                                                                                                             */
/*                                                                                                                        */
/*   NAME      SEX    AGE                                                                                                 */
/*                                                                                                                        */
/*  Alfred      M      14                                                                                                 */
/*  Alice       F      13                                                                                                 */
/*  Barbara     F      13                                                                                                 */
/*                                                                                                                        */
/* SD1.TABLE2 (DOES NOT EXIST)                                                                                            */
/* ===========================                                                                                            */
/*                                                                                                                        */
/* SD1.TABLE3                                                                                                             */
/* ==========                                                                                                             */
/*                                                                                                                        */
/*   NAME      SEX    AGE                                                                                                 */
/*                                                                                                                        */
/*  Ronald      M      15                                                                                                 */
/*  Thomas      M      11                                                                                                 */
/*  William     M      15                                                                                                 */
/*                                                                                                                        */
/*                                                                                                                        */
/*  WORK.EMPTY_0_OB_1_VARIABLES                                                                                           */
/*                                                                                                                        */
/*                          var  value                                                                                    */
/*  Observations         0  NULL   .                                                                                      */
/*  Variables            1                                                                                                */
/*  Indexes              0                                                                                                */
/*  Observation Length   8                                                                                                */
/*  Deleted Observations 0                                                                                                */
/*                                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                             _            _ _   _                 _
/ |  ___  __ _ ___   ___  __ _| | __      _(_) |_| |__   ___  _   _| |_  _ __ ___   __ _  ___ _ __ ___     __ _ _ __ _ __ __ _ _   _ ___
| | / __|/ _` / __| / __|/ _` | | \ \ /\ / / | __| `_ \ / _ \| | | | __|| `_ ` _ \ / _` |/ __| `__/ _ \   / _` | `__| `__/ _` | | | / __|
| | \__ \ (_| \__ \ \__ \ (_| | |  \ V  V /| | |_| | | | (_) | |_| | |_ | | | | | | (_| | (__| | | (_) | | (_| | |  | | | (_| | |_| \__ \
|_| |___/\__,_|___/ |___/\__, |_|   \_/\_/ |_|\__|_| |_|\___/ \__,_|\__||_| |_| |_|\__,_|\___|_|  \___/   \__,_|_|  |_|  \__,_|\__, |___/
                            |_|                                                                                                |___/

*/

proc datasets lib=sd1 nolist nodetails;
 delete want;
run;quit;

proc sql;
  create
    table want as
  %if %sysfunc(exist(sd1.table1)) %then %do;
    select
      'table1' as table
      ,*
    from
      sd1.table1
    union
      all
  %end;
  %if %sysfunc(exist(sd1.table2)) %then %do;
  select
      'table2'  as table
      ,*
  from
    sd1.table2
  union
    all
  %end;
  %if %sysfunc(exist(sd1.table3)) %then %do;
  select
      'table3'  as table
      ,*
  from
    sd1.table3
  union
     all
  %end;
  select
    'empty' as dummy
  from
     empty_0_ob_1_variables
  ;quit;
;quit;

/**************************************************************************************************************************/
/*  TABLE      NAME      SEX    AGE                                                                                       */
/*                                                                                                                        */
/*  table1    Alfred      M      14                                                                                       */
/*  table1    Alice       F      13                                                                                       */
/*  table1    Barbara     F      13                                                                                       */
/*                                                                                                                        */
/*  table3    Ronald      M      15                                                                                       */
/*  table3    Thomas      M      11                                                                                       */
/*  table3    William     M      15                                                                                       */
/**************************************************************************************************************************/

/*___                              _            _ _   _
|___ \   ___  __ _ ___   ___  __ _| | __      _(_) |_| |__   _ __ ___   __ _  ___ _ __ ___     __ _ _ __ _ __ __ _ _   _ ___
  __) | / __|/ _` / __| / __|/ _` | | \ \ /\ / / | __| `_ \ | `_ ` _ \ / _` |/ __| `__/ _ \   / _` | `__| `__/ _` | | | / __|
 / __/  \__ \ (_| \__ \ \__ \ (_| | |  \ V  V /| | |_| | | || | | | | | (_| | (__| | | (_) | | (_| | |  | | | (_| | |_| \__ \
|_____| |___/\__,_|___/ |___/\__, |_|   \_/\_/ |_|\__|_| |_||_| |_| |_|\__,_|\___|_|  \___/   \__,_|_|  |_|  \__,_|\__, |___/
                                |_|                                                                                |___/
*/

%array(_un,values=1-3);

proc sql;
  create
     table want as
  %do_over(_un,phrase=%nrstr(
     %if %sysfunc(exist(work.table?)) %then %do;
       select
         "table?" as table
         ,*
       from
         sd1.table?
       union
         all
     %end;
     ))
       select
         "empty" as table
       from
         empty_0_ob_1_variables
;quit;


/**************************************************************************************************************************/
/*  TABLE      NAME      SEX    AGE                                                                                       */
/*                                                                                                                        */
/*  table1    Alfred      M      14                                                                                       */
/*  table1    Alice       F      13                                                                                       */
/*  table1    Barbara     F      13                                                                                       */
/*                                                                                                                        */
/*  table3    Ronald      M      15                                                                                       */
/*  table3    Thomas      M      11                                                                                       */
/*  table3    William     M      15                                                                                       */
/*                                                                                                                        */
/*  LOG WILL HAVE GENERATED CODE(options mprint)                                                                          */
/*                                                                                                                        */
/*  select "table1" as table ,*                                                                                           */
/*     from sd1.table1 union all                                                                                          */
/*  select "table3" as table ,*                                                                                           */
/*     from sd1.table3 union all                                                                                          */
/*  select "empty" as table                                                                                               */
/*  from  empty_0_ob_1_variables                                                                                          */
/*                                                                                                                        */
/*  MINOR EDITED GENERATED CODE. MODIFIED CODE ELIMINATES ALL TABLES THAT DO NOT EXIST. CODE WORKS IN SAS R PYTHON EXCEL  */
/*                                                                                                                        */
/*  select "table1" as table ,*                                                                                           */
/*     from sd1.table1 union all                                                                                          */
/*  select "table3" as table ,*                                                                                           */
/*     from sd1.table3                                                                                                    */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____   _        _                                    _   _                              _            __
|___ /  | | _____| |__   __ _ _ __ _ __     ___  _ __ | |_(_) ___  _ __   _ __   ___   __| |___ _ __  / _| ___ _ __ _ __
  |_ \  | |/ / __| `_ \ / _` | `__| `_ \   / _ \| `_ \| __| |/ _ \| `_ \ | `_ \ / _ \ / _` / __| `_ \| |_ / _ \ `__| `__|
 ___) | |   <\__ \ | | | (_| | |  | |_) | | (_) | |_) | |_| | (_) | | | || | | | (_) | (_| \__ \ | | |  _|  __/ |  | |
|____/  |_|\_\___/_| |_|\__,_|_|  | .__/   \___/| .__/ \__|_|\___/|_| |_||_| |_|\___/ \__,_|___/_| |_|_|  \___|_|  |_|
                                  |_|           |_|
*/

options nodsnferr;

options nodsnferr;
data want ;
  set sd1.table1 sd1.table2 sd1.table3;
run;

options dsnferr;

/*************************************************************************************************************************/
/*     NAME   SEX AGE                                                                                                    */
/*                                                                                                                       */
/*    Alfred   M   14                                                                                                    */
/*    Alice    F   13                                                                                                    */
/*    Barbara  F   13                                                                                                    */
/*                                                                                                                       */
/*    Ronald   M   15                                                                                                    */
/*    Thomas   M   11                                                                                                    */
/*    William  M   15                                                                                                    */
/*************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
