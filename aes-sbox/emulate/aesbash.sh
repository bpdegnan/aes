#!/bin/sh
#Before anything else, set the PATH_SCRIPT variable
	pushd `dirname $0` > /dev/null; PATH_SCRIPT=`pwd -P`; popd > /dev/null
	PROGNAME=${0##*/}; 

####################################################################################
#  Dependencies
#

BIGNUMBERS=bashbignumbers.sh
URL_BIGNUMBERS="https://raw.githubusercontent.com/bpdegnan/bashbignumbers/master/bashbignumbers.sh"

#I changed the name from aesbash_verify_dependencies to aesbash_verdep
#this function is for backwards compatibility.   it is not in the help manifest because
# it lacks the function tag.
aesbash_verify_dependencies()
{
 aesbash_verdep $@
}

##  aesbash_verdep().  I will assume that we will be using the number library 
function aesbash_verdep() # Check and download dependencies
# aesbash_verdep & 0 & 0 & check and download deps.\\ \hline
{
FLAG_FETCH=0
#check for bignumbers
if [ ! -f $BIGNUMBERS ]; then
    printf 'Dependency, %s, not found!  Attempting to fetch...\n' "$BIGNUMBERS"
    #bash has hash, otherwise, I'd use command -v
    if hash wget 2>/dev/null; then
      FLAG_FETCH=1
      wget $URL_BIGNUMBERS
      printf '\nUsed wget to fetch %s\n' "$BIGNUMBERS"
    elif hash curl 2>/dev/null; then
      FLAG_FETCH=2
      curl -O $URL_BIGNUMBERS
      printf '\nUsed curl to fetch %s \n'"$BIGNUMBERS"
    else
      echo "File, $BIGNUMBERS, could not be acquired!"
      echo "Furthermore, wget and curl not found to get it from:"
      echo "$URL_BIGNUMBERS"
      exit
    fi
fi

#hopefully, we have it but if we don't, check again.
if [ ! -f $BIGNUMBERS ]; then
  echo "File, $BIGNUMBERS, not found!"
  exit
else
  #load big numbers
  source "$BIGNUMBERS"
fi



}

## aes_affineinv calculates the affine trassform inversion in the manner outlined in the document.
## The input is an 8-bit ASCII encoded string.
function aes_affineinv() # calculate the affine transform inverse
# aes_affineinv & 1 & 8 & inverse affine transform\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #now continue with the transform
  a7=${isom_inputstring:0:1} 
  a6=${isom_inputstring:1:1} 
  a5=${isom_inputstring:2:1} 
  a4=${isom_inputstring:3:1} 
  a3=${isom_inputstring:4:1} 
  a2=${isom_inputstring:5:1} 
  a1=${isom_inputstring:6:1} 
  a0=${isom_inputstring:7:1} 
  
  #calculate the a values
  at7=$(bashXORbinstringseries $a6 $a4 $a1 )
  at6=$(bashXORbinstringseries $a5 $a3 $a0 )
  at5=$(bashXORbinstringseries $a7 $a4 $a2 )
  at4=$(bashXORbinstringseries $a6 $a3 $a1 )
  at3=$(bashXORbinstringseries $a5 $a2 $a0 )
  at2=$(bashXORbinstringseries $a7 $a4 $a1 )
  at1=$(bashXORbinstringseries $a6 $a3 $a0 )
  at0=$(bashXORbinstringseries $a7 $a5 $a2 )
  
  resamatrix="$at7$at6$at5$at4$at3$at2$at1$at0"
  resaffine=$(bashXORbinstring $resamatrix "00000101")
  echo "$resaffine"
}

## aes_affine calculates the affine trassform in the manner outlined in the document.
## The input is an 8-bit ASCII encoded string.
function aes_affine() # calculate the affine transform
# aes_affine & 1 & 8 & calculate affine transform\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #now continue with the transform
  a7=${isom_inputstring:0:1} 
  a6=${isom_inputstring:1:1} 
  a5=${isom_inputstring:2:1} 
  a4=${isom_inputstring:3:1} 
  a3=${isom_inputstring:4:1} 
  a2=${isom_inputstring:5:1} 
  a1=${isom_inputstring:6:1} 
  a0=${isom_inputstring:7:1} 
  
  #calculate the a values
  at7=$(bashXORbinstringseries $a7 $a6 $a5 $a4 $a3)
  at6=$(bashXORbinstringseries $a6 $a5 $a4 $a3 $a2)
  at5=$(bashXORbinstringseries $a5 $a4 $a3 $a2 $a1)
  at4=$(bashXORbinstringseries $a4 $a3 $a2 $a1 $a0)
  at3=$(bashXORbinstringseries $a7 $a3 $a2 $a1 $a0)
  at2=$(bashXORbinstringseries $a7 $a6 $a2 $a1 $a0)
  at1=$(bashXORbinstringseries $a7 $a6 $a5 $a1 $a0)
  at0=$(bashXORbinstringseries $a7 $a6 $a5 $a4 $a0)
  
  resamatrix="$at7$at6$at5$at4$at3$at2$at1$at0"
  resaffine=$(bashXORbinstring $resamatrix "01100011")
  echo "$resaffine"
}

