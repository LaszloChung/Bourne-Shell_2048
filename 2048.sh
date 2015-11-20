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
    rand=`jot -r 1 1 4`
    rand2=`jot -r 1 1 4`
    rand3=`jot -r 1 2 4`
    while [ $rand3 = 3 ]
        do
        rand3=`jot -r 1 2 4`
        done
    if [ $((line$rand$rand2)) = 0 ];then
        eval line$rand$rand2=$rand3
    else
        randpiece
    fi
}

moveup()
{
    for row in $(seq 1 4)
        do
        for col in $(seq 2 4)
            do
                for compar in $(seq 1 $(($col-1)))
                    do
                    if [ $((line$compar$row)) = 0 ];then
                        eval line$compar$row=$((line$col$row))
                        eval line$col$row=""
                   elif [ $((line$compar$row)) = $((line$col$row)) ];then
                        eval line$compar$row=$(($((line$compar$row))*2))
                        eval line$col$row=""
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
                for compar in $(seq 4 $(($col+1)))
                    do
                    if [ $((line$compar$row)) = 0 ];then
                        eval line$compar$row=$((line$col$row))
                        eval line$col$row=""
                   elif [ $((line$compar$row)) = $((line$col$row)) ];then
                        eval line$compar$row=$(($((line$compar$row))*2))
                        eval line$col$row=""
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
                for compar in $(seq 1 $(($row-1)))
                    do
                    if [ $((line$col$compar)) = 0 ];then
                        eval line$col$compar=$((line$col$row))
                        eval line$col$row=""
                   elif [ $((line$col$compar)) = $((line$col$row)) ];then
                        eval line$col$compar=$(($((line$col$compar))*2))
                        eval line$col$row=""
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
                for compar in $(seq 4 $(($row+1)))
                    do
                    if [ $((line$col$compar)) = 0 ];then
                        eval line$col$compar=$((line$col$row))
                        eval line$col$row=""
                   elif [ $((line$col$compar)) = $((line$col$row)) ];then
                        eval line$col$compar=$(($((line$col$compar))*2))
                        eval line$col$row=""
                    fi
                    done
            done
        done
}

game()
{

        winscore=128
        div="\t---------------------------------\n"
        div2="\t|\t|\t|\t|\t|\n"
        while [ true ] 
            do
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
                
                echo -e "\n\n$div$div2\t|$line11\t|$line12\t|$line13\t|$line14\t|\n$div2$div" \
                "$div2\t|$line21\t|$line22\t|$line23\t|$line24\t|\n$div2$div" \
                "$div2\t|$line31\t|$line32\t|$line33\t|$line34\t|\n$div2$div" \
                "$div2\t|$line41\t|$line42\t|$line43\t|$line44\t|\n$div2$div" \
                "\n\tUSE w,s,a,d to MOVE ; q to EXIT \n\t\t Get $winscore to WIN!" | sed 's/0//g' | dialog --progressbox 25 50
                getc press
            done 
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
        . ./tempgame 
        echo $line11
        sleep 10
        ;;
    L) 
        ;;
    S) 
        ;;
    Q) 
        figlet "GoodBye !"
        if [ -e ./tempgame ];then
            rm ./tempgame
        fi
        break
        ;;
esac
}

dialog --exit-label "Go" --textbox ./welcome 17 37 && \
menu
