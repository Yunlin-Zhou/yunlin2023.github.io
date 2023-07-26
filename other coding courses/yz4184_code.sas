************************
* yz4184 Final Project *
************************;

ODS RTF FILE = "/home/u60923623/sasuser.v94/2022 fall sas/final/yz4184_code_output.rtf";

*************************************************
* Part 1 Data Cleaning and adding new variables *
*************************************************;


/* Import weight_loss.xlsx file */

PROC IMPORT OUT = weight_loss
	DATAFILE = "/home/u60923623/sasuser.v94/2022 fall sas/final/weight_loss.xlsx"
	DBMS = xlsx
	REPLACE;
RUN;


/* Delete the null rows */

DATA weight_loss;
    SET weight_loss;
    IF ID = "." THEN delete;
RUN;


/* Reset the levels of Ethnicity */

DATA weight_loss;
    SET weight_loss;
    LENGTH Ethnicity $15.;
    IF Ethnicity = "WHITE" OR Ethnicity = "white" OR Ethnicity = "White"
    THEN Ethnicity = "White";
	ELSE IF Ethnicity = "DECLINED" OR Ethnicity = "Unknown/Decline" OR Ethnicity = "Decline"
	THEN Ethnicity = "Decline";
	ELSE IF Ethnicity = "Asian"
    THEN Ethnicity = "Asian";
    ELSE IF Ethnicity = "Black"
    THEN Ethnicity = "Black";
    ELSE IF Ethnicity = "Other"
    THEN Ethnicity = "Other";
	RUN;


/* Indicator whether the patient was on metformin at initial visit */

DATA weight_loss;
    SET weight_loss;
    LENGTH Met1 8.;
    IF FINDW(Meds1,'metformin')>0 OR FINDW(Meds1,'Metformin')>0
    THEN Met1 = 1;
	ELSE Met1 = 0;
	RUN;


/* Indicator whether the patient was on metformin at any visits */

DATA weight_loss;
    SET weight_loss;
    LENGTH Metformin 8.;
    IF FINDW(Meds1,'metformin')>0 OR FINDW(Meds1,'Metformin')>0 OR
    FINDW(Meds2,'metformin')>0 OR FINDW(Meds2,'Metformin')>0 OR
    FINDW(Meds3,'metformin')>0 OR FINDW(Meds3,'Metformin')>0 OR
    FINDW(Meds4,'metformin')>0 OR FINDW(Meds4,'Metformin')>0 OR
    FINDW(Meds5,'metformin')>0 OR FINDW(Meds5,'Metformin')>0 OR
    FINDW(Meds6,'metformin')>0 OR FINDW(Meds6,'Metformin')>0 OR
    FINDW(Meds7,'metformin')>0 OR FINDW(Meds7,'Metformin')>0 OR
    FINDW(Meds8,'metformin')>0 OR FINDW(Meds8,'Metformin')>0 OR
    FINDW(Meds9,'metformin')>0 OR FINDW(Meds9,'Metformin')>0 OR
    FINDW(Meds10,'metformin')>0 OR FINDW(Meds10,'Metformin')>0 OR
    FINDW(Meds11,'metformin')>0 OR FINDW(Meds11,'Metformin')>0 OR
    FINDW(Meds12,'metformin')>0 OR FINDW(Meds12,'Metformin')>0 OR
    FINDW(Meds13,'metformin')>0 OR FINDW(Meds13,'Metformin')>0 OR
    FINDW(Meds14,'metformin')>0 OR FINDW(Meds14,'Metformin')>0 
    THEN Metformin = 1;
	ELSE Metformin = 0;
	RUN;

/* I also tried "do over" statement, but the result is not same. The code should be correct
	
DATA weight_loss;
SET weight_loss;
ARRAY all_chars Meds1 Meds2 Meds3 Meds4 Meds5 Meds6 Meds7 Meds8 Meds9 Meds10 Meds11 Meds12 Meds13 Meds14;
DO OVER all_chars;
IF FINDW(all_chars,'metformin')>0 OR FINDW(all_chars,'Metformin')>0 
	THEN Metformin1 = 1;
	ELSE Metformin1 = 0;
END;
RUN;

*/


/* Indicator whether a patient lost more than 5% of their initial weight by their final visit */

DATA weight_loss (DROP = i);
SET weight_loss;
ARRAY nums {*} Weight1 Weight2 Weight3 Weight4 Weight5 Weight6 Weight7 Weight8 Weight9 Weight10 Weight11 Weight12 Weight13 Weight14;
DO i = DIM(nums) TO 1 BY -1 UNTIL (i=1 or VVALUE(nums[i]) ne . );
	lastweight = nums[i];
END;
RUN;

