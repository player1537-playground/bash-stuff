#!./equation.bash
#problem 2
p_i=5.00 #kgm/s
F_net=-20.0 #N
t=1.50 #s
J=F_net*t #Ns
J_net=J #Ns
dp=F_net*t #kgm/s
p_f=p_i+dp #kgm/s

J_net
p_f

next
#problem 3
m=50.0 / KILO #kg
v_i=-5.00 #m/s
v_f=4.50 #m/s
p_i=m*v_i #kgm/s
p_f=m*v_f #kgm/s
dp=p_f-p_i #kgm/s
J_net=dp #Ns
#J=F_net*t
F_net=J_net/dt #N
dt=0.010 #s

dp
J_net
F_net

next
#problem 4
dp=500 #kgm/s
dt=2.00 #s
J_net=dp #Ns
#J_net=F_net*dt
F_net=J_net/dt #N
m=1500 #kg
#p=m*v
#dp=p_f-p_i
dv=dp/m #m/s

F_net
dv

next
#problem 5
rate=492 #kg/s
v=-3390 #m/s
#Thrust=Impulse? 
#No, thrust=force
#rate*v=kgm/ss=N
F=rate*v #N, 90deg
F_s=11.8*MEGA #N
r_s=F_s/v #kg/s

F
r_s

next
#problem 9
m_1=95 #kg
v_1=8.2 #m/s
m_2=128 #kg
v_2=-v_1 #m/s
v_f=0 #m/s
#p=m*v
p_1=m_1*v_1 #kgm/s
dp_1=-p_1 #kgm/s
#p_1-p_2=0
p_2=p_1 #kgm/s
dp_2=-p_2 #kgm/s
v_2=p_2/m_2 #m/s

p_1
dp_1
dp_2
p_2
v_2

next
#problem 10
a_m=5.0 #g
a_vi=-20.0 #cm/s
b_m=10.0 #g
b_vi=-10.0 #cm/s
a_vf=-8.0 #cm/s
#p_1+p_2=p_1'+p_2'
#p=m*v
#a_m*@a_v=-b_m*@b_v
#delta=@
@a_v=a_vf-a_vi #cm/s
@b_v=(-(a_m*@a_v/b_m)) #cm/s
b_vf=b_vi+@b_v #cm/s
b_pf=b_vf*b_m #gcm/s
a_pi=a_vi*a_m #gcm/s
b_pi=b_vi*b_m #gcm/s
a_pf=a_vf*a_m #gcm/s
@a_p=a_pf-a_pi #gcm/s
@b_p=b_pf-b_pi #gcm/s

b_pf
b_vf
@a_p
@b_p

next
#problem 11
a_m=2575 #kg
a_vf=8.5 #m/s
b_m=825 #kg
b_vi=0 #m/s
b_vf=a_vf
@b_v=b_vf-b_vi
#a_m*@a_v=-b_m*@b_v
@a_v=-b_m*@b_v/a_m #m/s
a_vi=a_vf-@a_v

a_vi

next
#problem 12
a_m=15 / KILO #kg
b_m=5085 / KILO #kg
b_vi=0 #m/s
t_m=a_m+b_m
t_vf=1.2 #m/s
#a_m*a_vi=t_m*t_vf
a_vi=t_m*t_vf/a_m #m/s

a_vi

next
#problem 13
a_m=0.115 #kg
a_vi=35.0 #m/s
b_m=256 / KILO #kg
b_vi=0 #m/s
t_m=a_m+b_m
#a_m*a_vi=t_m*t_vf
t_vf=a_m*a_vi/t_m #m/s

t_vf

next
#problem 14
a_m=50 #kg
b_m=10 #kg
t_v=5.0 #m/s
t_m=a_m+b_m
a_vf=7.0 #m/s
#t_v*t_m=a_m*a_vf+b_m*b_vf
b_vf=(t_v*t_m-a_m*a_vf)/b_m #m/s

b_vf

next
#problem 15
a_m=92 #kg
a_vi=5.0 #m/s
b_m=75 #kg
b_vi=-2.0 #m/s
c_m=b_m
c_vi=-4.0 #m/s
t_m=a_m+b_m+c_m
a_p=a_m*a_vi #kgm/s
b_p=b_m*b_vi #kgm/s
c_p=c_m*c_vi #kgm/s
t_p=a_p+b_p+c_p
#t_p=t_m*t_vf
t_vf=t_p/t_m #m/s

t_vf

next
#problem 16
a_m=10.0 / KILO #kg
a_v=800 #m/s
b_v=-1.50 #m/s
#a_m*a_v=-b_m*b_v
b_m=-a_m*a_v/b_v #kg

b_m
