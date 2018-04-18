byte i,t,gl[3],rc[3] // process,time,grant_left,running count
mtype = { req, rel, gr } // msgs from processes are request release grant
chan sr = [0] of { mtype, byte, byte } // send and receive request
chan que = [3] of { mtype, byte, byte } // request queue

active proctype p1()	// process1
{
	sr!req,1,t
	gl[0]=3
S1:	if 
	:: gl[0]>0
		if
		:: sr?req,1,t->goto S2
		:: sr?rel,i,t->goto S3
		:: sr?gr,2,t->goto S4
		:: sr?gr,3,t->goto S4
		:: else
		fi
	:: else
	skip
S2:	que!req,1,t
S3:	skip
S4:	gl[0]--
}

active proctype p2()	// process2
{
	sr!req,2,t
	gl[1]=3
S1:	if 
	:: gl[1]>0
		if
		:: sr?req,2,t->goto S2
		:: sr?rel,2,t->goto S3
		:: sr?gr,1,t->goto S4
		:: sr?gr,3,t->goto S4
		:: else
		fi
	:: else
	skip
S2:	que!req,2,t
S3:	skip
S4:	gl[1]--
}

active proctype p3()	// process1
{
	sr!req,3,t
	gl[2]=3
S1:	if 
	:: gl[2]>0
		if
		:: sr?req,3,t->goto S2
		:: sr?rel,3,t->goto S3
		:: sr?gr,1,t->goto S4
		:: sr?gr,2,t->goto S4
		:: else
		fi
	:: else
	skip
S2:	que!req,3,t
S3:	skip
S4:	gl[2]--
}

active proctype cs()  // CS
{
S1:	if
	:: que?req,1,t -> goto S2
	:: que?req,2,t -> goto S3
	:: que?req,3,t -> goto S4
	:: else
	fi
S2:	rc[0] = 0
	rc[1]++
	rc[2]++
	t++
	sr!rel,1,t
	sr!gr,1,t
	goto S1
S3:	rc[0]++
	rc[1] = 0
	rc[2]++
	t++
	sr!rel,2,t
	sr!gr,2,t
	goto S1
S4:	rc[0]++
	rc[1]++
	rc[2] =0
	t++
	sr!rel,3,t
	sr!gr,3,t
	goto S1
}