## aes_isomorphic calculates the isomorphic transform in the manner outlined in the document.
## The input is an 8-bit ASCII encoded string.
function aes_isomorphic() # isomorphic transform
# aes_isomorphic & 1 & 8 & isomorphic transform\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #now continue with the transform
  q7=${isom_inputstring:0:1} 
  q6=${isom_inputstring:1:1} 
  q5=${isom_inputstring:2:1} 
  q4=${isom_inputstring:3:1} 
  q3=${isom_inputstring:4:1} 
  q2=${isom_inputstring:5:1} 
  q1=${isom_inputstring:6:1} 
  q0=${isom_inputstring:7:1} 
  
  #calculate the a values
  a7=$(bashXORbinstringseries $q7 $q5)
  a6=$(bashXORbinstringseries $q7 $q6 $q4 $q3 $q2 $q1)
  a5=$(bashXORbinstringseries $q7 $q5 $q3 $q2)
  a4=$(bashXORbinstringseries $q7 $q5 $q3 $q2 $q1)
  a3=$(bashXORbinstringseries $q7 $q6 $q2 $q1) 
  a2=$(bashXORbinstringseries $q7 $q4 $q3 $q2 $q1)
  a1=$(bashXORbinstringseries $q6 $q4 $q1)
  a0=$(bashXORbinstringseries $q6 $q1 $q0) 
   
  echo "$a7$a6$a5$a4$a3$a2$a1$a0"
}
## aes_isomorphic calculates the isomorphic transform inverse in the manner outlined in the document.
## The input is an 8-bit ASCII encoded string.
function aes_isomorphicinv()# inverse isomorphic transform
# aes_isomorphicinv & 1 & 8 & inverse isomorphic transform\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #now continue with the transform
  q7=${isom_inputstring:0:1} 
  q6=${isom_inputstring:1:1} 
  q5=${isom_inputstring:2:1} 
  q4=${isom_inputstring:3:1} 
  q3=${isom_inputstring:4:1} 
  q2=${isom_inputstring:5:1} 
  q1=${isom_inputstring:6:1} 
  q0=${isom_inputstring:7:1} 
  
  #calculate the a values
  a7=$(bashXORbinstringseries $q7 $q6 $q5 $q1)
  a6=$(bashXORbinstringseries $q6 $q2)
  a5=$(bashXORbinstringseries $q6 $q5 $q1)
  a4=$(bashXORbinstringseries $q6 $q5 $q4 $q2 $q1)
  a3=$(bashXORbinstringseries $q5 $q4 $q3 $q2 $q1) 
  a2=$(bashXORbinstringseries $q7 $q4 $q3 $q2 $q1)
  a1=$(bashXORbinstringseries $q5 $q4)
  a0=$(bashXORbinstringseries $q6 $q5 $q4 $q2 $q0) 
   
  echo "$a7$a6$a5$a4$a3$a2$a1$a0"
}
## aes_lambdamultiply multiplies the binary input by the constant 1100
function aes_lambdamultiply()# multiplication by constant
# aes_lambdamultiply & 1 & 4 & multiplication by \(\lambda=\{1100\}\) \\ \hline

{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=4
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #map inputs to outputs
  i3=${isom_inputstring:0:1} 
  i2=${isom_inputstring:1:1} 
  i1=${isom_inputstring:2:1} 
  i0=${isom_inputstring:3:1} 

  o3=$(bashXORbinstring $i2 $i0)
  o2inner=$(bashXORbinstring $i3 $i1)
  o2=$(bashXORbinstring $o3 $o2inner)
  o1=$i3
  o0=$i2
  echo "$o3$o2$o1$o0"
}

