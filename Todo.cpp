// c++ test
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

using namespace std;

class Filedata
{
public:
	int Id;
	string status;
	string customer;
	string ticketnumber;
	string description;
	string comment;
};

class Statusmap
{
public:
	string keyU;
	string keyL;
	string value;
};


class Statusitems
{
public:
	vector<Statusmap> getStatuslist()
	{
		vector<Statusmap> list;
		Statusmap live;

		live.keyU = "X";
		live.keyL = "x";
		live.value = "LIVE";
		list.push_back(live);

		Statusmap ready;
		ready.keyU = "R";
		ready.keyL = "r";
		ready.value = "READY";
		list.push_back(ready);

		Statusmap wip;
		wip.keyU = "W";
		wip.keyL = "w";
		wip.value = "WIP";
		list.push_back(wip);

		Statusmap open;
		open.keyU = "O";
		open.keyL = "o";
		open.value = "OPEN";
		list.push_back(open);

		Statusmap declined;
		declined.keyU = "D";
		declined.keyL = "d";
		declined.value = "DECLINED";
		list.push_back(declined);

		return list;
	};
	string getValueByKey(string key)
	{
		vector<Statusmap> map;
		map = getStatuslist();
		string retval;
		for (int i=0; i<map.size(); ++i)
		{
			if(key == map[i].keyU || key == map[i].keyL)
			{
				retval = map[i].value;
				break;
			}
		}
		return retval;
	};
	string getKeyByValue(string val)
	{
		vector<Statusmap> map;
		map = getStatuslist();
		string retkey;
		for (int i=0; i<map.size(); ++i)
		{
			if(val == map[i].value)
			{
				retkey = map[i].keyU;
				break;
			}
		}
		return retkey;
	};
};

Filedata prepare(string str, char delim)
{
	Filedata fd;
	Statusitems si;
	vector<string> elems;
	string buff; // buffer string
	stringstream ss;
	ss.str(str);

	while (getline (ss, buff, delim))
	{
		elems.push_back(buff);
	}

	// prepare status for output
	elems[0] = si.getValueByKey(elems[0]);
	// cout << si.getStatuslist();
	if(elems[0].length() < 8) {
		fd.status 	= elems[0]+"\t\t";
	} else if(elems[0].length() < 16) {
		fd.status	= elems[0]+"\t";
	} else {
		fd.status 	= elems[0];
	}

	// prepare customer for output
	if(elems[1].length() < 8) {
		fd.customer	= elems[1]+"\t\t";
	} else if (elems[1].length() < 16) {
		fd.customer	= elems[1]+"\t";
	} else {
		fd.customer	= elems[1];
	}

	// prepare ticketnumber for output
	if(elems[2].length() < 8) {
		fd.ticketnumber	= elems[2]+"\t\t\t";
	} else if (elems[2].length() < 16) {
		fd.ticketnumber	= elems[2]+"\t\t";
	} else {
		fd.ticketnumber	= elems[2];
	}

	// prepare description for output
	if(elems[3].length() < 8) {
		fd.description	= elems[3]+"\t\t\t\t\t\t";
	} else if (elems[3].length() < 16) {
		fd.description	= elems[3]+"\t\t\t\t\t";
	} else if (elems[3].length() < 24) {
		fd.description	= elems[3]+"\t\t\t\t";
	} else if (elems[3].length() < 32) {
		fd.description	= elems[3]+"\t\t\t";
	} else if (elems[3].length() < 40) {
		fd.description	= elems[3]+"\t\t";
	} else if (elems[3].length() < 48) {
		fd.description	= elems[3]+"\t";
	} else {
		fd.description	= elems[3];
	}

	// there's no need to change anything at the last part
	fd.comment 		= elems[4];

	return fd;
}

void writeln(string str)
{
	cout << str << endl;
}

int main()
{
	int ln=0;
	string line;
	string item;

	Filedata fd;
	vector<Filedata> filedata;

	ifstream myfile ("test.txt");
	if ( myfile.is_open() )
	{

		writeln("start reading file");
		while (getline (myfile, line) )
		{
			filedata.push_back( prepare(line, ':') );
		}
		myfile.close();
		writeln("succesful read file");

		if( filedata.size() > 0 ) {
			writeln("Status\t\tCustomer\tTicketnumber\t\tDescription\t\t\t\t\tComment");
			writeln("------\t\t--------\t------------\t\t-----------\t\t\t\t\t-------");
			for (int i=0; i<filedata.size(); ++i)
			{
				writeln(filedata[i].status+filedata[i].customer+filedata[i].ticketnumber+filedata[i].description+filedata[i].comment);
			}
		}

	}
	else
	{
		writeln("Unable to open file");
	}

	return 0;
}
