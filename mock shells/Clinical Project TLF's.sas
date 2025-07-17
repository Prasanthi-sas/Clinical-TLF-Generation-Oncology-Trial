

1.Title: Summary of Adverse Events by Severity

Population: Safety Population (All subjects who received at least one dose of study treatment)
Dataset Source: ADaM.ADAE

2.
-------------------------------------------------------------------
Severity Level       	Number of Subjects (n)     	Percentage (%)
-------------------------------------------------------------------
Mild	                         xx	                  xx.x %
Moderate	                     xx	                  xx.x %
Severe	                         xx	                  xx.x %
Total	                         xx	                  100.0 %
--------------------------------------------------------------------

3.Footnotes:
"Severity Level" is based on the AESEV variable coded as:

1 = Mild

2 = Moderate

3 = Severe

A subject may be counted once for each severity level if they had multiple AEs.
Percentages are based on the total number of subjects with at least one AE.


---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





libname raw "C:\Users\ashok pc\OneDrive\Desktop\dmspec code\raw ds";
proc copy in=raw out=work;
run;

data dm;
length sex $3. ethnic $8. usubjid $20;
set demog(rename=(race=race0));
studyid=left(study);
domain='dm';
subjid=left(pt);
usubjid=catx('-',study,pt);
siteid=substr(left(pt),1,2);
if not missing(AGE_RAW) then age=input(AGE_RAW,??best.);
if not missing(AGE_RAWU) then ageu=upcase(AGE_RAWU);
if sex='Female' then sex='F';
if sex='Male' then sex='M';
if cmiss(race0,race2,race3,race4) >3 then race="MULTIPLE";
else race=upcase(coalescec(race0,race2,race3,race4));
ethnic=upcase(ETHNIC);
country=upcase(left(country));
run;

/*11.DTHDTC*/
/*12.DTHFL*/;

data dthdtc;
set eos;
where EOSCAT='End of Study' and EOTERM='Death';
if not missing(EOSTDT_RAW) then do;
dthdtc=put(input(EOSTDT_RAW,date11.),yymmdd10.);
dthfl='Y';
end;
else do;
dthdtc='';
dthfl='';
end;
keep study pt dthdtc dthfl;
run;
/*6.RFENDTC*/;

data rfendtc;
set eos;
where EOSCAT='End of Study';
if not missing(EOSTDT_RAW) then rfendtc=put(input(EOSTDT_RAW,date11.),yymmdd10.);
keep study pt rfendtc;
run;
/*7.RFXSTDTC*/ /*8.RFXENDTC*/;
/*TOD:-/*TIME OF DATE(TO ADD 0 TO THE SINGLE DIGIT TIME)*/*/
/*??:-/*TO AVOID FORMATTING ERROR*/;*/;;
data ipadmin1;
set ipadmin;
length dttm $20.;
if ~missing(IPSTDT_RAW) then dt=put(input(IPSTDT_RAW,date11.),yymmdd10.);
if ~missing(IPSTTM_RAW) then tm=put(input(IPSTTM_RAW,time5.),tod5.);
dttm=catx('T',dt,tm);
keep study pt dttm ipboxid;
run;
proc sort data=ipadmin1; by study pt dttm; run;
data rfxstdtc(rename=(dttm=rfxstdtc)) 
    rfxendtc(drop=ipboxid rename=(dttm=rfxendtc));
set ipadmin1;
by study pt dttm;
if not missing(dttm) then do;
if first.pt then output rfxstdtc;
if last.pt then output rfxendtc;
end;
run;

/*9.RFICDTC*/;
data rficdtc;
set enrlment;
if ~missing(ICDT_RAW) then RFICDTC=put(input(ICDT_RAW,date11.),yymmdd10.);
if not missing (ENRLDT_RAW) then enrldt=put(input(ENRLDT_RAW,date11.),yymmdd10.);
if ~missing (RANDDT_RAW) then randdtc=put(input(RANDDT_RAW,date11.),yymmdd10.);
keep study pt rficdtc enrldt randdtc;
run;
/*/*/*5.RFSTDTC*/ ;;