# aes_multGF2()# multiplication by constant
# # aes_multGF2 & 1 & 4 & multiplication by \(\lambda=\{1100\}\) \\ \hline
# {
#   isom_inputstring=$1
#   isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
#   isom_inputmaxsize=4
#   if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
#     echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
#     exit -1
#   fi
#   #map inputs to outputs
#   i3=${isom_inputstring:0:1} 
#   i2=${isom_inputstring:1:1} 
#   i1=${isom_inputstring:2:1} 
#   i0=${isom_inputstring:3:1} 
# 
#   and1in1=$(bashXORbinstring $i3 $i2)
#   and1in0=$(bashXORbinstring $i1 $i0)
# 
#   and2res=$(bashANDbinstring $i3 $i1)
#   and1res=$(bashANDbinstring $and1in1 $and1in0)
#   and0res=$(bashANDbinstring $i2 $i0)
#   
#   #inner is my notation for an inter node
#   o1=$(bashXORbinstring $and1res $and0res)
#   o0=$(bashXORbinstring $and2res $and0res)
#   echo "$o1$o0"
# }


## I tried to split out aes_multGF2 to take two arguments, but I had issues with how the 
## bashbignumber.sh library worked because I need two, two bits inputs but bashbignumbers.sh
## can only do nibbles.
function aes_multGF2()# multiplication by constant
# aes_multGF2 & 1 & 4 & mult. of 2, 2-bit numbers \\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=4
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #map inputs to outputs
  i3=${isom_inputstring:0:1} 
  i2=${isom_inputstring:1:1} 
  i1=${isom_inputstring:2:1} 
  i0=${isom_inputstring:3:1} 

  and1in1=$(bashXORbinstring $i3 $i2)
  and1in0=$(bashXORbinstring $i1 $i0)

  and2res=$(bashANDbinstring $i3 $i1)
  and1res=$(bashANDbinstring $and1in1 $and1in0)
  and0res=$(bashANDbinstring $i2 $i0)
  
  #inner is my notation for an inter node
  o1=$(bashXORbinstring $and1res $and0res)
  o0=$(bashXORbinstring $and2res $and0res)
  echo "$o1$o0"
}

##  aes_invGF24  Calculate the multiplicative inverse of the 4-bit input.
##
function aes_invGF24()
# aes_invGF24 & 1 & 4 & multiplicative inverse of input \\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=4
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
   
 #map inputs to outputs
 i3=${isom_inputstring:0:1} 
 i2=${isom_inputstring:1:1} 
 i1=${isom_inputstring:2:1} 
 i0=${isom_inputstring:3:1} 

 and321=$(bashANDbinstringseries $i3 $i2 $i1)
 and320=$(bashANDbinstringseries $i3 $i2 $i0)
 and310=$(bashANDbinstringseries $i3 $i1 $i0)
  and31=$(bashANDbinstringseries $i3 $i1)
  and30=$(bashANDbinstringseries $i3 $i0)
 and210=$(bashANDbinstringseries $i2 $i1 $i0)
  and21=$(bashANDbinstringseries $i2 $i1)
  and20=$(bashANDbinstringseries $i2 $i0) 
  
 o3=$(bashXORbinstringseries $i3 $and321 $and30 $i2)
 o2=$(bashXORbinstringseries $and321 $and320 $and30 $i2 $and21)
 o1=$(bashXORbinstringseries $i3 $and321 $and310 $i2 $and20 $i1)
 o0=$(bashXORbinstringseries $and321 $and320 $and31 $and310 $and30 $i2 $and21 $and210 $i1 $i0)
 
 # change the first argument to 1 to have 1==1 to print out states
 # you'll really need to watch this flag because if you try to use the output, you end up
 # gumming up the works.
 #
if [ 0 -eq 1 ]
then
  echo "i3i2i1i0: $i3$i2$i1$i0"
  echo "  and321=(bashANDbinstringseries $i3 $i2 $i1)" 
  echo "  and321: $and321"
  echo "  and320=(bashANDbinstringseries $i3 $i2 $i0)"  
  echo "  and320: $and320"
  echo "  and310: $and310"
  echo "  and210=(bashANDbinstringseries $i2 $i1 $i0)"
  echo "  and210: $and210"
  echo "   and31: $and31"
  echo "   and30: $and30"
  echo "   and21: $and21"
  echo "   and20: $and20"
  
  echo "o3: $o3=(bashXORbinstringseries $i3 $and321 $and30 $i2)"
  echo "o2: $o2=(bashXORbinstringseries $and321 $and320 $and30 $i2 $and21)"
  echo "o1: $o1=(bashXORbinstringseries $i3 $and321 $and310 $i2 $and20 $i1)"
  echo "o0: $o0=(bashXORbinstringseries and321 and320 and31 and310 and30 i2 and21 and210 i1 i0)"
  echo "o0: $o0=(bashXORbinstringseries $and321 $and320 $and31 $and310 $and30 $i2 $and21 $and210 $i1 $i0)"
