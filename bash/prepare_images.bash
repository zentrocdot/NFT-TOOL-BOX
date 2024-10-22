#!/usr/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC2206
#
# Prepare image files for minting as NFT.
# Version 0.0.0.6
# Copyright © 2024, Dr. Peter Netz
# Published under the MIT license.
#
# Description:
# The allowed image file types in case of this script are .jpg, .jpeg
# and .png. The script removes all the exif data from all files in a
# directory. Then new exif data are added to the file. Then the md5
# hash of the file is calculated. The original file is renamed using
# the md5 hash value, which is characteristic for the file.

# Define the set of valid file type extensions.
FILES=("*.jpg" "*.JPG" "*.jpeg" "*.JPEG" "*.png" "*.PNG")

# Set the creator related global EXIF data strings.
CREATOR="zentrocdot"
CREATORTOOL="AI Generator Stable Diffusion, AI WebUI AUTOMATIC1111"
COPYRIGHT="2024, zentrocdot"

# Set the image related global EXIF data strings.
USERCOMMENT="Cup Of Ice Collection"
IMAGEDESCRIPTION="Selected image for minting as NFT"

# Set the variable NOMATCH to True.
NOMATCH=True

# -------------------------
# Function modify exif data
# -------------------------
modify_exifdata () {
    # Set temporary filename.
    tmpfn=$1
    # Meta tag comment is preserved.
    comment=$(exiftool -s3 -usercomment "${tmpfn}")
    if [[ "${comment}" =~ ^Postprocess[[:space:]]upscale[[:space:]]by:[[:space:]]8.* ]]; then
        comment="Postprocessed upscaled image"
    fi
    # Strip all exif data from temporary file.
    exiftool -all= "${tmpfn}"
    # Add new exif data to the temporary file.
    exiftool -comment="${comment}" -usercomment="${USERCOMMENT}" \
             -creator="${CREATOR}" -creatortool="${CREATORTOOL}" \
             -imagedescription="${IMAGEDESCRIPTION}" "${tmpfn}" \
             -copyright="${COPYRIGHT}" "${tmpfn}" \
             -platform="Linux"
}

# -----------------------
# Function prepare_images
#
# Function Call:
#     modify_exifdata
# -----------------------
prepare_images () {
    # Loop over all image files by extension.
    for ext in "${FILES[@]}"
    do
        # Get the file list.
        list=$(ls ${ext} 2>/dev/null)
        # Create an array from a multiline string.
        SAVEIFS=$IFS; IFS=$'\n'; files=(${list}); IFS=$SAVEIFS
        # Loop over all files from the file list.
        for file in "${files[@]}"
        do
            # Check if a filename is a md5 hash. Ignore md5 filenames.
            filename="${file%.*}"
            size=${#filename}
            MD5="${file:0:32}"
            if [[ ! ${MD5} =~ ^[a-f0-9]{32}$ ]] || [ "${size}" -ne 32 ]
            then
                NOMATCH=False
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
                # Remove the not wanted bckup of original file.
                rm "${tmpfn}"_original
                # Remove the original file.
                rm "${file}"
            fi
        done
    done
}

# +++++++++++++++++++
# Main script section
# +++++++++++++++++++

# Print a header message into the terminal window.
echo -e "Prepare images for minting as NFT\n"

# Call main script function.
prepare_images

# Print a message in the terminal window.
if [[ "${NOMATCH}" == True ]]; then
    echo -e "Nothing to do yet!"
fi

# Print a farewell message into the terminal window.
echo -e "\nHave a nice day. Bye!"

# Exit the script.
exit 0
