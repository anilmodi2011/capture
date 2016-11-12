#include "define.h"

// A structure to represent a subset for union-find
class subset
{
public:
	int parent;
	int rank;
};

// A utility function to find set of an element i
// (uses path compression technique)
int find(subset subsets[], int i)
{
	// find root and make root as parent of i (path compression)
	if (subsets[i].parent != i)
		subsets[i].parent = find(subsets, subsets[i].parent);

	return subsets[i].parent;
}

// A function that does union of two sets of x and y
// (uses union by rank)
void Union(subset subsets[], int x, int y)
{
	int xroot = find(subsets, x);
	int yroot = find(subsets, y);

	// Attach smaller rank tree under root of high rank tree
	// (Union by Rank)
	if (subsets[xroot].rank < subsets[yroot].rank)
		subsets[xroot].parent = yroot;
	else if (subsets[xroot].rank > subsets[yroot].rank)
		subsets[yroot].parent = xroot;

	// If ranks are same, then make one as root and increment
	// its rank by one
	else
	{
		subsets[yroot].parent = xroot;
		subsets[xroot].rank++;
	}
}

// Compare two edges according to their weights.
// Used in qsort() for sorting an array of edges
int myComp(const void* a, const void* b)
{
	Edge* a1 = (Edge*)a;
	Edge* b1 = (Edge*)b;
	return a1->weight < b1->weight;
}

// The main function to construct MST using Kruskal's algorithm
void KruskalMST(Graph* graph)
{
	int V = graph->V;
	Edge result[1000];  // Tnis will store the resultant MST
	int e = 0;  // An index variable, used for result[]
	int i = 0;  // An index variable, used for sorted edges

	// Step 1:  Sort all the edges in non-decreasing order of their weight
	// If we are not allowed to change the given graph, we can create a copy of
	// array of edges
	qsort(graph->edge, graph->E, sizeof(graph->edge[0]), myComp);

	// Allocate memory for creating V ssubsets
	subset subsets[150];

	// Create V subsets with single elements
	for (int v = 0; v < V; ++v)
	{
		subsets[v].parent = v;
		subsets[v].rank = 0;
	}

	// Number of edges to be taken is equal to V-1
	while (e < V - 1)
	{
		// Step 2: Pick the smallest edge. And increment the index
		// for next iteration
		Edge next_edge = graph->edge[i++];

		int x = find(subsets, next_edge.src);
		int y = find(subsets, next_edge.dest);

		// If including this edge does't cause cycle, include it
		// in result and increment the index of result for next edge
		if (x != y)
		{
			result[e++] = next_edge;
			Union(subsets, x, y);
		}
		// Else discard the next_edge
	}

	graph->replace(result, e);
	graph->print();
}
