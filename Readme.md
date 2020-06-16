# RadMON analysis scripts express start:

This document guides one through two steps required to analyse raw RadMON output and calculate the dose in Gy, the HEH fluence in cm^-2 and the 1MeV NEQ fluence in cm^-2.

The scripts are self-sufficient provided that fundamental RadMON configurations are not changed.

Common sense of the positional context of the RadMON system (motherboard + deported module) for the run being analysed must be taken into account when considering the output of the scripts.

### 1.Retrieve data from timber: *** LOCAL TIME + LDB& MDB databases ***

&nbsp;&nbsp;&nbsp;&nbsp;a. Sec 1 – File: excel -> Timescale in fixed intervals -> 10 sec SUM <sup>1</sup>

&nbsp;&nbsp;&nbsp;&nbsp;b. RadMON variables -> Timescale in fixed intervals -> 10 sec AVG <sup>2</sup> (list below)
This convention is important because:

* Excel files can’t exceed 65’000 lines
* The Matlab scripts rely on reading an excel file and the name of its sheets

  This convention is practical because:

* Facilitates matrix algebra, as every row will have the same date stamp
 
&nbsp;&nbsp;&nbsp;&nbsp;c. Separate RadMON data files by system and sensor:

&nbsp;&nbsp;&nbsp; -Dose script:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SEC 1 data file

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RadMON version #, system # file (2 sheets):
a. 400nm rfet in first sheet
b. 100nm rfet in second sheet

&nbsp;&nbsp;&nbsp; - 1-MeV NEQ script:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SEC 1 data file

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RadMON version #, system # file single sheet

&nbsp;&nbsp;&nbsp; -Risk Factor script (provides both HEHs and thNs):

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SEC 1 data file

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RadMON version #, system # file (2 sheets):

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. Cypress memory bank (B1)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Toshiba memory bank (B2)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; If V5 – needs two motherboards to use (2 sheets)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. Toshiba @ 5 volts on first sheet

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Toshiba @ 3 volts on second sheet

### 2.Prepare and run the script:

&nbsp;&nbsp;&nbsp;a. Set up a convenient folder and filename system for output

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The script needs both files to be in the same file directory

&nbsp;&nbsp;&nbsp;b. Change target input file names in the beginning of the script as appropriate

&nbsp;&nbsp;&nbsp;c. Set name of file location in the png, matlab figure and variable output lines

&nbsp;&nbsp;&nbsp;d. Run the script (F5)

### 3.Remember:

&nbsp;&nbsp;&nbsp;a. The scripts are currently named so that they’re easy to identify but this is not supported by matlab (-> delete the %%%s )

&nbsp;&nbsp;&nbsp;b. The scripts need the extra functions in the root folder to work

&nbsp;&nbsp;&nbsp;c. New radfets/pin diodes = new initial voltages

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; This needs to be corrected in the initvoltages file (keep a copy of the old version and document the new change carefully!)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Or manually in the script

&nbsp;&nbsp;&nbsp; d. 90% of possible issues in the past were related to calculation errors involving matrixes of different sizes -> this should not be a problem now

&nbsp;&nbsp;&nbsp;e. V6 logs raw data in V, V5 logs it in mV

### 4.Run timings, run context

&nbsp;&nbsp;&nbsp;a. Run timings can be found (resource not in use).

&nbsp;&nbsp;&nbsp;b. Run setup can be looked at in the CHARM e-logbook

&nbsp;&nbsp;&nbsp;c. RadMON locations can be found (resource not in use).  

<br/>
<br/>

<sup>1</sup> SUM filtering is used on the SEC such that every event recorded is count and thus an accurate POT is retrieved.

<sup>2</sup> AVG filtering is used on the data because it is integrated over time, SUM for example would produce incorrect data sets. A 10 second window is a good compromise in order to shorten the length of the data set whilst correctly capturing any discernible variability in the sensor signal over time. ( = it does not change drastically during 10 seconds)


<br/>
Variable lists:

a. Radfets V5, PIN diodes V5, SEU counts V5:

RADMON.CHARM3:RAW_RF1

RADMOND.CHARM3:RAW_RF2

RADMOND.CHARM5:RAW_RF1

RADMOND.CHARM5:RAW_RF2

RADMOND.CHARM3:RAW_PIN3

RADMOND.CHARM5:RAW_PIN3

RADMON.CHARM3:SEU_COUNTS_INT

RADMON.CHARM5:SEU_COUNTS_INT

b. Radfets V6, PIN diodes V6, Bank1 counts V6 (Cypress, 3.3V), Bank 2 (Toshiba 3V)

SIMA.CHARMB3:RADFETS_0

SIMA.CHARMB3:RADFETS_1

SIMA.CHARMB4:RADFETS_0

SIMA.CHARMB4:RADFETS_1

SIMA.CHARMB5:RADFETS_0

SIMA.CHARMB5:RADFETS_1

SIMA.CHARMB6:RADFETS_0

SIMA.CHARMB6:RADFETS_1

SIMA.CHARMB7:RADFETS_0

SIMA.CHARMB7:RADFETS_1

SIMA.CHARMB8:RADFETS_0

SIMA.CHARMB8:RADFETS_1

SIMA.CHARMB3:PINDIODES_0

SIMA.CHARMB4:PINDIODES_0

SIMA.CHARMB5:PINDIODES_0

SIMA.CHARMB6:PINDIODES_0

SIMA.CHARMB7:PINDIODES_0

SIMA.CHARMB8:PINDIODES_0

SIMA.CHARMB3:SEU_B1_COUNTS_INT

SIMA.CHARMB3:SEU_B2_COUNTS_INT

SIMA.CHARMB4:SEU_B1_COUNTS_INT

SIMA.CHARMB4:SEU_B2_COUNTS_INT

SIMA.CHARMB5:SEU_B1_COUNTS_INT

SIMA.CHARMB5:SEU_B2_COUNTS_INT

SIMA.CHARMB6:SEU_B1_COUNTS_INT

SIMA.CHARMB6:SEU_B2_COUNTS_INT

SIMA.CHARMB7:SEU_B1_COUNTS_INT

SIMA.CHARMB7:SEU_B2_COUNTS_INT

SIMA.CHARMB8:SEU_B1_COUNTS_INT

SIMA.CHARMB8:SEU_B2_COUNTS_INT
