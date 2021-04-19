#!/usr/bin/env bash
# TODO: May need a new dir to hold the results,conveniently for retrieve

Help(){
   cat << EOF
DESCRIPTION:
   ${0} - A image batch process script for a director.
 or
Usage:
    Put your director path firstly and bash ${0} DirectorName [OPTIONS]... 

Avaliable options:
    -h,--hlep                  Show this help text.
    -q,--quality               JPEG quality compression,value range from1 to 100
                               (Defualt 80 if not be provided).Output files will 
                               be named with "JpgC_" preffix.
    -r,--resize                Resize jpeg/png/svg images with original ratio(Defualt 
                               80 not be provided).Outpu will be named with 
                               "R_" preffix.
    -w string                  Add text watermark to the images.Output files will be
                               named with "WM_" prefix.
    -p,--prefix                Add prefix to files.
    -s,--suffix                Add suffix to files (Wouldn't impact files type name).
    -c,--convert               Convert png/svg images to jpeg.Possibly,to avoid files 
                               with the same name.If image is png,output will be named
                               with "_p" suffix. If image is svg,output will be named 
                               with "_s" suffix.

Attention:
    By default,if the image format isn't be supported,the script will skips the
    image file.And the result wiil be strored in the ImgOutPut dir.
EOF
}

quality=0
resize=0
watermark_string=""
prefix=""
suffix=""
if_convert=0
dir=""
out="ImgOutPut"
# Jpg compress
# input compress jpg path, output with JpgC_ prefix
# convert filename1 -compress JPEG -quality 50 filename2 
JpgCompress(){
    path=($1) 
    for i in ${path[*]};do
        if [[  ${i##*.} != "jpg" ]];then
            continue
        fi
        (convert "$dir""/""$i" -compress JPEG -quality "$2" "$out""/""JpgC_$i")
    done
    echo "Jpg quality  compress finish." 
}


# JpgCompress img   80 # Test


# compress image resolution while maintaining image size
# convert Lena.jpg -Resize 50 Clena.jpg
ResolutionCompress(){
    path=($1)
    for i in ${path[*]};do
        if [[  ${i##*.} == "jpg" ||  ${i##*.} == "svg" || ${i##*.} == "png" ]];then
            convert "$dir""/""$i" -resize "$2%" "$out""/""R_$i"
        fi
    done
    echo "resolution compress finish"
    return
}


# ResolutionCompress img 50 # Test


# water marking only not support svg
#  convert Lena.jpg -pointsize 50 -fill black -gravity center
# -draw "text 10,10 'Works like magick' " WLena.jpg 
AddWaterMark(){
    path=($1)
    for i in ${path[*]};do
        if [[  ${i##*.} == "jpg" || ${i##*.} == "png" ]];then
            convert "$dir/$i" -pointsize 50 -fill black -gravity center -draw "text 10,10 '$2' " "$out/WM_$i"              
        fi
    done
    echo "Add watermark  finish"
    return
}

# AddWaterMark img hello  # Test


# pic prefix add  
#cp Lena.jpg ~/workplace/ch0x04/123Lena.jpg
PrefixAdd(){
    path=($1)
   for i in ${path[*]};do 
       if [[  ${i##*.} == "jpg" || ${i##*.} == "png" || ${i##*.} == "svg" ]];then
          cp "$dir""/""$i" "$out""/""$2$i"  
       fi
   done
   echo "PrefixAdd finish"
   return 
}


# Test
# PrefixAdd img 123

#cp Lena.jpg ~/workplace/ch0x04/Lena123.jpg
SuffixAdd(){ 
    path=($1)
   for i in ${path[*]};do 
       if [[ ${#i} -ge 4 && ( ${i##*.} == "jpg" || ${i##*.} == "png" || ${i##*.} == "svg" ) ]];then
           cp "$dir""/""$i" "$out""/""${i::-4}$2${i:(-4)}"  
       fi
   done
   echo "SuffixAdd finish"
   return 
}

# TEST
# SuffixAdd img 123

# convert gray.png gray.jpg 
ConverToJpeg(){
    path=($1)
    for i in ${path[*]};do 
        # echo "$i"
        if [[ ${#i} -ge 4 && ( ${i##*.} == "png" || ${i##*.} == "svg" ) ]];then
            convert "$dir/$i" "$out/${i::-4}_${i:(-3):1}.jpg"  
        fi
    done
    echo "Conver To Jpeg Finish"
    return    
}

# TEST
# ConverToJpeg img

while true;do
    case "$1" in
        -q|--quality) # have defualt parameter
            if [[ "${2}" == "" || "${2}" =~ ^- || $2 -lt 1 || $2 -gt 100  ]]; then
                quality=80;shift 1
            else 
                quality=$2; shift 2
            fi ;;               
        -r|--resize)
            if [[ "${2}" == "" || "${2}" =~ ^- || $2 -lt 1 || $2 -gt 100  ]]; then
                echo "$2"
                resize=80;shift 1
            else
                resize=$2; shift 2
            fi ;;
        -w)# must have parameter
            watermark_string=${2? must provid string to be added!}
            shift 2 ;;
        -p|--prefix)
            prefix=${2? must provid a string to be added!}
            shift 2 ;;
        -s|--suffix)
            suffix=${2? must provid a string to be added!}
            shift 2 ;;
        -c|--convert) # don't have to have a parameter
            if_convert=1; shift ;;    
        -h|--help)
            Help ;exit 0 ;;
         "") break;;
         *)
            if [[ $dir != ""  ]];then
                echo " More than one path or  parameter wrong!"   
                exit 1
            fi;
            dir=${1}
            shift;; 
    esac
done

log="log.txt"
echo "program start" >$log
if [[ $dir == "" ]];then
    echo "Erro must provide a path!" 
    exit 1
fi
dir_path=($(ls "$dir" 2>>$log | tee "$log"))
# echo "${#dir_path[@]}"
if [[  $quality -gt 0  ]];then
    JpgCompress "${dir_path[*]}" "$quality" 2>>$log 
fi
if [[ $resize -gt 0 ]];then
    ResolutionCompress "${dir_path[*]}" "$resize" 2>>$log
fi
if [[ $watermark_string != ""  ]];then
    AddWaterMark "${dir_path[*]}" "$watermark_string" 2>>$log
fi
if [[ $prefix != ""  ]];then
    PrefixAdd "${dir_path[*]}" "$prefix" 2>>$log
fi
if [[ $suffix != ""  ]];then
    SuffixAdd "${dir_path[*]}" "$suffix" 2>>$log
fi
if [[ if_convert -gt 0  ]];then
    ConverToJpeg "${dir_path[*]}"  2>>$log
fi

