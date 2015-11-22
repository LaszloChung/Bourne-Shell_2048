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
        dialog --ok-label "You Lose" --textbox ./title/gameover 10 60
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
        dialog --ok-label "You Win" --textbox ./title/win 10 45
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

game()
{
        winscore=128
        major=0
        countp=2
        div="\t---------------------------------\n"
        div2="\t|\t|\t|\t|\t|\n"
        while [ $winscore != 0 ] 
            do
                bprint
                getc press
                case $press in
                    w)
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
        dialog --title 'Menu' --menu "Load Game" 15 50 100 1 $save1 2 $save2 3 $save3 4 $save4 5 $save5 2> /tmp/tmpoption
        chooption=$(cat /tmp/tmpoption)
        if [ $(eval echo "\$save$chooption") == "Empty" ];then
            dialog --msgbox "It's Empty!" 5 15
            menu
        elif [ $chooption ];then
            countline=1 # Skip line 1 (save name)
            for i in $(seq 1 4)
                do
                for j in $(seq 1 4)
                    do
                        countline=$(($countline + 1)) #To read increasing line
                        eval line$i$j=$(cat $savepath/save$chooption | sed -n "${countline}p" | awk '{print $2}')
                    done
                done
            game
        else
            menu
        fi
    elif [ $slstate = 2 ];then #For save operation
        dialog --title 'Menu' --menu "Save Game" 15 50 100 1 $save1 2 $save2 3 $save3 4 $save4 5 $save5 2> /tmp/tmpoption
        chooption=$(cat /tmp/tmpoption)
        if [ $chooption ];then
            dialog --inputbox "Enter your save name" 8 30 2> /tmp/tmpsavename
            cat ./tempgame >> /tmp/tmpsavename
            cp /tmp/tmpsavename $savepath/save$chooption && rm /tmp/tmpsavename
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

menu()
{
dialog --title 'Menu' --menu "Command Line 2048" 15 50 100 N "New Game" R "Resume" L "Load" S "Save" Q "Quit" 2> /tmp/tmpchoice
slstate=0 # For Check SL Operation
return=$(cat /tmp/tmpchoice)
case $return in
    N)
        echo "" > tempgame
        line11="" line12="" line13="" line14=2
        line21="" line22=2 line23="" line24=""
        line31="" line32="" line33="" line34=""
        line41="" line42="" line43="" line44=""
        game
        break
        ;;
    R)
        ;;
    L)
        slstate=1
        saveload
        break
        ;;
    S)
        slstate=2
        saveload
        break
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

dialog --exit-label "Go" --textbox ./title/welcome 17 37 && \
menu
