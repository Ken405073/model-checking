mtype={msg,req,rel,gr}
chan sr[3]=[8] of {mtype,byte,byte,byte}

byte t[3],clk[3],gl[3];
byte i;

active proctype P1(){
  byte x,n;
  chan q1= [4] of {byte};
  byte R1[1],I1[1],st1[3];
  R1[0]=1;
  I1[0]=1;
  st1[0]=1;st1[1]=2;st1[2]=3;
  clk[0]=clk[0]+1;
  gl[0]=1;
  t[0]=clk[0];
  for(i in R1[1])
      sr[i-1]!req,1,t[0],clk[0] 
  do
  ::q1?x->q1!!x
  do

    ::gl[0]>0||!(x%4==1&&x/4==t[0]) ->
        sr[0]?msg,i,t[i-1],clk[i-1];
        clk[0]=max(clk[0],clk[i-1])
s0:     if
        ::msg==req->goto s1;
        ::msg==rel->goto s2;
        ::msg==gr->goto s3;
        fi

s1:     x=4*t[i-1]+i;
        q1!!x;
        if
        ::!((t[0]<t[i-1])||(t[0]==t[i-1]&&1<i))->
          sr[i-1]!gr,1,t[0],clk[0];
          bool flag=true;
          for(j,0,2)
            if
            ::st1[j]==i->flag=flase;
            fi
          rof(j);
          if
          ::flag==true->q1??x,4*t[i-1]+i   
          fi

s2:   q1??x,4*t[i-1]+i

s3:   gl[0]=gl[0]-1;

  ::else->break




  printf("Critical Section P1\n");

  for(i in R1[1])
      sr[i-1]!rel,1,t[0],clk[0] ;

  for(x in q1)
      n=x/4;
      sr[n-1]!gr,1,t[0],clk[0];
      bool flag=true;
          for(j,0,2)
            if
            ::st1[j]==n->flag=flase;
            fi
          rof(j);
          if
          ::flag==true->q1??x,4*t[n-1]+n  
          fi
         

}


active proctype P2(){
  chan q1= [4] of {byte};
  byte y,n;
  byte R2[3],I2[2],st2[1];
  R2[0]=1;R2[1]=2;R2[2]=[3];
  I2[0]=1;I2[1]=2;
  st2[0]=2;
  clk[1]=0;
  clk[1]=clk[1]+1;
  gl[1]=3;
  t[1]=clk[1];
  for(i in R2[3])
      sr[i-1]!req,2,t[1],clk[1] 
     
    do
    ::q1?y->q1!!y

    do
    ::gl[1]>0|| !(y%4==1&&y/4==t[0])->
        sr[1]?msg,i,t[i-1],clk[i-1];
        clk[1]=max(clk[1],clk[i-1])
s0:     if
        ::msg==req->goto s1;
        ::msg==rel->goto s2;
        ::msg==gr->goto s3;
        fi

s1:     y=4*t[i-1]+i;
        q2!!y;
        if
        ::!((t[1]<t[i-1])||(t[1]==t[i-1]&&2<i))->
          sr[i-1]!gr,2,t[1],clk[1];
          if
          ::st2[0]!=i->q2??y,4*t[i-1]+i
          fi

s2:     q2??y,4*t[i-1]+i

s3:     gl[1]=gl[1]-1;

  ::else->break

  printf("Critical Section P1\n");

  for(i in R2[3])
      sr[i-1]!rel,2,t[1],clk[1];
      

  for(y in q2)
      n=y/4;
      sr[n-1]!gr,1,t[0],clk[0];
      bool flag=true;
          for(j,0,2)
            if
            ::st1[j]==n->flag=flase;
            fi
          rof(j);
          if
          ::flag==true->q2??y,4*t[n-1]+n  
          fi

}


active proctype P3(){
  byte z,n;
  chan q3=[4] of {byte}
  byte R3[3],I3[2],st3[3];
  R3[0]=1;R3[1]=2;R3[2]=3;
  I3[0]=1;I3[1]=3
  st3[0]=3;
  clk[2]=0;
  clk[2]=clk[2]+1;
  gl[2]=3;
  t[2]=clk[2];
  for(i in R3[3])
      sr[i-1]!req,3,t[2],clk2  
  do


    ::q1?z->q1!!z

    do
    ::gl[2]>0|| !(z%4==1&&z/4==t[0]) ->
        sr[2]?msg,i,t[i-1],clk[i-1];
        clk[2]=max(clk[2],clk[i-1])
s0:     if
        ::msg==req->goto s1;
        ::msg==rel->goto s2;
        ::msg==gr->goto s3;
        fi

s1:      z=4*t[i-1]+i;
         q2!!z;

        if
        ::!((t[2]<t[i-1])||(t[2]==t[i-1]&&3<i))->
          sri[!-1]gr,3,t[2],clk[2];
          if
          ::st3[0]!=i->q2??z,4*t[i-1]+i
          fi

s2:     q2??z,4*t[i-1]+i

s3:     gl[2]=gl[2]-1;

  ::else->break

  printf("Critical Section P1\n");

  for(i in R1[1])
      sr[i-1]!rel,3,t[2],clk[2]

  for(z in q2)
      n=z/4;
      sr[n-1]!gr,1,t[0],clk[0];
      bool flag=true;
          for(j,0,2)
            if
            ::st1[j]==n->flag=flase;
            fi
          rof(j);
          if
          ::flag==true->q2??z,4*t[n-1]+n  
          fi

}