proc sort data=rfxstdtc; by study pt; run;
proc sort data=rficdtc; by study pt; run;
data rfstdtc1;
merge rfxstdtc(in=a) rficdtc;
by study pt;
if a;
run;
data  rfstdtc;
set rfstdtc1;
if rfxstdtc ne ''  then rfstdtc=substr(rfxstdtc,1,10);
if rfstdtc eq '' and randdtc ne '' then rfstdtc=randdtc;
if rfstdtc eq '' and randdtc eq '' then rfstdtc=rficdtc;
keep study pt rfstdtc;
run;

/*10.RFPENDTC*/;

data DT_raw;
set Adverse(keep=study pt AESTDT_RAW rename=(AESTDT_RAW=date))
    Adverse(keep=study pt AEENDT_RAW rename=(AEENDT_RAW=date))
	Adverse(keep=study pt HADMTDT_RAW rename=(HADMTDT_RAW=date))
	Adverse(keep=study pt HDSDT_RAW rename=(HDSDT_RAW=date))
	conmeds(keep=study pt CMSTDT_RAW rename=(CMSTDT_RAW=date))
	conmeds(keep=study pt CMENDT_RAW rename=(CMENDT_RAW=date))
	Ecg(keep=study pt EGDT_RAW rename=(EGDT_RAW=date))
	Enrlment(keep=study pt ICDT_RAW rename=(ICDT_RAW=date))
	Enrlment(keep=study pt ENRLDT_RAW rename=(ENRLDT_RAW=date))
	Enrlment(keep=study pt RANDDT_RAW rename=(RANDDT_RAW=date))
	  eoip(keep=study pt EOSTDT_RAW rename=(EOSTDT_RAW=date))
	  eos(keep=study pt EOSTDT_RAW rename=(EOSTDT_RAW=date))
	  eq5d3l(keep=study pt DT_RAW rename=(DT_RAW=date))
	hosp(keep=study pt STDT_RAW rename=(STDT_RAW=date))
	hosp(keep=study pt ENDT_RAW rename=(ENDT_RAW=date))
	ipadmin(keep=study pt IPSTDT_RAW rename=(IPSTDT_RAW=date))
	lab_chem(keep=study pt LBDT_RAW rename=(LBDT_RAW=date))
	lab_hema(keep=study pt LBDT_RAW rename=(LBDT_RAW=date))
	physmeas(keep=study pt PMDT_RAW rename=(PMDT_RAW=date))
    surg(keep=study pt SURGDT_RAW rename=(SURGDT_RAW=date))
	vitals(keep=study pt VSDT_RAW rename=(VSDT_RAW=date));
run;


data alldates1;
set DT_raw;
DAY=SCAN(DATE,1,'/');
MONTH=UPCASE(SCAN(DATE,2,'/'));
YEAR=SCAN(DATE,3,'/');
if month='JAN' THEN MONTHC='01';
ELSE IF MONTH='FEB' THEN MONTHC='02';
ELSE IF MONTH='MAR' THEN MONTHC='03';
ELSE IF MONTH='APR' THEN MONTHC='04';
ELSE IF MONTH='MAY' THEN MONTHC='05';
ELSE IF MONTH='JUN' THEN MONTHC='06';
ELSE IF MONTH='JUL' THEN MONTHC='07';
ELSE IF MONTH='AUG' THEN MONTHC='08';
ELSE IF MONTH='SEP' THEN MONTHC='09';
ELSE IF MONTH='OCT' THEN MONTHC='10';
ELSE IF MONTH='NOV' THEN MONTHC='11';
ELSE IF MONTH='DEC' THEN MONTHC='12';
ELSE MONTH='-';
dayn=input(day,??best.);
yearn=input(year,??best.);
if dayn ne . then dayc=put(dayn,z2.);
IF DAYN NE . THEN DAYC=PUT(DAYN,Z2.);
ELSE DAYC='-';
IF YEARN NE . THEN YEARC=PUT(YEAR,4.);
ELSE YEARC='-';

DATEC=STRIP(YEARC)||'-'||STRIP(MONTHC)||'-'||STRIP(DAYC);
IF COMPRESS(DATEC,'-')='' THEN DATEC='';
run;

PROC SORT DATA=ALLDATES1 OUT=ALLDATES2;
BY STUDY PT DATEC;
WHERE DATEC NE '';
RUN;

