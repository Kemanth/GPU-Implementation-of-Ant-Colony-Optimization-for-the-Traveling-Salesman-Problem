#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>

using namespace std;

int MAX_CITIES;
int MAX_ANTS;
int MAX_TIME;
int QVAL = 100;
float  ALPHA = 1.0f;
float BETA = 5.0f; 
float RHO = 0.5f; 



struct cities
{
	int x,y;
};
struct ants{
	
	int curCity, nextCity, pathIndex;
	int *visited;
	int *path;
	double tourLength;
};

int n=0;
cities *city;
double **pheromone;
double **dist;
ants *ant;
double best=(double)999999;
int bestIndex;

void initialize()
{	
	for(int i=0;i<n;i++)
	{
		for(int j=0;j<n;j++)
		{
			dist[i][j]=0.0;
			pheromone[i][j]=(1.0/n);
			if(i!=j)
			{
				dist[i][j]=sqrt(pow(abs(city[i].x-city[j].x),2)+pow(abs(city[i].y-city[j].y),2));
				dist[j][i]=dist[i][j];
			}
		}	
	}
	
	int visit=0;
	for(int i=0;i<MAX_ANTS;i++)
	{
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
		
		if(j >= MAX_CITIES)
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
    cout << "inside tour" <<endl;
	
	for(int i=0;i<MAX_ANTS;i++)
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
				ant[i].tourLength+=dist[n-1][ant[i].path[0]];
			}
			ant[i].curCity = ant[i].nextCity;
			movement++;
		}
	}
    cout << "movement "<<movement<<endl;
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
	for(int i=0;i<MAX_ANTS;i++)
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
	for(int i=0;i<MAX_ANTS;i++)
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
void initConstants(){
    MAX_ANTS = MAX_CITIES = n;
    MAX_TIME = 20 * MAX_CITIES;
    city = new cities[MAX_CITIES];

    pheromone = new double*[MAX_CITIES];
    for(int i = 0; i < MAX_CITIES; i++)
            pheromone[i] = new double[MAX_CITIES];
    
    dist= new double*[MAX_CITIES];
    for(int i = 0; i < MAX_CITIES; i++)
            dist[i] = new double[MAX_CITIES];
    
    ant = new ants[MAX_ANTS];
    for(int i = 0; i<MAX_ANTS; i++){
            ant[i].visited = new int[MAX_ANTS];
            ant[i].path = new int[MAX_ANTS];
    }
    
}
int main(int argc, char *argv[])
{	if (argc > 1){
		cout << "Reading File "<< argv[1]<<endl;
	}
	ifstream in;
    in.open(argv[1]);
	in>>n;
    
    //initialize constants

	cout<<n<<endl;
	int num;
	initConstants();
    cout << "initialized" <<endl;
    for(int i=0;i<n;i++)
	{
		in>>num;	
		in>>city[i].x;
		in>>city[i].y;
		cout<<city[i].x<<" "<<city[i].y<<" "<<endl;	
	}
    initialize(); 
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
	return 0;
}

