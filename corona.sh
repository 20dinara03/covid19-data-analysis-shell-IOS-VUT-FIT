POSIXLY_CORRECT=yes
HELP_FOR_USER()
{
echo "HELP
NAME
corona - COVID-19 coronovirus infectious disease record analyzer

USE
corona [-h][FILTERS][COMMAND][LOG[LOG2[[...]]]

COMMAND
infected -counts the number of infected.
merge- merges several files with records into one, maintaining the original order.
gender- lists the number of infected for each sex.
age- lists statistics on the number of infected persons by age.
daily- lists statistics of infected persons for individual days.
monthly- lists statistics of infected persons for individual months.
yearly- lists statistics on infected persons for each year.
countries- lists statistics of infected persons for individual countries of the disease (excluding the Czech Republic, ie the code CZ).
districts- lists statistics on infected persons for individual districts.
regions- lists statistics of infected persons for individual regions.

FILTERS
-a DATETIME- after: only PO records of this date are considered (including this date). DATETIMEis a format YYYY-MM-DD.
-b DATETIME- before: only records BEFORE this date (including this date) are considered.
-g GENDER- only records of infected persons of a given sex are considered. GENDERcan be M(men) or Z(women).
-s [WIDTH]for the  gender, age, daily, monthly, yearly, countries, districts and regions commands it displays data not numerically, but graphically in the form of histograms ."
}

DAYS_IN_MONTHS_1=( 31 28 31 30 31 30 31 31 30 31 30 31 )
DAYS_IN_MONTHS_2=( 31 29 31 30 31 30 31 31 30 31 30 31 )
START_YEAR=1970
END_YEAR=9999
DATETIME_A_F="0000-00-00"
DATETIME_B_F="0000-00-00"
GENDER_F=" "
WIDTH_F="ZERO"
COMMAND_F="ZERO"
FILE=" "
one=100
two=500
three=1000
four=10000
five=100000

YEAR_IS_LEAP()
{
    awk -v rok="$1" '
    BEGIN{
        DAYS_IN_MONTHS_1=( 31 28 31 30 31 30 31 31 30 31 30 31 )
        DAYS_IN_MONTHS_2=( 31 28 31 30 31 30 31 31 30 31 30 31 )
    }
    {if($rok%4 == rok_4){
        print $DAYS_IN_MONTHS_2[*]
    }else{
        print $DAYS_IN_MONTHS_1[*]
    } 
    }'
     
}


DATE_IS_TRUE()
{
   DATA=$1
   if [[ "$DATA" =~ 20[0-9]{2}-[01][0-9]-[0-3][0-9] ]]; then
       return $(echo $DATA | awk -F- -v MONTHS_DAYS=YEAR_IS_LEAP $1'
       {print ($1>9999||$1<1970||$2>12||$3>MONTHS_DAYS[int($2)-1]||$2<0||$3<0?0:1)}')
    else 
     echo "Invalid date! Write something like YYYY-MM-DD."
    fi

}

DATETIME_A()
{
    echo  "$FILE" | awk -F,  -v DATE="$DATETIME_A_F" '{ if(DATE<=$2||length($2)==0){print $0} }'
}

if [ "$#" = 0 ]; then
    echo "The number of arguments is 0"
    exit 1
fi 
while [ "$#" -gt 0 ]; do 
    case "$1" in
     infected | merge | gender | age | daily | monthly | yearly | countries | districts | regions)
         COMMAND="$1"
         shift
         ;;
     -a)
         DATETIME_A_F="$2"
         DATE_IS_TRUE $DATETIME_A_F
         if [[ $? == "0" ]]; then
             echo "Invalid argument! Write something like YYYY-MM-DD."
         fi
         FILE=$(DATETIME_A)
         shift
         shift
         ;;
     -b)
         DATETIME_B_F = "$2"
         shift
         shift
         ;;
     -g)
         if [ "$2" != "Z" && "$2" != "M" ]; then
             echo "Invalid gender designation"
             exit 1
             shift
         else
             GENDER_F = "$2"
           fi
         shift
         shift
         ;;
     -s)
         if [ "$2" !=~ ^[0-9]+$ ]; then
             WIDTH_F = "NUMBER"
             shift
         else
             WIDTH_F = "$2"
           fi
         shift
         shift
         ;;
     -h)
         HELP_FOR_USER
         exit 0
         ;;
     *.csv)
         if [ -r "$1" ]; then
             if [ -z "$FILE" ]; then
                 FILE+=$(cat $1)
             else 
                 FILE=$(echo "$FILE" && cat "$1")
               fi
         else 
             echo "Unreadable file"
             exit 1
            fi
            shift
            ;;
     *.gz)
         if [ -r "$1" ]; then
             if [ -z "$FILE" ]; then
                 FILE = $(gzip -d -c "$1")
             else
                 FILE = $(echo "$FILE" && gzip -d -c "$1")
               fi
         else 
             echo "Unreadable file"
             exit 1
           fi
          shift
           ;;
     *.bz2)
          if [ -r "$1" ]; then
             if [ -z "$FILE" ]; then
                 FILE = $(bunzip2 -c "$1")
              else
                 FILE = $(echo "$FILE" && bunzip2 -c "$1")
               fi
          else 
             echo "Unreadable file"
             exit 1
           fi
          shift
        ;;
    esac 
