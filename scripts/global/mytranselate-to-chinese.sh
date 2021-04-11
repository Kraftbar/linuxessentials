#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------
# fak it, translate-shell OP
# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------

unicode=($(      echo $1 | od -An -t uC |  head -n 1 | awk '{ print $2 }'       ))

if ((unicode >= 65 && unicode <= 122)); then
    # get trans | delete "(" | delete ")" | replace newline with tab | delete last newline also
    trans  -show-original n  -show-prompt-message n -show-languages n -show-original-dictionary N -show-dictionary n -show-alternatives n  en:zh $1 | cut -d "(" -f2 | cut -d ")" -f1 | sed -z 's/\n/\t/g;s/\t$/\n/' | tr -d '\n'
    printf "\t"
    echo $1 
else
    # get trans | delete empty new line | delete "(" | delete ")" | replace newline with tab | delete last newline also
    trans           -show-prompt-message n -show-languages n -show-original-dictionary N -show-dictionary n -show-alternatives n  zh:en $1 | sed '/^[[:space:]]*$/d' | cut -d "(" -f2 | cut -d ")" -f1 | sed -z 's/\n/\t/g;s/\t$/\n/' 
fi
















exit 1
# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------
# Make own solution?
# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------
#https://stackoverflow.com/questions/15172690/using-wget-to-get-the-result-of-google-translate
#https://gist.github.com/ayubmalik/149e2c7f28104f61cc1c862fe9834793
curl -A "Mozilla/5.0" 'http://translate.google.com/translate_a/t?client=t&text=hello&hl=en&sl=en&tl=zh-CN&ie=UTF-8&oe=UTF-8&multires=1&prev=btn&ssel=0&tsel=0&sc=1'
The previous command will print the following result:
[[["你好","hello","Nǐ hǎo",""]],[["interjection",["喂"],[["喂",["hello","hey"],,0.0087879393]]]],"en",,[["你好",[5],0,0,1000,0,1,0]],[["hello",4,,,""],["hello",5,[["你好",1000,0,0],["招呼",0,0,0],["打招呼",0,0,0],["个招呼",0,0,0],["喂",0,0,0]],[[0,5]],"hello"]],,,[["en"]],6]
You can then use sed to obtain the result as follows:
curl -A "Mozilla/5.0" 'http://translate.google.com/translate_a/t?client=t&text=hello&hl=en&sl=en&tl=zh-CN&ie=UTF-8&oe=UTF-8&multires=1&prev=btn&ssel=0&tsel=0&sc=1' | sed 's/\[\[\["\([^"]*\).*/\1/'







exit 1
# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------
# Old script i used to use, clean - but workig atm
# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------
set -ue
LANG1="en"
LANG2="zh"
BASE_URL="https://translate.google.com/"
USER_AGENT='Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.34 (KHTML, like Gecko) QupZilla/1.3.1 Safari/534.34'


# help
if [ $# -eq 0 ] || [ $# -eq 2 ] || [ $# -gt 3 ]; then
    echo -e "\nAvailable languages:"
    echo -e "---------------------"
    curl -s --user-agent "${USER_AGENT}" "${BASE_URL}m?&mui=sl"|grep -Eo 'sl=[a-zA-Z-]{2,}">[^>]*<'|sed -e 's/sl=//g' -e 's/">/ -> /g' -e 's/<$//g'|tr "\n" ","|awk -F, '{ for ( i=1; i<=NF;i=i+3) printf "%-24s %-24s %-24s\n", $i, $(i+1), $(i+2) }'
    echo -e "\nUsage: `basename $0` Sentence [From] [To]"
    echo -e "------------------------------------"
    echo -e "Example:\n`basename $0` how"
    echo -e "`basename $0` \"How are you\" en zh"
    exit 1
fi

# Main
if [ $# -eq 1 ]; then
    SENTENCE=`echo "$1" | tr " " "+"`

    # Default languages settings
    if [[ "$SENTENCE" =~ ^[a-zA-Z] ]]; then
        FROM=${LANG1}
        TO=${LANG2}
    else
        FROM=${LANG2}
        TO=${LANG1}
    fi
else
    SENTENCE=`echo "$1" | tr " " "+"`
    FROM="$2"
    TO="$3"
fi

# Translate
RESULT=$(curl -s --user-agent "${USER_AGENT}" "${BASE_URL}m?hl=en&sl=${FROM}&tl=${TO}&ie=UTF-8&prev=_m&q=${SENTENCE}" 2>/dev/null | sed -n 's/.*class="t0">//;s/<.*$//p')
echo -n  $RESULT 
echo -n -e '\t'
if [ ${TO} == "zh" ]; then
    RESULTpinyin=$(curl -s --user-agent "${USER_AGENT}" "${BASE_URL}m?hl=en&sl=${FROM}&tl=${TO}&ie=UTF-8&prev=_m&q=${SENTENCE}" 2>/dev/null | sed -n 's/.*class="o1">//;s/<.*$//p')
    echo -n  $RESULTpinyin
    echo -n -e '\t'
    echo  "$1"
fi

# Voice
CHECKED=1
if [ -s $CHECKED ] && [ -n "$RESULT" ] && [ "X$RESULT" != "X$SENTENCE" ]; then
    MP3FILE=$(mktemp --suffix .mp3)
    [ -f ${MP3FILE} ] && curl -s --user-agent "${USER_AGENT}" "${BASE_URL}translate_tts?ie=UTF-8&tl=${FROM}&q=${SENTENCE}" -o ${MP3FILE}
    [ -s ${MP3FILE} ] && mpg123 -q ${MP3FILE}

    if [ -n "$RESULT" ]; then
        [ -f ${MP3FILE} ] && curl -s --user-agent "${USER_AGENT}" "${BASE_URL}translate_tts?ie=UTF-8&tl=${TO}&q=${RESULT}" -o ${MP3FILE}
        [ -s ${MP3FILE} ] && mpg123 -q ${MP3FILE}
    fi

    [ -f ${MP3FILE} ] && rm -f ${MP3FILE}
fi

set +ue

# Exit
exit 0
