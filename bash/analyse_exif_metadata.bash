#!/usr/bin/bash
# shellcheck disable=SC1083
# shellcheck disable=SC2155
# shellcheck disable=SC2059
# shellcheck disable=SC2076
# shellcheck disable=SC2034
#
# Extract exif metadata from image.
# Version 0.0.1.2
# Copyright © 2024, Dr. Peter Netz
# Published under the MIT license.
#
# Description:
# Extract slected exif data from image file.
#
# Prerequisite:
# Installation of exiftool
# sudo apt-get install exiftool
#
# Development Environment:
# Linux 5.15.0-117-generic #127-Ubuntu SMP Fri Jul 5 20:13:28 UTC 2024 x86_64 GNU/Linux
# Linuxmint, Linux Mint 21.3, Virginia

# Get the filename from the command line.
FN=$1

# Check if file exist. Otherwise exit script.
if [ ! -f "${FN}" ]; then
    # Write a message into the terminal window.
    echo "File not found! Bye!"
    # Exit script with error code 1.
    exit 1
fi

# Initialise the boundary key and value variables.
R4=8192  # or higher -> Ultra High
R3=4096  # or higher -> High
R2=2048  # or higher -> Medium
R1=512   # or higher -> Low
R0=0     # or higher -> Not Allowed
S4="Ultra High"
S3="High"
S2="Medium"
S1="Low"
S0="Not Allowed"

# Declare the associative array for key and value pairs of the resolutions.
declare -A resarray=(["${R4}"]="${S4}" ["${R3}"]="${S3}"
                     ["${R2}"]="${S2}" ["${R1}"]="${S1}"
                     ["${R0}"]="${S0}")
# Declare the orders array for the resolutions. Keeps the order of the associative array.
declare -a resorders=("${R4}" "${R3}" "${R2}" "${R1}" "${R0}")

# Set collection key and value variables.
T1="Mushroom"
T2="Avatar"
T3="Cyberpunk Girls"
T4=""
C1="Fantastic Mushroom Collection"
C2="Avatar Image Collection"
C3="Cyberpunk Girls Image Collection"
C4=""

# Declare the associative array for key and value pairs of the collections.
declare -A collection_array=(["${T1}"]="${C1}" ["${T2}"]="${C2}"
                             ["${T3}"]="${C3}" ["${T4}"]="${C4}")

# -------------------------------
# Function make script executable
# -------------------------------
function make_executable {
    # Assign the function argument to the local variable.
    scriptname=$1
    # Make the script executable.
    if [ -x "${scriptname}" ]; then
        echo -e "Script is executable!"
    else
        echo -e "Script is NOT executable yet!"
        chmod u+x "${scriptname}"
    fi
    # Return the error code 0.
    return 0
}