done




    

FILTER_GENDER ()
{
  if [ "$GENDER_F" == "M" ]; then
     echo "FILE" | awk -F "," '/,M,/ {print}'
  elif [ "$GENDER_F" == "Z" ]; then
     echo "FILE" | awk -F "," '/,Z,/ {print}'
    fi
}

FILTER_S ()
{
    awk -F: -v classic="$1"
    'BEGIN {first=0; histogramm=""; l=0, p=0}
    {
        ($2 > first){first=$2}
        END{
            if ($WIDTH_F>0)
            {
                p=$2/firsrt
                l=int(p*$WIDTH_F)
            }
            else
            {
                p=$2/classic
                l=int(p)
            }
            for (j=0; j<l; j++)
            {
                histogramm=histogramm"#"
            }
            print $1":", histogramm
            histogramm=""
        }
    }'
        
}



#COMMANDS

infected()
{
 echo -e "$FILE" | wc -l
 exit 0
}

gender()
{
    if [ $WIDTH_F == "ZERO" ];then
     echo "$FILE" | awk -F ',' '{a[$4]++}\
        END{for (i in a){if(i =="")print("None: "a[i]);else{print i": "a[i]}}}' | sort 
    elif [ $WIDTH_F == "NUMBER" ]; then
     echo "$FILE" | FILTER_GENDER | awk -F ',' 'BEGIN {
         M=0; Z=0
       }{
         if ($4 == "M"){M++}
         if ($4 == "Z"){Z++}
        }
     END {printf("M: ")}\
     END {for (j=0; j < M/100000; j++)\
     printf("#")}\
     END {printf("\n")}\
     END {printf("Z: ")}\
     END {for (j=0; j < Z/100000; j++)\
     printf("#")}\
     END {printf("\n")}'
    else 
     echo "$FILE" | FILTER_GENDER | awk -F ',' -v width="$WIDTH_F"'BEGIN {
         M=0; Z=0
        }{
         if ($4 == "M"){M++}
         if ($4 == "Z"){Z++}
        }
     END{
         if (M > Z)
            {
             printf("M: ")
             for(j=0; j<width; j++){
                 printf("#")
              }
              printf("\n")
             printf("Z: ")
             for(j=0; int j<(width*Z)/M; j++){
                 printf("#")
                }
               printf("\n")
            }
         else 
           {
             printf("Z: ")
             for(j=0; j<width; j++){
                 printf("#")
                }
              printf("\n")
             printf("M: ")
             for(j=0; int j<(width*M)/Z; j++){
                 printf("#") 
                }
               printf("\n")
            }
        }
    }'
    fi
}

