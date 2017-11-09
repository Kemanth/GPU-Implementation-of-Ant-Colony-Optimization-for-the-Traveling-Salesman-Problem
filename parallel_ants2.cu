#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <curand_kernel.h>
#include <math.h>

#define MAX_CITIES 5000
#define MAX_ANTS 5000
#define QVAL 100
#define ALPHA 1.0
#define BETA 5.0 
#define RHO 0.5 

using namespace std;

struct cities
{
	int x,y;
};
struct ants{
	
	int curCity, nextCity, pathIndex;
	int visited[MAX_CITIES];
	int path[MAX_CITIES];
	double tourLength;
};

int n=0;
cities city[MAX_CITIES];
float pheromone[MAX_CITIES][MAX_CITIES];
float dist[MAX_CITIES][MAX_CITIES];
ants ant[MAX_ANTS];
float best=(double)999999;
int bestIndex;

__global__ void initialize(float *dist, float *pheromone, ants *ant,cities *city,int n){
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	if((row<n)&&(col<n)){
	
		dist[col + row * n] = 0.0f;
		pheromone[col + row * n] = 1.0 / n;
		if(row!=col)
		{
			dist[col + row * n]=sqrt(powf(abs(city[row].x-city[col].x),2)+powf(abs(city[row].y-city[col].y),2));
			dist[col + row * n]=dist[col + row * n];
		}
		ant[row].visited[col]=0;
		ant[row].path[col]=-1;
		if(col==0){
			ant[row].curCity=row;
			ant[row].pathIndex = 1;
			ant[row].path[0] = ant[row].curCity;
			ant[row].nextCity = -1;
			ant[row].tourLength = 0;
			ant[row].visited[ant[row].curCity]=1;
		}
	}
}

double fitness(int i, int j)
{
	return(( pow( pheromone[i][j], ALPHA) * pow( (1.0/ dist[i][j]), BETA)));
}

int selectNextCity(int k,int n)
{
	int i = ant[k].curCity;
	int j;
	double prod=0.0;
	for(j=0;j<n;j++)
	{
		if(ant[k].visited[j]==0)
		{
			prod+= fitness(i,j);
		}
	}
	
	while(1)
	{
		j++;
		
		if(j >= n)
			j=0;
		if(ant[k].visited[j] == 0)
		{
			double p = fitness(i,j)/prod;
			double x = ((double)rand()/RAND_MAX); 
			
			if(x < p)
			{
				break;
			}
		}
	}
	
	return j;
}

int tourConstruction()
{
	int movement=0;
	
	for(int i=0;i<n;i++)
	{
		if(ant[i].pathIndex < n)
		{
			ant[i].nextCity = selectNextCity(i,n);
			ant[i].visited[ant[i].nextCity]=1;
			ant[i].path[ant[i].pathIndex]=ant[i].nextCity;
			ant[i].pathIndex++;
			ant[i].tourLength+=dist[ant[i].curCity][ant[i].nextCity];
			
			if(ant[i].pathIndex == n)
			{//changed here
				ant[i].tourLength+=dist[ant[i].path[n-1]][ant[i].path[0]];
			}
			ant[i].curCity = ant[i].nextCity;
			movement++;
		}
	}
	return movement;
}

int updatePheromones()
{
	for(int i=0;i<n;i++)
	{
		for(int j=0;j<n;j++)
		{
			if(i!=j)
			{
				pheromone[i][j] *=( 1.0 - RHO);
				
				if(pheromone[i][j]<0.0)
				{
					pheromone[i][j] = (1.0/n);
				}
			}
		}
	}
	int a,b;
	for(int i=0;i<n;i++)
	{
		for(int j=0;j<n;j++)
		{
			if(j==n-1)
			{
				a=ant[i].path[j];
				b=ant[i].path[j+1];
			}
			else
			{
				a=ant[i].path[j];
				b=ant[i].path[0];
			}
			
			pheromone[a][b]+=(QVAL)/ant[i].tourLength;
			pheromone[b][a]+=pheromone[a][b];
		}
	}
}

void reDeployAnts()
{
	int visit=0;
	for(int i=0;i<n;i++)
	{
		if(ant[i].tourLength < best)
		{
			best = ant[i].tourLength;
			bestIndex = i;
			break;
		}
		if(i==n)
			visit=0;
		ant[i].curCity=visit++;
		for(int j=0;j<n;j++)
		{
			ant[i].visited[j]=0;
			ant[i].path[j]=-1;
		}
		ant[i].pathIndex = 1;
		ant[i].path[0] = ant[i].curCity;
		ant[i].nextCity = -1;
		ant[i].tourLength = 0;
		ant[i].visited[ant[i].curCity]=1;
	}
}

int main(int argc, char *argv[])
{	if (argc > 1){
		cout << "Reading File "<< argv[1]<<endl;
	}
	else{
		cout << "Usage:Progname inputFileName" << endl;
		return 1;
	}
	ifstream in;
    	in.open(argv[1]);
	in>>n;
	cout<<n<<endl;
	int num;
	for(int i=0;i<n;i++)
	{
		in>>num;	
		in>>city[i].x;
		in>>city[i].y;
		cout<<city[i].x<<" "<<city[i].y<<" "<<endl;	
	}
	dim3 blockDim(1024, 1024, 1);
	dim3 gridDim((n - 1)/ 1024 + 1, (n - 1)/ 1024 + 1, 1 );
	float *d_dist,*d_pheromone;
	ants *d_ant;
	cities *d_city;
	cudaMalloc((void**)&d_pheromone, sizeof(float) * n * n);
	cudaMalloc((void**)&d_dist, sizeof(float) * n * n);
	cudaMalloc((void**)&d_ant, sizeof(ants) * n);
	cudaMalloc((void**)&d_city, sizeof(cities) * n);
	cudaMemcpy(d_city,city,sizeof(cities) * n,cudaMemcpyHostToDevice);
	initialize<<<gridDim,blockDim>>>(d_dist,d_pheromone,d_ant,d_city,n);
	
	/*
	initialize();
	int MAX_TIME = 20 * n;
	for(int i=0;i<MAX_TIME;i++)
	{
		if( tourConstruction() == 0)
		{
			updatePheromones();
			
			if(i != MAX_TIME)
				reDeployAnts();
				
			cout<<"\n Time is "<<i<<"("<<best<<")";
			
		}
	}
	cout<<endl;
	for(int i=0;i<n;i++)
	{
		cout<<ant[bestIndex].path[i]<<" ";
	}
	cout<<endl;
	cout<<"\nSACO: Best tour = "<<best<<endl<<endl<<endl;
	*/
	return 0;
}

