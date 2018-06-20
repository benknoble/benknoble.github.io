# substitute the placeholder on the title line with the title variable
/title: TITLE/ {
    sub("TITLE", title, $2)
}

1
