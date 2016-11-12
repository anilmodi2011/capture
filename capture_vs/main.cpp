#include "define.h"

#include <map>

#include <time.h>
#include <set>

using namespace std;


int STATE_RESULT = 0;
int STATE_MAXCUT = 1;
int STATE_HEURISTIC = 2;
int STATE_LATENCY = 3;

int state = 0;

int CASE_CNT = 100000;

const char input[100] = "data.txt";

int devices[150] = {
1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 
35, 36, 37, 38, 39, 45, 46, 47, 48, 51, 
53, 54, 55, 56, 57, 58, 59, 60, 63, 64, 
65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
75, 76, 77, 78, 79, 80, 82, 83, 84, 117, 
118, 119, 120, 122, 123, 124, 126, 128, 130, 131, 
132, 133, 135, 136, 137, 138, 139
};

int channels[20] = {26,21,25,22,15,20,23,24,17,12,19,16,14,11,13};

const int numDevices = 87;
const int numChannels = 3;


//int devices[150] = {1, 2, 3, 4, 5};
//int numDevices = 5;





// node graph
int nodes[1000] = { 0, };
int nodeCount = 0;

int addNode(int n){
	for (int i = 0; i < nodeCount; ++i){
		if (nodes[i] == n)
			return i;
	}

	nodes[nodeCount++] = n;
	return nodeCount - 1;
}

int data[1000][1000] = { { 0, }, };
int tempData[1000][1000] = { { 0, }, };

// edge graph
Edge nodes2[1000];
int nodeCount2 = 0;

int addNode2(Edge n){
	for (int i = 0; i < nodeCount2; ++i){
		if (nodes2[i] == n)
			return i;
	}

	nodes2[nodeCount2++] = n;
	return nodeCount2 - 1;
}

int getNext(int channel){
	if (channel <= 1)
		return channel + 1;
	else
		return 0;
}

int data2[1000][1000] = { { 0, }, };

class Triple{
public:
	int v[3];

	bool operator < (Triple const & rhs) const{
		return v[0] < rhs.v[0] || (v[0] == rhs.v[0] && v[1] < rhs.v[1]) || (v[0] == rhs.v[0] && v[1] == rhs.v[1] && v[2] < rhs.v[2]);
	}
	bool operator == (Triple const & rhs) const{
		return v[0] == rhs.v[0] && v[1] == rhs.v[1] && v[2] == rhs.v[2];
	}
};

class Quad{
public:
	int v[4];
};

