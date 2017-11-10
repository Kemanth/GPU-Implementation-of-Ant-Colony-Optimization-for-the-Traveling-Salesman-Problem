#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>

#define MAX_CITIES 1002 
#define MAX_ANTS 1002
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
float Delta[MAX_CITIES][MAX_CITIES];
void initialize()
{	
	for(int i=0;i<MAX_CITIES;i++)
	{
		for(int j=0;j<MAX_CITIES;j++)
		{
			dist[i][j]=0.0f;
			pheromone[i][j]=(1.0f/n);
			Delta[i][j] = 0.0f;
			if(i!=j)
			{
				dist[i][j]=sqrt(pow(abs(city[i].x-city[j].x),2)+pow(abs(city[i].y-city[j].y),2));
			}
		}	
	}
}
void initTour(){
	cout << "inside init tour" << endl;
	s = 0;
	for(int k=0;k<MAX_ANTS;k++)
	{
		int j = rand() % MAX_CITIES;
		ant[k].curCity = j;
		for(int i=0;i<n;i++)
		{
			ant[k].visited[i]=0;
		}
		ant[k].visited[j] = 1;
		ant[k].tabu[s] = j;
		ant[k].L = 0.0;
	}
}
double fitness(int i, int j)
{	cout<<"ditness"<<endl;
	return(( pow( pheromone[i][j], ALPHA) * pow( (1.0/ dist[i][j]), BETA)));
}

int selectNextCity(int k,int n)
{	cout<<"next city"<<endl;
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

void tourConstruction()
{	cout<<"tourConstruc"<<endl;
	int j;
	for(int s=1 ;s<n  ;s++)
	{	
		for(int k = 0; k < MAX_ANTS ; k++){
			j = selectNextCity(k, n);
				
			ant[k].nextCity = j;
			ant[k].visited[j]=1;
			ant[k].tabu[s] = j;			
			ant[k].L+=dist[ant[k].curCity][j];
			
			ant[k].curCity = j;
		}
	}
}
void wrapUpTour(){
	cout<<"wrapup"<<endl;
	for(int k = 0; k < MAX_ANTS;k++){
		ant[k].L += dist[ant[k].curCity][ant[k].tabu[0]];
		ant[k].curCity = ant[k].tabu[0];
		
		if(best > ant[k].L){
			best = ant[k].L;
			bestIndex = k;
		}
		for(int i = 0; i < MAX_CITIES;i++){
			int first = ant[k].tabu[i];
			int second = ant[k].tabu[(i + 1) % MAX_CITIES];
			Delta[first][second] += Q/ant[k].L;
		}
	}
}
int updatePheromone(){
	cout<<"update"<<endl;
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
			pheromone[i][j] += Delta[i][j];
			Delta[i][j] = 0;
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
	initialize();
	int MAX_TIME = 20;
	for(;;)
	{	initTour();
		tourConstruction();
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

