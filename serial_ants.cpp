#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>

#define MAX_CITIES 50

using namespace std;

struct cities
{
	int x,y;
};

double pheromone[MAX_CITIES][MAX_CITIES];
double dist[MAX_CITIES][MAX_CITIES];

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
	initialize(city,ncities);
	return 0;
}

