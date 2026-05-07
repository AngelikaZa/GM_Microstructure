import glob, nibabel as nib
import numpy as np, pandas as pd
from brainstat.stats.SLM import SLM
from brainspace.datasets import load_conte69  # fsLR-32k surfaces
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("-subs", type=str, help="path to list of subjects")
parser.add_argument("-analysis", type=str, help="base, or s1 or s2 or s3")
args = parser.parse_args()
participant_list = args.subs
analysis = args.analysis

def read_func(path): return nib.load(path).darrays[0].data.astype(np.float32)

# Define paths
root = Path("Y:/PROJECTS/GMmicrostructure/DATA")
if analysis == "s1":
    basedir = root / "Longitudinal_VIPD/SESSION1"
elif analysis == "s2":
    basedir = root / "Longitudinal_VIPD/SESSION2"
else:
    basedir = root

fsavg_dir = root / "fsaverage"
template = fsavg_dir / "fsaverage_brain.nii.gz"

maps = ["FWF", "NDI_ftissue", "ODI_ftissue"]
subs = pd.read_csv(participant_list, header=None, sep="\t", engine="python")[0].astype(str).str.strip()

# Loop through subjects
for m in maps:
    L = [fr"{basedir}\{s}\AMICO\NODDI\{s}.L.{m}.fsLR32.func.gii" for s in subs]
    R = [fr"{basedir}\{s}\AMICO\NODDI\{s}.R.{m}.fsLR32.func.gii" for s in subs]
    # concatenate and stack to array
    Y = np.vstack([
        np.concatenate([read_func(lh), read_func(rh)])
        for lh, rh in zip(L, R)
    ])

    out = f"Y_{m}_fslr32k_{analysis}.npy"
    np.save(out, Y)
    print(f"Saved {Y.shape} → {out}")