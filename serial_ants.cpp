#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>

#define MAX_CITIES 50
#define MAX_ANTS 50
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

double pheromone[MAX_CITIES][MAX_CITIES];
double dist[MAX_CITIES][MAX_CITIES];
ants ant[MAX_ANTS];

void initialize(cities city[],int n)
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
	double prod=0.0;
	for(int j=0;j<n;j++)
	{
		if(ant[k].visited[j]==0)
		{
			prod+= fitness(i,j);
		}
	}
	double maxp=-99999;
	int nextcity=0;
	for(int j=0;j<n;j++)
	{
		if(ant[k].visited[j]==0)
		{
			double p = fitness(i,j)/prod;
			if(p>maxp)
			{
				maxp=p;
				nextcity=j;
			}
		}
	}
	
	return nextcity;
}

int tourConstruction(cities city[],int n)
{
	int movement=0;
	
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
			{
				ant[i].tourLength+=dist[n-1][ant[i].path[0]];
			}
			ant[i].curCity = ant[i].nextCity;
			movement++;
		}
	}
}

int main()
{
	ifstream in;
	int ncities;
	in.open("cities.txt");
	in>>ncities;
	cities city[ncities];
	cout<<ncities<<endl;
	for(int i=0;i<ncities;i++)
	{
		in>>city[i].x;
		in>>city[i].y;	
	}
	//initialize the ants and place them on the TSP cities 
	initialize(city,ncities);
	tourConstruction(city,ncities);
	return 0;
}

