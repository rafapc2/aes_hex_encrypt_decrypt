#!/bin/bash

## Variables
password="te_pass_for_privKey" #the pass for encrypted the_privkey.pem
test_case_dir="test_case/"
sourceFile="${1}"
dataEncFile="data.enc.bin"
dataEncFileP="data.enc.processed.bin"
dataDecriptFinal="desenencriptado_objetivo.txt"

#paths
fileInput="${test_case_dir}${sourceFile}"
fileEncOutput="${test_case_dir}${dataEncFile}"

fileEncOutputHex="${test_case_dir}${dataEncFileP}.hex"

fileEncOutputProcessed="${test_case_dir}${dataEncFileP}"
fileDecFinal="${test_case_dir}${dataDecriptFinal}"


bin_to_hex(){

    echo "----- bin_to_hex ------"
    echo "$fileEncOutputHex"
    xxd -p -c 100000 "$1" > $fileEncOutputHex
    echo ""
    cat $fileEncOutputHex
    echo "-------------------"
    echo ""

}


hex_to_bin(){
    echo "----- hex_to_bin ------"
    echo "$fileEncOutputProcessed"
    xxd -r -p "$1" > $fileEncOutputProcessed
    echo "---------------------"
    echo ""

}

echo ""
echo "encriptando archivo: ${fileInput}"
textFileInput=$( cat "$fileInput" )
echo "$textFileInput"
echo ""


if [[ $sourceFile == *"hex"* ]]; then
    echo "procesando Archivo Hex Encriptado"
    echo ""
    hex_to_bin "$fileInput"

else
    echo "procesando Archivo en texto plano"
    echo ""

    openssl pkeyutl -encrypt -pubin -inkey the_pubkey.pem -in "$fileInput" -out $fileEncOutput
    #hexdump -x $fileEncOutput
    
    bin_to_hex "$fileEncOutput"
    hex_to_bin "$fileEncOutputHex"

    #hexdump -x $fileEncOutputProcessed

    echo "diff:"
    diff -s $fileEncOutput $fileEncOutputProcessed
    #diff -y <(xxd $fileEncOutput) <(xxd $fileEncOutputProcessed)

fi
openssl pkeyutl -decrypt -inkey the_privkey.pem -in $fileEncOutputProcessed -out $fileDecFinal -passin pass:"$password"
cat $fileDecFinal
