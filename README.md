# Analysis pipeline for GM NODDI 

## CODE
## Step 1. Data preprocessing 
### Step 1a. PreprocessMPRAGE.sh
- Brain mask and tissue segmentation
- Register to DWI
- Shaeffer parcellation
- Prerequisites: fsl, niftyreg

### Step 1b. Prepare Diffusion
- DWIpreproc: Motion, ringing, bias correct (prev performed)
- Step1b.AMICO.py: Fit NODDI model
- Prerequisites on environment.yml

### Step 1c. Get Tissue Fraction Maps
- Step1c_GetTissueFractionMaps.sh

## Step 2. Whole Brain Analysis
### Step 2a. RegisterToTemplate.sh
- Registers all T1/DWI images to fsaverage template

### Step 2b. SurfaceProject.sh (bash) or .py (python subprocess for powershell)
- Projects the NODDI derived maps fsaverage template to allow for surface-based whole brain comparisons
- Prerequisites: connectome workbench

### Step 2c. CollateSurfaces.py
- Collates and joins hemisphere files into a numpy array Y (n_subj × n_verts)
- Prerequisites: Brainstat

### Step 3. GetSubcorticalMeans.sh
- Collates tissue-weighted means for subcortical regions of interest using the Tian 32 parcellation

## Step 4. Cortical Thickness
### Step 4a. PrepFSdata.sh
- Converts FS thickness files to giftii

### Step 4b. SurfaceProjectFS.py
- Surface proejects cortical thickness to FSLR for subsequent use with Brainstat

Also contains all the files (Schaefer and Tian atlas, normative surfaces etc) needed for analyses.
Downloaded from HCP github https://github.com/Washington-University/HCPpipelines/tree/master/global/templates/standard_mesh_atlases/resample_fsaverage 
 
## DATA
All metrics for 200 cortical regions as array
