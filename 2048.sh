#!/bin/sh
getc ()
{
    stty raw
    tmp=`dd bs=1 count=1 2>/dev/null`
    eval $1='$tmp'
    stty cooked
}

randpiece()
{
    randc=`jot -r 1 1 4` #for  var col
    randr=`jot -r 1 1 4` #for var row
    randp=`jot -r 1 2 4` #for rand piece 2 or 4
    while [ $randp = 3 ] # if rand = 3 do again
        do
        randp=`jot -r 1 2 4`
        done
    if [ $countp = 16 ];then #max 16 pieces
        dialog --ok-label "You Lose" --msgbox "$gameover" 10 60
        winscore=0
    elif [ $((line$randc$randr)) = 0 ];then #looking for empty pieces
        eval line$randc$randr=$randp
        countp=$(($countp + 1))
    else
        randpiece #not found and do again
    fi
}

checkwin()
{
    if [ $((line$compar$row)) = $winscore -o $((line$col$compar)) = $winscore ];then 
        dialog --ok-label "You Win" --msgbox "$winner" 10 45
        winscore=0
    fi
}

moveup()
{
    for row in $(seq 1 4)
        do
        for col in $(seq 2 4)
            do
                for compar in $(seq $(($col-1)) 1)
                    do
                    if [ $((line$compar$row)) = $((line$col$row)) -a $((line$col$row)) != 0 ];then
                        eval line$compar$row=$(($((line$compar$row))*2))
                        checkwin
                        countp=$(($countp - 1))
                        eval line$col$row=""
                        break
                    elif [ $((line$compar$row)) != 0 ];then 
                        break
                    fi
                    done
                for compar in $(seq 1 $(($col-1)))
                    do
                    if [ $((line$compar$row)) = 0 ];then
                        eval line$compar$row=$((line$col$row))
                        eval line$col$row=""
                        break
                    fi
                    done
            done
        done
}

movedown()
{
    for row in $(seq 1 4)
        do
        for col in $(seq 3 1)
            do
                for compar in $(seq $(($col+1)) 4)
                    do
                    if [ $((line$compar$row)) = $((line$col$row)) -a $((line$col$row)) != 0 ];then
                        eval line$compar$row=$(($((line$compar$row))*2))
                        checkwin
                        countp=$(($countp - 1))
                        eval line$col$row=""
                        break
                    elif [ $((line$compar$row)) != 0 ];then
                        break
                    fi
                    done
                for compar in $(seq 4 $(($col+1)))
                    do
                    if [ $((line$compar$row)) = 0 ];then
                        eval line$compar$row=$((line$col$row))
                        eval line$col$row=""
                        break
                    fi
                    done
            done
        done
}

moveleft()
{
    for col in $(seq 1 4)
        do
        for row in $(seq 2 4)
            do
                for compar in $(seq $(($row-1)) 1)
                    do
                    if [ $((line$col$compar)) = $((line$col$row)) -a $((line$col$row)) != 0 ];then
                        eval line$col$compar=$(($((line$col$compar))*2))
                        checkwin
                        countp=$(($countp - 1))
                        eval line$col$row=""
                        break
                    elif [ $((line$col$compar)) != 0 ];then
                        break
                    fi
                    done
                for compar in $(seq 1 $(($row-1)))
                    do
                    if [ $((line$col$compar)) = 0 ];then
                        eval line$col$compar=$((line$col$row))
                        eval line$col$row=""
                        break
                    fi
                    done
            done
        done
}

moveright()
{
    for col in $(seq 1 4)
        do
        for row in $(seq 3 1)
            do
                for compar in $(seq $(($row+1)) 4)
                    do
                    if [ $((line$col$compar)) = $((line$col$row)) -a $((line$col$row)) != 0 ];then
                        eval line$col$compar=$(($((line$col$compar))*2))
                        checkwin
                        countp=$(($countp - 1))
                        eval line$col$row=""
                        break
                    elif [ $((line$col$compar)) != 0 ];then
                        break
                    fi
                    done
                for compar in $(seq 4 $(($row+1)))
                    do
                    if [ $((line$col$compar)) = 0 ];then
                        eval line$col$compar=$((line$col$row))
                        eval line$col$row=""
                        break
                    fi
                    done
            done
        done
}