DATA weight_loss;
    SET weight_loss;
    LENGTH loss5 8.;
    IF lastweight/weight1 < 0.95
    THEN loss5 = 1;
	ELSE loss5 = 0;
	RUN;


/* BMI at every visit */

DATA weight_loss (DROP = i);
SET weight_loss;
ARRAY weight{*} Weight1 Weight2 Weight3 Weight4 Weight5 Weight6 Weight7 Weight8 Weight9 Weight10 Weight11 Weight12 Weight13 Weight14;
ARRAY BMI{*} BMI1 BMI2 BMI3 BMI4 BMI5 BMI6 BMI7 BMI8 BMI9 BMI10 BMI11 BMI12 BMI13 BMI14;
DO i = 1 TO DIM(weight);
BMI{i} = weight{i}/(Height1)**2;
END;
RUN;


/* Overall change in BMI */

DATA weight_loss;
    SET weight_loss;
    LENGTH bmi_last 8.;
    lastbmi = lastweight/(Height1)**2;
	RUN;

DATA weight_loss;
    SET weight_loss;
    LENGTH bmi_change 8.;
    bmi_change = BMI1 - lastbmi;
	RUN;


/* Apply variable labels */

DATA weight_loss;
SET weight_loss;
LABEL 
HTN = "Hypertension diagnosis at initial visit"
Prediabetes = "Prediabetes diagnosis at initial visit"
T2DM = "Type II Diabetes diagnosis at initial visit"
HLD = "Hyperlipidemia diagnosis at initial visit"
CVD = "Cardiovascular disease diagnosis at initial visit"
NASH = "Non-Alcoholic Fatty Liver Disease/Non-Alcoholic Steatohepatitis diagnosis at initial visit"
Hypothyroidism = "Hypothyroidism diagnosis at initial visit"
OSA = "Obstructive sleep apnea diagnosis at initial visit"
Psych = "Psychiatric diagnosis at initial visit"
PCOS = "Polycystic Ovary Syndrome diagnosis at initial visit"
Height1 = "Patient’s height in meters measured at initial visit"
Weight1 = "Patient’s weight in kilograms measured at initial visit"
Meds1 = "Weight loss medications taken at initial visit"
Weight2 = "Patient’s weight in kilograms at visit 2"
Meds2 = "Weight loss medications taken at visit 2"
Weight3 = "Patient’s weight in kilograms at visit 3"
Meds3 = "Weight loss medications taken at visit 3"
Weight4 = "Patient’s weight in kilograms at visit 4"
Meds4 = "Weight loss medications taken at visit 4"
Weight5 = "Patient’s weight in kilograms at visit 5"
Meds5 = "Weight loss medications taken at visit 5"
Weight6 = "Patient’s weight in kilograms at visit 6"
Meds6 = "Weight loss medications taken at visit 6"
Weight7 = "Patient’s weight in kilograms at visit 7"
Meds7 = "Weight loss medications taken at visit 7"
Weight8 = "Patient’s weight in kilograms at visit 8"
Meds8 = "Weight loss medications taken at visit 8"
Weight9 = "Patient’s weight in kilograms at visit 9"
Meds9 = "Weight loss medications taken at visit 9"
Weight10 = "Patient’s weight in kilograms at visit 10"
Meds10 = "Weight loss medications taken at visit 10"
Weight11 = "Patient’s weight in kilograms at visit 11"
Meds11 = "Weight loss medications taken at visit 11"
Weight12 = "Patient’s weight in kilograms at visit 12"
Meds12 = "Weight loss medications taken at visit 12"
Weight13 = "Patient’s weight in kilograms at visit 13"
Meds13 = "Weight loss medications taken at visit 13"
Weight14 = "Patient’s weight in kilograms at visit 14"
Meds14 = "Weight loss medications taken at visit 14"
Met1 = "Indicator whether the patient was on metformin at initial visit"
Metformin = "Indicator whether the patient was on metformin at any visits"
lastweight = "Patient’s weight in kilograms at last visit"
lastbmi = "Patient’s BMI at last visit"
loss5 = "Indicator whether the patient lost 5% weight"
BMI1 = "Patient’s BMI at initial visit"
BMI2 = "Patient’s BMI at visit 2"
BMI3 = "Patient’s BMI at visit 3"
BMI4 = "Patient’s BMI at visit 4"
BMI5 = "Patient’s BMI at visit 5"
BMI6 = "Patient’s BMI at visit 6"
BMI7 = "Patient’s BMI at visit 7"
BMI8 = "Patient’s BMI at visit 8"
BMI9 = "Patient’s BMI at visit 9"
BMI10 = "Patient’s BMI at visit 10"
BMI11 = "Patient’s BMI at visit 11"
BMI12 = "Patient’s BMI at visit 12"
BMI13 = "Patient’s BMI at visit 13"
BMI14 = "Patient’s BMI at visit 14"
bmi_change = "Patient’s BMI change from initial visit to the last visit"
;
RUN;


