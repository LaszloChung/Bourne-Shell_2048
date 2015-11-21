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
    while [ $randp = 3 ]
        do
        randp=`jot -r 1 2 4`
        done
    if [ $countp = 16 ];then
        dialog --ok-label "You Lose" --textbox ./title/gameover 10 60
        winscore=0
    elif [ $((line$randc$randr)) = 0 ];then
        eval line$randc$randr=$randp
        countp=$(($countp + 1))
    else
        randpiece
    fi
}

checkwin()
{
    if [ $((line$compar$row)) = $winscore ];then
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
                                            echo "line$i$j=$((line$i$j))" >> ./tempgame
                                        done
                                done
                        menu
                        ;;
                esac
            done 
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
dialog --title 'menu' --menu "Command Line 2048" 15 50 100 N "New Game" R "Resume" L "Load" S "Save" Q "Quit" 2> /tmp/chotemp
return=$(cat /tmp/chotemp)
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
        ;;
    S) 
        ;;
    Q) 
        figlet "Good Bye !"
        if [ -e ./tempgame ];then
            rm ./tempgame
        fi
        break
        ;;
esac
}

dialog --exit-label "Go" --textbox ./title/welcome 17 37 && \
menu