:movepiece() <<!
{
    for col in $(seq 1 4)
        do
        for row in $(seq 3 1)
            do
                for compar in $(seq $(($row+1)) 4)
                    do
                    if [ $((line$col$compar)) = $((line$col$row)) -a $((line$col$row)) != 0 ];then
                        eval line$col$compar=$(($((line$col$compar))*2))
                        checkwin
                        countp=$(($countp - 1))
                        eval line$col$row=""
                        break
                    elif [ $((line$col$compar)) != 0 ];then
                        break
                    fi
                    done
                for compar in $(seq 4 $(($row+1)))
                    do
                    if [ $((line$col$compar)) = 0 ];then
                        eval line$col$compar=$((line$col$row))
                        eval line$col$row=""
                        break
                    fi
                    done
            done
        done
}
!

game()
{
        winscore=128
        major=0
        div="\t---------------------------------\n"
        div2="\t|\t|\t|\t|\t|\n"
        while [ $winscore != 0 ] 
            do
                bprint
                getc press
                case $press in
                    w)
                        major=1
                        moveup
                        randpiece
                        ;;
                    s)
                        movedown
                        randpiece
                        ;;
                    a)
                        moveleft
                        randpiece
                        ;;
                    d)
                        moveright
                        randpiece
                        ;;
                    q)
                        for i in $(seq 1 4)
                                do
                                    for j in $(seq 1 4)
                                        do
                                            echo "line$i$j $((line$i$j))" >> ./tempgame #quit and save vars to temp
                                        done
                                done
                        menu
                        ;;
                esac
            done 
        if [ -e ./tempgame ];then
            rm ./tempgame
        fi
}

saveload()
{
    savepath="./saves"
    if [ ! -d $savepath ];then
        mkdir $savepath
        touch $savepath/save1 $savepath/save2 $savepath/save3 $savepath/save4 $savepath/save5
    fi
    for savenum in $(seq 1 5)
        do
            eval save$savenum=$(cat $savepath/save$savenum | head -n 1) #check line 1 for save name
            if [ ! -s $savepath/save$savenum ];then
                eval save$savenum="Empty"
            fi
        done
    if [ $slstate = 1 ];then #For load operation
        dialog --title 'Menu' --menu "Load Game" 15 50 100 1 "$save1" 2 "$save2" 3 "$save3" 4 "$save4" 5 "$save5" 2> /tmp/tmpoption
        if [ $? -eq 0 ];then #ok button pressed 
            chooption=$(cat /tmp/tmpoption)
            if [ $(eval echo "\$save$chooption") == "Empty" ];then
                dialog --msgbox "It's Empty!" 5 15
                menu
            elif [ $chooption ];then
                countline=1 # Skip line 1 (save name)
                countp=0
                for i in $(seq 1 4)
                    do
                    for j in $(seq 1 4)
                        do
                            countline=$(($countline + 1)) #To read increasing line
                            eval line$i$j=$(cat $savepath/save$chooption | sed -n "${countline}p" | awk '{print $2}')
                            if [ $((line$i$j)) != 0 ];then
                                countp=$(($countp + 1))
                            fi
                        done
                    done
                game
                break
            fi
        else
            menu
        fi

    elif [ $slstate = 2 ];then #For save operation
        dialog --title 'Menu' --menu "Save Game" 15 50 100 1 "$save1" 2 "$save2" 3 "$save3" 4 "$save4" 5 "$save5" 2> /tmp/tmpoption
        if [ $? -eq 0 ];then #ok button pressed 
            chooption=$(cat /tmp/tmpoption)
            if [ $chooption ];then
                dialog --no-cancel --inputbox "Enter your save name" 8 30 2> /tmp/tmpsavename
                #while [ ! -s /tmp/tmpsavename -a $? -eq 0 ]
                #    do
                #        dialog --no-cancel --inputbox "You enter nothing, please try again" 8 40 2> /tmp/tmpsavename
                #    done
                cat ./tempgame >> /tmp/tmpsavename
                cp /tmp/tmpsavename $savepath/save$chooption && rm /tmp/tmpsavename
            fi
        fi
        menu
    fi

    if [ -e /tmp/tmpoption ];then
        rm /tmp/tmpoption
    fi
}

