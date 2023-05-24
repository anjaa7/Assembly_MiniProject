! INIT SIMULATION
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! /INIT SIMULATION

! ======================== Main Program ========================
org x.4000
! --------- Initializing IVT ---------
ldimm x.0300, r0 
mvrir r0, ivtp 
ldimm x.2000, r0
stmem x.0300, r0 
!ulaz 1
ldimm x.1500, r0
stmem x.0301, r0 
!ulaz 2
ldimm x.2500, r0
stmem x.0302, r0
!ulaz 3
ldimm x.0500, r0
stmem x.0303, r0
!ulaz 4
ldimm x.1000, r0
stmem x.0304, r0
!ulaz 5
ldimm x.3000, r0
stmem x.0305, r0
! --------- /Initializing IVT --------


! --------- Reading Array A & B ---------
! Array A -> location 5000h, KP1.1 (Interrupts)
! Array B -> location 6000h, KP2.1 (Interrupts)
! 8h elements


! Starting KP1.1 (Interrupt)
ldimm x.08, r2 ! Array A elem count
ldimm x.5000, r ! Pointer to Array A
ldimm x.00, r4 ! KP1.1 Load Semaphore <= 0

ldimm x.03, r0  ! IVT Entry no 
stmem x.F102, r0 ! KP1.1[entry] <= 3
ldimm x.0F,r0 
stmem x.F100, r0 ! Starting KP1.1 with flags 1111

! Starting KP2.1 (Interrupt)
ldimm x.08, r5 ! Array B elem count
ldimm x.6000, r6 ! Pointer to Array B
ldimm x.00, r7 ! KP2.1 Load Semaphore <= 0

ldimm x.01, r0 ! IVT Entry no 
stmem x.F202, r0 ! KP1.1[entry] <= 1
ldimm x.0F,r0 
stmem x.F200, r0 ! Starting KP2.1 with flags 1111

! Waiting for KP1.1 to finish Array B input
loopKP11:
    ldimm x.01, r0 ! Mask to check semaphore value
    tst r0, r4
    beql loopKP11 ! If ( !semaphore ) jmp loopKP11
ldimm x.00, r0  
stmem x.F100, r0 

loopKP21:
    ldimm x.01, r0 ! Mask to check semaphore value
    tst r0, r7
    beql loopKP21  ! If ( !semaphore ) jmp loopKP21
ldimm x.00, r0  
stmem x.F200, r0 
! --------- /Reading Array A & B ---------

! --------- SummingUp Array A and B ----------
ldimm x.08, r1  ! Counter 
push r1
ldimm x.6000, r1  ! Pointer to Array B
push r1
ldimm x.5000, r1 ! Pointer to Array A
push r1
jsr sumAll
pop r1
pop r1
pop r1
! --------- SummingUp Array A and B ----------

! mem[9999h] = [r0], result is stored in register r0
stmem x.9999, r0 

! --------- Copying Array B ----------
ldimm x.00, r2 ! DMA1.4 Semaphore
ldimm x.05, r0 ! IVT entry
stmem x.F0C2, r0 
ldimm x.08,r0 ! Element count
stmem x.F0C4, r0 
ldimm x.6000, r0 ! Source	Array location
stmem x.F0C5, r0 
ldimm x.6100, r0 ! Destination Array location
stmem x.F0C6, r0 
ldimm x.0BE ,r0 ! Flags to start DMA1.4
stmem x.F0C0, r0 ! Starting DMA1.4

loopDMA14:
    ldimm x.01, r0 
    tst r0, r2
    beql loopDMA14

ldimm x.00, r0
stmem x.F0C0, r0 
! --------- /Copying Array B --------

! --------- Sending Array A to DMA1.1 ---------
ldimm x.00, r2 !DMA1.1 Semaphore
ldimm x.03, r0 ! IVT entry
stmem x.F002, r0 
ldimm x.08, r0 ! Element count
stmem x.F004, r0 
ldimm x.5000, r0 ! Source	Array location
stmem x.F005, r0
ldimm x.8E, r0 ! Flags to start DMA1.1
stmem x.F000, r0
! --------- /Sending Array A to DMA1.1 --------

