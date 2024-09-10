#!/bin/bash

FIRMWARE_PATH="os.linux.intelnext.firmware/"
TARGET_PATH="../build/target/lib/firmware"

SRC_DIR="${FIRMWARE_PATH}i915"


# Remove old i915 files from live image
rm -rf $TARGET_PATH
mkdir -p $TARGET_PATH

# Clone intelnext repo without downloading any files
git clone --filter=blob:none --no-checkout https://github.com/intel-innersource/os.linux.intelnext.firmware

# Set git to download only i915 folder
git -C $FIRMWARE_PATH sparse-checkout set --no-cone /i915 '!*/i915'
git -C $FIRMWARE_PATH checkout master

# List of prefixes to search for
prefixes=("adlp_guc" "bxt_guc" "cml_guc" "dg1_guc" "dg1_huc" "dg2_guc" "ehl_guc" "glk_guc" "icl_guc" "kbl_guc" "mtl_gsc" "mtl_guc" "pvc_guc")

cd ${SRC_DIR}

# Function to compare two version strings X.Y.Z
compare_versions() {
    ver1=$1
    ver2=$2

    # Convert versions to arrays of integers
    IFS='.' read -r -a ver1_arr <<< "$ver1"
    IFS='.' read -r -a ver2_arr <<< "$ver2"

    # Compare each segment of the version
    for i in {0..2}; do
        seg1=${ver1_arr[i]:-0}  # Default to 0 if missing
        seg2=${ver2_arr[i]:-0}  # Default to 0 if missing
        
        # Compare numeric values
        if [[ $seg1 -gt $seg2 ]]; then
            return 1
        elif [[ $seg1 -lt $seg2 ]]; then
            return 2
        fi
    done
    return 0  # Versions are equal
}

# Loop through each prefix
for prefix in "${prefixes[@]}"; do
    echo "Processing files for prefix: $prefix"
    
    # Find all files with the current prefix
    files=($(ls ${prefix}_*.bin 2>/dev/null))

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files found for prefix: $prefix"
        continue
    fi

    # Variable to hold the highest version file
    highest_version_file=""
    highest_version=""

    # Loop through files to determine the highest version
    for file in "${files[@]}"; do
        version=$(echo "$file" | sed -r "s/^${prefix}_([0-9]+\.[0-9]+\.[0-9]+)\.bin$/\1/")
        
        if [[ -z $highest_version ]]; then
            highest_version=$version
            highest_version_file=$file
        else
            compare_versions "$version" "$highest_version"
            result=$?
            if [[ $result -eq 1 ]]; then
                highest_version=$version
                highest_version_file=$file
            fi
        fi
    done

    echo "Highest version for prefix $prefix: $highest_version_file"

    # Delete all other files except the one with the highest version
    for file in "${files[@]}"; do
        if [[ $file != "$highest_version_file" ]]; then
            echo "Deleting $file"
            rm "$file"
        fi
    done
done

cd -

cp -r $FIRMWARE_PATH"i915" $TARGET_PATH

# Remove intelnext repo
rm -rf $FIRMWARE_PATH