$PROBLEM  indirect response model Effect compartment initialized with unity dose
$DATA dat IGNORE=# 
$INPUT ID TIME DV MDV AMT BW DOSE CMT iCL
$SUBROUTINES ADVAN6 TOL=5 
$MODEL
COMP=(DOSE, DEFDOSE)
COMP=(CENTRAL)
COMP=(PERIPH)
COMP=(EFFECT,DEFOBS)       ; indirect response compartment

$PK
K12= THETA(1)
CL = THETA(2)                   ; imports post-hoc estimation for CL from prn file
V2 = THETA(3)
V3 = THETA(4)
Q  = THETA(5)
K20=CL/V2
K23=Q/V2
K32=Q/V3

BL  = THETA(6)*EXP(ETA(1)) ; Baseline for PD model with inter-individual variability
Kout= THETA(7)             ; Kout for indirect repsonse PD model 
Rin = BL*Kout              ; at equilibrium BL = Rin/Kout
A_0(4)=BL                  ; initialization of effect to BL value

EMAX= THETA(8)             ; Emax for effect 
EC50= THETA(9)             ; EC50 for drug effect concentration 

$DES
DADT(1) = -K12*A(1)
DADT(2) =  K12*A(1) - K20*A(2) - K23*A(2) + K32*A(3) 
DADT(3) =                        K23*A(2) - K32*A(3) 

C2  = A(2)/V2                       ; Calculate central/plasma concentration 
EFF =  1 - C2*EMAX/( C2 + EC50 )    ; Calculate drug effect relative to 1 = 100% = baseline
DADT(4)= EFF*Rin - Kout*A(4)        ; type I IRM model has drug effect as inhibtion of Rin

$ERROR
IPRE = F
Y    = IPRE + ERR(1)               ; Residual error = additive

$THETA
(1.95   )   ; TH1 K12 
(1      )   ; TH2 CL
(1.31   )   ; TH3 V2
(4.15   )   ; TH4 V3
(0.904  )   ; TH5 Q
               
(0 100   )  ; TH6 BL   ; (0 = lower limit for baseline, 110 = starting value)
(0 3.94  )  ; TH7 Kout
(0 0.9 1 )  ; TH8 EMAX ; inhibtion not greater than 1 = 100% of baseline; else effect becomes negative
(0 2     )  ; TH9 EC50
;
$OMEGA 
0.1       ; ETA1 = BL
;
$SIGMA
30        ; ERR1
$EST PRINT=5 MAX=9999 METHOD=0 POSTHOC 
$COV COMP
$TABLE ID TIME DOSE CMT BL EC50 C2 EFF IPRE 
ONEHEADER NOPRINT FILE=par