/* Apply user-defined formats */

PROC FORMAT;
VALUE DIAGFMT
1 = "Yes"
0 = "No";
RUN;

DATA weight_loss;
SET weight_loss;
FORMAT 
HTN--PCOS DIAGFMT.
Met1 DIAGFMT.
Metformin DIAGFMT.
loss5 DIAGFMT.
;
RUN;


*********************************
* Part 2 Descriptive Statistics *
*********************************;


/* Descriptive Statistics for Demographic and clinical variables */

TITLE "Frequency Table for Demographic and clinical variables (sample size 372)";
PROC FREQ DATA = weight_loss NLEVELS;
	TABLE Gender -- PCOS;
RUN;
TITLE;


/* Descriptive Statistics for BMI at initial visit */

TITLE "Histogram and density plot for BMI at initial visit to check skewness";
PROC SGPLOT DATA = weight_loss;
HISTOGRAM BMI1;
DENSITY BMI1 / TYPE=KERNEL;
RUN;
TITLE;


/* The BMI at initial visit is highly skewed */

TITLE "Descriptive Statistics for BMI at initial visit (sample size 372)";
PROC MEANS DATA = weight_loss MEDIAN P25 P75 MAXDEC=2;
	VAR BMI1;
RUN;
TITLE;


/* Descriptive Statistics for Metformin use at initial visit */

TITLE "Frequency Table for Metformin use at initial visit (sample size 372)";
PROC FREQ DATA = weight_loss NLEVELS;
	TABLE Met1;
RUN;
TITLE;


*******************
* Part 4 Analysis *
*******************;

ODS ESCAPECHAR = '^';

/* LINEAR REGRESSION */

ODS ESCAPECHAR = '^';
TITLE "LINEAR REGRESSION";

*Check for collinearity of predictor variables (except for the categorical variables);
TITLE "Collinearity Check";
PROC REG DATA = weight_loss;
	MODEL bmi_change = HTN -- PCOS Metformin / VIF;
	RUN;
TITLE;

ODS TEXT = "^{style[fontsize=12pt] There are no variables with VIF>10 in this model.}";


*Automatic Model Selection Procedure;
TITLE "Automatic Model Selection Procedure";
PROC GLMSELECT DATA = weight_loss;
	CLASS Gender Ethnicity;
	MODEL bmi_change = HTN -- PCOS Metformin;
RUN;
QUIT;
TITLE;

ODS TEXT = "^{style[fontsize=12pt]The final model should include Gender, Ethnicity and OSA as predictors.}";

*Run the full and the final model and interpret;

TITLE "Full Model";
PROC GLM DATA = weight_loss;
	CLASS Gender Ethnicity;
	MODEL bmi_change = HTN -- PCOS Metformin / SOLUTION;
RUN;
TITLE;

ODS TEXT = "^{style[fontsize=12pt]From the full model we can see that only NASH OSA PCOS are significant predictors. OSA is a very significant predictor.}";


TITLE "Final Model: Gender, Ethnicity and OSA predicting BMI change over visits";
PROC GLM DATA = weight_loss;
	CLASS Gender Ethnicity;
	MODEL bmi_change = OSA / SOLUTION;
	OUTPUT OUT = resid_data R = resid_value;
RUN;
TITLE;

*Residual Check;
TITLE "Plot to Examine Normality of Residuals from Final Model";
PROC SGPLOT DATA = resid_data;
	HISTOGRAM resid_value;
	DENSITY resid_value / TYPE=NORMAL;
	DENSITY resid_value / TYPE=KERNEL;
RUN;
TITLE;

ODS TEXT = "^{style[fontsize=16pt]Conclusion:}";
ODS TEXT = "^{style[fontsize=12pt]The residuals are not obviously skewed. We therefore proceed the normality assumption.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]The F-test p-value is significant, indicating that at least one X-variable is a significant predictor of the outcome.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]The R-squared values are not close to 1 in both full model and the final model, indicating that this model explains a low degree of variation in the outcome, BMI change.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]OSA is a significant predictor of BMI change at 5% significant level.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]The 95% confidence interval for OSA is (0.8286, 2.6685).}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]For people with Obstructive sleep apnea diagnosis at initial visit, BMI change increases by 1.75 units, on average.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]OSA has a negative effect on decrease BMI.}";
TITLE;


/* LOGISTIC REGRESSION */

ODS ESCAPECHAR = '^';
TITLE "LOGISTIC REGRESSION";

*Automatic Model Selection Procedure;

