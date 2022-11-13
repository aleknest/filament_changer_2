#include "utils.h"

bool toInt(const String& s, int& i)
{
	if (s=="0" || s=="0.0" || s=="0.00")
	{
		i=0;
		return true;
	}
	i = atol (s.c_str());
	return i!=0;
}

bool toUnsigned(const String& s, unsigned& i)
{
	if (s=="0")
	{
		i=0;
		return true;
	}
	int ii = atol (s.c_str());
	if (ii < 0)
		return false;
	i = (unsigned)ii;
	return i!=0;
}

bool toFloat(const String& s, float& f)
{
	f = float(atof(s.c_str()));
	if (f!=0)
		return true;
	int i;
	if (toInt(s,i))
	{
		f=i;
		return true;
	}
	return false;
}