DATA RFPENDTC;
SET ALLDATES2;
BY STUDY PT DATEC;
IF LAST.PT;
RFPENDTC=DATEC;
KEEP STUDY PT RFPENDTC;
RUN;

/**/
/*19.ARMCD:
20.ARM:
/**/;

data randno;
set enrlment;
where randno ne '';
keep study pt randno;
run;
data randno1;
set rand;
armcd=TX_CD;
randno=RAND_ID;
keep randno armcd;
run;
proc sort data=randno; by randno; run;
proc sort data=randno1; by randno; run;
data armcd;
length armcd $20.;
merge randno(in=a) randno1(in=b);
by randno;
if a;
length arm $10.;
if ARMCD='ACTIVE' then arm='active';
if armcd='PBO' then arm='placebo';
run;


/*
/*21.ACTARMCD:-
/*22.ACTARM:-*/;

data box1;
set box;
ipboxid=kitid;
drop kitid;
run;
proc sort data=rfxstdtc; by ipboxid; run;
proc sort data=box1; by ipboxid; run;
data actarmcd;
merge rfxstdtc(in=a) box1;
by ipboxid;
if a;
length actarm $10.;
actarmcd=content;
if actarmcd='ACTIVE' then actarm='Active';
else if actarmcd= 'PBO' then actarm='Placebo';
drop content;
run;


/*Guideline*/
/* A coded reason that Arm variables (ARM and ARMCD) and/or actual Arm variables */
/*(ACTARM and ACTARMCD) are null. Examples: */
/*"SCREEN FAILURE", "NOT ASSIGNED", "ASSIGNED, NOT TREATED", "UNPLANNED TREATMENT". */
/*It is assumed that if the Arm and */
/*actual Arm variables are null, the same reason applies to both Arm and actual Arm.*/;



proc sort data=RFICDTC; by study pt; run;
proc sort data=RFENDTC; by study pt; run;
proc sort data=DTHDTC; by study pt; run;
proc sort data=RFXSTDTC; by study pt; run;
proc sort data=RFXENDTC; by study pt; run;
proc sort data=ARMCD; by study pt; run;
proc sort data=ACTARMCD; by study pt; run;
proc sort data=RFPENDTC; by study pt; run;

DATA DM1;
MERGE DM(IN=A)
      RFICDTC
	  RFENDTC
	  DTHDTC
	  RFXSTDTC
	  RFXENDTC
	  ARMCD
	  ACTARMCD
	  RFPENDTC;
BY STUDY PT;
IF a;
run;


data dm2;
set dm1;
if rfxstdtc ne ''  then rfstdtc=substr(rfxstdtc,1,10);
if rfstdtc eq '' and randdtc ne '' then rfstdtc=randdtc;
if rfstdtc eq '' and randdtc eq '' then rfstdtc=rficdtc;
if armcd eq '' then do;
if rficdtc ne '' and enrldtc eq '' then do;
armcd='SCRNFAIL';
arm='Screen Failure';
actarmcd='SCRNFAIL';
actarm='Screen Failure';
end;
end;
else if enrldtc ne '' and randdtc eq '' then do;
armcd='NOTASSGN';
arm='Not assigned';
actarmcd='NOTASSGN';
actarm='Not assigned';
end;
else if armcd ne '' and randdtc ne '' and rfxstdtc eq '' then do;
actarmcd='NOTTRT';
actarm='Not Treated';
end;
else if armcd ne '' and randdtc ne '' and rfxstdtc eq '' then do;
actarmcd='NOTTRT';
actarm='Not Treated';
end;
run;


proc contents data=dm2 short varnum;
run;
/*STUDY PT SEX ETHNIC race0 RACE2 RACE3 RACE4 RACESP AGE_RAW 
AGE_RAWU BRTHDT_RAW COUNTRY race  siteid age ageu RFICDTC enrldt 
randdtc rfendtc dthdtc dthfl IPBOXID rfxstdtc rfxenddtc armcd 
RANDNO arm actarm actarmcd RFPENDTC rfstdtc enrldtc*/;