bprint()
{
    echo -e "\n\n$div$div2\t|$line11\t|$line12\t|$line13\t|$line14\t|\n$div2$div" \
    "$div2\t|$line21\t|$line22\t|$line23\t|$line24\t|\n$div2$div" \
    "$div2\t|$line31\t|$line32\t|$line33\t|$line34\t|\n$div2$div" \
    "$div2\t|$line41\t|$line42\t|$line43\t|$line44\t|\n$div2$div" \
    "\n\tUSE w,s,a,d to MOVE ; q to EXIT \n\t\t Get $winscore to WIN!" | sed 's/0//g' | dialog --progressbox 25 50
}

tprint()
{
    welcome=$(echo "   ____    _    __  __ _____\n " \
                   "/ ___|  / \  |  \/  | ____|\n" \
                   "| |  _  / _ \ | |\/| |  _|\n" \
                   "| |_| |/ ___ \| |  | | |___\n" \
                   " \____/_/   \_\_|  |_|_____|\n" \
                   "  ____   ___  _  _    ___\n" \
                   " |___ \ / _ \| || |  ( _ )\n" \
                   "   __) | | | | || |_ / _ \ \n" \
                   "  / __/| |_| |__   _| (_) |\n" \
                   " |_____|\___/   |_|  \___/")

    gameover=$(echo "   ____                         ___\n" \
                    " / ___| __ _ _ __ ___   ___   / _ \__   _____ _ __\n" \
                    "| |  _ / _\` | '_ \` _ \ / _ \ | | | \ \ / / _ \ '__|\n" \
                    "| |_| | (_| | | | | | |  __/ | |_| |\ V /  __/ |\n" \
                    " \____|\__,_|_| |_| |_|\___|  \___/  \_/ \___|_|")

    winner=$(echo " __     ___      _                     _\n" \
                  "\ \   / (_) ___| |_ ___  _ __ _   _  | |\n" \
                  " \ \ / /| |/ __| __/ _ \| '__| | | | | |\n" \
                  "  \ V / | | (__| || (_) | |  | |_| | |_|\n" \
                  "   \_/  |_|\___|\__\___/|_|   \__, | (_)\n" \
                  "                              |___/")
}

menu()
{
dialog --title 'Menu' --menu "Command Line 2048" 15 50 100 N "New Game" R "Resume" L "Load" S "Save" Q "Quit" 2> /tmp/tmpchoice
slstate=0 # For Check SL Operation
return=$(cat /tmp/tmpchoice)
case $return in
    N)
        echo "" > tempgame
        countp=2 # For Calculating pieces
        line11="" line12="" line13="" line14=2
        line21="" line22=2 line23="" line24=""
        line31="" line32="" line33="" line34=""
        line41="" line42="" line43="" line44=""
        game
        break
        ;;
    R)
        if [ ! -e ./tempgame ];then
           dialog --msgbox "No Game To Resume!" 6 23
           menu
        fi
        ;;
    L)
        slstate=1
        saveload
        ;;
    S)
        slstate=2
        saveload
        ;;
    Q) 
        figlet "Good Bye !"
        rm /tmp/tmpchoice
        if [ -e ./tempgame ];then
            rm ./tempgame
        fi
        break
        ;;
esac
}

tprint
dialog --ok-label "Go" --msgbox "$welcome" 15 36 && \
menu
