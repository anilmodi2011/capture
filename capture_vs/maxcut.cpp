#include <stdlib.h>
#include <time.h>

#include "define.h"

int setValidCh(int currentCh, int maxCh){
	if (currentCh >= maxCh){
		currentCh = 1;
		//remainChannel--;
	}
	else{
		currentCh++;
	}
	return currentCh;
}

vector<int> maxRandKCut(int K, int numCluster, int graph[1000][1000])
{
	vector<int> edgeWeight;
	vector<int> edgeFrom;
	vector<int> edgeTo;
	for (int i = 0; i < numCluster; i++)
	{
		for (int j = 0; j < numCluster; j++)
		{
			if (graph[i][j] > 0){
				edgeWeight.push_back(graph[i][j]);
				edgeFrom.push_back(i);
				edgeTo.push_back(j);
			}
		}
	}
	//Step 1
	bool swapped = true;
	int tempBig, tempSmall;
	int tempBigFrom, tempSmallFrom;
	int tempBigTo, tempSmallTo;
	while (swapped == true)
	{
		swapped = false;
		for (int i = 1; i<edgeWeight.size(); i++)
		{
			if (edgeWeight[i - 1] > edgeWeight[i])
			{
				//swap weight
				tempBig = edgeWeight[i - 1];
				tempSmall = edgeWeight[i];
				edgeWeight[i - 1] = tempSmall;
				edgeWeight[i] = tempBig;
				//swap edgeFrom
				tempBigFrom = edgeFrom[i - 1];
				tempSmallFrom = edgeFrom[i];
				edgeFrom[i - 1] = tempSmallFrom;
				edgeFrom[i] = tempBigFrom;
				//swap edgeTo
				tempBigTo = edgeTo[i - 1];
				tempSmallTo = edgeTo[i];
				edgeTo[i - 1] = tempSmallTo;
				edgeTo[i] = tempBigTo;
				swapped = true;
			}
		}
	}
	cout << "after sort" << endl;
	for (int j = 0; j < edgeWeight.size(); j++)
		cout << edgeWeight[j] << ' ';
	cout << endl;
	for (int j = 0; j < edgeWeight.size(); j++)
		cout << edgeFrom[j] << ' ';
	cout << endl;
	for (int j = 0; j < edgeWeight.size(); j++)
		cout << edgeTo[j] << ' ';
	cout << endl;

	//Step 2:
	vector<int> setIndex;
	for (int i = 0; i<numCluster; i++)
		setIndex.push_back(0);

	int setValid = 1;

	setIndex[edgeFrom[edgeFrom.size()-1]] = setValid; //assign set 1 to nodes on edge with max weight
	setValid = setValidCh(setValid, K);
	setIndex[edgeTo[edgeTo.size() - 1]] = setValid; //assign set 1 to nodes on edge with max weight
	setValid = setValidCh(setValid, K);

	for (int j = edgeWeight.size() - 2; j >= 0; j--)
	{
		cout << j << "channel " << setValid << ":: edgeFrom[j] " << edgeFrom[j] << " edgeTo[j] " << edgeTo[j] << endl;

		//Step 2.1:
		if (setIndex[edgeFrom[j]] == 0 && setIndex[edgeTo[j]] == 0){
			setIndex[edgeFrom[j]] = setValid;
			setValid = setValidCh(setValid, K);
			setIndex[edgeTo[j]] = setValid;
			setValid = setValidCh(setValid, K);
			//setChannelWeight[setValid-1] = setChannelWeight[setValid-1] + edgeWeight[j];
			//remainCluster=remainCluster-2;
			cout << "case 1 from&to " << edgeFrom[j] << "and " << edgeTo[j] << endl;
		}
		//Step 2.2:
		else if (setIndex[edgeFrom[j]] == 0 && setIndex[edgeTo[j]] != 0){
			//setIndex[edgeFrom[j]] = setIndex[edgeTo[j]];
			setIndex[edgeFrom[j]] = setValid;
			setValid = setValidCh(setValid, K);
			if (setValid == setIndex[edgeTo[j]])
				setValid = setValidCh(setValid, K);
			//setChannelWeight[setValid-1] = setChannelWeight[setValid-1] + edgeWeight[j];
			//remainCluster--;
			cout << "case 2 from " << edgeFrom[j] << endl;
		}

		//Step 2.3:
		else if (setIndex[edgeTo[j]] == 0 && setIndex[edgeFrom[j]] != 0){
			//setIndex[edgeTo[j]] = setIndex[edgeFrom[j]];
			setIndex[edgeTo[j]] = setValid;
			setValid = setValidCh(setValid, K);
			if (setValid == setIndex[edgeFrom[j]])
				setValid = setValidCh(setValid, K);
			//setChannelWeight[setValid-1] = setChannelWeight[setValid-1] + edgeWeight[j];
			//remainCluster--;
			cout << "case 3 to " << edgeTo[j] << endl;
		}
	}
	for (int i = 0; i<setIndex.size(); i++)
		cout << setIndex[i] << ' ';
	cout << endl;

	return setIndex;
}