! --------- mem[9999h] -> DMA1.2 ---------
! Starting DMA1.2
ldimm x.0, r4 ! DMA1.2 Semaphore
ldimm x.9999, r0 ! Source	Array location
stmem x.F045, r0 !saljemo sa lok 9999, to ide u AR1
ldimm x.01, r0 ! Element count
stmem x.F044, r0 
ldimm x.02,r0 ! IVT entry
stmem x.F042, r0 
ldimm x.08E, r0 ! Flags to start DMA1.4
stmem x.F040, r0 ! Starting DMA1.4


loopDMA11:
  ldimm x.01, r0 ! Mask
  tst r0, r2
  beql loopDMA11

loopDMA12:
  ldimm x.01, r0 ! Mask
  tst r0, r2
  beql loopDMA12
! --------- /mem[9999h] -> DMA1.2 --------

halt
! ======================== /Main Program =======================



! ========= SummingUp Subroutine =========
sumAll:
  push r1
  push r2
  push r3
  push r4
  push r5
  push r6
  mvrpl r6, sp ! upisuje vrednost registra sp u r0, na steku je 08,6000,5000,r0,r1,r2,r3,r4,r5
  ldrid [r6]x.09, r1 !8 counter
  ldrid [r6]x.08, r2 !6000
  ldrid [r6]x.07, r3 !5000 sp pokazuje na prvu slob lok
  ldimm x.00, r0
  loopSum:  
      ldrid [r3]x.00, r4 !u r4 jedan el niza A
      ldrid [r2]x.00, r5 !u r5 jedan el niza B
      add r0,r0,r4
      add r0,r0,r5
      inc r2
      inc r3
      dec r1
      bgrt loopSum
  pop r6
  pop r5
  pop r4
  pop r3
  pop r2
  pop r1
  rts
! ========= /SummingUp Subroutine ========



! ========= KP1.1 Interrupt routine =========
org x.0500 ! Interrupt ivtp[3]

push r0
push r1

ldimm x.00, r0
cmp r2, r0 
bgrt getElement
ldimm x.01, r4 ! semaphore <= 1
ldimm x.00, r0  
stmem x.F100, r0 ! Turn off KP1.2
jmp backKP11

getElement:
     ldmem x.F103, r0 ! Reading KP2.1 Data
    stri [r3],r0 ! Array B[cnt] <= Data
    inc r3
    dec r2 ! decrement elem cnt
backKP11:
    pop r1
    pop r0
    rti
! ========= /KP1.1 Interrupt routine ========



! ========= KP2.1 Interrupt routine =========
org x.1500! Interrupt ivtp[1]
push r0
push r1

ldimm x.00, r0
cmp r5, r0 
bgrt getElement1
ldimm x.01, r7 ! semaphore <= 1
ldimm x.00, r0 
stmem x.F200, r0! Turn off KP1.2
jmp backKP21
getElement1:
    ldmem x.F203, r0 ! Reading KP2.1 Data
    stri [r6],r0 ! Array B[cnt] <= Data
    inc r6
    dec r5 ! decrement elem cnt
    backKP21:
    pop r1
    pop r0
    rti
! ========= /KP2.1 Interrupt routine ========



! ========= DMA1.4 Interrupt routine =========
org x.3000 
push r1
push r0
ldimm x.01, r2
ldimm x.00, r0
stmem x.F0C0, r0
pop r0
pop r1
rti
! ========= /DMA1.4 Interrupt routine =========



! ========= DMA1.2 Interrupt routine =========
org x.2500
push r0
push r1
ldimm x.01, r2
ldimm x.00, r0
stmem x.F040, r0
pop r1
pop r0
rti
! ========= /DMA1.2 Interrupt routine =========



! ========= DMA1.1 Interrupt routine =========
org x.2000
push r1
push r0
ldimm x.01, r2
ldimm x.00, r0
stmem x.F000, r0
pop r0
pop r1
rti
! ========= /DMA1.1 Interrupt routine =========
