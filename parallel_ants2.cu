#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>
#include<curand_kernel.h>
#include<curand.h>

#define MAX_CITIES 318	
#define MAX_ANTS 318		
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
int best=999999;
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
		d_pheromone[col + row * n] = 1.0f / n;
		d_delta[col + row * n] = 0.0f;
		if(row!=col)
		{
			d_dist[col + row * n]=sqrt(powf(abs(d_city[row].x-d_city[col].x),2)+powf(abs(d_city[row].y-d_city[col].y),2));
			
		}
	}
}

__global__ void setup_curand_states(curandState *state_d,int t){
	
	int id = threadIdx.x + blockIdx.x*blockDim.x;
	curand_init(t, id, 0, &state_d[id]);
}

__device__ float generate(curandState* globalState, int ind){
    //int ind = threadIdx.x;
    curandState localState = globalState[ind];
    float RANDOM = curand_uniform( &localState );
    globalState[ind] = localState;
    return RANDOM;
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
			float p = d_fitness[i*n+j]/prod;
			float x = (float)generate(state_d,i); 
			
			if(x < p)
			{
				break;
			}
		}
	}
	
	return j;
}

__global__ void tourConstruction(ants *d_ant, float *d_dist, float *d_fitness,int n,curandState *state_d)
{	//printf("tour contruction\n");
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
__global__
void wrapUpTour(float *delta, ants *ant,float *dist, int *best, int *bestIndex){
	//printf("wrap tour\n");
	int k = threadIdx.x + blockIdx.x * blockDim.x;
	if(k < MAX_ANTS){
		ant[k].L += dist[ant[k].curCity * MAX_CITIES + ant[k].tabu[0]];
		ant[k].curCity = ant[k].tabu[0];
		
		int temp = *best;
		printf("before best %d\n", *best);
		atomicMin(best, ant[k].L);
		printf("after best %d\n", *best);
		if (*best!= temp){
			*bestIndex = k;
		}
		for(int i = 0; i < MAX_CITIES;i++){
			int first = ant[k].tabu[i];
			int second = ant[k].tabu[(i + 1) % MAX_CITIES];
			delta[first * MAX_CITIES + second] += Q/ant[k].L;
		}
	}
	
}
__global__ void updatePheromone(float *d_pheromone, float *d_delta, int n){

	//printf("inside update phero\n");
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if(id < n){
		for(int s=0;s<n;s++){
			if(id!=s)
			{
				d_pheromone[id*n+s] *=( 1.0 - RHO);
				
				if(d_pheromone[id*n+s]<0.0)
				{
					d_pheromone[id*n+s] = (1.0/n);
				}
			}
			d_pheromone[id*n+s] += d_delta[id*n+s];
			d_delta[id*n+s] = 0;	
		}
	}
}
__global__ void emptyTabu(ants *d_ant,float *d_delta,int n){
	
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	
	if(id < n){
		//printf("Empty Tabu\n");
		for(int s=0;s<n;s++){		
			d_ant[id].tabu[s] = 0;
			d_ant[id].visited[s] = 0;
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
	int *d_best, *d_bestIndex;
	cudaMalloc((void**)&d_pheromone, sizeof(float) * n * n);
	cudaMalloc((void**)&d_dist, sizeof(float) * n * n);
	cudaMalloc((void**)&d_delta, sizeof(float) * n * n);
	cudaMalloc((void**)&d_ant, sizeof(ants) * n);
	cudaMalloc((void**)&d_city, sizeof(cities) * n);
	cudaMalloc((void**)&d_fitness, sizeof(float) * n *n);
	cudaMalloc( (void**) &state_d, sizeof(state));
	cudaMalloc((void **)&d_best, sizeof(int));
	cudaMalloc((void **)&d_bestIndex, sizeof(int));
	cudaMemcpy(d_city,city,sizeof(cities) * n,cudaMemcpyHostToDevice);
	srand(time(0));
        cudaMemcpy(d_best, &best, sizeof(int), cudaMemcpyHostToDevice);	
	int seed = rand();
	setup_curand_states <<< (n-1)/32+1,32 >>> (state_d,seed);
	initialize<<<gridDim, blockDim>>>(d_dist,d_pheromone,d_delta,d_city,n);
	cudaMemcpy(dist,d_dist,sizeof(float) * n * n,cudaMemcpyDeviceToHost);
	cudaMemcpy(pheromone,d_pheromone,sizeof(float) * n * n,cudaMemcpyDeviceToHost);
	cudaMemcpy(delta,d_delta,sizeof(float) * n * n,cudaMemcpyDeviceToHost);
	int MAX_TIME = 20;
	for(;;)
	{		
		initTour<<<(n-1)/32+1,32>>>(d_ant,n);
		cudaThreadSynchronize();
		calcFitness<<< gridDim, blockDim>>>(d_fitness, d_dist, d_pheromone, n);
		cudaThreadSynchronize();
		tourConstruction<<<(n-1)/32+1,32>>>(d_ant,d_dist,d_fitness,n,state_d);
		cudaThreadSynchronize();
		cudaMemcpy(ant,d_ant,sizeof(ants) * n,cudaMemcpyDeviceToHost);
		wrapUpTour<<<(n - 1)/32 + 1, 32>>>(d_delta, d_ant, d_dist, d_best, d_bestIndex);
		updatePheromone<<< (n-1)/32+1,32>>>(d_pheromone,d_delta,n);
		cudaThreadSynchronize();
		t += MAX_ANTS;
		NC += 1;
		if(NC < MAX_TIME){
			emptyTabu<<<(n-1)/32+1,32>>>(d_ant,d_delta,n);
			cudaMemcpy(&best, d_best, sizeof(int), cudaMemcpyDeviceToHost);
			cout<<"Best Tour so far -->  "<<best<<endl;
			cudaThreadSynchronize();
		}
		else{
			break;
		}
	}
	cout<<endl;
	cudaMemcpy(&best, d_best, sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(&bestIndex, d_bestIndex, sizeof(int), cudaMemcpyDeviceToHost);

	for(int i=0;i<n;i++)
	{
		cout<<ant[bestIndex].tabu[i]<<" ";
	}
	cout<<endl;
	cout<<"\nSACO: Best tour = "<<best<<endl<<endl<<endl;
	return 0;
}

