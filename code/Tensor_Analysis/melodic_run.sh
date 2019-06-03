cd ../..
maindir=`pwd`
datalist=${maindir}/zimages_all4stims.txt
my_bg_image=${maindir}/derivatives/Tensor_ICA/bg_image.nii.gz
my_ica_output=${maindir}/derivatives/Tensor_ICA/Tensor_output_stimsassession.ica

echo ${maindir}
echo ${datalist}
echo ${bg_image}
echo ${my_ica_output}
echo `cat ${datalist}`


melodic -i ${datalist} -o ${my_ica_output} -v --nobet --report --guireport=report.html --Oall -a tica -v --nomask --bgimage=${my_bg_image}