fi 

  echo "$o3$o2$o1$o0"
}

## aes_phimultiply() does the simple multiply by a constant
##
function aes_phimultiply()
# aes_phimultiply & 1 & 2 & mult. by constant \(\varphi=\{10\}\) \\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=2
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #map inputs to outputs
  i1=${isom_inputstring:0:1} 
  i0=${isom_inputstring:1:1} 

  o1=$(bashXORbinstring $i1 $i0)
  o0=$i1
  echo "$o1$o0"
}

function aes_squarerGF24()
# aes_squarerGF24 & 1 & 4 & the square of the input \\ \hline

{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=4
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #map inputs to outputs
  i3=${isom_inputstring:0:1} 
  i2=${isom_inputstring:1:1} 
  i1=${isom_inputstring:2:1} 
  i0=${isom_inputstring:3:1} 

  o3=$i3
  o2=$(bashXORbinstring $i3 $i2)
  o1=$(bashXORbinstring $i2 $i1)
  #inner is my notation for an inter node
  o0inner=$(bashXORbinstring $i1 $i0)
  o0=$(bashXORbinstring $i3 $o0inner)
  echo "$o3$o2$o1$o0"
}

## aes_multGF24() multiplies two nibbles to result in a nibble.  The two input nibbles
## are a 8-bit word.
function aes_multGF24()
# aes_multGF24 & 1 & 8 & mult. of 2, 4-bit numbers\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #map inputs to outputs
  i7=${isom_inputstring:0:1} 
  i6=${isom_inputstring:1:1} 
  i5=${isom_inputstring:2:1} 
  i4=${isom_inputstring:3:1} 
  i3=${isom_inputstring:4:1} 
  i2=${isom_inputstring:5:1} 
  i1=${isom_inputstring:6:1} 
  i0=${isom_inputstring:7:1}

  mul1input1=$(bashXORbinstring "$i7$i6" "$i5$i4")
  mul1input0=$(bashXORbinstring "$i3$i2" "$i1$i0")

  mul2res=$(aes_multGF2 "$i7$i6$i3$i2")
  mul1res=$(aes_multGF2 "$mul1input1$mul1input0")
  mul0res=$(aes_multGF2 "$i5$i4$i1$i0")

  ohigh=$(bashXORbinstring $mul1res $mul0res)
  
  mulphires=$(aes_phimultiply $mul2res)
  
#  echo "mulphires: $mulphires"
  
  olow=$(bashXORbinstring $mulphires $mul0res)
  
  echo "$ohigh$olow"
}

function aes_multiplicativeinversion()
# aes_multiplicativeinversion & 1 & 8 & multiplicative inversion\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  #working from left to right in the diagram from Satoh
  
  resiso=$(aes_isomorphic $isom_inputstring) 
  isohigh=${resiso:0:4}  
  isolow=${resiso:4:4} 
  
  resxor0=$(bashXORbinstring $isohigh $isolow)
  ressqr=$(aes_squarerGF24 $isohigh)
  reslambda=$(aes_lambdamultiply $ressqr)
 # resmul0=$(aes_multGF24 "$resxor0$isolow")
  resmul0=$(aes_multGF24 "$isolow$resxor0")
  
  resxor1=$(bashXORbinstring $reslambda $resmul0)  
  resmulinv=$(aes_invGF24 $resxor1)
  
  resmul1=$(aes_multGF24 "$isohigh$resmulinv")
  resmul2=$(aes_multGF24 "$resxor0$resmulinv")
  
  resmi=$(aes_isomorphicinv "$resmul1$resmul2")

# change the first argument to 1 to have 1==1 to print out states
if [ 0 -eq 1 ]
then
  echo "isohigh isolow: $isohigh $isolow"
  echo "  resxor0: $resxor0"
  echo "   ressqr: $ressqr"
  echo "reslambda: $reslambda"
  echo "  resmul0: $resmul0"
  echo "  resxor1: $resxor1"
  echo "resmulinv: $resmulinv"
  echo "  resmul1: $resmul1"
  echo "  resmul2: $resmul2"
  echo "    resmi: $resmi"