data DM(label='Demographics');	
attrib  studyid 	label='Study Identifier' 					length=$10
        domain		label='Domain Abbreviation'					length=$2
		usubjid 	label='Unique Subject Identifier'			length=$20
		subjid		label='Subject Identifier for the Study'	length=$40
		rfstdtc		label='Subject Reference Start Date/Time'	length=$20
		rfendtc		label='Subject Reference End Date/Time'		length=$20
		rfxstdtc    label='date/time of first study treatment'  length=$20
		rfxendtc    label='date/time of last study treatment'   length=$20
		rfpendtc    label='date/time of end participation'      length=$20
		rficdtc     label='date/time of informed consent date'  length=$20
		dthdtc      label='date/time of death'                  length=$20
		dthfl       label='death flag'                          length=$10
        siteid      label= 'study site identifier'              length=$20
		age         label='age'                                 length=8
		ageu        label='ageunits'                            length=$10
		sex         label='sex'                                 length=$3
		race        label='race'                                length=$20
		ethnic      label='ethinicity'                          length=$8
		armcd       label='planned arm code'                    length=$20
		arm         label='description armcode'                 length=$20
		actarmcd    label='actual arm code'                     length=$20
		actarm      label='description of actual arm code'      length=$20
		country     label='country'                             length=$20;				
set dm2;
/*keep STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC*/
/*RFPENDTC DTHDTC DTHFL SITEID AGE AGEU SEX RACE ETHNIC ARMCD ARM ACTARMCD*/
/*ACTARM COUNTRY;*/
run;

proc transpose data=DM out=suppdm (rename=(col1=qval)where=(qval ne '')) name=qnam label=qlabel;
var race0 race2 race3 race4 racesp randno;
by studyid usubjid;
run;

data suppdm;
set suppdm;
rdomain='dm';
idvar='';
idvarval='';
qorign='crf';
qeval='investigation';
run;

libname dm2 xport "C:\Users\ashok pc\OneDrive\Desktop\SDTM/dm2.xpt";

proc copy in=work out=dm2;
select dm;
run;
libname suppdm2 xport "C:\Users\ashok pc\OneDrive\Desktop\SDTM/suppdm2.xpt";

proc copy in=work out=suppdm2;
select suppdm;
run;

proc printto log="C:\Users\ashok pc\OneDrive\Desktop\SDTM/dm2log.txt";
run;


proc printto log="C:\Users\ashok pc\OneDrive\Desktop\SDTM/suppdm2log.txt";
run;





/*AE*/


libname AEraw "C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\AE\AE";

proc copy in=AEraw out=work;
run;

data AE1;
set adverse;
STUDYID=left(study);
DOMAIN="AE";
USUBJID=catx('-',study,pt);
AETERM=left(AEVT);
AELLT=left(AELLT);
AEDECOD=left(AEDECOD);
AECAT=left(AECAT);
AEBODSYS=left(AEBODSYS);
AESEV=upcase(AESEV);
PREDOSE=left(PREFDOSE);

if upcase(AESER)='Yes' then aeser='y';
else if upcase(AESER)='No' then aeser='n';
if upcase(AEACN)='NO ACTION TAKEN' then AEACN='DOSE NOT CHANGED';
else AEACN=upcase(AEACN);
AEACNOTH=upcase(AEACNOTH);
if upcase(AEREL)='yes' then aerel ='y';
else if upcase(AEREL)='no' then aerel ='n';
AEOUT=upcase(AEOUT);
if upcase(SCONG)='yes' then AESCONG='Y';
else if upcase(SCONG)='no' then AESCONG='n';

if upcase(SDISAB)='yes' then AESDISAB='Y';
else if upcase(SDISAB)='no' then AESDISAB='n';

if upcase(SDEATH)='yes' then AESDTH='Y';
else if upcase(SDEATH)='no' then AESDTH='n';

if upcase(SHOSP)='yes' then AESHOSP='Y';
else if upcase(SHOSP)='no' then AESHOSP='n';

if upcase(SLIFE)='yes' then AESLIFE='Y';
else if upcase(SLIFE)='no' then AESLIFE='n';

if upcase(SMIE)='yes' then AESMIE='Y';
else if upcase(SMIE)='no' then AESMIE='n';

dayn=input(scan(AESTDT_RAW,1,"/"),??best.);
if dayn ne . then stday=put(dayn,z2.);

