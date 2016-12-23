/*
Hershey font converter v2.0
Jari Komppa http://iki.fi/sol/
2011

--------------------------------------------------------------------

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.

--------------------------------------------------------------------

This little tool converts the Hershey Fonts to a OpenGL/hardware
rendering friendly format.

Both this tool and its output are licensed under WTFPL, with the
exception clause from the Hershey fonts.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>

using namespace std;

void legalese(char *fn)
{
	printf("/*\nSource: Hershey font \"%s\"\n", fn);
	printf(
	"Converted with Hershey font converter v2.0 by Jari Komppa, http://iki.fi/sol/\n"
	"--------------------------------------------------------------------\n"
	"\n"
	"            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE\n"
	"                    Version 2, December 2004\n"
	"\n"
	" Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>\n"
	"\n"
	" Everyone is permitted to copy and distribute verbatim or modified\n"
	" copies of this license document, and changing it is allowed as long\n"
	" as the name is changed.\n"
	"\n"
	"            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE\n"
	"   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION\n"
	"\n"
	"  0. You just DO WHAT THE FUCK YOU WANT TO.\n"
	"\n"
	"--------------------------------------------------------------------\n"
	"\n"
	"USE RESTRICTION:\n"
	"This distribution of the Hershey Fonts may be used by anyone for\n"
	"any purpose, commercial or otherwise, providing that:\n"
	"	1. The following acknowledgements must be distributed with\n"
	"		the font data:\n"
	"		- The Hershey Fonts were originally created by Dr.\n"
	"			A. V. Hershey while working at the U. S.\n"
	"			National Bureau of Standards.\n"
	"		- The format of the Font data in this distribution\n"
	"			was originally created by\n"
	"				James Hurt\n"
	"				Cognition, Inc.\n"
	"				900 Technology Park Drive\n"
	"				Billerica, MA 01821\n"
	"				(mit-eddie!ci-dandelion!hurt)\n"
	"	2. The font data in this distribution may be converted into\n"
	"		any other format *EXCEPT* the format distributed by\n"
	"		the U.S. NTIS (which organization holds the rights\n"
	"		to the distribution and use of the font data in that\n"
	"		particular format). Not that anybody would really\n"
	"		*want* to use their format... each point is described\n"
	"		in eight bytes as \"xxx yyy:\", where xxx and yyy are\n"
	"		the coordinate values as ASCII numbers.\n"
	"\n"
	"--------------------------------------------------------------------\n"
	"\n"
	"(And yes, I know the format output here is rather\n"
	"ironic looking at the comments above)\n"
	"*/\n\n"
	);
}

