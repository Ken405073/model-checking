/* Information structure for this model, R1=={1,2}, R2=={1,2}, I1==I2==emptyset */

mtype={req,gr}; /* request, release, grant */
chan sr[2]=[8] of {mtype,byte,byte,byte}  /* a channel dedicated for one process to receive a packet
                                           * of the form {message type, process i, current time t, clk} */

byte t[2],clk[2],gl[2]; /* current time, clk, grants left */
byte mutex;

/** The first task is to verify mutual exclusion */

active proctype P1(){

  chan tmp = [8] of {short};
  chan q1 = [8] of {short};  /* the priority queue used for sorting (t, u) pairs, 
                             * (t_1,u_1)>(t_2,u_2) iff t_1*4+u_1< t_2*4+u_2 --- that is, smaller time, higher priority
                             * we encode t and u in a single short, by shifting t left by 2 then add u */
  byte R1[2];               /* request set for process 1, which contains 1 & 2 */
  R1[0]=1;
  R1[1]=2;
  byte i, j, head, r, u, c;
  mtype msg;
  short item;

  /* initialization */
  clk[0]=0;

  for(i : 0 .. 1){  /* to run the protocol 2 times, assuming it doesn't overflow clk[0] and t[0] */
    clk[0]++;
    gl[0]=2;   /* grants left */
    t[0]=clk[0];
    for(j in R1){  /* sending requests to all agents in the request set R1 */
      sr[R1[j]-1]!req,1,t[0],clk[0] 
    }

    /* we model it as a do-while loop instead of a while loop */
L1:
    sr[0]?msg,r,u,c;
    
    if
      :: c>clk[0] -> clk[0] = c /* update local clock */
      :: else -> skip
    fi
    if
      ::msg==req ->
        /*q1!!u*4+r; q1!! is a sorted send, so that messages are numerically ordered in q1 */
        head=u*4+r;
        if
        :: head<=t[0]*4+1 -> sr[head%4-1]!gr,1,head/4,clk[0] /* if head has higher priority, send out a grant*/
           if
           ::head%4==1 -> q1!head /* if r in St1, we add it into the priority queue, 
                                   * this is more efficient than first inserting (r,u) then removing the pair */
           ::else -> skip
           fi        
        :: else -> q1!head
        fi
      ::msg==gr -> gl[0]--
    fi
    q1?head; /* to test if the head of q1 is t[0]*4 + 1 */
    if
      :: t[0]*4+1==head ->
        if
        :: gl[0]==0 -> goto CS1 /* all grants received */
        :: else -> skip
        fi 
      :: else -> skip
    fi
    q1!!head;
    goto L1;
CS1: /* critical section */
    mutex++;
    mutex--;

    /* next we send grant messages for all request messages remaining in q1
     * and only remove the request when it's not in St1 */
    do
      ::empty(q1)-> break;
      ::q1?item -> 
          sr[item%4-1]!gr,1,item/4,clk[0]
          if /*if item%4 is not in St1, remove that from q1, that is, not to copy it to tmp */
          ::item%4 != 1 -> tmp!item
          ::else -> skip
          fi
    od
      /* then we move everything back to q1 from tmp */
    do
      ::empty(tmp)->break;
      ::tmp?item -> q1!item
    od

  }
}

active proctype P2(){

  chan tmp = [8] of {short};
  chan q2 = [8] of {short};  /* the priority queue used for sorting (t, u) pairs, 
                             * (t_1,u_1)>(t_2,u_2) iff t_1*4+u_1< t_2*4+u_2 --- that is, smaller time, higher priority
                             * we encode t and u in a single short, by shifting t left by 2 then add u */
  byte R2[2];               /* request set for process 1, which contains 1 & 2 */
  R2[0]=1;
  R2[1]=2;
  byte i, j, head, r, u, c;
  mtype msg;
  short item;

  clk[1]=0;

  /* no need to define the singleton sets I2={2} and St2={2} */

  for(i : 0 .. 1){  /* to run the protocol 2 times, assuming it doesn't overflow clk[1] and t[1] */
    clk[1]++;
    gl[1]=2;   /* grants left */
    t[1]=clk[1];
    for(j in R2){  /* sending requests to all agents in the request set R2 */
      sr[R2[j]-1]!req,2,t[0],clk[0] 
    }
    /* we model it as a do-while loop instead of a while loop */
L2:
    sr[1]?msg,r,u,c;
    if
      :: c>clk[1] -> clk[1] = c /* update local clock */
      :: else -> skip
    fi
    if
      ::msg==req ->
        /*q2!!u*4+r; q2!! is a sorted send */
        head=u*4+r;
        if
        :: head<=t[1]*4+2 -> sr[head%4-1]!gr,2,head/4,clk[0] /* if head has higher priority, send out a grant*/
           if
           :: head%4==2 -> q2!head /* if r in St2, we add it into the priority queue, 
                                   * this is more efficient than first inserting (r,u) then removing the pair */
           :: else -> skip
           fi        
        :: else -> q2!head
        fi
     
      ::msg==gr -> gl[1]--
        
    fi
    q2?head; /* to test if the head of q2 is t[0]*4 + 2 */
    if
      :: t[1]*4+2==head ->
        if
        :: gl[1]==0 -> goto CS2 /* all grants received */
        :: else -> skip
        fi 
      :: else -> skip
    fi
    q2!!head;
    goto L2;
CS2: /* critical section */
    mutex++;
    mutex--;

    /* next we send grant messages for all request messages remaining in q2
     * and only remove the request when it's not in St2 */
    do
      ::empty(q2)-> break;
      ::q2?item -> 
          sr[item%4-1]!gr,2,item/4,clk[1]
          if /*if item%4 is not in St2, remove that from q2, that is, not to copy it to tmp */
          ::item%4 != 2 -> tmp!item
          ::else -> skip
          fi
    od
      /* then we move everything back to q1 from tmp */
    do
      ::empty(tmp)->break;
      ::tmp?item -> q2!item
    od

  }
}
    
ltl {[] (mutex < 1)}