monthc=upcase(scan(AESTDT_RAW,2,'/'));
if monthc='JAN' then stmonth='01';
else if monthc='FEB' then stmonth='02';
else if monthc='MAR' then stmonth='03';
else if monthc='APR' then stmonth='04';
else if monthc='MAY' then stmonth='05';
else if monthc='JUN' then stmonth='06';
else if monthc='JUL' then stmonth='07';
else if monthc='AUG' then stmonth='08';
else if monthc='SEP' then stmonth='09';
else if monthc='OCT' then stmonth='10';
else if monthc='NOV' then stmonth='11';
else if monthc='DEC' then stmonth='12';
else stmonth='';
styear=scan(AESTDT_RAW,3,'/');
AESTDTC=catx('-',styear,stmonth,stday);

enddayn=input(scan(AEENDT_RAW,1,"/"),??best.);
if enddayn ne . then enday=put(dayn,z2.);

monthc=upcase(scan(AEENDT_RAW,2,'/'));
if monthc='JAN' then enmonth='01';
else if monthc='FEB' then enmonth='02';
else if monthc='MAR' then enmonth='03';
else if monthc='APR' then enmonth='04';
else if monthc='MAY' then enmonth='05';
else if monthc='JUN' then enmonth='06';
else if monthc='JUL' then enmonth='07';
else if monthc='AUG' then enmonth='08';
else if monthc='SEP' then enmonth='09';
else if monthc='OCT' then enmonth='10';
else if monthc='NOV' then enmonth='11';
else if monthc='DEC' then enmonth='12';
else enmonth='';
enyear=scan(AEENDT_RAW,3,'/');
AEENDTC=catx('-',enyear,enmonth,enday);
run;

proc sort data=ae1;
by  usubjid;
run;
proc sort data=dm out=dm(keep=studyid usubjid rfstdtc rfxendtc);
by usubjid;
run;


data ae02;
merge ae1(in=a) dm(in=b);
by usubjid;
if a;
if length(aestdtc)=10 then aestdt=input(AESTDTC,?? yymmdd10.);
if length(aeendtc)=10 then aeendt= input(AEENDTC, ?? yymmdd10.);
if length(rfstdtc)=10 then rfstdt= input(rfstdtc, ?? yymmdd10.);
if rfxendtc ne "" then rfxendtc15=input(substr(rfxendtc,1,10),??yymmdd10.)+15;

if aestdt ne "" and rfstdt ne "" then do;
if  aestdt >= rfstdt then AESTDY=(aestdt-rfstdt)+1;
else if aestdt <= rfstdt then aestdy =(aestdt-rfstdt);
else aestdy=.; 
end; 

if aeendt ne "" and rfstdt ne"" then do;
if aeendt >= rfstdt then AEENDY = (aeendt-rfstdt)+ 1;
else if  aeendt <= rfstdt then aeendy=(aeendt-rfstdt);
else aeendy=.;
end;
if prefdose='Y' then aetrtem='N';
else if aestdt>=rfstdt and aestdt < rfxendtc15 then aetrtem='Y';
else aetrtem='N';
run;


proc sort data=ae02;
by usubjid aestdtc aedecod ;
run;


proc sort data=se;
by usubjid sestdtc seendtc;
run;

data ae03;
merge ae02(in=a) se(in=b keep=sestdtc seendtc usubjid epoch);
by usubjid;
if a and sestdtc <= aestdtc <= seendtc then do;
epoch = epoch; 
end;
if first.usubjid then AESEQ= 1;
else AESEQ + 1;
run;

proc sort data=ae03; by studyid usubjid; run;

proc contents data=ae03 varnum short;
run;
proc sql;
select * from ae03;
STUDY as studyid  PT AECAT AEVT PREFDOSE AESTDT_RAW AEENDT_RAW AESEV
AEREL AEACN AEACNOTH AESER SDEATH SLIFE SHOSP SDISAB SCONG
SMIE AEOUT HADMTDT_RAW HADMTTM_RAW HDSDT_RAW HDSTM_RAW AELLT 
AEDECOD AEHLT AEHLGT AEBODSYS STUDYID DOMAIN USUBJID AETERM PREDOSE
AESCONG AESDISAB AESDTH AESHOSP AESLIFE AESMIE dayn stday monthc 
stmonth styear AESTDTC enddayn enday enmonth enyear AEENDTC RFSTDTC 
RFXENDTC aestdt aeendt rfstdt rfxendtc15 AESTDY AEENDY aetrtem EPOCH 
SESTDTC SEENDTC AESEQ
quit;