age(){
    echo "age"
    without_s_age(){
    echo "$FILE" | awk -F,  'BEGIN{
        age_0_5=0
        age_6_15=0
        age_16_25=0
        age_26_35=0
        age_36_45=0
        age_46_55=0
        age_56_65=0
        age_66_75=0
        age_76_85=0
        age_86_95=0
        age_96_105=0
        age_106=0
        age_nothing=0
        }{
            if(length($3)==0){
              age_nothing++
            }
            else if ($3<6){
             age_0_5++
            }
            else if($3>5&&$3<16){
             age_6_15++
            }
            else if($3>15&&$3<26){
             age_16_25++
            }
            else if($3 > 25 && $3 < 36){
              age_26_35++
            }
            else if($3 > 35 && $3 < 46){
             age_36_45++
            }
            else if($3 > 45 && $3 < 56){
             age_46_55++
            }
            else if($3 > 55 && $3 < 66){
             age_56_65++
            }
            else if($3 > 65 && $3 < 76){
             age_66_75++
            }
            else if($3 > 75 && $3 < 86){
             age_76_85++
            }
            else if($3 > 85 && $3 < 96){
             age_86_95++
            }
            else if($3 > 95 && $3 < 106){
             age_96_105++
            }
            else if ($3 > 105){
             age_106++
            }
        }  
        END{
         print(NR);\
         printf("0-5   : %d\n",age_0_5 )
         printf("6-15  : %d\n",age_6_15 )
         printf("16-25 : %d\n",age_16_25 )
         printf("26-35 : %d\n",age_26_35 )
         printf("36-45 : %d\n",age_36_45 )
         printf("46-55 : %d\n",age_46_55 )
         printf("56-65 : %d\n",age_56_65 )
         printf("66-75 : %d\n",age_66_75 )
         printf("76-85 : %d\n",age_76_85 )
         printf("86-95 : %d\n",age_86_95 )
         printf("96-105: %d\n",age_96_105 )
         printf(">105  : %d\n",age_106 )
        }
        END{if (age_nothing>1){
         printf("None  : %d\n",age_nothing )
        }
      }
      '
    }
    if [[ "$WIDTH_F" != "ZERO" ]]; then
      echo "$FILE" | without_s_age | FILTER_S $four
    else
       echo "yes"
       echo -e "$FILE" | without_s_age
    fi
}

daily()
{
    if [ "$WIDTH_F" != "ZERO" ]; then
     echo "$FILE" | FILTER_S $two | awk -F, '{print $2}' | sort -M | uniq -c 
 else
     echo "$FILE" | awk -F, '{print $2}' | sort -M | uniq -c 
 fi
}    

monthly()
{
 if [ "$WIDTH_F" != "ZERO" ]; then
     echo "$FILE" | FILTER_S $four | awk -F ',' '{a[substr($2,1,7)]++}END{for (i in a)print i": "a[i];}' | sort 
 else
     echo "$FILE" | awk -F ',' '{a[substr($2,1,7)]++}END{for (i in a)print i": "a[i];}' | sort 
 fi
}
    
yearly()
{
    if [ "$WIDTH_F" != "ZERO" ]; then
     echo "$FILE" | FILTER_S $five | awk -F, '{print substr($2,0,4)}' | sort -M | uniq -c 
 else
     echo "$FILE" | awk -F, '{print substr($2,0,4)}' | sort -M | uniq -c 
  fi
}

countries()
{
    if [ "$WIDTH_F" != "ZERO" ]; then
     echo "$FILE" | FILTER_S $one | awk -F, '{print $8}' | sort -d | uniq -c 
 else
     echo "$FILE" | awk -F, '{print $8}' | sort -d | uniq -c 
  fi
}

districts()
{
    if [ "$WIDTH_F" != "ZERO" ]; then
     echo "$FILE" | FILTER_S $three | awk -F, '{print $6}' | sort -n | uniq -c 
 else
     echo "$FILE" | awk -F, '{print $6}' | sort -n | uniq -c 
  fi
}

regions()
{
if [ "$WIDTH_F" != "ZERO" ]; then
     echo "$FILE" | FILTER_S $four |  awk -F, '{print $5}' | sort -n | uniq -c 
 else
     echo "$FILE" |  awk -F, '{print $5}' | sort -n | uniq -c 
  fi
}


if [[ $COMMAND == "infected" ]];then
 infected 
elif [[ $COMMAND == "gender" ]];then
 gender
elif [[ $COMMAND == "age" ]];then
 age
elif [[ $COMMAND == "daily" ]];then
 daily
elif [[ $COMMAND == "monthly" ]];then
 monthly
elif [[ $COMMAND == "yearly" ]];then
 yearly
elif [[ $COMMAND == "countries" ]];then
 countries
elif [[ $COMMAND == "districts" ]];then
 districts
elif [[ $COMMAND == "regions" ]];then
 regions
fi

exit 0

  