fi 
   
  #finally, the result of the multiplicative inversion
  echo "$resmi"
}
##  aes_subbyte() compute the subbyte for the SBox by the inversion
##  followed by the affine transform
function aes_subbyte()
# aes_subbyte & 1 & 8 & subbyte calculation\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  
  resinv=$(aes_multiplicativeinversion $isom_inputstring)
  resaff=$(aes_affine $resinv)
  echo "$resaff"
}

function aes_subbyteinv()
# aes_subbyteinv & 1 & 8 & inverse subbyte calculation\\ \hline
{
  isom_inputstring=$1
  isom_inputsize=${#isom_inputstring}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  
  resaffinv=$(aes_affineinv $isom_inputstring)
  resmuli=$(aes_multiplicativeinversion $resaffinv)
  
  echo "$resmuli"
}

#
# aes_roundconstant() creates the round key constant, and takes two arguments
# The first is the last number in the series and the second is "0" for up and "1" for down
#
aes_roundconstant()
{
  isom=$1
  isom_inputsize=${#isom}  #get the length, it should be 8
  isom_inputmaxsize=8
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  isom_mode=$2

 rc7i=${isom:0:1}
 rc6i=${isom:1:1}  
 rc5i=${isom:2:1}  
 rc4i=${isom:3:1}  
 rc3i=${isom:4:1}  
 rc2i=${isom:5:1}  
 rc1i=${isom:6:1}  
 rc0i=${isom:7:1}    

 #the feedback line
 if [ "$isom_mode" == "0" ]; then
   fback=$rc7i #encyption
 else
   fback=$rc4i #decryption
 fi
 
 #shift the register
 rc7=$rc6i 
 rc6=$rc5i 
 rc5=$rc4i 
 rc4=$(bashXORbinstring $rc3i $fback)

 if [ "$isom_mode" == "0" ]; then
  #encyption
  rc3=$(bashXORbinstring $rc2i $fback)
  rc2=$rc1i
 else
 #decryption
  rc3=$rc2i
  rc2=$(bashXORbinstring $rc1i $fback)
 fi
 rc1=$(bashXORbinstring $rc0i $fback)
 rc0=$rc7i
 
 echo "$rc7$rc6$rc5$rc4$rc3$rc2$rc1$rc0" 
 
}

#
# aes_RotWord() rotates the 32-bit word by 8bits 
# I could use the bashbignumbers functions but instead I am using a fixed 8-bit version
#

aes_RotWord()
{
  isom=$1
  isom_inputsize=${#isom}  #get the length
  isom_inputmaxsize=32
  if [ "$isom_inputsize" -ne "$isom_inputmaxsize" ]; then
    echoerr "ERROR, ${FUNCNAME[0]} failed due to isom_inputsize != $isom_inputmaxsize ($isom_inputsize) " 
    exit -1
  fi
  
  isom_mode=$2
  let BITOFFSET=8
  
if [ "$isom_mode" == "0" ]; then  
  #bit based operation on an ascii encoded binary word
  #Take the byte on the left and put it on the right

  let STRLSB=isom_inputsize-BITOFFSET  #there should be 32 bits, so this is 8 bits down
  LEFTBITS=${isom:0:BITOFFSET}
  REMAIN=${isom:BITOFFSET:$STRLSB}
  STRCONSTRUCT="$REMAIN$LEFTBITS"
else  
  #decryption we take the byte on the right and put it to the left.
  let STRLSB=isom_inputsize-BITOFFSET  #there should be 32 bits, so this is 8 bits down
  RIGHTBITS=${isom:STRLSB:isom_inputsize}
  REMAIN=${isom:0:STRLSB}
  STRCONSTRUCT="$RIGHTBITS$REMAIN"
fi  
  printf '%s' "$STRCONSTRUCT"  

}

function help() # Show a list of functions
{
    echo "okay"
    grep "^function" $0
}
function helplatex()
# helplatex & 0 & 0 & autogenerate this table\\ \hline
{
	# get the next line of with "function" and remove #
    grep -A 1 "^function" $0 | grep "^#" | cut -c 2- | sed 's/_/\\_/g'
}

####################################################################################
#  TEST Run
#
# get the dependencies for this file

# helplatex
# aesbash_verdep

#aes_multiplicativeinversion "00000100"
#aes_affine "11001011"
#aes_subbyte "00000100"

#aestest_subbytetable
#aestest_multiplicativeinversion
#aestest_multGF24
#aestest_multinv24
#aes_invGF24 "0110"

