$PLUGIN autodec nm-vars
$PROB THEOPHYLLINE EXAMPLE - base model

$PARAM
THETA1 = 0.0834407, THETA2 = 2.69216, THETA3 = 1.35976, THETA4 = 0.511949, THETA5 = 1.34313, WEIGHT = 1, SEX = 1

$CMT A1 A2

$PK

COV1 = pow((WEIGHT/70), THETA(4)) ;
COV2 =  1 ;
if(SEX == 1) COV2 =  THETA(5) ;
KA =  THETA(1) * exp(ETA(1)) ;
CL =  THETA(2) * COV1 * exp(ETA(2)) ;
V =  THETA(3) * COV2 ;
S2 =  V ;
K =  CL/V ;
F1 =  1 ;

A_0(1) = 0;
A_0(2) = 0;

$DES

CP =  A(2)/V ;
DADT(1) =  - KA*A(1) ;
DADT(2) =    KA*A(1) - K*A(2) ;


$OMEGA @annotated @block
ETA1: 0.0254089  : ETA1
ETA2: 0 0.0390664 : ETA2

$CAPTURE CP