proc transpose data=ae03 out=ae04(rename=(COL1=qval _NAME_=qnam  _LABEL_=qlabel));
var prefdose aetrtem;
by studyid usubjid aeseq;
run;

data suppae;
set ae04;
idvar=aeseq;
idvarval=strip(put(aeseq, best.));
qorign='crf';
qeval='investigation';
run;

libname AE xport "C:\Users\ashok pc\OneDrive\Desktop\SDTM/AE.xpt";

proc copy in=work out=AE;
select ae03;
run;
libname suppae xport "C:\Users\ashok pc\OneDrive\Desktop\SDTM/suppae.xpt";

proc copy in=work out=suppae;
select suppae;
run;



proc printto log="C:\Users\ashok pc\OneDrive\Desktop\SDTM/aelog.txt";
run;


proc printto log="C:\Users\ashok pc\OneDrive\Desktop\SDTM/suppdaelog.txt";
run;

proc printto log=log;
run;


/*Validation of ADaM:-*/

/**/
/*Steps for Developing ADaM Dataset from SDTM (AE domain):*/
/*After you've created the SDTM AE dataset, the next step is to transform this into ADaM format, which is used for statistical analysis.*/
/**/
/*Here’s an outline of the steps to develop ADaM datasets:*/

Step 1: Identify the ADaM Dataset Type
In ADaM, there are two main types of datasets:

ADaM - AE dataset: Focuses on adverse events.

ADaM - Analysis Dataset: Generally created for statistical analysis like TFL generation.

For AE, you typically need to create an ADaM - AE dataset that includes adverse event analysis data.

Step 2: Start with SDTM AE Data
Use the SDTM AE data as the starting point, and you can extract necessary variables for analysis. You will need to identify key ADaM variables like:

USUBJID: Subject ID (same as in SDTM).

AETERM: Adverse Event Term (from SDTM AE).

AEDECOD: Adverse Event Code (from SDTM AE).

AESTDTC: Start Date of the AE (in ADaM, it may need to be converted to a standard date format).

AEENDTC: End Date of the AE.

Step 3: Create Analysis-Specific Variables
For ADaM datasets, you’ll need to create analysis-specific variables, which can include:

AESTDY (AE start day relative to study start date)

AEENDY (AE end day relative to study start date)

AELAST (Flag for last AE within the study period)

AESTDT and AEENDT: These may need to be calculated or formatted in a way suitable for analysis.

Step 4: Recode AE Events
Recode the AE events for analysis, including:

Serious AE (AESER): Convert to a binary (Y/N) variable for serious events.

AE Severity: This variable may be recoded to a standard format (e.g., 1 for mild, 2 for moderate, 3 for severe).

Outcome of AE (AEOUT): Recode as needed (e.g., whether the event led to death, hospitalization, etc.).




data adam_ae;
    set sdtm_ae;  /* SDTM AE dataset */
    /* Converting AE start and end date to relative study days */
    AESTDY = (AESTDT - RFSTDTC) + 1;  /* Assuming RFSTDTC is the study start date */
    AEENDY = (AEENDT - RFSTDTC) + 1;  /* Assuming RFSTDTC is the study start date */
    
    /* Create outcome flags for AE */
    if upcase(AESER) = 'YES' then AESER = 'Y';
    else AESER = 'N';
    
    /* Severity Levels */
    if upcase(AESEV) = 'MILD' then AESEV = 1;
    else if upcase(AESEV) = 'MODERATE' then AESEV = 2;
    else if upcase(AESEV) = 'SEVERE' then AESEV = 3;
    
    /* Outcome flags */
    if upcase(AEOUT) = 'DEATH' then AEOUT = 'Y';
    else AEOUT = 'N';

    /* Create variable for the last AE */
    if last.USUBJID then AELAST = 'Y';
    else AELAST = 'N';
    
    /* Recode other necessary variables */
    /* Any additional recoding or derivation can be done here */

run;


tep 6: Check ADaM Dataset for Compliance
After creating the ADaM dataset, make sure:

All required variables are included.

The ADaM rules for dataset structure (like ADaM metadata standards) are met.

Variables like AESTDY, AEENDY, and AELAST are correctly calculated.