//Complicated but best known method for solving max k cut is http://www.math.cmu.edu/~af1p/Texfiles/cuts.pdf
vector<int> maxKCut(int K, int numCluster, int graph[1000][1000])
{
	//Step 1: Sort all the edges in ascending order of its weight and creat K empty sets C1,..,Ck
	//Step 2: Select an edge (x,y) from lightest and
	//            place the node x and y into associate set based on following conditions
	//Step 2.1: if x and y have no setIndexs in the other sets, place both node x and y into a same empty set
	//Step 2.2: if x has a setIndex in a set Ci and y has no setIndex in the other set, place x and y into Ci
	//Step 2.3: if y has a setIndex in a set Ci and x has no setIndex in the other set, place x and y into Ci
	//Step 2.4: if x has a setIndex in a set Ci and y has setIndex in Cj, i!=j, skip

	vector<int> edgeWeight;
	vector<int> edgeFrom;
	vector<int> edgeTo;
	for (int i = 0; i < numCluster; i++)
	{
		for (int j = 0; j < numCluster; j++)
		{
			if (graph[i][j] > 0){
				edgeWeight.push_back(graph[i][j]);
				edgeFrom.push_back(i);
				edgeTo.push_back(j);
			}
		}
	}
	//Step 1
	bool swapped = true;
	int tempBig, tempSmall;
	int tempBigFrom, tempSmallFrom;
	int tempBigTo, tempSmallTo;
	while (swapped == true)
	{
		swapped = false;
		for (int i = 1; i<edgeWeight.size(); i++)
		{
			if (edgeWeight[i - 1] > edgeWeight[i])
			{
				//swap weight
				tempBig = edgeWeight[i - 1];
				tempSmall = edgeWeight[i];
				edgeWeight[i - 1] = tempSmall;
				edgeWeight[i] = tempBig;
				//swap edgeFrom
				tempBigFrom = edgeFrom[i - 1];
				tempSmallFrom = edgeFrom[i];
				edgeFrom[i - 1] = tempSmallFrom;
				edgeFrom[i] = tempBigFrom;
				//swap edgeTo
				tempBigTo = edgeTo[i - 1];
				tempSmallTo = edgeTo[i];
				edgeTo[i - 1] = tempSmallTo;
				edgeTo[i] = tempBigTo;
				swapped = true;
			}
		}
	}
	cout << "after sort" << endl;
	for (int j = 0; j < edgeWeight.size(); j++)
		cout << edgeWeight[j] << ' ';
	cout << endl;
	for (int j = 0; j < edgeWeight.size(); j++)
		cout << edgeFrom[j] << ' ';
	cout << endl;
	for (int j = 0; j < edgeWeight.size(); j++)
		cout << edgeTo[j] << ' ';
	cout << endl;

	//Step 2:
	vector<int> setIndex;
	vector<int> setChannelWeight;
	int minChannelWeight = numCluster*numCluster;
//	int minChannelWeight = numNodes*numNodes;
	int setValid = 1;
	int remainCluster = numCluster;
	int remainChannel = K;
	int mergTo;
	for (int i = 0; i<numCluster; i++){
		setIndex.push_back(0);
	}

	for (int i = 0; i<K; i++){
		setChannelWeight.push_back(0);
	}

	setIndex[edgeFrom[0]] = setValid; //assign set 1 to nodes on edge with min weight
	setIndex[edgeTo[0]] = setValid; //assign set 1 to nodes on edge with min weight
	setChannelWeight[setValid - 1] = edgeWeight[0];
	minChannelWeight = 1;
	remainChannel--;
	remainCluster = remainCluster - 2;
	for (int j = 1; j < edgeWeight.size(); j++)
	{
		cout << j << "channel " << setValid << ":: edgeFrom[j] " << edgeFrom[j] << " edgeTo[j] " << edgeTo[j] << endl;
		//if (remainCluster > K){
		if (remainChannel > 0){
			setValid++;
			remainChannel--;
		}
		else{
			for (int i = 0; i<K; i++){
				if (setChannelWeight[setValid - 1] > setChannelWeight[i])
					setValid = i + 1;//since setValid start from 1 instead of 0
			}
		}
		//Step 2.1:
		if (setIndex[edgeFrom[j]] == 0 && setIndex[edgeTo[j]] == 0){

			//setValid++;
			//if (setValid > K)
			//    setValid = 1;

			setIndex[edgeFrom[j]] = setValid;
			setIndex[edgeTo[j]] = setValid;
			setChannelWeight[setValid - 1] = setChannelWeight[setValid - 1] + edgeWeight[j];
			remainCluster = remainCluster - 2;
			cout << "case 1 from&to " << edgeFrom[j] << "and " << edgeTo[j] << endl;
		}
		//Step 2.2:
		else if (setIndex[edgeFrom[j]] == 0 && setIndex[edgeTo[j]] != 0){
			//setIndex[edgeFrom[j]] = setIndex[edgeTo[j]];
			setIndex[edgeFrom[j]] = setValid;
			setChannelWeight[setValid - 1] = setChannelWeight[setValid - 1] + edgeWeight[j];
			remainCluster--;
			cout << "case 2 from " << edgeFrom[j] << endl;
		}

		//Step 2.3:
		else if (setIndex[edgeTo[j]] == 0 && setIndex[edgeFrom[j]] != 0){
			//setIndex[edgeTo[j]] = setIndex[edgeFrom[j]];
			setIndex[edgeTo[j]] = setValid;
			setChannelWeight[setValid - 1] = setChannelWeight[setValid - 1] + edgeWeight[j];
			remainCluster--;
			cout << "case 3 to " << edgeTo[j] << endl;
		}

		if (remainCluster < 1)
			break;
		/*
		//Step 2.4: merge one set into another
		else if (setIndex[edgeTo[j]] != 0 && setIndex[edgeFrom[j]] != 0){
		mergTo = setIndex[edgeFrom[j]];
		setIndex[edgeFrom[j]] = setIndex[edgeTo[j]];
		for (int i=0; i<numCluster; i++){
		if (setIndex[edgeFrom[i]] == mergTo){
		setIndex[edgeFrom[i]] = setIndex[edgeTo[j]];
		cout << "case 4 merge " << edgeFrom[i] << endl;
		}
		}
		//remainCluster--;

		}
		*/
		/*}else{
		//Step 2.2:
		if (setIndex[edgeFrom[j]] == 0 && setIndex[edgeTo[j]] == 0){
		setValid++;
		setIndex[edgeFrom[j]] = setValid;
		setIndex[edgeTo[j]] = setValid;
		}
		//Step 2.2:
		if (setIndex[edgeFrom[j]] == 0 && setIndex[edgeTo[j]] != 0){
		setValid++;
		setIndex[edgeFrom[j]] = setValid;
		}

		//Step 2.3:
		if (setIndex[edgeTo[j]] == 0 && setIndex[edgeFrom[j]] != 0){
		setValid++;
		setIndex[edgeTo[j]] = setValid;
		}
		}
		*/
	}

	/*
	//Step 3: This mean those remaining clusters disconnected. Therefore same channel is fine.
	setValid++;
	for (int i=0; i<numCluster; i++){
	if (setIndex[i] == 0){
	cout << i << " disconnect??" << endl;
	setIndex[i] = setValid;
	}
	}
	*/
	cout << "remainCluster " << remainCluster << " setValid " << setValid << endl;
	for (int i = 0; i<numCluster; i++)
		cout << setIndex[i] << ' ';
	cout << endl;

	return setIndex;
}


