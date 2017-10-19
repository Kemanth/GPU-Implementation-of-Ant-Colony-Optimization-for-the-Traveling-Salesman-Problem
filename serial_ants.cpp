#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>

#define MAX_CITIES 50
#define MAX_ANTS 50

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
	
	return 0;
}

