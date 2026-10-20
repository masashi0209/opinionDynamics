#include<stdio.h>
#include "random.h"


/***********************************
Note on random-number generation: The function urand() should return a uniformly distributed random number between 0 and 1. 
The original C implementation used ran1() from Numerical Recipes in C.
Its source code is not included here because it is copyrighted. Users should replace urand() with an appropriate random-number generator available in their environment.
************************************/


#define L 51 // space size
#define TL 0.02
#define N_INDIV 10 //population size

void mutation(int P_Opinion[], int Location[], double m_rate)
{
	int m, position;
	double rnd, rnd2;
	
	
	for(m = 0; m < N_INDIV; m++){
		position = P_Opinion[m];
		if(position == 0){
			rnd = urand();
			if(rnd < m_rate){
				P_Opinion[m]++;
				Location[position]--;
				Location[position + 1]++;
				
			}
		} else if(position == L-1){
			rnd = urand();
			if(rnd < m_rate){
				P_Opinion[m]--;
				Location[position]--;
				Location[position - 1]++;
			}
		} else {
			rnd = urand();
			if(rnd < m_rate){
				rnd2 = urand();
				if(rnd2<0.5){
					P_Opinion[m]++;
					Location[position]--;
					Location[position + 1]++;
					
				} else {
					P_Opinion[m]--;
					Location[position]--;
					Location[position - 1]++;
				}
			}
		}
	}
}

int main()
{
	int i, j, l, nop, m, t, one_t;
	int Location[L], NextLocation[L]; // population size at opinion location L
	int P_Opinion[N_INDIV], opSelection[3];
	double a, c, x, xm, w, m_rate, prb, tUse, socialCost, expSC, beta_m, beta_i, beta_o, sumFit;
	double rtCost, ri, ro, rm, r, totalWeight, fmin;
	double Fw[L], usage[L], benefit[L], LocationFit[L], weight[L], cumulative[L];
	
	// parameters 
	a = 1.0;
	c = 1.0;
	w = 0.01;
	
	xm = 5.0; //maximum size of x
	
	m_rate = 0.000001;
	
	for(i=0; i<L; i++){
		usage[i] = xm*TL*(double)i;
		x = usage[i];
		Fw[i]=exp(-w*x);
		benefit[i] = exp(a*x);
	}
	
	// set individuals
	for(m = 0; m < N_INDIV; m++){
		P_Opinion[m] = 0;//initially, opinion of all individuals is at location 0, this must be between 0 and L
	}
			
	// initial state
	for(i=0; i<L; i++) Location[i] = 0; //no one in this space
	for(m = 0; m < N_INDIV; m++){
		i = P_Opinion[m];
		Location[i] ++;
	}
	
	for(t=0; t<100; t++){
		
		for(one_t = 0; one_t<1000000; one_t++){
			
			tUse = 0;
			for(l = 0; l<L; l++){
				tUse += Location[l] * usage[l];
			}
			tUse /= (double)N_INDIV;
			
			socialCost = c * tUse * tUse;
			expSC = exp(-socialCost);
			
			rm = 0;
			beta_m = 0;
			for(l=0; l<L; l++){
				rm += benefit[l] * expSC * (double)Location[l];
				beta_m += Fw[l] * (double)Location[l];
			}
			rm /= (double)N_INDIV;
			beta_m /= (double)N_INDIV;
			
			
			for(l=0; l<L; l++){
				LocationFit[l] = 0;
			}

			for(l = 0; l<L; l++){
				// in flow of Location[l] by benefit
				ri = benefit[l]*expSC;
				// out flow of Location[i]
				ro = rm;//*Location[l];
				//net flow
				LocationFit[l] = ri- ro;
				// in flow of Location[l] by interaction
				beta_i = Fw[l];
				// out flow of  Location[i]
				beta_o = beta_m;
				//total net flow
				LocationFit[l] += socialCost*(beta_i - beta_o);
			}
			
			int focal, model;
			int xf, xm;
			double diff;
			double p;
			double selection_scale;
			
			/* scale parameter to make p <= 1 */
			selection_scale = 0.01;
			
			focal = (int)(N_INDIV * urand());
			model = (int)(N_INDIV * urand());
			
			if(focal != model){
				
				xf = P_Opinion[focal];
				xm = P_Opinion[model];
				
				diff = LocationFit[xm] - LocationFit[xf];
				
				if(diff > 0.0){
					p = selection_scale * diff;
					
					if(p > 1.0) p = 1.0;
					
					if(urand() < p){
						Location[xf]--;
						Location[xm]++;
						
						P_Opinion[focal] = xm;
					}
				}
			}
						
			mutation(P_Opinion, Location, m_rate);
			

		} //one_t
		
		for(l = 0; l<L; l++){
			printf("%d ", Location[l]);
		}
		printf("\n");

	}
	return 0;
}
	