int getPanalty(int K, int numNode, int state[1000], int graph[1000][1000]){

	int sum = 0;

	for (int k = 0; k < K; ++k){
		vector<int> v;
		for (int i = 0; i < numNode; ++i){
			if (state[i] == k)
				v.push_back(i);
		}

		if (v.size() == 0)
			return INT_MAX;

		for (int i = 0; i < v.size()-1; ++i){
			for (int j = i + 1; j < v.size(); ++j){
				sum += graph[v[i]][v[j]];
				sum += graph[v[j]][v[i]];
			}
		}
	}

	return sum;
}

vector<int> cut(int K, int numNode, int graph[1000][1000], int p)
{
	vector<int> result;

	int min = p;
	int minState[1000] = { 0, };
	int curState[1000] = { 0, };

	srand(time(0));

	//for (int i = 0; i < numNode; ++i)
	//	minState[i] = rand() % 3;
	//min = getPanalty(K, numNode, minState, graph, parents);

	for (int case_idx = 0; case_idx < 100000; ++case_idx){
		cout << case_idx << endl;

		for (int i = 0; i < numNode; ++i)
			curState[i] = rand() % 3;

		int panalty = getPanalty(K, numNode, curState, graph);

		if (panalty < min){
			min = panalty;
			ofstream fout("panalty.txt");
			fout << min << ", ";
			for (int i = 0; i < numNode; ++i){
				minState[i] = curState[i];
				fout << curState[i] << ", ";
			}
			fout.close();
		}
	}

	if (min < p)
	{
		for (int i = 0; i<numNode; ++i)
			result.push_back(minState[i]);
	}

	return result;
}

