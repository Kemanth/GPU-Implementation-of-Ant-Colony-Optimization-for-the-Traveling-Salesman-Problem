#include <stdio.h>
#include <iostream>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

using namespace std;
using namespace thrust;

const int MAX_CITIES = 0;
const int MAX_ANTS = 0;
const int MAX_TIME = 0;
const int QVAL = 100
const float ALPHA = 1.0f;
const float BETA 5.0f; 
const float RHO 0.5f;

struct cities{
	int x, y;	//holds the coordinates of the city
};

struct ants{
	int curCity, nextCity, pathIndex;
	int visited[MAX_CITIES];
	int path[MAX_CITIES];
	float tourLength;
};

int n = 0;
host_vector<cities> h_city(MAX_CITIES);
host_vector< host_vector<float> > h_pheromone(MAX_CITIES, host_vector<float> (MAX_CITIES));
host_vector< host_vector<float> > h_dist(MAX_CITIES, host_vector<float>(MAX_CITIES));
host_vector<ants> h_ant(MAX_ANTS);
float best = (float)999999;
int bestIndex;

device_vector<cities> city(MAX_CITIES);
device_vector< device_vector<float> > pheromone(MAX_CITIES, device_vector<float> (MAX_CITIES));
device_vector< device_vector<float> > dist(MAX_CITIES, device_vector<float>(MAX_CITIES));
device_vector<ants> ant(MAX_ANTS);

//raw pointers to device memory
cities *d_city = raw_pointer_cast(&city[0]);
float *d_pheromone = raw_pointer_cast(&pheromone[0][0]);
float *d_dist = raw_pointer_cast(&dist[0][0]);
ants *d_ant = raw_pointer_cast(&ant[0]);


/*<----Initializes the const variables----->*/
void initConstants(){
	MAX_ANTS = MAX_CITIES = n;
	MAX_TIME = 20 * MAX_CITIES;

}

/*incomplete initialize*/
__global__
void initialize(float *d_dist, float *d_pheromone, ants *d_ant, cities *int n){
	col = blockIdx.x * blockDim.x + threadIdx.x;
	row = blockIdx.y * blockDim.y + threadIdx.y;
	if((row<n)&&(col<n)){
	
		d_dist[col + row * n] = 0.0f;
		d_pheromone[col + row * n] = 1.0 / n;
		if(row!=col)
		{
			dist[col + row * n]=sqrt(pow(abs(city[row].x-city[col].x),2)+pow(abs(city[row].y-city[col].y),2));
			dist[col + row * n]=dist[col + row * n];
		}
		visit=0;
		if(i==n)
			visit=0;
		ant[i].curCity=visit++;
		ant[i].visited[j]=0;
		ant[i].path[j]=-1;
		ant[i].pathIndex = 1;
		ant[i].path[0] = ant[i].curCity;
		ant[i].nextCity = -1;
		ant[i].tourLength = 0;
		ant[i].visited[ant[i].curCity]=1;
	}
}


int main(int argc, char *argv[]){
	if (argc < 2){
		cout << "Usage: executable_name input_file_name" << endl;
	}
	ifstream in;
	in.open(argv[1]);
	in >> n;
	cout << "No of cities: " << n << endl;
	initConstants();		
	for(int i=0;i<n;i++)
	{
		in>>num;	
		in>>h_city[i].x;
		in>>h_city[i].y;
		cout<<h_city[i].x<<" "<<h_city[i].y<<" "<<endl;

	}
	in.close();

	city = h_city;
	int h_movement = 0;

	dim3 blockDim(1024, 1024, 1);
	dim3 gridDim((n - 1)/ 1024 + 1, (n - 1)/ 1024 + 1, 1 )
	
	initialize<<<gridDim, blockDim>>>(d_dist, d_pheromone, d_ant, d_city, n);
	
	for ( int i = 0; i < MAX_TIME; i++){
	
		tourConstruction<<<1024, (n - 1)/ 1024 + 1>>>(d_ant, h_movement, n);
	
		if(h_movement == 0){
	
			updatePheromones<<<gridDim, blockDim>>>(d_pheromone, d_ant, n);
	
			if(i != MAX_TIME){
	
				reDeployAnts<<<1024, (n - 1)/ 1024 + 1>>>(d_ant, n);

			cout << "\n Time is "<<i<<"("<<best<<")";
			}
		}
	}


	cout << endl;

	h_ant = ant;

	for(int i=0;i<n;i++)
	{
		cout<<h_ant[bestIndex].path[i]<<" ";
	}
	cout<<endl;
	cout<<"\nSACO: Best tour = "<<best<<endl<<endl<<endl;
	return 0;
}