# ---------------------
# Function print header
# ---------------------
header () {
    # Print the header to the screen.
    echo -e "\e[44m**********************\e[49m"
    echo -e "\e[44mEXIF Metadata Analysis\e[49m"
    echo -e "\e[44m**********************\e[49m\n"
    # Return the error code 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function gcd
# ------------------------------------------------------------------------------
function gcd {
    # Assign the function arguments to the local variables.
    local a=$1
    local b=$2
    # Declare the variable n.
    local n
    # Loop until the greatest common divisor is found.
    while [[ "${b}" -gt 0 ]]
    do
        n="${a}"
        a="${b}"
        b=$((n%b))
    done
    # Output the greatest common divisor.
    echo -n "${a}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function get_orientation
# ------------------------------------------------------------------------------
function get_orientation {
    # Assign the function arguments to the local variables.
    local x=$1
    local y=$2
    # Set the local page orientation strings.
    local po_str0="Unknown"
    local po_str1="None"
    local po_str2="Landscape"
    local po_str3="Portrait"
    # Initialise the local variable.
    local orientation="n\a"
    # Determine the orientation of the image.
    if [ "${y}" -gt "${x}" ]; then
        orientation="${po_str3}"
    elif [ "${y}" -lt "${x}" ]; then
        orientation="${po_str2}"
    elif [ "${x}" -eq "${y}" ]; then
        orientation="${po_str1}"
    else
        orientation="${po_str0}"
    fi
    # Output the orientation.
    echo -n "${orientation}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function get_resolution
# ------------------------------------------------------------------------------
function get_resolution {
    # Assign the function arguments to the local variables.
    local x=$1
    local y=$2
    # Initialise the local variables.
    resolution="Unknown"
    # Loop over the resolution array.
    for i in "${resorders[@]}"
    do
        # Check x and y. Leave loop on match.
        if [ "${y}" -ge "${i}" ] && [ "${x}" -ge "${i}" ]; then
            resolution="${resarray[${i}]}"
            break
        fi
    done
    # Output the resolution.
    echo -n "${resolution}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function aspect_ratio
# ------------------------------------------------------------------------------
function aspect_ratio {
    # Get width and height from the function arguments.
    local xres=$1
    local yres=$2
    # Calculate the greatest common divisor.
    gcd_val=$(gcd "${xres}" "${yres}")
    # Calculate the aspect ratio.
    x=$((xres/gcd_val))
    y=$((yres/gcd_val))
    # Output the aspect ratio.
    echo -n "${x}:${y}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function calc_size
# ------------------------------------------------------------------------------
function calc_size {
    # Get the filesize from the function argument.
    local filesize=$1
    # Get the unit from the filesize string.
    unit=$(echo "${filesize}" | awk {'print $2'})
    # Check on KiB and on MiB
    if [[ "${unit}" == "KiB" ]]; then
        kib_raw=$(echo "${filesize}" | awk {'print $1'})
        mib_raw=$(echo "scale=1;(${kib_raw}/1000)" | bc)
    elif [[ "${unit}" == "MiB" ]]; then
        mib_raw=$(echo "${filesize}" | awk {'print $1'})
    else
        mib_raw=-1
    fi
    # Format the MiB and MB value.
    mib=$(echo "${mib_raw}" | awk '{printf "%.1f", $0}')
    mb_raw=$(echo "scale=1;(${mib_raw}*1.048576)" | bc)
    mb=$(echo "${mb_raw}" | awk '{printf "%.1f", $0}')
    # Output formatted MiB and MB value.
    echo -n "${mib}" "${mb}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function is_wallpaper
# ------------------------------------------------------------------------------
function is_wallpaper {
    # Assign the function arguments to the local variables.
    local x=$1
    local y=$2
    # Initialise the local variables.
    wp="n\a"
    # Wallpaper yes/no.
    if [ "${y}" -ge "${x}" ]; then
        fac=$(echo "scale=1;(${y}/${x})" | bc)
    else
        fac=$(echo "scale=1;(${x}/${y})" | bc)
    fi
    if (( $(echo "${fac} > 1.2" | bc -l) )) && (( $(echo "${fac} < 1.8" | bc -l) )); then
        wp="Yes"
    else
        wp="No"
    fi
    # Output wallpaper string.
    echo -n "${wp}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function creator_tool
# ------------------------------------------------------------------------------
function creator_tool {
    # Assign the function argument to the local variable.
    local creatortool=$1
    # Set the local strings.
    local ig0="Unknown"
    local ig1="Stable Diffusion"
    local ui0="Unknown"
    local ui1="Easy Diffusion"
    local ui2="AUTOMATIC1111"
    # Get AI generator.
    if [[ "${creatortool}" =~ "${ig1}" ]]; then
        generator="${ig1}"
    else
        generator="${ig0}"
    fi
    # Get AI web UI.
    if [[ "${creatortool}" =~ "${ui2}" ]]; then
        webui="${ui2}"
    elif [[ "${creatortool}" =~ "${ui1}" ]]; then
        webui="${ui1}"
    else
        webui="${ui0}"
    fi
    # Output engine and webui.
    echo -n "${generator};${webui}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function get_category
# ------------------------------------------------------------------------------
function get_category {
    # Assign the function argument to the local variable.
    local comment=$1
    # Set the local variable.
    local category="Unknown"
    # Loop over the collection array.
    for c in "${!collection_array[@]}"
    do
        # Check the tag comment. Leave loop on match.
        if [[ "${usercomment}" == "${collection_array[${c}]}" ]]; then
            category="${c}"
            break
        fi
    done
    # Output category.
    echo -n "${category}"
    # Return 0.
    return 0
}

# ------------------------------------------------------------------------------
# Function print_exifdata
# ------------------------------------------------------------------------------
function print_exifdata {
    # Get the filename from the function argument.
    local fn=$1
    # Get the md5 hash value for the file.
    local hash=$(md5sum "${fn}" | awk '{print $1}')
    # Get basename and extension.
    filename="${fn%.*}"
    extension="${fn##*.}"
    # Get EXIF version.
    exifversion=$(exiftool -exifversion -s3 "${fn}")
    # Get filetype.
    ft=$(exiftool -filetype -s3 "${fn}")
    fte=$(exiftool -filetypeextension -s3 "${fn}")
    mt=$(exiftool -mimetype -s3 "${fn}")
    # Check extension.
    if [ "${extension,,}" != "${fte,,}" ]; then
        echo -e "\e[41mWARNING! Extension mismatch!\e[49m\n"
    fi
    # Check md5 hash.
    if [ "${hash,,}" != "${filename,,}" ]; then
        echo -e "\e[41mWARNING! MD5 hash mismatch!\e[49m\n"
    fi
    # Get the width and height of the image.
    xres=$(exiftool -imagewidth -s3 "${fn}")
    yres=$(exiftool -imageheight -s3 "${fn}")
    # Get the creator and copyright informations.
    copyright=$(exiftool -copyright -s3 "${fn}")
    creator=$(exiftool -creator -s3 "${fn}")
    creatortool=$(exiftool -creatortool -s3 "${fn}")
    # Get the informations from the comment tags.
    comment=$(exiftool -comment -s3 "${fn}")
    usercomment=$(exiftool -usercomment -s3 "${fn}")
    imagedescription=$(exiftool -imagedescription -s3 "${fn}")
    # Get the filesize and the image size of the image.
    filesize=$(exiftool -filesize -s3 "${fn}")
    megapixels=$(exiftool -megapixels -s3 "${fn}")
    imagesize0=$(exiftool -imagesize -s3 "${fn}" | sed 's/x/ x /')
    imagesize1="${xres} x ${yres}"
    # Calculate MiB and MB.
    read -r mib mb < <(calc_size "${filesize}")
    # Calculate the aspect ratio.
    ar=$(aspect_ratio "${xres}" "${yres}")
    # Wallpaper yes/no.
    wp=$(is_wallpaper "${xres}" "${yres}")
    # Get AI generator an AI web UI.
    IFS=";" read -r engine webui < <(creator_tool "${creatortool}")
    # Determine the image oriantation.
    io=$(get_orientation "${xres}" "${yres}")
    # Determine the image resolution.
    ir=$(get_resolution "${xres}" "${yres}")
    # Get category.
    category=$(get_category "${comment}")
    # Print the summery into the terminal window.
    fmtstr="%-28s%s%b"
    printf "${fmtstr}" "ExifTool Version:" "${EXIFTOOL_VERSION}" "\n"
    printf "${fmtstr}" "Exif Version:" "${exifversion}" "\n\n"
    printf "${fmtstr}" "Filename (ARG):" "${fn}" "\n"
    printf "${fmtstr}" "MD5 Hash (CALC):" "${hash}" "\n\n"
    printf "${fmtstr}" "Image Description (EXIF):" "${imagedescription}" "\n"
    printf "${fmtstr}" "AI Generator (EVAL):" "${engine}" "\n"
    printf "${fmtstr}" "AI Web UI (EVAL):" "${webui}" "\n"
    printf "${fmtstr}" "Category (EVAL):" "${category}" "\n"
    printf "${fmtstr}" "Copyright (EXIF):" "${copyright}" "\n"
    printf "${fmtstr}" "Creator: (EXIF)" "${creator}" "\n"
    printf "${fmtstr}" "Creator Tool (EXIF):" "${creatortool}" "\n"
    printf "${fmtstr}" "Comment (EXIF):" "${comment}" "\n"
    printf "${fmtstr}" "User Comment (EXIF):" "${usercomment}" "\n"
    printf "${fmtstr}" "File Type (EXIF):" "${ft}" "\n"
    printf "${fmtstr}" "File Type Extension (EXIF):" "${fte}" "\n"
    printf "${fmtstr}" "Mime Type (EXIF):" "${mt}" "\n"
    printf "${fmtstr}" "File Size (MiB):" "${mib} MiB" "\n"
    printf "${fmtstr}" "File Size (MB):" "${mb} MB" "\n"
    printf "${fmtstr}" "Megapixels (EXIF):" "${megapixels}" "\n"
    printf "${fmtstr}" "Image Width (EXIF):" "${xres}" "\n"
    printf "${fmtstr}" "Image Height (EXIF):" "${yres}" "\n"
    if [ "${imagesize}" != "${imagesize_ra}" ]; then
        printf "${fmtstr}" "Image Size (EVAL):" "${imagesize1} pixel" "\n"
    fi
    printf "${fmtstr}" "Image Size (EXIF):" "${imagesize0} pixel" "\n"
    printf "${fmtstr}" "Aspect Ratio (CALC):" "${ar}" "\n"
    printf "${fmtstr}" "Orientation (EVAL):" "${io}" "\n"
    printf "${fmtstr}" "Resolution: (EVAL)" "${ir}" "\n"
    printf "${fmtstr}" "Wallpaper: (CALC)" "${wp}" "\n"
    # Return 0.
    return 0
}

# +++++++++++++++++++++++++++++
# Main script section
# +++++++++++++++++++++++++++++

# Get exittool version
EXIFTOOL_VERSION=$(exiftool "${FN}" | \
                   grep "ExifTool Version Number" | \
                   awk -F ' : ' '{print $2}')

# Get the name of this script.
SCRIPTNAME=$(basename "$0")

# Make this script executable.
make_executable "${SCRIPTNAME}"

# Clear the screen
clear

# Call function header.
header

# Extract and print the EXIF metadata.
print_exifdata "${FN}"

# Print a farewell message.
echo -e "\nHave a nice day. Bye!"

# Exit the script.
exit 0