int main()
{
	ifstream fin;
	ofstream fout;


/*	map<Triple, Quad> m;

	fin.open(input);
	fout.open("align.txt");

	while (fin.eof() == false){
		int line[7] = { 0, };
		fin >> line[0] >> line[1] >> line[2] >> line[3] >> line[4] >> line[5] >> line[6];

		Triple t;
		Quad q;
		t.v[0] = line[0];
		if(line[1] < line[2]){
			t.v[1]= line[1];
			t.v[2]= line[2];
			q.v[0] = line[3];
			q.v[1] = line[4];
			q.v[2] = line[5];
			q.v[3] = line[6];
		}
		else{
			t.v[1]= line[2];
			t.v[2]= line[1];
			q.v[0] = line[4];
			q.v[1] = line[3];
			q.v[2] = line[6];
			q.v[3] = line[5];
		}

		m.insert(make_pair(t, q));
	}

	map<Triple, Quad>::iterator it;
	for(it=m.begin(); it != m.end(); ++it){
		fout << it->first.v[0] << '\t' << it->first.v[1] << '\t' << it->first.v[2] << '\t' << it->second.v[0] << '\t' << it->second.v[1] << '\t' << it->second.v[2] << '\t' << it->second.v[3] << endl;
	}

	fin.close();
	fout.close();

	return 0;
	*/


	
/*	ifstream fin1("align1.txt");
	ifstream fin2("align2.txt");
	ifstream fin3("align3.txt");

	fout.open("align.txt");

	bool enable1 = true;
	bool enable2 = true;
	bool enable3 = true;

	Triple t1, t2, t3;
	Quad q1, q2, q3;
	{fin1 >> t1.v[0] >> t1.v[1] >> t1.v[2] >> q1.v[0] >> q1.v[1] >> q1.v[2] >> q1.v[3]; enable1 = !fin1.eof();}
	{fin2 >> t2.v[0] >> t2.v[1] >> t2.v[2] >> q2.v[0] >> q2.v[1] >> q2.v[2] >> q2.v[3]; enable2 = !fin2.eof();}
	{fin3 >> t3.v[0] >> t3.v[1] >> t3.v[2] >> q3.v[0] >> q3.v[1] >> q3.v[2] >> q3.v[3]; enable3 = !fin3.eof();}
		
	while (enable1 || enable2 || enable3){
		if(t1 == t2 && t1 == t3){
			if(q1.v[0] < q1.v[2]) q1.v[0] = q1.v[2];
			if(q1.v[1] < q1.v[3]) q1.v[1] = q1.v[3];
			if(q2.v[0] < q2.v[2]) q2.v[0] = q2.v[2];
			if(q2.v[1] < q2.v[3]) q2.v[1] = q2.v[3];
			if(q3.v[0] < q3.v[2]) q3.v[0] = q3.v[2];
			if(q3.v[1] < q3.v[3]) q3.v[1] = q3.v[3];

		//	fout << t1.v[0] << '\t' << t1.v[1] << '\t' << t1.v[2] << '\t' << 
		//		q1.v[0] << '\t' << q1.v[1] << '\t' << q1.v[2] << '\t' << q1.v[3] << '\t' << 
		//		q2.v[0] << '\t' << q2.v[1] << '\t' << q2.v[2] << '\t' << q2.v[3] << '\t' << 
		//		q3.v[0] << '\t' << q3.v[1] << '\t' << q3.v[2] << '\t' << q3.v[3] << endl;
			
			fout << t1.v[0] << '\t' << t1.v[1] << '\t' << t1.v[2] << '\t'
				<< (q1.v[0] + q1.v[1])/2.0 << '\t'
				<< (q2.v[0] + q2.v[1])/2.0 << '\t'
				<< (q3.v[0] + q3.v[1])/2.0 << '\t'
				<< (q1.v[2] + q1.v[3])/2.0 << '\t'
				<< (q2.v[2] + q2.v[3])/2.0 << '\t'
				<< (q3.v[2] + q3.v[3])/2.0 << '\t'
				<< (q1.v[2] + q1.v[3]) / (float)(q1.v[0] + q1.v[1]) << '\t'
				<< (q2.v[2] + q2.v[3]) / (float)(q2.v[0] + q2.v[1]) << '\t'
				<< (q3.v[2] + q3.v[3]) / (float)(q3.v[0] + q3.v[1]) << endl;
			
			fin1 >> t1.v[0] >> t1.v[1] >> t1.v[2] >> q1.v[0] >> q1.v[1] >> q1.v[2] >> q1.v[3]; enable1 = !fin1.eof();
			fin2 >> t2.v[0] >> t2.v[1] >> t2.v[2] >> q2.v[0] >> q2.v[1] >> q2.v[2] >> q2.v[3]; enable2 = !fin2.eof();
			fin3 >> t3.v[0] >> t3.v[1] >> t3.v[2] >> q3.v[0] >> q3.v[1] >> q3.v[2] >> q3.v[3]; enable3 = !fin3.eof();
		}
		
		if(enable1 && (t1 < t2 || t1 == t2) && (t1 < t3 || t1 == t3)){
			fin1 >> t1.v[0] >> t1.v[1] >> t1.v[2] >> q1.v[0] >> q1.v[1] >> q1.v[2] >> q1.v[3]; enable1 = !fin1.eof();}
		else if(enable2 && (t2 < t1 || t2 == t1) && (t2 < t3 || t2 == t3)){
			fin2 >> t2.v[0] >> t2.v[1] >> t2.v[2] >> q2.v[0] >> q2.v[1] >> q2.v[2] >> q2.v[3]; enable2 = !fin2.eof();}
		else if(enable3 && (t3 < t1 || t3 == t1) && (t3 < t2 || t3 == t2)){
			fin3 >> t3.v[0] >> t3.v[1] >> t3.v[2] >> q3.v[0] >> q3.v[1] >> q3.v[2] >> q3.v[3]; enable3 = !fin3.eof();}
		else
			break;
	}

	return 0;*/
	


/*	fin.open(input);
	fout.open("usb.txt");

	int d[30][4] = {0, };
	int t[30][3] = {{1, 2, 3},
					{1, 2, 4},
					{1, 2, 5},
					{1, 3, 4},
					{1, 3, 5},
					{1, 4, 5},
					{2, 1, 3},
					{2, 1, 4},
					{2, 1, 5},
					{2, 3, 4},
					{2, 3, 5},
					{2, 4, 5},
					{3, 1, 2},
					{3, 1, 4},
					{3, 1, 5},
					{3, 2, 4},
					{3, 2, 5},
					{3, 4, 5},
					{4, 1, 2},
					{4, 1, 3},
					{4, 1, 5},
					{4, 2, 3},
					{4, 2, 5},
					{4, 3, 5},
					{5, 1, 2},
					{5, 1, 3},
					{5, 1, 4},
					{5, 2, 3},
					{5, 2, 4},
					{5, 3, 4},
	};

	int r = 0;
	int c = 0;
	bool bPrint = true;

	while (fin.eof() == false){
		int line[7] = { 0, };
		fin >> line[0] >> line[1] >> line[2] >> line[3] >> line[4] >> line[5] >> line[6];

		// 
		if(line[3] == 0 || line[4] == 0)
			bPrint = false;

		int ind = (line[0]-1) * 6;
		bool swap = false;
		for(int i=ind; i<ind + 6; ++i){
			if((t[i][1] == line[1] && t[i][2] == line[2]) ||
				(t[i][1] == line[2] && t[i][2] == line[1]))
			{
				ind = i;
				swap = t[i][1] == line[2] && t[i][2] == line[1];
				break;
			}
		}

		if(swap == false){
			d[ind][0] = line[3];
			d[ind][1] = line[4];
			d[ind][2] = line[5];
			d[ind][3] = line[6];
		}
		else{
			d[ind][0] = line[4];
			d[ind][1] = line[3];
			d[ind][2] = line[6];
			d[ind][3] = line[5];
		}

		if(line[0] != r){
			r = line[0];
			c = 1;
			bPrint = true;
		}
		else{
			++c;
			if(r == 5 && c == 6 && bPrint){
				
				bool check = true;
				for(int i=0; i<30; ++i){
					for(int j=0; j<4; ++j)
					{
						if(d[i][j] == 0){
							check = false;
							break;
						}
					}
					if(check == false)
						break;
				}

				if(check){
					for(int i=0; i<30; ++i){
						for(int j=0; j<4; ++j)
							fout << d[i][j] << '\t';
					}
					fout << endl;
				}
				
				for(int i=0; i<30; ++i){
					for(int j=0; j<4; ++j)
						d[i][j] = 0;
				}
			}
		}
	}

	fin.close();
	fout.close();

	return 0;*/


/*	fin.open(input);
	fout.open("usb.txt");

	vector<Quad> d[3];
	int t[3][3] = {{7, 4, 19},
					{7, 8, 19},
					{7, 19, 26},
	};
	
	while (fin.eof() == false){
		int line[7] = { 0, };
		fin >> line[0] >> line[1] >> line[2] >> line[3] >> line[4] >> line[5] >> line[6];

		int temp;
		if(line[1] > line[2]){
			temp = line[1];
			line[1] = line[2];
			line[2] = temp;
			temp = line[3];
			line[3] = line[4];
			line[4] = temp;
			temp = line[5];
			line[5] = line[6];
			line[6] = temp;
		}
		for(int i=0; i<3; ++i){
			if(t[i][1] == line[1] && t[i][2] == line[2]){
				Quad q;
				q.v[0] = line[3];
				q.v[1] = line[4];
				q.v[2] = line[5];
				q.v[3] = line[6];
				d[i].push_back(q);
			}
		}
	}

	for(int i=0; i<83; ++i){
		for(int j=0; j<3; ++j){
			for(int k=0; k<4; ++k)
				fout << d[j][i].v[k] << '\t';
		}
		fout << endl;
	}

	fin.close();
	fout.close();

	return 0;
	
	*/
	


	int MAX = 100;


	if (state == STATE_RESULT){
		// result
		fin.open("children11.txt");

		int n1, n2;
		vector<int> ch[150];
		int result[150] = { 0, };

		fin >> n1;
		for (int i = 0; i < n1; ++i){
			int parent;
			fin >> parent;
			fin >> n2;
			for (int j = 0; j < n2; ++j){
				int num;
				fin >> num;
				ch[parent].push_back(num);
			}
		}

		fin.close();

		fin.open("out11.txt");
		fout.open("packet11.txt");
		int w[150] = { 0, };
		for (int i = 0; i < n1; ++i){
			int parent;
			int num;
			fin >> parent >> num;
			w[parent] = num;

			int sum = 0;
			for (int j = 0; j < ch[parent].size(); ++j)
				sum += w[ch[parent][j]] + MAX;
			fout << num / (float)sum << endl;
		}

		fin.close();
		fout.close();

		return 0;
	}
	else if(state == STATE_LATENCY)
	{
		int w[150] = { 0, };

		fin.open("latencyIn.txt");

		int accum = 0;
		fin >> accum;
		
		while(fin.eof() == false){
			int id, packet;
			fin >> id >> packet;
			w[id] += packet;
			if(w[id] > MAX)
				w[id] = MAX;
		}
		fin.close();

		if(accum == 1){
			fin.open("latencyOut.txt");
			while(fin.eof() == false){
				int id, packet;
				fin >> id >> packet;
				w[id] += packet;
				if(w[id] > MAX)
					w[id] = MAX;
			}
			fin.close();
		}

		fout.open("latencyOut.txt");
		for (int i = 0; i < numDevices; ++i)
			fout << devices[i] << "\t" << w[devices[i]] << endl;
		fout.close();

		w[1] = MAX;
		
		fout.open("latencyCode.txt");
		for (int i = 0; i < numDevices; ++i){
			if(i == 0)
				fout << "if(TOS_NODE_ID == ";
			else
				fout << "else if(TOS_NODE_ID == ";

			fout << devices[i] << ") num = " << MAX - w[devices[i]] << ";" << endl;
		}
		fout.close();

		return 0;
	}
	
	for(int case_cnt = 0; case_cnt < numChannels; ++case_cnt){
		for(int i=0; i<1000; ++i){
			for(int j=0; j<1000; ++j)
				tempData[i][j] = 0;
		}

		string filename = "data";
		char str[10];
		itoa(channels[case_cnt], str, 10);
		filename += str;
		filename += ".txt";
		fin.open(filename);

		set<int> s[150];
		set<int> nb[150];

		while (fin.eof() == false){
			int line[9] = { 0, };
			fin >> line[0] >> line[1] >> line[2] >> line[3] >> line[4] >> line[5] >> line[6] >> line[7] >> line[8];

			// 
			if(line[3] == 0 || line[4] == 0)
				continue;

			s[line[0]].insert(line[1]);
			s[line[0]].insert(line[2]);

			nb[line[0]].insert(line[1]);
			nb[line[0]].insert(line[2]);

			bool r[3] = {false, };
			for(int i=0; i<numDevices; ++i){
				if(line[0] == devices[i]) r[0] = true;
				if(line[1] == devices[i]) r[1] = true;
				if(line[2] == devices[i]) r[2] = true;
			}
			if(r[0] == false || r[1] == false || r[2] == false)
				continue;

			int ind0 = addNode(line[0]);
			int ind1 = addNode(line[1]);
			int ind2 = addNode(line[2]);
			if (tempData[ind0][ind1] < line[3]) tempData[ind0][ind1] = line[3];
			if (tempData[ind1][ind0] < line[3]) tempData[ind1][ind0] = line[3];
			if (tempData[ind0][ind2] < line[4]) tempData[ind0][ind2] = line[4];
			if (tempData[ind2][ind0] < line[4]) tempData[ind2][ind0] = line[4];
		}

		fin.close();

		for(int i=0; i<1000; ++i){
			for(int j=0; j<1000; ++j){
				if(tempData[i][j] > 0)
					data[i][j] += tempData[i][j];
			}
		}
	}
	
	for(int i=0; i<1000; ++i){
		for(int j=0; j<1000; ++j){
			if(data[i][j] > 0)
				data[i][j] /= numChannels;
		}
	}

/*	int c = 0;
	int sum = 0;
	for(int i=0; i<150; ++i){
		if(s[i].size() > 0){
			++c;
			sum += s[i].size();
		}
	}

	float f = sum / (float)c;*/

	int e = 0;  // Number of edges in graph
	for (int i = 0; i < 999; ++i){
		for (int j = i + 1; j < 1000; ++j){
			if (data[i][j] > 0)
				++e;
		}
	}

	Graph graph;
	graph.V = nodeCount;
	graph.E = e;

	int k = 0;
	for (int i = 0; i < 999; ++i){
		for (int j = i + 1; j < 1000; ++j){
			if (data[i][j] > 0){
				graph.edge[k].src = i;
				graph.edge[k].dest = j;
				graph.edge[k].weight = data[i][j];
				++k;
			}
		}
	}


	for (int i = 0; i < graph.E; ++i){
		addNode2(graph.edge[i]);
	}

	fin.open(input);
	/*
	while (fin.eof() == false){
	int line[7] = { 0, };
	fin >> line[0] >> line[1] >> line[2] >> line[3] >> line[4] >> line[5] >> line[6];
	for (int i = 0; i < nodeCount2 - 1; ++i){
	for (int j = i + 1; j < nodeCount2; ++j){
	if (i == j)
	continue;
	if ((line[0] == nodes[nodes2[i].src] || line[0] == nodes[nodes2[i].dest]) && (line[0] == nodes[nodes2[j].src] || line[0] == nodes[nodes2[j].dest]) &&
	(line[1] == nodes[nodes2[i].src] || line[1] == nodes[nodes2[i].dest] || line[1] == nodes[nodes2[j].src] || line[1] == nodes[nodes2[j].dest]) &&
	(line[2] == nodes[nodes2[i].src] || line[2] == nodes[nodes2[i].dest] || line[2] == nodes[nodes2[j].src] || line[2] == nodes[nodes2[j].dest]))
	{
	bool winner =	(line[5]>line[6] && (line[1] == nodes[nodes2[i].src] || line[1] == nodes[nodes2[i].dest])) ||
	(line[5]<line[6] && (line[2] == nodes[nodes2[i].src] || line[2] == nodes[nodes2[i].dest]));
	int capture = line[5]>line[6] ? line[5] : line[6];
	int link = line[5]>line[6] ? line[3] : line[4];
	int weight = 100 - (int)((capture * link) / 100.0);
	//	int weight = link + (100 - capture);
	//	int weight = capture;
	if (winner)
	data2[j][i] = weight;
	else
	data2[i][j] = weight;
	}
	}
	}
	}
	*/
	
	for(int case_cnt = 0; case_cnt < numChannels; ++case_cnt){
		for(int i=0; i<1000; ++i){
			for(int j=0; j<1000; ++j)
				tempData[i][j] = 0;
		}

		string filename = "data";
		char str[10];
		itoa(channels[case_cnt], str, 10);
		filename += str;
		filename += ".txt";
		fin.open(filename);

		int raw[20000][7] = { { 0, }, };
		int numRaw = 0;

		while (fin.eof() == false){
			int line[9] = { 0, };
			fin >> line[0] >> line[1] >> line[2] >> line[3] >> line[4] >> line[5] >> line[6] >> line[7] >> line[8];

			if(line[3] < data[line[0]][line[1]]) line[3] = data[line[0]][line[1]];
			if(line[3] < data[line[1]][line[0]]) line[3] = data[line[1]][line[0]];
			if(line[4] < data[line[0]][line[2]]) line[4] = data[line[0]][line[2]];
			if(line[4] < data[line[2]][line[0]]) line[4] = data[line[2]][line[0]];

			raw[numRaw][0] = line[0];
			raw[numRaw][1] = line[1];
			raw[numRaw][2] = line[2];
			raw[numRaw][3] = line[3];
			raw[numRaw][4] = line[4];
			raw[numRaw][5] = line[5];
			raw[numRaw][6] = line[6];
			++numRaw;

			//int first = 0;
			int first = -1;
			for (int i = 0; i < nodeCount2; ++i){
				if ((line[0] == nodes[nodes2[i].src] && line[1] == nodes[nodes2[i].dest]) ||
					(line[0] == nodes[nodes2[i].dest] && line[1] == nodes[nodes2[i].src])){
					first = i;
					break;
				}
			}

			//int second = 0;
			int second = -1;
			for (int i = 0; i < nodeCount2; ++i){
				if ((line[0] == nodes[nodes2[i].src] && line[2] == nodes[nodes2[i].dest]) ||
					(line[0] == nodes[nodes2[i].dest] && line[2] == nodes[nodes2[i].src])){
					second = i;
					break;
				}
			}

			if(first == -1 || second == -1)
				continue;

			if (state == STATE_HEURISTIC){
				tempData[first][second] = 10000 - (line[3] * line[5]);
				tempData[second][first] = 10000 - (line[4] * line[6]);
			}

			if (state == STATE_MAXCUT){
			/*	int weight1 = 100 - (int)((line[3] * line[5]) / 100.0);
				int weight2 = 100 - (int)((line[4] * line[6]) / 100.0);

				if (weight1 > weight2){
					data2[first][second] = weight2;
					data2[second][first] = weight2;
				}
				else{
					data2[first][second] = weight1;
					data2[second][first] = weight1;
				}*/
			
				int weight = (line[3] + line[4]) - (line[5] + line[6]);
				//int weight = floor(((line[5] + line[6]) / (float)(line[3] + line[4])) * 100);
				//int weight = (line[5] + line[6]);
				if (weight < 0)
					weight = 0;
				tempData[first][second] = weight;
				tempData[second][first] = weight;
			}
		}

		fin.close();

		for(int i=0; i<1000; ++i){
			for(int j=0; j<1000; ++j){
				if(tempData[i][j] > 0)
					data2[i][j] += tempData[i][j];
			}
		}
	}
	
	for(int i=0; i<1000; ++i){
		for(int j=0; j<1000; ++j){
			if(data2[i][j] > 0)
				data2[i][j] /= numChannels;
		}
	}


	/*
	fout.open("pdf.txt");

	{
		int pdf[10] = {0, };
		for(int i=0; i<nodeCount - 1; ++i){
			for(int j=i+1; j<nodeCount; ++j){
				if(data[i][j] > 0)
					++pdf[(data[i][j] - 1) / 10];
			}
		}
		float sum = 0.0f;
		for(int i=0; i<10; ++i)
			sum += pdf[i];
		for(int i=0; i<10; ++i)
			fout << pdf[i] / sum << endl;
	}

	fout << endl;
	
	{
		int pdf[10] = {0, };
		for(int i=0; i<nodeCount2 - 1; ++i){
			for(int j=i+1; j<nodeCount2; ++j){
				if(data2[i][j] > 0)
					++pdf[(data2[i][j] - 1) / 10];
			}
		}
		float sum = 0.0f;
		for(int i=0; i<10; ++i)
			sum += pdf[i];
		for(int i=0; i<10; ++i)
			fout << pdf[i] / sum << endl;
	}

	fout.close();

	return 0;
	*/

	
	/*
	fout.open("pairs.txt");

	for(int i=0; i<nodeCount2 - 1; ++i){
		for(int j=i+1; j<nodeCount2; ++j){
			if(data2[i][j] > 0)
			{
				int r = 0;
				int s1 = 0;
				int s2 = 0;
				if(nodes[nodes2[i].src] == nodes[nodes2[j].src]){
					r = nodes[nodes2[i].src];
					s1 = nodes[nodes2[i].dest];
					s2 = nodes[nodes2[j].dest];
				}
				else if(nodes[nodes2[i].src] == nodes[nodes2[j].dest]){
					r = nodes[nodes2[i].src];
					s1 = nodes[nodes2[i].dest];
					s2 = nodes[nodes2[j].src];
				}
				else if(nodes[nodes2[i].dest] == nodes[nodes2[j].src]){
					r = nodes[nodes2[i].dest];
					s1 = nodes[nodes2[i].src];
					s2 = nodes[nodes2[j].dest];
				}
				else if(nodes[nodes2[i].dest] == nodes[nodes2[j].dest]){
					r = nodes[nodes2[i].dest];
					s1 = nodes[nodes2[i].src];
					s2 = nodes[nodes2[j].src];
				}

				if(data[s1][r] >= 90 && data[s2][r] >= 90)
					fout << r << '\t' << s1 << '\t' << s2 << endl;
			}
		}
	}

	fout.close();

	return 0;
	*/

	/*
	vector<Edge> check[150];
	fin.open("pairs.txt");
	while(fin.eof() == false){
		int r;
		int s1, s2;
		fin >> r >> s1 >> s2;
		Edge e;
		e.src = s1;
		e.dest = s2;
		e.weight = -1;
		check[r].push_back(e);
	}
	fin.close();

	fout.open("cdf.txt");

	for(int i=0; i<nodeCount2 - 1; ++i){
		for(int j=i+1; j<nodeCount2; ++j){
			if(data2[i][j] > 0)
			{
				int r = 0;
				int s1 = 0;
				int s2 = 0;
				if(nodes[nodes2[i].src] == nodes[nodes2[j].src]){
					r = nodes[nodes2[i].src];
					s1 = nodes[nodes2[i].dest];
					s2 = nodes[nodes2[j].dest];
				}
				else if(nodes[nodes2[i].src] == nodes[nodes2[j].dest]){
					r = nodes[nodes2[i].src];
					s1 = nodes[nodes2[i].dest];
					s2 = nodes[nodes2[j].src];
				}
				else if(nodes[nodes2[i].dest] == nodes[nodes2[j].src]){
					r = nodes[nodes2[i].dest];
					s1 = nodes[nodes2[i].src];
					s2 = nodes[nodes2[j].dest];
				}
				else if(nodes[nodes2[i].dest] == nodes[nodes2[j].dest]){
					r = nodes[nodes2[i].dest];
					s1 = nodes[nodes2[i].src];
					s2 = nodes[nodes2[j].src];
				}

				for(int k=0; k<check[r].size(); ++k){
					if((check[r][k].src == s1 && check[r][k].dest == s2) ||
						(check[r][k].dest == s1 && check[r][k].src == s2) )
					{
						check[r][k].weight = data2[i][j];
						break;
					}
				}
			}
		}
	}

	for(int i=0; i<150; ++i){
		for(int j=0; j<check[i].size(); ++j)
			fout << check[i][j].weight << endl;
	}

	fout.close();

	return 0;
	*/






	vector<int> result;
	if (state == STATE_MAXCUT){
		result = maxRandKCut(numChannels, nodeCount2, data2);
		for (int i = 0; i < result.size(); ++i){
			if (result[i] != 0)
				--result[i];
		}
	}

	int chCnt[numChannels] = {0, };

	for(int i=0; i<result.size(); ++i){
		for(int j=0; j<numChannels; ++j){
			if(result[i] == j)
				++chCnt[j];
		}
	}

	KruskalMST(&graph);

	int min = INT_MAX;
	int minState[1000] = { 0, };
	/*
	if (state == STATE_HEURISTIC)
	{
		int curState[1000] = { 0, };

		srand(time(0));

		for (int case_idx = 0; case_idx < CASE_CNT; ++case_idx)
		{
			cout << case_idx << endl;

			for (int i = 0; i < 150; ++i)
				curState[i] = rand() % numChannels;

			int weight = 0;

			bool b[150] = { false, };

			queue<int> q;
			b[1] = true;
			q.push(1);

			int cnt = 0;

			while (q.empty() == false){
				int n = q.front();
				q.pop();

				for (int i = 0; i < graph.E; ++i){
					if ((nodes[graph.edge[i].src] == n && b[nodes[graph.edge[i].dest]] == false) || (nodes[graph.edge[i].dest] == n && b[nodes[graph.edge[i].src]] == false)){
						int child = nodes[graph.edge[i].src] == n ? nodes[graph.edge[i].dest] : nodes[graph.edge[i].src];
						q.push(child);
						b[child] = true;

						for (int j = 0; j < numRaw; ++j){
							if (n == raw[j][0] && (child == raw[j][1] || child == raw[j][2])){
								int other = child == raw[j][1] ? raw[j][2] : raw[j][1];
								if (curState[child] == curState[other]){
									if (child == raw[j][1])
										weight += 10000 - (raw[j][3] * raw[j][5]);
									else
										weight += 10000 - (raw[j][4] * raw[j][6]);
								}
							}
						}
					}
				}
			}

			if (weight < min){
				min = weight;
				for (int i = 0; i < 150; ++i){
					minState[i] = curState[i];
				}
			}
		}

	}
	*/
	// post process
	bool checkChannel[numChannels] = { false, };
	for (int i = 0; i < result.size(); ++i){
		bool check = false;
		for (int j = 0; j < graph.E; ++j){
			if ((graph.edge[j].src == nodes2[i].src && graph.edge[j].dest == nodes2[i].dest) ||
			(graph.edge[j].src == nodes2[i].dest && graph.edge[j].dest == nodes2[i].src)){
				check = true;
				break;
			}
		}
		if (check)
			checkChannel[result[i]] = true;
	}

	int cnt = 0;
	int newChannel = 0;
	for(int i=0; i<numChannels; ++i){
		if (checkChannel[i]){
			++cnt;
			if(i == numChannels-1)
				newChannel = 0;
			else
				newChannel = i+1;
		}
	}
	

	if (cnt < 3){
		for (int i = 0; i < 3; ++i){
			int first = -1;
			bool changed = false;
			for (int j = 0; j < result.size(); ++j){
				if (result[j] == i){
					bool check = false;
					for (int k = 0; k < graph.E; ++k){
						if ((graph.edge[k].src == nodes2[j].src && graph.edge[k].dest == nodes2[j].dest) ||
						(graph.edge[k].src == nodes2[j].dest && graph.edge[k].dest == nodes2[j].src)){
							check = true;
							break;
						}
					}
					if (check == false)
						continue;

					if (first == -1)
						first = j;
					else{
						changed = true;

						int firstSum = 0;
						for (int k = 0; k < nodeCount2; ++k)
							firstSum += data2[first][k];

						int secondSum = 0;
						for (int k = 0; k < nodeCount2; ++k)
							secondSum += data2[j][k];

						if (firstSum > secondSum)
							result[j] = newChannel;
						else
							result[first] = newChannel;
					}
				}
			}

			if (changed)
				newChannel = getNext(newChannel);
		}
	}


	int parent[150] = { 0, };
	bool b[150] = { false, };
	vector<int> children[150];

	vector<int> v;

	queue<int> q;
	b[1] = true;
	q.push(1);
	
	for(int i=0; i<numChannels; ++i)
		chCnt[i] = 0;

	while (q.empty() == false){
		int n = q.front();
		q.pop();
		v.push_back(n);

		for (int i = 0; i < graph.E; ++i){
			if ((nodes[graph.edge[i].src] == n && b[nodes[graph.edge[i].dest]] == false) || (nodes[graph.edge[i].dest] == n && b[nodes[graph.edge[i].src]] == false)){
				int child = nodes[graph.edge[i].src] == n ? nodes[graph.edge[i].dest] : nodes[graph.edge[i].src];
				
				for (int j = 0; j < nodeCount2; ++j){
					if ((graph.edge[i].src == nodes2[j].src && graph.edge[i].dest == nodes2[j].dest) ||
						(graph.edge[i].src == nodes2[j].dest && graph.edge[i].dest == nodes2[j].src)){
							
						for(int k=0; k<numChannels; ++k){
							if(result[j] == k)
								++chCnt[k];
						}
						break;
					}
				}

				parent[child] = n;
				children[n].push_back(child);
				q.push(child);
				b[child] = true;
			}
		}
	}

	int channelCnt[150][numChannels] = { { 0, }, };
	int randomCnt[150][numChannels] = { { 0, }, };

	/*fout.open("channel.txt");
	for (int i = 0; i < 150; ++i){
		if (b[i]){
			if (i == 1)
				fout << "if(TOS_NODE_ID == ";
			else
				fout << "else if(TOS_NODE_ID == ";

			fout << i << "){parent = " << parent[i] << "; ";

			for(int j=0; j<result.size(); ++j){
				if(nodes[nodes2[j].src] == i || nodes[nodes2[j].dest] == i){
					int me = nodes[nodes2[j].src] == i ? nodes[nodes2[j].src] : nodes[nodes2[j].dest];
					int other = nodes[nodes2[j].src] == i ? nodes[nodes2[j].dest] : nodes[nodes2[j].src];
					++channelCnt[me][result[j]];
					fout << "c[" << other << "] = " << result[j] << "; ";
				}
			}

			fout << "}" << endl;
		}
	}
	fout.close();*/
	
	fout.open("channel.txt");
	for (int i = 0; i < 150; ++i){
		if (b[i]){
			if (i == 1)
				fout << "if(TOS_NODE_ID == ";
			else
				fout << "else if(TOS_NODE_ID == ";

			fout << i << "){parent = " << parent[i] << "; ";
			
			for(int j=0; j<result.size(); ++j){
				if((nodes[nodes2[j].src] == i && nodes[nodes2[j].dest] == parent[i]) || (nodes[nodes2[j].src] == parent[i] && nodes[nodes2[j].dest] == i)){
					fout << "parentChannel = " << result[j] << "; ";
					break;
				}
			}

			for(int j=0; j<result.size(); ++j){
				if(nodes[nodes2[j].src] == i || nodes[nodes2[j].dest] == i){
					int me = nodes[nodes2[j].src] == i ? nodes[nodes2[j].src] : nodes[nodes2[j].dest];
					int other = nodes[nodes2[j].src] == i ? nodes[nodes2[j].dest] : nodes[nodes2[j].src];
					++channelCnt[me][result[j]];
					fout << "c[" << other << "] = " << result[j] << "; ";
				}
			}

			fout << "}" << endl;
		}
	}
	fout.close();

	/*
	fout.open("benefit1.txt");
	for(int i=0; i<numDevices; ++i){
		if (children[devices[i]].size() == 0)
			continue;

		vector<int> v1;
		for(int j=0; j<nodeCount2; ++j){
			if(devices[i] == nodes[nodes2[j].src] || devices[i] == nodes[nodes2[j].dest])
				v1.push_back(j);
		}

		vector<int> v2; // neighbor id
		set<int>::iterator it;
		for(it=nb[devices[i]].begin(); it != nb[devices[i]].end(); ++it)
			v2.push_back(*it);

		vector<int> v3; // neighbor index
		for(int j=0; j<v2.size(); ++j){
			v3.push_back(-1);
			for(int k=0; k<v1.size(); ++k){
				if(v2[j] == nodes[nodes2[v1[k]].src] || v2[j] == nodes[nodes2[v1[k]].dest]){
					v3[v3.size()-1] = v1[k];
					break;
				}
			}
		}

		float sum = 0;
		int cnt = 0;

		for(int j=0; j<=2; ++j){
			vector<int> v4; // same channel
			for(int k=0; k<v2.size(); ++k){
				if(result[v3[k]] == j)
					v4.push_back(v3[k]);
			}

			if(v4.size() == 0)
				continue;
			else if(v4.size() == 1){
				sum += MAX;
				++cnt;
				continue;
			}

			int partSum = 0;
			int partCnt = 0;
			for(int k1=0; k1<v4.size()-1; ++k1){
				for(int k2=k1+1; k2<v4.size(); ++k2){
					++partCnt;
					partSum += data2[v4[k1]][v4[k2]];
				}
			}

			if(partCnt > 0){
				sum += (partSum / (float)partCnt / 2.0f) * (float)v4.size();
				cnt += v4.size();
			}
		}

		fout << devices[i] << '\t' << sum / (float)cnt << endl;
	}
	fout.close();
	*/


	cnt = 0;
	fout.open("random.txt");
	for (int i = 0; i < 150; ++i){
		if (b[i]){
			if (i == 1)
				fout << "if(TOS_NODE_ID == ";
			else
				fout << "else if(TOS_NODE_ID == ";

			fout << i << "){parent = " << parent[i] << "; ";
			
			for(int j=0; j<result.size(); ++j){
				if(nodes[nodes2[j].src] == i || nodes[nodes2[j].dest] == i){
					int me = nodes[nodes2[j].src] == i ? nodes[nodes2[j].src] : nodes[nodes2[j].dest];
					int other = nodes[nodes2[j].src] == i ? nodes[nodes2[j].dest] : nodes[nodes2[j].src];
				//	fout << "c[" << other << "] = " << j % 3 << "; ";
				//	fout << "c[" << other << "] = " << (i+other) % 3 << "; ";

					do{
						++cnt;
						if (cnt >= numChannels)
							cnt = 0;
					} while (channelCnt[i][cnt] <= randomCnt[i][cnt]);

					++randomCnt[i][cnt];
					result[j] = cnt;

					fout << "c[" << other << "] = " << cnt << "; ";
				}
			}

			fout << "}" << endl;
		}
	}
	fout.close();
	
	/*
	fout.open("benefit2.txt");
	for(int i=0; i<numDevices; ++i){
		if (children[devices[i]].size() == 0)
			continue;

		vector<int> v1;
		for(int j=0; j<nodeCount2; ++j){
			if(devices[i] == nodes[nodes2[j].src] || devices[i] == nodes[nodes2[j].dest])
				v1.push_back(j);
		}

		vector<int> v2; // neighbor id
		set<int>::iterator it;
		for(it=nb[devices[i]].begin(); it != nb[devices[i]].end(); ++it)
			v2.push_back(*it);

		vector<int> v3; // neighbor index
		for(int j=0; j<v2.size(); ++j){
			v3.push_back(-1);
			for(int k=0; k<v1.size(); ++k){
				if(v2[j] == nodes[nodes2[v1[k]].src] || v2[j] == nodes[nodes2[v1[k]].dest]){
					v3[v3.size()-1] = v1[k];
					break;
				}
			}
		}

		float sum = 0;
		int cnt = 0;

		for(int j=0; j<=2; ++j){
			vector<int> v4; // same channel
			for(int k=0; k<v2.size(); ++k){
				if(result[v3[k]] == j)
					v4.push_back(v3[k]);
			}

			if(v4.size() == 0)
				continue;
			else if(v4.size() == 1){
				sum += MAX;
				++cnt;
				continue;
			}

			int partSum = 0;
			int partCnt = 0;
			for(int k1=0; k1<v4.size()-1; ++k1){
				for(int k2=k1+1; k2<v4.size(); ++k2){
					++partCnt;
					partSum += data2[v4[k1]][v4[k2]];
				}
			}

			if(partCnt > 0){
				sum += (partSum / (float)partCnt / 2.0f) * (float)v4.size();
				cnt += v4.size();
			}
		}

		fout << sum / (float)cnt << endl;
	}
	fout.close();
	*/



	fout.open("single.txt");
	for (int i = 0; i < 150; ++i){
		if (b[i]){
			if (i == 1)
				fout << "if(TOS_NODE_ID == ";
			else
				fout << "else if(TOS_NODE_ID == ";

			fout << i << "){parent = " << parent[i] << "; ";
			
			for(int j=0; j<result.size(); ++j){
				if(nodes[nodes2[j].src] == i || nodes[nodes2[j].dest] == i){
					int other = nodes[nodes2[j].src] == i ? nodes[nodes2[j].dest] : nodes[nodes2[j].src];
					fout << "c[" << other << "] = " << 0 << "; ";
				}
			}

			fout << "}" << endl;
		}
	}
	fout.close();

	fout.open("index.txt");
	cnt = 0;
	for (int i = v.size()-1; i>=0; --i){
		if (children[v[i]].size() > 0){
			if (cnt % 10 == 0 && cnt != 0)
				fout << " // " << cnt-10 << endl;
			++cnt;

			fout << v[i] << ", ";
		}
	}
	fout.close();

	fout.open("children.txt");

	int size = 0;
	for (int i = v.size() - 1; i >= 0; --i){
		if (children[v[i]].size() > 0)
			++size;
	}

	fout << size << endl;

	for (int i = v.size() - 1; i >= 0; --i){
		if (children[v[i]].size() > 0)
		{
			fout << v[i] << " " << children[v[i]].size() << " ";
			for (int j = 0; j < children[v[i]].size(); ++j)
				fout << children[v[i]][j] << " ";
			fout << endl;
		}
	}
	fout.close();

	
	vector<int> vLink[numChannels];
	int linkSum[numChannels] = {0, };
	int linkCnt[numChannels] = {0, };
	for (int i = 0; i < graph.E; ++i){
		for (int j = 0; j < nodeCount2; ++j){
			if ((graph.edge[i].src == nodes2[j].src && graph.edge[i].dest == nodes2[j].dest) ||
				(graph.edge[i].src == nodes2[j].dest && graph.edge[i].dest == nodes2[j].src)){
				++linkCnt[result[j]];
				vLink[result[j]].push_back(data[nodes2[j].src][nodes2[j].dest]);
				linkSum[result[j]] += data[nodes2[j].src][nodes2[j].dest];
				break;
			}
		}
	}

	float avg[numChannels];
	for(int i=0; i<numChannels; ++i)
		avg[i] = linkSum[i] / (float)linkCnt[i];
	float variance[numChannels] = {0.0f, };

	for(int i=0; i<numChannels; ++i){
		for(int j=0; j<vLink[i].size(); ++j){
			float diff = avg[i] - vLink[i][j];
			variance[i] += diff * diff;
		}
		variance[i] /= (float)vLink[i].size();
	}

	fout.open("link.txt");

	for(int i=0; i<numChannels; ++i)
		fout << avg[i] << '\t';
	fout << endl;

	for(int i=0; i<numChannels; ++i)
		fout << variance[0] << '\t';
	fout << endl;
	fout.close();

	return 0;
}
