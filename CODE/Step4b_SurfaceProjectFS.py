import subprocess
from pathlib import Path
import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("-subs", type=str, help="path to list of subjects (txt)")
parser.add_argument("-analysis", type=str, help="base, or s1 or s2")
args = parser.parse_args()
analysis = args.analysis

participant_list = pd.read_csv(args.subs, header=None, sep="\t", engine="python")[0].astype(str).str.strip()

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
hemis = ["L", "R"]

for sub in participant_list:
    subdir = basedir / sub
    surf_dir = subdir / "surf"

    for hemi in hemis:
        # Match FreeSurfer hemisphere names
        hemi_fs = "lh" if hemi == "L" else "rh"
        
        # Input and intermediate filenames
        fs_thickness = surf_dir / f"{hemi_fs}.thickness.fsaverage"
        fs_gii = surf_dir/ f"{hemi_fs}.thickness.fsavg6.func.gii"
        fsLR_gii = surf_dir / f"{sub}.{hemi}.thickness.fsLR32.func.gii"

        # Surface and registration references
        src_sph = fsavg_dir / f"fsaverage_std_sphere.{hemi}.164k_fsavg_{hemi}.surf.gii"
        tgt_sph = fsavg_dir / f"fs_LR-deformed_to-fsaverage.{hemi}.sphere.32k_fs_LR.surf.gii"
        tgt_va = fsavg_dir / f"fs_LR.{hemi}.midthickness_va_avg.32k_fs_LR.shape.gii"
        fsavg_va = fsavg_dir / f"fsaverage.{hemi}.midthickness_va_avg.164k_fsavg_{hemi}.shape.gii"

        # # Step 1: convert FreeSurfer binary surface data to GIFTI
        # subprocess.run([
        #     "mris_convert", str(fs_thickness), str(fs_gii)
        # ], check=True)

        # Resample to fsLR 32k
        subprocess.run([
            "wb_command", "-metric-resample", str(fs_gii),
            str(src_sph), str(tgt_sph), "ADAP_BARY_AREA",
            str(fsLR_gii),
            "-area-metrics", str(fsavg_va), str(tgt_va)
        ], check=True)

        print(f"[✓] {sub} {hemi} thickness projected → {fsLR_gii}")