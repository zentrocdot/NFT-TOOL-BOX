#!/usr/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC2206
#
# Prepare image files for minting as NFT.
# Version 0.0.0.3
# Copyright © 2024, Dr. Peter Netz
# Published under the MIT license.
#
# Description:
# The script removes all the exif data from all the files in a directory.
# Then new exif data are added to the file. Then the md5 hash of the file
# is calculated. The original file is renamed using the characteristic
# md5 hash value.

# Define the set of valid file type extensions.
FILES=("*.jpg" "*.JPG" "*.jpeg" "*.JPEG" "*.png" "*.PNG")

# Set the global EXIF data strings.
CREATOR="zentrocdot"
CREATORTOOL="AI Generator Stable Diffusion, AI WebUI Easy Diffusion"
COPYRIGHT="2024, zentrocdot"
USERCOMMENT="Fantastic Mushroom Collection"
IMAGEDESCRIPTION="Selected image for minting as NFT"

# -------------------------
# Function modify exif data
# -------------------------
modify_exifdata () {
    # Set temporary filename.
    tmpfn=$1
    # Meta tag comment is preserved.
    comment=$(exiftool -s3 -usercomment "${tmpfn}")
    # Strip all exif data from temporary file.
    exiftool -all= "${tmpfn}"
    # Add new exif data to the temporary file.
    exiftool -comment="${comment}" -usercomment="${USERCOMMENT}" \
             -creator="${CREATOR}" -creatortool="${CREATORTOOL}" \
             -imagedescription="${IMAGEDESCRIPTION}" "${tmpfn}" \
             -copyright="${COPYRIGHT}" "${tmpfn}"
}

# -----------------------
# Function prepare_images
# -----------------------
prepare_images () {
    # Loop over all image files by extension.
    for ext in "${FILES[@]}"
    do
        # Get the file list.
        list=$(ls ${ext} 2>/dev/null)
        files=(${list})
        # Loop over all files from the file list.
        for file in "${files[@]}"
        do
            # Check if a filename is a md5 hash. Ignore md5 filenames.
            MD5="${file:0:32}"
            if [[ ! ${MD5} =~ ^[a-f0-9]{32}$ ]]
            then
                # Get the file extension.
                extension="${file##*.}"
                # Create a temporary filename.
                tmpfn="tmp.${extension}"
                # Print the filename in work to screen.
                echo -e "${file}"
                # Copy the file to the temporary file.
                cp "${file}" "${tmpfn}"
                # Strip all exif data from temporary file.
                modify_exifdata "${tmpfn}"
                # Get the md5 hash of the temporary file.
                HASH=$(md5sum "${tmpfn}" | awk '{print $1}')
                # Rename the temporary file using the md5 hash as filename.
                mv "${tmpfn}" "${HASH}"."${extension}"
                # Remove the not wanted original file.
                rm "${tmpfn}"_original
            fi
        done
    done
}

# +++++++++++++++++++++++++++++
# Call the main script function
# +++++++++++++++++++++++++++++
prepare_images

# Exit the script.
exit 0
