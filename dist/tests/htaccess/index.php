<?php
header("Content-Type: text/plain");
$INFO=$MISS=array();
foreach($_SERVER as $v=>$r)
{
  if(substr($v,0,5)=='HTTP_')
  {
    if(!empty($r) && $r!='(null)')$INFO[substr($v,5)]=$r;
    else $MISS[substr($v,5)]=$r;
  }
}
 
/* thanks Mike! */
ksort($INFO);
ksort($MISS);
ksort($_SERVER);
 
echo "Received These Variables:\n";
print_r($INFO);
 
echo "Missed These Variables:\n";
print_r($MISS);
 
echo "ALL Variables:\n";
print_r($_SERVER);
?>