Step 7: Final Export for Submission
Once your ADaM dataset is complete, export it in the XPORT format for submission or analysis:

sas
Copy
Edit
libname adam xport "C:\path\to\output\adam_ae.xpt";
proc copy in=work out=adam;
   select adam_ae;
run;


Summary of Key ADaM AE Steps:
Start with SDTM AE data (study ID, AE term, AE severity, etc.).

Create analysis variables like AESTDY, AEENDY, AELAST.

Recode AE events and flags for analysis (seriousness, outcome, severity).

Sort and ensure dataset compliance with ADaM standards.

Export the final ADaM AE dataset for use in statistical analysis.



/*Prog steps*/


Thank you for sharing your AE code! Based on that, I will walk you through the ADaM AE dataset creation, step by step. We will make use of the AE dataset you’ve created and adapt it for ADaM compliance.

Step 1: Identify Key ADaM AE Variables
In the ADaM AE dataset, we need the following essential variables:

USUBJID: Subject ID (taken from SDTM AE dataset).

AETERM: Adverse event term.

AEDECOD: Adverse event code (from SDTM AE).

AESTDY: Adverse event start day relative to the study start date.

AEENDY: Adverse event end day relative to the study start date.

AELAST: Flag to identify the last adverse event for the subject.

AESER: Seriousness of AE (converted to binary Y/N).

AESEV: Severity of AE (coded to 1 = mild, 2 = moderate, 3 = severe).

AEOUT: Outcome of AE (whether it resulted in death, hospitalization, etc.).

AEACN: Action taken with the drug due to AE.

Step 2: Prepare the Dataset for ADaM
Here’s how you can adapt your SDTM AE dataset into an ADaM AE dataset.

Code for Step 2:
sas
Copy
Edit;
data adam_ae;
    set ae02;  /* The dataset created after merging SDTM AE with DM */

    /* Convert AE Start and End Date to Study Days */
    AESTDY = (AESTDT - RFSTDTC) + 1;   /* Relative to study start date */
    AEENDY = (AEENDT - RFSTDTC) + 1;    /* Relative to study start date */

    /* Convert serious AE to a binary Y/N variable */
    if upcase(AESER) = 'Y' then AESER = 'Y';
    else AESER = 'N';

    /* Convert AE severity to numeric levels (1= mild, 2= moderate, 3= severe) */
    if upcase(AESEV) = 'MILD' then AESEV = 1;
    else if upcase(AESEV) = 'MODERATE' then AESEV = 2;
    else if upcase(AESEV) = 'SEVERE' then AESEV = 3;

    /* Outcome of AE (whether it led to death, hospitalization, etc.) */
    if upcase(AEOUT) = 'DEATH' then AEOUT = 'Y';
    else AEOUT = 'N';

    /* Determine the last AE for the subject */
    if last.USUBJID then AELAST = 'Y';
    else AELAST = 'N';

run;


proc print data=Adam_ae;
run;




Step 3: Create Analysis-Specific Variables
In ADaM, you’ll need to create additional analysis-specific variables such as:

AELAST: Identifies the last AE for each subject.

AESEQ: A sequence number for AE events within a subject.

AESTDY and AEENDY: The start and end day relative to the study start date (already created above).

AEACNOTH: Other action taken (already coded in the SDTM code).

AELAST: Flag for the last adverse event.

Code for Step 3:
sas
Copy
Edit;
data adam_ae;
    set ae02;  /* The dataset created after merging SDTM AE with DM */

    /* Convert AE Start and End Date to Study Days */
    AESTDY = (AESTDT - RFSTDTC) + 1;   /* Relative to study start date */
    AEENDY = (AEENDT - RFSTDTC) + 1;    /* Relative to study start date */

    /* Convert serious AE to a binary Y/N variable */
    if upcase(AESER) = 'Y' then AESER = 'Y';
    else AESER = 'N';

    /* Convert AE severity to numeric levels (1= mild, 2= moderate, 3= severe) */
    if upcase(AESEV) = 'MILD' then AESEV = 1;
    else if upcase(AESEV) = 'MODERATE' then AESEV = 2;
    else if upcase(AESEV) = 'SEVERE' then AESEV = 3;

    /* Outcome of AE (whether it led to death, hospitalization, etc.) */
    if upcase(AEOUT) = 'DEATH' then AEOUT = 'Y';
    else AEOUT = 'N';

    /* Determine the last AE for the subject */
    if last.USUBJID then AELAST = 'Y';
    else AELAST = 'N';