int main(int parc, char ** pars)
{
	unsigned int i;    // loop iterator
	FILE * f;

	if (parc < 2)
	{
		printf("Usage: fontfile [prefix]\n"
			   "output on stdout.\n");
		return 0;
	}

	// Step 1: read the whole datafile in

	f = fopen(pars[1], "rb");

	if (f == NULL)
	{
		printf("File '%s' not found\n", pars[1]);
		return 0;
	}
	fseek(f, 0, SEEK_END);
	int len = ftell(f);
	fseek(f, 0, SEEK_SET);
	char *buf = new char[len + 1];
	memset(buf, 0, len + 1);
	fread(buf, 1, len, f);
	fclose(f);	

	// Now we're done with file i/o, and the data is in buf.

	// Print out legalese.

	legalese(pars[1]);

	// Figure out prefix from the source filename

	// Cut the filename from '.' by overwriting the dot with zero..
	if (strrchr(pars[1], '.'))
		*(strrchr(pars[1], '.')) = 0;
	
	// Find the start of the string by finding the last (back)slash, otherwise use
	// the whole string..

	char *prefix = strrchr(pars[1], '\\');
	if (!prefix) 
		prefix = strrchr(pars[1], '/');

	if (prefix) 
	{
		prefix++;
	}
	else
	{
		prefix = pars[1];
	}

	// If user provided a prefix, use that instead.

	if (parc > 2)
		prefix = pars[2];

	// Now we're ready to start parsing.

	char *c = buf;
	unsigned int gc = 0; // glyph counter

	// vector of vectors to gather all the data
	vector<vector<int>> gd;

	vector<int> minx;
	vector<int> glyph;
	vector<int> width;
	vector<int> realwidth;
	int lminx=200, lmaxx=-200;
	int miny=200;
	int maxy=-200;

	int col = 0;

	while (*c) // Loop until we hit 0, which is the end of file
	{


		while (*c == ' ' || *c == '\t' || *c == '\n' || *c == '\r') 
		{
			if (*c == '\n' || *c == '\r')
				col = 0;
			else
				col++;
			c++; // skip whitespace
		}

		int glyphno = 0;
		// grab glyph number
		while (col < 5 && *c >= '0' && *c <= '9')
		{
			glyphno *= 10;
			glyphno += *c - '0';
			c++;
			col++;
		}

		if (glyphno == 0)
		{
			printf("\n\n#error Error parsing glyph number %d (or so)\n",gc);
			for (i = 0; i < 30; i++)
				printf("%c",(c[i-10]=='\n')?'n':(c[i-10]=='\r')?'r':c[i-10]);
			printf("\n          ^\n");
			        //1234567890
			printf("col: %d\n", col);
			return 0;
		}

		// add a row
		gd.push_back(vector<int>());

		glyph.push_back(glyphno);

		while (*c == ' ' || *c == '\t' || *c == '\n' || *c == '\r') 
		{
			if (*c == '\n' || *c == '\r')
				col = 0;
			else
				col++;
			c++; // skip whitespace
		}

		int pairs = 0;

		// grab number of pairs
		while (col < 8 && *c >= '0' && *c <= '9')
		{
			pairs *= 10;
			pairs += *c - '0';
			c++;
			col++;
		}

		while (*c == ' ' || *c == '\t' || *c == '\n' || *c == '\r') c++; // skip whitespace
		if (*c == 0) return 0; // just in case

		int left = *c - 'R'; c++;
		if (*c == 0) return 0; // just in case

		int right = *c - 'R'; c++;
		if (*c == 0) return 0; // just in case

		// store reported width
		width.push_back(abs(right)+abs(left));

		 // debug stuff!
		// we should be at the start of the opcodes, let's print out stats
		printf("// idx: %d\n"
			   "// Glyph: %d\n"
			   "// Pairs: %d\n"
			   "// Left/right/width: %d/%d/%d\n", gc, glyphno, pairs, left, right, abs(right) + abs(left));
		
		pairs--;

		int penup = 1; // is the pen up or down? initially up.
		int x = 0, y = 0; // Last coordinates
		int lminx = 200, lmaxx = -200;

		// the data may span several lines, so the only way (well, not the ONLY way, but
		// a sane one) to figure out when data ends is to count the data pairs.
		while (pairs > 0)
		{
			char first = *c - 'R'; c++;
			while (*c == '\n' || *c == '\r') 
			{
				c++; // skip newline
				col = 0;
			}
			if (*c == 0) return 0; // just in case
			char second = *c - 'R'; c++;
			while (*c == '\n' || *c == '\r') 
			{
				c++; // skip newline
				col = 0;
			}
			pairs--;

			if (penup == 0)
			{
				if ( first == ' ' - 'R' && 
					second == 'R' - 'R')
				{
					// special "pen up" code.
					penup = 1;
				}
				else
				{
					/* debug code: 
					printf("%d, %d, %d, %d,\n", x, y, first, second);
					*/

					gd[gc].push_back(x);
					gd[gc].push_back(y);
					gd[gc].push_back(first);
					gd[gc].push_back(second);

					x = first;
					y = second;
					if (miny > y) miny = y;
					if (maxy < y) maxy = y;
					if (lminx > x) lminx = x;
					if (lmaxx < x) lmaxx = x;
				}
			}
			else
			{
				penup = 0;
				x = first;
				y = second;
				if (miny > y) miny = y;
				if (maxy < y) maxy = y;
				if (lminx > x) lminx = x;
				if (lmaxx < x) lmaxx = x;
			}
			
		}

		// scanning done.

		if (gd[gc].size() < 4)
		{
			// generate degen stuff for empty glyph (yes, it's a kludge)
			gd[gc].push_back(0);
			gd[gc].push_back(0);
			gd[gc].push_back(0);
			gd[gc].push_back(0);
		}

		if (gd[gc].size() == 4 &&
			gd[gc][0] == gd[gc][2] &&
			gd[gc][1] == gd[gc][3])
		{
			// degen (either through above code or original data)
			lmaxx = width[gc]; // report width from the original data
			lminx = 0;
		}

		minx.push_back(lminx);

		realwidth.push_back(abs(lmaxx) + abs(lminx));
		
		while (*c != 0 && *c <= ' ')
		{
			if (*c == '\n' || *c == '\r')
				col = 0;
			else
				col++;
			c++; // skip whitespace and any control chars (at least one of the files has garbage in it)
		}

		gc++;
	}

	// scan all glyphs and modify data

	for (gc = 0; gc < gd.size(); gc++)
	{
		for (i = 0; i < gd[gc].size(); i+=2)
		{
			gd[gc][i+0] += -minx[gc];
			gd[gc][i+1] += -miny;
		}
	}

	// output modified data

	for (gc = 0; gc < gd.size(); gc++)
	{
		printf("// Glyph %d\n", glyph[gc]);

		printf("static const char %s_%d_width = %d;\n", prefix, gc+1, width[gc]);
		printf("static const char %s_%d_realwidth = %d;\n", prefix, gc+1, realwidth[gc]);

		// output the data

		printf("static const int %s_%d_size = %d;\n", prefix, gc+1, gd[gc].size());
		printf("static const char %s_%d[%d] = {\n", prefix, gc+1, gd[gc].size());
		for (i = 0; i < gd[gc].size(); i++)
		{
			if (i)
				printf(", ");
			if ((i-1)%4 == 3)
				printf("    ");
			if ((i-1)%12 == 11)
				printf("\n");
			printf("%4d", gd[gc][i]);
		}
		printf("\n};\n");
		printf("\n\n");
	}


	// all glyphs done, now let's output totals and the global tables..
	
	printf("// Number of glyphs\n");
	printf("const int %s_count = %d;\n", prefix, gc);
	printf("// Font height\n");
	printf("const char %s_height = %d;\n", prefix, abs(miny)+abs(maxy));
	printf("// Widths of the glyphs\n");
	printf("const char %s_width[%d] = {", prefix, gc);
	for (i = 0; i < gc; i++)
	{
		if (i)
			printf(", ");
		printf("%s_%d_width", prefix, i+1);
	}
	printf("};\n");
	printf("// Real widths of the glyphs (calculated from data)\n");
	printf("const char %s_realwidth[%d] = {", prefix, gc);
	for (i = 0; i < gc; i++)
	{
		if (i)
			printf(", ");
		printf("%s_%d_realwidth", prefix, i+1);
	}
	printf("};\n");
	printf("// Number of chars in each glyph\n");
	printf("const int %s_size[%d] = {", prefix, gc);
	for (i = 0; i < gc; i++)
	{
		if (i)
			printf(", ");
		printf("%s_%d_size", prefix, i+1);
	}
	printf("};\n");
	printf("// Pointers to glyph data\n");
	printf("const char *%s[%d] = {", prefix, gc);
	for (i = 0; i < gc; i++)
	{
		if (i)
			printf(", ");
		printf("&%s_%d[0]", prefix, i+1);
	}
	printf("};\n");

	// all done!

	delete[] buf;

	return 0;
}