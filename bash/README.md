# Introduction

<p align="justify">This subdirectory only contains <code>Bash</code> scripts that I use to prepare AI generated images for minting as NFTs.</p> 

# Bash Scripts

## <code>sd_aspect_ratio.bash</code>

### Explanation

<p align="justify">The script calculates a valid resolution in pixel based on a given aspect ratio. The lowest possible value for width and height of an image is 512 pixel. If one of these two sizes is smaller than 512 pixel the AI generator may have problems to create an image of desired quality. Since the Easy Diffusion values are divisible by 8, they result in meaningful values based on the binary number system. This way I using the preset values from Easy Diffusion to try to calculate a valid resolution in pixel.</p> 

<p align="justify">Easy diffusion has preset values for width and height, while AUTOMATIC1111 knows such a limitation not.</p> 

## <code>analyse_exif_metadata.bash</code>

### Explanation

<p align="justify">The task of the script <code>analyse_exif_metadata.bash</code> is to analyse the EXIF metadata in an given image. On the one hand, the script should ensure that the correct EXIF metadata is contained in the image before publication as NFT. On the second hand, the extracted, determined and calculated data is required in the publishing process as NFT.</p> 

<p align="justify">To mine an NFT, you need e.g. a local installation or you can use an Internet service like OpenSea [1] or Rarible [2]. The first involves a lot of effort. The second is quick and easy. An NFT consists of two parts, a contract on the blockchain and an image to be stored externally. If one use OpenSea or Rarible and prepare an NFT for minting in the related Web UI, then one needs next to Collection, Name and Supply the so-called Traits to describe the image.</p> 

<p align="justify">The script <code>analyse_exif_metadata.bash</code> extracts, determines and calculates data, which can be used for the previously described Traits.</p>

Some of my traits are:
- Category (e.g. Avatar, Vehicle, Mushroom)
- Orientation (e.g. Portrait, Landscape or None)
- Aspect Ratio (e.g. 2:3, 19:9, 1:1)
- Wallpaper (e.g. Yes, No or Unknown)

<p align="justify">Category will be extracted from my EXIF metadata. Orientation is derived from the data. Aspect Ratio values and Wallpaper string are calculated.</p>  

### Sample Printout

An example printout looks like this

<pre>
**********************
EXIF Metadata Analysis
**********************

Filename:                   0f8acf268f58060702f32ef0d51bcfb4.jpeg
MD5 Hash:                   0f8acf268f58060702f32ef0d51bcfb4
AI Generator (EVAL):        Stable Diffusion
AI Web UI (EVAL):           AUTOMATIC1111
Category (EVAL):            Mushroom
Copyright (EXIF):           2024, zentrocdot
Creator: (EXIF)             zentrocdot
Creator Tool (EXIF):        AI Generator Stable Diffusion, AI WebUI AUTOMATIC1111
Comment (EXIF):             Fantastic Mushroom Collection
User Comment (EXIF):        Selected image for minting as NFT
File Type (EXIF):           JPEG
File Type Extension (EXIF): jpg
Mime Type (EXIF):           image/jpeg
File Size (MiB):            3.5 MiB
File Size (MB):             3.7 MB
Image Width (EXIF):         8192
Image Height (EXIF):        4608
Image Size (EXIF):          8192 x 4608 pixel
Image Size (EVAL):          8192 x 4608 pixel
Aspect Ratio (CALC):        16:9
Orientation (EVAL):         Landscape
Resolution: (EVAL)          High
Wallpaper: (CALC)           Yes

Have a nice day. Bye!</pre>

<p align="justify">The previous printout shows an open problem I have. File type, file type extension and mime type are inconsistent using <code>exiftool</code>. This has to be checked.</p>

<p align="justify">Technically speaking, JPG and JPEG are exactly the same thing.</p>

### Side Note

<p align="justify">Stable Diffusion uses the file type extension .jpeg for writing images. After upload to the IPFS, the image has the file type extension .jpg.</p>

### TO-DO

<p align="justify">Extracting of the file type extension from the file name and comparing this extension with the EXIF meta data. Checking if the MD5 hash is the (file) name without file type extension. On mismatch write an error to the terminal. Extract Encoding Process and Megapixels for documentation purposes. Extracting ExifTool Version Number and Exif Version.</p>

### Special Features

<p align="justify">I used the first time an ordered associative array in a <code>Bash</code> script. By default an associative array is unordered. by using a trick one can use an unordered associative array as ordered associative array.</p>

<p align="justify">The aspect ratio of a given image is calculatied using the greatest common divisor of width and height of the image.</p>

<p align="justify">If the aspect ratio <it>x:y</it> is in a range of 1.2 upt to 1.8, where  <it>x</it> is the large value and  <it>y</it> is the small value, it is calculated if the image can be used as wallpaper.</p>

### Final Remark

<p align="justify">The script is in a way written, that it can easily be adapted to the needs of another user.</p>

## <code>aspect_ratio.bash</code>

<p align="justify">The script <code>aspect_ratio.bash</code> calculates the aspect ratio of a given image using the greatest common divisor.</p>

# References

[1] [OpenSea](https://opensea.io/)

[2] [Rarible](https://rarible.com/)

# Abbreviations

Abbreviation | Description
:----|:------------------------------|
AI   | Artificial intelligence
Bash | Bourne-Again SHell
CALC | Calculation
EVAL | Evaluation
EXIF | Exchangeable Image File Format 
GCD  | Greatest Common Divisor
GB   | Gigabyte
GiB  | Gibibyte
IPFS | InterPlanetary File System
JPG  | Joint Photographic (Experts) Group
JPEG | Joint Photographic Experts Group
KB   | Kilobyte
KiB  | Kibibyte
MB   | Megabyte
MiB  | Mebibyte
NFT  | Non-Fungible Token
PNG  | Portable Network Graphics

# Glossary

Denotation | Description
:----------|:--------------------------------------------------------------------------------------------------------------|
Trait      | A Trait describes an attribute of an item and consists of Type and Name. E.g. Type is Size and Name is Large or Small 
KB  [^1]   | 1 KB = 1000 Byte 
KiB        | 1 KiB = 1024 Byte, 1 KiB = 1.024 KB
MB  [^1]   | 1 MB = 1000 KB
MiB        | 1 MiB = 1024 KiB, 1 MiB = 1.024 MB

<hr width="100%" size="2">

<p align="center">I loved the time when you could get also a hamburger :hamburger: for one euro!</p>

<p align="center">
<a target="_blank" href="https://www.buymeacoffee.com/zentrocdot"><img src="..\IMAGES\greeen-button.png" alt="Buy Me A Coffee" height="41" width="174"></a>
</p>
<hr width="100%" size="2">

<p align="justify">If you like what I present here, or if it helps you, or if it is useful, you are welcome to donate a small contribution or a cup of coffee. Or as you might say: Every TRON counts! Many thanks in advance! :smiley:</p>

<pre>TQamF8Q3z63sVFWiXgn2pzpWyhkQJhRtW7            (TRON)
DMh7EXf7XbibFFsqaAetdQQ77Zb5TVCXiX            (DOGE)
12JsKesep3yuDpmrcXCxXu7EQJkRaAvsc5            (BITCOIN)
0x31042e2F3AE241093e0387b41C6910B11d94f7ec    (Ethereum)</pre>

[^1]: Side Note: The designations KiB, KB, MiB and MB must be checked against implementation and usage in the operating system and against the relevant international standards. For my current OS the conversion is consistent. 