run;


proc print data=Adam_ae;
run;
data adam_ae1;
    set adam_ae;

    /* Generate Sequence Number for AEs within a subject */
    if first.USUBJID then AESEQ = 1;
    else AESEQ + 1;

    /* Check for any additional recoding needed */
    if upcase(AEACN) = 'DOSE NOT CHANGED' then AEACN = 'No Change';
    else AEACN = upcase(AEACN);  /* Convert to uppercase for standardization */
run;


proc print data=Adam_ae1;
run;




data adam_ae2;
    set adam_ae;

    /* Create other analysis-specific variables like AEACNOTH and AELAST */
    if AESER = 'Y' then AESER = 'Y';
    else AESER = 'N';

    /* Recode the AEACN variable for any non-standard values */
    if upcase(AEACN) = 'NO ACTION TAKEN' then AEACN = 'DOSE NOT CHANGED';
    else AEACN = upcase(AEACN);

    /* Recode AE severity levels */
    if upcase(AESEV) = 'MILD' then AESEV = 1;
    else if upcase(AESEV) = 'MODERATE' then AESEV = 2;
    else if upcase(AESEV) = 'SEVERE' then AESEV = 3;
run;

proc print data=adam_ae2;
run;


data adam_ae;
    merge adam_ae (in=a) se (in=b keep=usubjid epoch);
    by usubjid;
    
    if a;
    
    /* Assign the EPOCH variable to the AE dataset */
    if first.usubjid then AESEQ = 1;
    else AESEQ + 1;
run;
proc print data=adam_ae;
run;
/*m*/


/* Export the ADaM dataset for submission */

libname adam xport "C:\path\to\output\adam_ae.xpt";
proc copy in=work out=adam;
    select adam_ae;
run;
Summary of Steps for ADaM AE Dataset Creation
Start with SDTM AE Data: Begin by importing and cleaning your SDTM AE dataset.

Identify Key ADaM Variables: Focus on variables like USUBJID, AETERM, AEDECOD, and AESER.

Create Analysis-Specific Variables: Create variables like AESTDY, AEENDY, and AELAST for analysis.

Recode AE Events: Convert variables like AESER, AESEV, and AEOUT into standardized formats.

Merge with Other Datasets: If needed, merge with other datasets (e.g., SE) to incorporate additional study-related data.

Export the ADaM Dataset: Export the ADaM dataset in the XPORT format for submission.

/*Let me know if you'd like more details on any specific step or need further assistance with your ADaM dataset!*/
/**/
/**/
/**/




/* Step 1: Get subject counts by AE severity */;
proc sql;
    create table ae_severity_summary as
    select
        AESEV as Severity,
        case
            when AESEV = 'Mild' then 1
            when AESEV = 'Moderate' then 2
            when AESEV = 'Severe' then 3
        end as Severity_order,
        count(distinct USUBJID) as N_Subjects
    from adam_ae
    group by AESEV;
quit;

proc sql;
select * from ae_severity_summary;
quit;



/* Step 2: Calculate total subjects with AE */
proc sql;
    select count(distinct USUBJID) as total_subjs
    from adam_ae;
quit;

/* Step 3: Calculating percentage */
data ae_severity_summary;
set ae_severity_summary;
Total_Subjects = &total_subjs;
Percent = (N_Subjects / Total_Subjects) * 100;
run;


data ae_severity_summary;
    set ae_severity_summary end=last;
    output;
    if last then do;
        Severity = 'Total';
        Severity_order = 4;
        N_Subjects = Total_Subjects;
        Percent = 100;
        output;
    end;
run;


proc report data=ae_severity_summary nowd headline headskip;
    columns Severity_order Severity N_Subjects Percent;
    define Severity_order / noprint;
    define Severity / "Severity Level" order=internal;
    define N_Subjects / "Number of Subjects (n)";
    define Percent / "Percentage (%)" format=6.1;
run;

libname TLF  xport "C:\Users\ashok pc\OneDrive\Desktop\SDTM/TLF.xpt";

proc copy in=work out=TLF;
select ae_severity_summary ;
run;
