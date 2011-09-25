name = "/lib/some problematic file name.txt"
#res = name.split("").map((x) -> if (x == " ") then "\\ " else x)

res = name.replace(///\s///g, '\\ ')
console.log res
