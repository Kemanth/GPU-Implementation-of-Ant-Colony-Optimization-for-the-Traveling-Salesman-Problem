#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>
#include<curand_kernel.h>

#define MAX_CITIES 48 
#define MAX_ANTS 48			
#define Q 100
#define ALPHA 1.0
#define BETA 5.0 
#define RHO 0.5 

using namespace std;

int n=0;
int NC = 0;
int t = 0;
struct cities
{
	int x,y;
};
int s;
struct ants{
	
	int curCity, nextCity;
	int visited[MAX_CITIES];
	int tabu[MAX_CITIES];
	float L;
};

cities city[MAX_CITIES];
float pheromone[MAX_CITIES][MAX_CITIES];
float dist[MAX_CITIES][MAX_CITIES];
ants ant[MAX_ANTS];
float best=(double)999999;
int bestIndex;
float delta[MAX_CITIES][MAX_CITIES];
float fitness[MAX_CITIES][MAX_CITIES];
curandState  state[MAX_ANTS];


__global__ void initialize(float *d_dist,float *d_pheromone,float *d_delta,cities *d_city,int n)
{	
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	if((row<n)&&(col<n)){
	
		d_dist[col + row * n] = 0.0f;
		d_pheromone[col + row * n] = 1.0 / n;
		d_delta[col + row * n] = 0.0f;
		if(row!=col)
		{
			d_dist[col + row * n]=sqrt(powf(abs(d_city[row].x-d_city[col].x),2)+powf(abs(d_city[row].y-d_city[col].y),2));
			
		}
	}
}

__global__ void setup_curand_states(curandState *state_d, unsigned long t){
	
	int id = threadIdx.x + blockIdx.x*blockDim.x;
	curand_init(t, id, 0, &state_d[id]);
}

__global__ void initTour(ants *d_ant,int n){
	//cout << "inside init tour" << endl;
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if(id<n){
		int j = id;
		d_ant[id].curCity = j;
		for(int i=0;i<n;i++)
		{
			d_ant[id].visited[i]=0;
		}
		d_ant[id].visited[j] = 1;
		d_ant[id].tabu[0] = j;
		d_ant[id].L = 0.0;
	}
}

__global__ void calcFitness(float *d_fitness, float *d_dist, float *pheromone, int n){
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	if(row < n && col < n){
		int id = row * n + col;
		d_fitness[id] =  powf( pheromone[id], ALPHA) * powf( (1.0/ d_dist[id]), BETA);
	}
}

__device__ int selectNextCity(int k,int n,float *d_fitness,ants *d_ant,curandState *state_d)
{	//cout<<"next city"<<endl;
	int i = d_ant[k].curCity;
	int j;
	double prod=0.0;
	for(j=0;j<n;j++)
	{
		if(d_ant[k].visited[j]==0)
		{
			prod+= d_fitness[i*n+j];
		}
	}
	
	while(1)
	{
		j++;
		if(j >= n)
			j=0;
		if(d_ant[k].visited[j] == 0)
		{
			double p = d_fitness[i*n+j]/prod;
			double x = ((double)(curand(&state_d[k])% 1000000000000000000)/1000000000000000000); 
			
			if(x < p)
			{
				break;
			}
		}
	}
	
	return j;
}

__global__ void tourConstruction(ants *d_ant, float *d_dist, float *d_fitness,int n,curandState *state_d)
{	//cout<<"tourConstruc"<<endl;
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if(id < n){
		for(int s=1;s<n;s++)
		{	
		
			int j = selectNextCity(id, n, d_fitness,d_ant,state_d);	
			d_ant[id].nextCity = j;
			d_ant[id].visited[j]=1;
			d_ant[id].tabu[s] = j;			
			d_ant[id].L+=d_dist[d_ant[id].curCity * n + j];
			d_ant[id].curCity = j;
		}
	}
}
void wrapUpTour(){
	//cout<<"wrapup"<<endl;
	for(int k = 0; k < MAX_ANTS;k++){
		ant[k].L += dist[ant[k].curCity][ant[k].tabu[0]];
		ant[k].curCity = ant[k].tabu[0];
		
		if(best > ant[k].L){
			best = ant[k].L;
			bestIndex = k;
		}
	}
}
void updatePheromone(){
	//cout<<"update"<<endl;
	for(int i =0;i<n;i++)
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
			pheromone[i][j] += delta[i][j];
			delta[i][j] = 0;
		}
	}
	t += MAX_ANTS;
	NC += 1;
}
void emptyTabu(){
	cout<<"emptytabu"<<endl;
	for(int k = 0;k<MAX_ANTS;k++){
		for(int i = 0; i < MAX_CITIES;i++){
			ant[k].tabu[i] = 0;
			ant[k].visited[i] = 0;
			int first = ant[k].tabu[i];
			int second = ant[k].tabu[(i + 1) % MAX_CITIES];
			delta[first][second] += Q/ant[k].L;
		}
	}
}

int main(int argc, char *argv[])
{	if (argc > 1){
		cout << "Reading File "<< argv[1]<<endl;
	}
	else{
		cout << "Usage:progname inputFileName" <<endl;
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
	
	dim3 blockDim(32, 32, 1);
	dim3 gridDim((n - 1)/ 32 + 1, (n - 1)/ 32 + 1, 1 );
	float *d_dist,*d_pheromone,*d_delta,*d_fitness;
	ants *d_ant;
	cities *d_city;
	curandState  *state_d;
	cudaMalloc((void**)&d_pheromone, sizeof(float) * n * n);
	cudaMalloc((void**)&d_dist, sizeof(float) * n * n);
	cudaMalloc((void**)&d_delta, sizeof(float) * n * n);
	cudaMalloc((void**)&d_ant, sizeof(ants) * n);
	cudaMalloc((void**)&d_city, sizeof(cities) * n);
	cudaMalloc((void**)&d_fitness, sizeof(float) * n *n);
	cudaMalloc( (void**) &state_d, sizeof(state));
	cudaMemcpy(d_city,city,sizeof(cities) * n,cudaMemcpyHostToDevice);
	time_t t; 
	time(&t);
	setup_curand_states <<< (n-1)/32+1,32 >>> (state_d, (unsigned long) t);
	initialize<<<gridDim, blockDim>>>(d_dist,d_pheromone,d_delta,d_city,n);
	cudaMemcpy(dist,d_dist,sizeof(float) * n * n,cudaMemcpyDeviceToHost);
	cudaMemcpy(pheromone,d_pheromone,sizeof(float) * n * n,cudaMemcpyDeviceToHost);
	cudaMemcpy(delta,d_delta,sizeof(float) * n * n,cudaMemcpyDeviceToHost);
	int MAX_TIME = 20;
	for(;;)
	{		
		initTour<<<(n-1)/32+1,32>>>(d_ant,n);
		calcFitness<<< gridDim, blockDim>>>(d_fitness, d_dist, d_pheromone, n);
		tourConstruction<<<(n-1)/32+1,32>>>(d_ant,d_dist,d_fitness,n,state_d);
		cudaMemcpy(ant,d_ant,sizeof(ants) * n,cudaMemcpyDeviceToHost);
		wrapUpTour();
		updatePheromone();
		if(NC < MAX_TIME){
			emptyTabu();
		}
		else{
			break;
		}
	}
	cout<<endl;
	for(int i=0;i<n;i++)
	{
		cout<<ant[bestIndex].tabu[i]<<" ";
	}
	cout<<endl;
	cout<<"\nSACO: Best tour = "<<best<<endl<<endl<<endl;
	return 0;
}

