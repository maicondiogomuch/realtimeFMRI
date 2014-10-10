#!/bin/tcsh

setenv AFNI_REALTIME_Registration  	3D:_realtime
setenv AFNI_REALTIME_Base_Image    	2
setenv AFNI_REALTIME_Graph         	Realtime
setenv AFNI_REALTIME_MP_HOST_PORT  	localhost:53214
setenv AFNI_REALTIME_SEND_VER      	YES
setenv AFNI_REALTIME_SHOW_TIMES    	YES
setenv AFNI_REALTIME_Mask_Vals     	ROI_means
setenv AFNI_REALTIME_Function 	   	FIM
setenv AFNI_TRUSTHOST		   	10.30.160.159

setenv RECEIVED_IMAGES_DIR		imagesAFNI

if ( ! -d $RECEIVED_IMAGES_DIR ) mkdir imagesAFNI
endif	   	 

cd $RECEIVED_IMAGES_DIR

afni -rt -yesplugouts                     \
     -com "SWITCH_UNDERLAY epi_r1+orig"   \
     -com "SWITCH_OVERLAY func_slim+orig" &

#prompt_user -pause        "         \
# - open graph window                \
# - FIM->Ignore->2                   \
# - FIM->Pick Ideal->epi_r1_ideal.1D \
# - close graph window"

