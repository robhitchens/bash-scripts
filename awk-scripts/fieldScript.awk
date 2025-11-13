/^[ ]*Outbound Request.*$/ { 
    isRequest = 1 
    print ""
}
/^[ ]*Outbound Response.*$/ { 
    isRequest = 0 
    print ""
}
/^[ ]{2}/ { print "//-------" $1 }
/^[^ ]{2}/ { 
    comment = ($5 == ""? "" : "// " $5)
    if(isRequest == 1) {
        lefthand = $6
        righthand = $1
        name = ": pld."
    } else {
        lefthand = $1
        righthand = $6
        name = ": response."
    }
    if(lefthand != "" && match($1, /[ :-]|null/) == 0) {
        print lefthand name righthand ", " comment
    }
    if(match($1, /[ :-]|null/) > 0) {
        print "// " $0
    }
}
