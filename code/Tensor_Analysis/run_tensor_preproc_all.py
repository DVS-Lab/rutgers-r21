
# coding: utf-8

# In[1]:


import pandas as pd 
import numpy as np
import os
import re
import subprocess


# In[2]:



cwd=os.getcwd()
fnames=pd.read_csv('../../rest_task_outlier_exclusion_data.csv')
fnames=fnames['fname']


# In[ ]:


for file in fnames:
    print file
    sub=re.search('sub-(.*)_task-', file).group(1)
    run=re.search('run-(.*)_bold', file).group(1)
    task=pd.read_csv('../../sourcedata/sub-%s/sub-%s_task-rest_run-%s_events.tsv'%(sub,sub,run),delimiter='\t')
    task=task['trial_type'][0]
    print(task)
    scriptname="preproc_sm_demean.sh"
    NCORES=20
    get_ipython().system(u'while [ $(ps -ef | grep -v grep | grep $scriptname | wc -l) -ge $NCORES ] ; do sleep 5s; done')
    get_ipython().system(u'bash $scriptname $sub $run &')
    get_ipython().system(u'sleep 5s')


