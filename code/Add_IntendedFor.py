
# coding: utf-8

# In[12]:


#imports libraries
import json
import os
import subprocess
# sets subject number we can later set this to all in the bids folder

#gets current working directory If your bids is in the same folder as this file this should work for everyone
cwd = os.getcwd() 
bidsdir="/%s/../ds000000"%(cwd)


# In[2]:
files= os.listdir(bidsdir)
subs=[x for x in files if x.startswith('sub')]
for subj in subs:
	print subj
	#makes list of the json files to edit
	files = os.path.abspath("%s/sub-%s/fmap"%(bidsdir,subj))
	files_json = [i for i in files if i.endswith('.json')]
	#makes list of the func files to add into the intended for field
	files = ["func/%s"%(file) for file in os.listdir('%s/sub-%s/func'%(bidsdir,subj))]
	files_txt = [i for i in files if i.endswith('.nii.gz')]

	#This could be done better but we open the json files ('r' for read only) as a dictionary add the Intended for key 
	#and add the func files to the key value
	#The f.close is a duplication. f can only be used inside the with "loop"
	# we open the file again to write only and dump the dictionary to the files
	for i in range(len(files_json)):
		with open(files_json[i],'r')as f:
			data=json.load(f)
			data["IntendedFor"]=[files_txt]
			f.close
		with open(files_json[i],'w')as f:
	        	json.dump(data,f)
	        	f.close


# In[ ]:


files

