#pragma once

// Kruskal's algortihm to find Minimum Spanning Tree of a given connected,
// undirected and weighted graph
#include <iostream>
#include <fstream>
#include <vector>
#include <queue>

using namespace std;

// node graph
extern int nodes[1000];
extern int nodeCount;

int addNode(int n);

extern int data[1000][1000];

// a structure to represent a weighted edge in graph
class Edge
{
public:
	int src, dest, weight;

	Edge(){
		src = 0;
		dest = 0;
		weight = 0;
	}

	bool operator ==(const Edge &rhs){
		return src == rhs.src && dest == rhs.dest && weight == rhs.weight;
	}
};

// a structure to represent a connected, undirected and weighted graph
class Graph
{
public:
	// V-> Number of vertices, E-> Number of edges
	int V, E;

	// graph is represented as an array of edges. Since the graph is
	// undirected, the edge from src to dest is also edge from dest
	// to src. Both are counted as 1 edge here.
	Edge edge[1000];

	void replace(Edge * e, int cnt){
		E = cnt;
		for (int i = 0; i < cnt; ++i)
			edge[i] = e[i];
	}

	void print(){
		cout << "Following are the edges in the constructed MST\n";
		for (int i = 0; i < E; ++i)
			cout << nodes[edge[i].src] << "\t" << nodes[edge[i].dest] << "\t" << edge[i].weight << endl;
	}
};

// edge graph
extern Edge nodes2[1000];
extern int nodeCount2;

int addNode2(Edge n);

extern int data2[1000][1000];

// a structure to represent a weighted edge in graph
class Edge2
{
public:
	Edge src, dest;
	double weight;
};

// a structure to represent a connected, undirected and weighted graph
class Graph2
{
public:
	// V-> Number of vertices, E-> Number of edges
	int V, E;

	// graph is represented as an array of edges. Since the graph is
	// undirected, the edge from src to dest is also edge from dest
	// to src. Both are counted as 1 edge here.
	Edge2 edge[1000];

	void replace(Edge2 * e, int cnt){
		E = cnt;
		for (int i = 0; i < cnt; ++i)
			edge[i] = e[i];
	}

	void print(){
	}
};

void KruskalMST(Graph* graph);

vector<int> maxRandKCut(int K, int numCluster, int graph[1000][1000]);
vector<int> maxKCut(int K, int numCluster, int graph[1000][1000]);

vector<int> cut(int K, int numCluster, int graph[1000][1000] , int p);
