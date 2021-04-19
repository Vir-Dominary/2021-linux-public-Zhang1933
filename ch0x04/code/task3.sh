#!/usr/bin/env bash

HELP(){
    cat << EOF
Usage:
    bash ${0} [Options]

    Avaliable options:
    -h          Show this help text.
    -o          输出访问来源主机TOP 100和分别对应出现的总次数          
    -p          输出访问来源主机TOP 100 IP和分别对应出现的总次数
    -m          统计最频繁被访问的URL TOP 100         
    -c          统计不同响应状态码的出现次数和对应百分比
    -f          分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
    -u          给定URL输出TOP 100访问来源主机
EOF
    return
}

File="web_log.tsv"
GetTop100Host(){
    printf "=====TOP 100 Host And Its Total Apperance=====\n"
    = cnt=100
    awk -F '\t' '
    NR>1 {
        host[$1]++;
    }
    END{
        for(key in host){
            printf "%s:%d\n", key,host[key]
        }        
    }
    ' $File | sort -n -r -k 2 -t : | head -n 100| 
    awk -F ':' '{printf "%s%-30s\t%s%03d\n","Host:",$1,"Apperance:",$2}'
    return  
}
# GetTop100Host

GetTop100Ip(){
    printf "=====TOP 100 IP And Its Total Apperance=====\n"
    awk -F '\t' '
    BEGIN{
        = reg="[0-9]\{1,3\}[.][0-9]\{1,3\}[.][0-9]\{1,3\}[.][0-9]\{1,3\}";
    } 
    NR>1{
        if($1~/([0-9]{1,3}\.){3}[0-9]{1,3}/){
            ip[$1]++; 
        }   
    }
    END{
        for(key in ip){
            printf "%s:%d\n", key,ip[key]
        }
    }
    ' $File | sort -n -r -k 2 -t : | head -n 100 |  
        awk -F ':' '{printf "%s%-30s\t%s%03d\n","IP:",$1,"Apperance:",$2}'
    return
}
# GetTop100Ip

GetTop100Url(){
    printf "=====TOP 100 Url And Its Total Apperance=====\n"
    awk -F '\t' '
    NR>1{
       Url[$5]++
    }
    END{
        for(i in Url){
            printf "%s:%d\n",i,Url[i]
        }
    } 
    ' $File | sort -n -r -k 2 -t : | head -n 100 |  
    awk -F ':' '{printf "%s%-55s\t%s%03d\n","Url:",$1,"Apperance:",$2}'
    return
}
# GetTop100Url

GetStatus(){
    printf "=====Status Code,The number of occurrences,Ratio=====\n"
    awk -F '\t' '
    BEGIN{
        tot=0;
    }
    NR>1{
        sta[$6]++;tot++;
    }
    END{
        for(key in sta){
            printf "Status:%d\tTimes:%8d\tRatio:%.3lf\n",key,sta[key],sta[key]/tot    
        }
    }
    ' $File
}
# GetStatus

Get4xUrl(){
    printf "=Top 10 URLs Corresponding To Status Codes And The Total Number Of Occurrences=\n"
    printf "===Status:%d===\n" 403
    awk -F '\t' '
    NR>1{
        if($6~/403/){
            url[$5]++;
        }
    }
    END{
        for(i in url){
            printf "%s:%d\n",i,url[i]
        }     
    }
    ' $File | sort -n -r -k 2 -t : | head -n 10 | 
     awk -F ':' '
       {printf "%s%-55s\t%s%d\n","Url:",$1,"Apperance:",$2}
    '  
    printf "===Status:%d===\n" 404
    awk -F '\t' '
    NR>1{
    if($6~/404/){
            url[$5]++;
        }
    }
    END{
        for(i in url){
            printf "%s:%d\n",i,url[i]
        }     
    }
    ' $File | sort -n -r -k 2 -t : | head -n 10 | 
     awk -F ':' '
       {printf "%s%-55s\t%s%d\n","Url:",$1,"Apperance:",$2}
    '  
    return
}
# Get4xUrl

showUrl(){
    printf "===============Show Url for %s\t===\n" "$1"
    awk -F '\t' -v url="$1" '
    NR>1{
        if($5==url){
            host[$1]++
        }
    }
    END{
        for(i in host){
            printf "%s:%d\n",i,host[i]
        }     
    }
    ' $File | sort -n -r -k 2 -t : | head -n 100 | 
     awk -F ':' '
       {printf "%s%-55s\t%s%d\n","Host:",$1,"Apperance:",$2}
    '  
    return 
}
# showUrl "/pub/winvn/readme.txt"

while getopts ":hopmcfu:" opt;do
    case $opt in
        h)HELP;exit ;;
        o)GetTop100Host;;        
        p)GetTop100Ip;;
        m)GetTop100Url;;
        c)GetStatus;;
        f)Get4xUrl;;
        u)showUrl "${OPTARG}";;
        *)printf "Error\n";HELP;;
    esac
done