TITLE "Automatic Model Selection Procedure";
PROC LOGISTIC DATA = weight_loss PLOTS(ONLY) = (ROC EFFECT);
CLASS Gender(REF = 'M') Ethnicity (REF = 'White') / PARAM = REF;
MODEL loss5 = HTN -- PCOS Metformin / SELECTION = STEPWISE LACKFIT OUTROC = ROC;
RUN;
TITLE;

ODS TEXT = "^{style[fontsize=12pt] The model selected by stepwise function only includes OSA.}";

*Run the full and the final model and interpret;

TITLE "Full Model";
PROC LOGISTIC DATA = weight_loss PLOTS(ONLY) = (ROC EFFECT);
CLASS Gender(REF = 'M') Ethnicity (REF = 'White')/ PARAM = REF;
MODEL loss5 = HTN -- PCOS Metformin / LACKFIT OUTROC = ROC;
RUN;
TITLE;

ODS TEXT = "^{style[fontsize=12pt]From the full model we can see that only OSA is the significant predictor.}";

TITLE "Final Model: Gender, Ethnicity and OSA predicting 5% of weight loss at the 
final visit";
PROC LOGISTIC DATA = weight_loss PLOTS(ONLY) = (ROC EFFECT);
CLASS Gender(REF = 'M') Ethnicity (REF = 'White')/ PARAM = REF;
MODEL loss5 = OSA / LACKFIT OUTROC = ROC;
RUN;
TITLE;

ODS TEXT = "^{style[fontsize=16pt]Conclusion:}";
ODS TEXT = "^{style[fontsize=12pt]Since there is only 1 predictor in the final model, the hosmer and lemeshow goodness-of-fit test cannot be shown in our output.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]The p-value is smaller than 0.05, indicating that OSA is a significant predictor of losing weight over 5% at 5% significant level.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]The 95% confidence interval for OSA is (0.209, 0.829).}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]For the patients who had Obstructive sleep apnea diagnosis at initial visit has 0.416 times the odds of a positive test as compared to the patients who had not.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]The area under ROC curve is 0.5581 in the final model, which indicating that this model is not a good fit. Also, the final model has a poorer fit than the full model.}";
ODS TEXT = "^{style[fontsize=12pt]}"; /* Adding a blank line to create a space between sections */
ODS TEXT = "^{style[fontsize=12pt]OSA has a negative effect on losing weight.}";
TITLE;


******************
* Part 5 Figures *
******************;


/* The trend of BMI from initial visit to final visit */

TITLE "The means of BMI from the initial visit to the visit 14";
PROC MEANS DATA = weight_loss MEAN MEDIAN ;
	VAR BMI1 --BMI14;
	OUTPUT OUT = bmi_mean (DROP = _TYPE_ _FREQ_);
RUN;
TITLE;

TITLE "Transpose the means table";
PROC TRANSPOSE DATA = bmi_mean
OUT = bmi_long (DROP = _LABEL_ COL1 COL2 COL3 COL5 RENAME = (_Name_ = visit COL4 = mean));
RUN;
TITLE;

TITLE "The trend of BMI from initial visit to final visit";
PROC SGPLOT DATA = bmi_long;
SERIES X=visit Y=mean / MARKERS;
RUN;
TITLE;


/* The frequency of the top 5 more common comorbidities */

TITLE "Selcet the comorbidities into a new table";
PROC SQL;
CREATE TABLE como AS
SELECT ID, HTN, Prediabetes, T2DM, HLD, CVD, NASH, Hypothyroidism, OSA, Psych, PCOS
FROM weight_loss;
QUIT;
TITLE;

TITLE "Transpose new table";
PROC TRANSPOSE DATA = como
OUT = como_long (DROP = _LABEL_ RENAME = (_NAME_ = como COL1 = Indicator));
BY ID;
RUN;
TITLE;

TITLE "Filter the table with comorbidities";
DATA como_new;
SET como_long;
WHERE Indicator = 1;
RUN;
TITLE;


TITLE "The frequency of the comorbidities";
PROC FREQ DATA = como_new;
	TABLE como /OUT = como_freq;
RUN;
TITLE;

TITLE "Rank the frequency";
PROC SORT DATA = como_freq
OUT = como_rank;
BY DESCENDING PERCENT;
RUN;
TITLE;

TITLE "The top 5 common comorbidities";
PROC PRINT DATA=como_rank (OBS=5);
RUN;
TITLE;

TITLE "The plot of top 5 common comorbidities";
PROC SGPLOT DATA = como_rank (OBS=5);
VBAR como / RESPONSE = PERCENT CATEGORYORDER = RESPDESC DATALABEL = PERCENT;
RUN;
TITLE;



ODS RTF CLOSE;