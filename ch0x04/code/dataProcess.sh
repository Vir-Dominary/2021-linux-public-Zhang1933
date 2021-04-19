#!/usr/bin/env bash

Help(){
    cat << EOF
Usage:
    bash ${0} [Options]

Avaliable options:
    -h          Show this help text.
    -r          Show age range under 20,between 20 and 30,greater 
                than 30 persipect respectively.
    -p          Show different position's amout and ratio.
    -n          Show the player with the longest name and shortest 
                name.
    -a          Show the player with the oldest age and youngest age.
EOF
}


# 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
File="worldcupplayerinfo.tsv"
Age_range(){
    awk -F '\t' 'BEGIN{ le20=0;le30=0;gt30=0;}
    NR>1 {
        if($6<20)
            le20++
        else if($6<=30)
            le30++
        else gt30++
    } 
    END{
        tot=le20+le30+gt30;
        printf "**************Age***************\n";
        printf "%-40s:%5d\t%.3f\n","Age under 20 amount and ratio",le20,le20/tot;
        printf "%-40s:%5d\t%.3f \n","Age between 20 and 30 amount  and ratio",le30,le30/tot;
        printf "%-40s:%5d\t%.3f \n","Age greater than 30 amount and ratio",gt30,gt30/tot;
    }' "$File"  
    return
}

# Age_range

# 统计不同场上位置的球员数量、百分比
Position(){
    awk -F '\t' '
    BEGIN {
        tot=0
    }
    NR>1{
        pos[$5]++;tot++
    }
    END{
        printf("*****Position amount and Ratio*****\n");
        for(key in pos){
            printf "amount of %-15s%5d\t\tRatio: %.3f\n",key,pos[key],pos[key]/tot;
        }
    }
    ' $File
    return
}

# Position

# 名字最长的球员是谁？名字最短的球员是谁？
GetMostName(){
    awk -F '\t' '
    BEGIN{
        lName="";
        SName="**********************************";
    }
    NR>1{
        if(length($9)<length(SName)){
            SName=$9;    
        }
        if(length($9)>length(lName)){
            lName=$9;
        }    
    }
    END{
        printf "*************Name Statistics*********************\n"
        printf "Longest Name:\t%s\nShortest Name:\t%s\n",lName,SName
    }
    ' $File    
    return
}

# GetMostName 

# 年龄最大的球员是谁？年龄最小的球员是谁？
GetMostAge(){
    awk -F '\t' '
    BEGIN{
        oldest=0;youngest=100; 
    }
    NR>1{
        if($6>oldest){
            op=$9;
            oldest=$6;
        }
        if($6<youngest){
            yp=$9;
            youngest=$6;
        }
    }
    END{
        printf "*****************Age Most********************\n"
        printf "%-10s\t%s\n%-10s\t%s\n","Oldest:",op,"Youngest:",yp     
    }   

    ' $File
   return
}

while getopts ":hrpna" opt
do
    case $opt in
        h)Help;exit;;
        r)Age_range;;
        p)Position;;
        n)GetMostName;;
        a)GetMostAge;;
        *)echo "Parameter Error";Help;exit 1;;
    esac
done
