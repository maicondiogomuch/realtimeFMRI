#!/bin/tcsh

#execute this script once per run

setenv BASEDIR 			images	#export/home1/sdc_image_pool/images
setenv PATIENTDIR		0
setenv FULLPATH			0
setenv RTFMRI_AFNI_HOST		10.30.160.159	
setenv NUMBER_OF_SLICES		32
setenv TR_TIME			2.0
setenv VOLUMES_PER_RUN		16		



if ( ! -d $BASEDIR ) then 
	echo "-->Base Directory: "$BASEDIR "not found."
	echo "-->Please insert the correct BASEDIR using Sendimage -BASEDIR /../"
else
	cd $BASEDIR	
	echo "-->Base Directory: "$BASEDIR	

	#Look for AFNI program in the network to ensure that will be found when the exam start
	#--------------------------------------------------------------------------------------------------------
	#echo "--> Please start AFNI in $RTFMRI_AFNI_HOST host using afni -rt."
	#echo "--> Waiting for connection."	
	#while(testarconexao)
	#
	#	sleep 1	
	#	echo ".."	
	#end
	#echo "-->Connected with $RTFMRI_AFNI_HOST host."
	#--------------------------------------------------------------------------------------------------------
	echo "-->Searching for the new images from the Scanner. Start the Exam now!"
	
	#Waiting for the scanner to create the folder images
	#---------------------------------------------------------------------------------------------------------		
	set newdirfound = 0	
	while($newdirfound == 0)		
		sleep 1
		echo ".."		
		find . -type d > new.txt		#-mindepth 3
		if ( -f "last.txt" ) then
			setenv PATIENTDIR `diff last.txt new.txt | \
				awk 'END{ if($2) {print substr($2, RSTART + 3)}}'`		
			if($PATIENTDIR != "")set newdirfound = 1				
			rm new.txt
		else
			mv new.txt last.txt	
		endif	
	end
	rm last.txt
	#----------------------------------------------------------------------------------------------------------

	setenv FULLPATH $BASEDIR/$PATIENTDIR
	#cd $FULLPATH
	echo $FULLPATH "is now the current Patient."
	echo "Running Dimon..."

	Dimon -rt -infile_prefix $PATIENTDIR/i -host $RTFMRI_AFNI_HOST -pause 400 -tr $TR_TIME -dicom_org -nt $VOLUMES_PER_RUN -quit
	#Dimon -rt -infile_prefix $PATIENTDIR/i -host $RTFMRI_AFNI_HOST -tr $TR_TIME -quit	
				 	

endif