/*
int getPanalty(vector<int> & result, int graph[1000][1000], int index, int channel){

	int sum = 0;
	for (int i = 0; i < result.size(); ++i){
		if (result[i] == channel && i != index){
			sum += graph[index][i];
			sum += graph[i][index];
		}
	}

	return sum;
}

vector<int> cut(int K, int numNode, int graph[1000][1000])
{
	vector<int> result;
	for (int i = 0; i<numNode; ++i)
		result.push_back(-1);

	for (int k = 0; k < K; ++k){
		int max = 0;
		int index = 0;

		for (int i = 0; i < numNode; ++i){
			int cnt = 0;
			for (int j = 0; j < numNode; ++j){
				if (i != j && graph[i][j] == 0 && graph[j][i] == 0 && result[j] == -1)
					++cnt;
			}

			if (cnt > max){
				max = cnt;
				index = i;
			}
		}

		if (max != 0){
			result[index] = k;
			for (int i = 0; i < numNode; ++i){
				if (graph[index][i] == 0 && graph[i][index] == 0)
					result[i] = k;
			}
		}
	}

	for (int i = 0; i < numNode; ++i)
	{
		cout << "000   " << i << endl;

		if (result[i] != -1)
			continue;

		int min = INT_MAX;
		int channel = 0;
		for (int k = 0; k < K; ++k){
			result[i] = k;
			int panalty = getPanalty(result, graph, i, k);
			if (panalty < min){
				panalty = min;
				channel = k;
			}
		}

		result[i] = channel;
	}

	for (int case_idx = 0; case_idx < 3; ++case_idx){
		for (int i = 0; i < numNode; ++i)
		{
			cout << case_idx << "   " << i << endl;

			int min = INT_MAX;
			int channel = 0;
			for (int k = 0; k < K; ++k){
				result[i] = k;
				int panalty = getPanalty(result, graph, i, k);
				if (panalty < min){
					panalty = min;
					channel = k;
				}
			}

			result[i] = channel;
		}
	}

	return result;
}*/