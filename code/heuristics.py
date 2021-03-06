import os

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')

    return template, outtype, annotation_classes

#0005: fmap/sub-<label>[_ses-<session_label>][_acq-<label>][_run-<run_index>]_magnitude1.nii[.gz]
#0006: fmap/sub-<label>[_ses-<session_label>][_acq-<label>][_run-<run_index>]_phasediff.nii[.gz]

def infotodict(seqinfo):

    t1w = create_key('sub-{subject}/anat/sub-{subject}_T1w')
    t2w = create_key('sub-{subject}/anat/sub-{subject}_T2w')
    mag = create_key('sub-{subject}/fmap/sub-{subject}_magnitude')
    phase = create_key('sub-{subject}/fmap/sub-{subject}_phasediff')
    cardgame = create_key('sub-{subject}/func/sub-{subject}_task-cardgame_run-{item:02d}_bold')
    rest = create_key('sub-{subject}/func/sub-{subject}_task-rest_run-{item:02d}_bold')


    info = {t1w: [], t2w: [], rest: [], cardgame: [], mag: [], phase: []}

    for s in seqinfo:
    		#the mag images should always be 72 since it's concatenating two images with 36 slices
        if (s.dim3 == 72) and ('gre_field' in s.protocol_name):
            info[mag] = [s.series_id]
        if (s.dim3 == 36) and ('gre_field' in s.protocol_name):
            info[phase] = [s.series_id]
        if (s.dim2 == 256) and ('t1' in s.protocol_name):
            info[t1w] = [s.series_id]
        if (s.dim2 == 256) and ('t2' in s.protocol_name):
            info[t2w] = [s.series_id]
        if (s.dim4 > 175) and ('CardGame' in s.protocol_name):
            info[cardgame].append({'item': s.series_id})
        if (s.dim4 > 175) and ('Rest' in s.protocol_name):
            info[rest].append({'item': s.series_id})


    return info
