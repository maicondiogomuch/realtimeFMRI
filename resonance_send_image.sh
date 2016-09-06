#!/bin/tcsh

#-------------------------------------------------------------------------------------
# Description: 	This script intended to localize the folder that contain the
#             	new images from the exam and start Dimon in real time mode
#		to send the images to AFNI in AFNI_HOST computer.
#
# Author: 	Maicon Diogo Much [MDM]
#
# Date:		15/09/14
#
# Revision:	--/--/-- - Description/Author
#		15/09/14 - First Release/[MDM]
#		14/10/14 - find. type spend much time. Changed to ls -t before 
#			   find . -type d. Localizer exam must be executed to 
#			   create the new folder before starting find . -type d./[MDM]
#		25/03/15 - It worked first time
#		24/04/15 - rt_cmd added to configure afni Layout
#-------------------------------------------------------------------------------------

#execute this script once per run

#setenv RESONANCE_COMPUTER		#comment this line to use this scipt in another computer

if ( ! ($?RESONANCE_COMPUTER) ) then	#set base dir in Resonance computer and in another computer	
	setenv BASEDIR 			images 
else
	setenv BASEDIR 			home1/sdc_image_pool/images
endif

setenv PATIENTDIR		0
setenv FULLPATH			0
setenv RTFMRI_AFNI_HOST		192.168.1.173 #10.30.160.159	
setenv NUMBER_OF_SLICES		29
setenv TR_TIME			2.0	
setenv VOLUMES_PER_RUN		16
setenv FMRI_SESSION		REAL_TIME_FMRI	
setenv MASKSET                  rt.__001+orig   	
			
	                                                                    	
	echo "\n"	
	echo "Brain Institute"
	echo "Porto Alegre-RS-Brazil"
	echo "Description: This script will help you to Send the images to AFNI in real time."

if ( ! -d $BASEDIR ) then 
	echo "-->Scanner Base Directory: "$BASEDIR "nout found."
else
	cd $BASEDIR	
	echo "-->Scanner Base Directory: "$BASEDIR	
	echo "\n"
	echo "--> To send the images in real time is necessary run the localizer exam before."	
	echo "--> Press Enter only if you have executed the localizer exam from this patient."		
	set stuff = $<
	#Look for the new patient
	#--------------------------------------------------------------------------------------------------------
	setenv PATIENTBASEDIR `ls -ht | head -1`
	echo -n "--> $BASEDIR/"$PATIENTBASEDIR "is the Patient created for this exam at" `date -r $PATIENTBASEDIR`". Is this correct? (yes or Enter/no):"	
	set choice = $<	
	switch ($choice)
	     case [yY][eE][sS]:	
	       breaksw
	     case "":
	       breaksw
	     case [nN][oO]:
	       	echo "--> Wrong Patient. Please run the localizer exam before start this script."
		exit(1)
	       breaksw
	     endsw
	
	#--------------------------------------------------------------------------------------------------------		
	cd $PATIENTBASEDIR	
	
	echo "\n"
	echo -n "--> Please insert TR in the form [2.0 or 3.0 or 5.0] [Enter to default = 2.0]:"			
	set choice = $<	
	if($choice != "")setenv TR_TIME 		choice	
	echo "--> TR was sucessfully changed to:" $TR_TIME
	echo "\n"
	set choice = ""

	echo -n "--> Please insert the number of volumes [Enter to default = 131]:"			
	set choice = $<	
	if($choice != "")setenv VOLUMES_PER_RUN 	choice	
	echo "--> Number of volumes was sucessfully changed to:" $VOLUMES_PER_RUN	
	echo "\n"
	set choice = ""
	
	echo -n "--> Please insert the number of slices [Enter to default = 29]:"			
	set choice = $<		
	if($choice != "")setenv NUMBER_OF_SLICES 	choice	
	echo "--> Number of slices was sucessfully changed to:" $NUMBER_OF_SLICES	
	echo "\n"

        echo -n "--> Please insert the session name [Enter to default = REAL_TIME_FMRI]:"			
	set choice = $<		
	if($choice != "")setenv FMRI_SESSION 	choice	
	echo "--> Session name was sucessfully changed to:" $FMRI_SESSION	
	echo "\n"

	echo "-->Searching for the new images from the Scanner. Start the Exam now!"
	
	#Waiting for the scanner to create the folder images
	#---------------------------------------------------------------------------------------------------------		
	set newdirfound = 0

	if ( -f "last.txt" )rm -f last.txt		#verify if exists
	if ( -f "new.txt"  )rm -f new.txt		#verify if exists
	
	while($newdirfound == 0)		
		sleep 1
		echo ".."		
		find . -type d > new.txt		
		if ( -f "last.txt" ) then
			setenv PATIENTDIR `diff last.txt new.txt | \
				awk 'END{ if($2) {print substr($2, RSTART + 3)}}'`		
			if($PATIENTDIR != "")set newdirfound = 1							
			rm -f new.txt
		else
			mv new.txt last.txt	
		endif	
	end
	rm -f last.txt
	----------------------------------------------------------------------------------------------------------
	#setenv PATIENTDIR e829384784/s103760941rt 
	setenv FULLPATH $BASEDIR/$PATIENTBASEDIR/$BASEDIR/$PATIENTBASEDIR/$PATIENTDIR

	echo $FULLPATH "is now the current Patient."

#-------------------------------------------------------------------------------------
# -rt 			= realtime mode
# -infile_prefix 	= Folder that contain dicom 
# -pause 		= Pause between volumes in offline mode
# -tr			= Time between volumes
# -dicom_org		= organize dicom in offline mode
# -rt_cmd		= drive afni with commands
# -num_slices		= Number of slices
# -nt			= Number of volumes
# -quit			= quit when end the volumes
#-------------------------------------------------------------------------------------

#sort methos
#           none            : do not apply any real-time sorting
#           acq_time        : by acqusition time, if set
#           default         : sort by run, [ATIME], IIND, RIND
#           geme_index      : by GE multi-echo index
#           num_suffix      : based on numeric suffix
#           zposn           : based on z-coordinate and input order

#considerar colocar pause no real time


if ( ! ($?RESONANCE_COMPUTER) ) then	#set base dir in Resonance computer and in another computer	
		
	Dimon 	-rt 								\
		-infile_prefix $PATIENTDIR/i					\
		-host $RTFMRI_AFNI_HOST 					\
		-pause 1000 							\
		-tr $TR_TIME 							\
		-dicom_org 							\
		-num_slices $NUMBER_OF_SLICES					\
		-nt $VOLUMES_PER_RUN 						\
                -rt_cmd 'PREFIX '$FMRI_SESSION''				\
		-rt_cmd 'GRAPH_XRANGE '$VOLUMES_PER_RUN''	        	\
		-drive_afni 'SETENV AFNI_REALTIME_Mask_Dset '$MASKSET''         \
                #-max_quiet_trs 3                      				\
                #-sleep_frac 0.4                       				\
		#-sort_method num_suffix						\
		#-sleep_init 3000						\
		#-zorder alt							\
		#-sleep_vol 2000							\
		#-debug 3							\
		-quit 

else

	Dimon 	-rt 							\
		-infile_prefix $PATIENTDIR/i 				\
		-host $RTFMRI_AFNI_HOST 				\
		-tr $TR_TIME 						\
		-nt $VOLUMES_PER_RUN 					\
		-rt_cmd 'GRAPH_XRANGE '$VOLUMES_PER_RUN''	        \
		-num_slices $NUMBER_OF_SLICES				\
		-quit


endif				 	

endif
