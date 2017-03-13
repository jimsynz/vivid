/*
 * This is a C++ reference implementation of SLPFA
 */


#include <algorithm>
#include <iostream>
#include "Rasterizer.h"
#include "Canvas.h"
/*
    Compares the yMins of the given buckets parameters
 
    @param edge1 First edge bucket
    @param edge2 Second edge bucket
 
    @return true if edge1's yMin < edge2's yMin, false otherwise
 */
bool minYCompare (Bucket* edge1, Bucket* edge2) {
    return edge1->yMin < edge2->yMin;
}
/*
 Compares the Xs of the given buckets parameters
 
 @param edge1 First edge bucket
 @param edge2 Second edge bucket
 
 @return true if edge1's X is less than edge2 X, false otherwise
 */
bool xCompare (Bucket* edge1, Bucket* edge2) {
    if (edge1->x < edge2->x) {
        return true;
    } else if (edge1->x > edge2->x) {
        return false;
    } else {
        return ((edge1->dX / edge1->dY) < (edge2->dX / edge2->dY));
    }
}
/*
    Creates edge buckets from the given edges
 
    @param n    Number of vertices
    @param x[]  array of x points
    @param y[]  array of y points
 
    @return     List of edge buckets
 */
std::list<Bucket*> createEdges (int n, int x[], int y[]) {
    int startIndex = n - 1;
    int yMax;
    int yMin;
    int initialX;
    int sign;
    int dX;
    int dY;
    Vertex v1;
    Vertex v2;
    Vertex tmp;
    
    std::list<Bucket*> edgeTable;
    
    // Create the edge buckets and place in tempEdgeTable
    for (int i = 0; i < n; i++) {
        v1 = { x[startIndex], y[startIndex] };
        v2 = { x[i], y[i] };
        
        // Check and swap vertices if not in left to right order
        if (v2.x < v1.x) {
            tmp = v1;
            v1 = v2;
            v2 = tmp;
        }
        yMax = (v1.y > v2.y) ? v1.y : v2.y;
        yMin = (v1.y < v2.y) ? v1.y : v2.y;
        initialX = (v1.y < v2.y) ? v1.x : v2.x;
        sign = ((v2.y - v1.y) < 0) ? -1 : 1;
        dX = abs(v2.x - v1.x);
        dY = abs(v2.y - v1.y);
        
        if (dY != 0) {
            Bucket *freshBucket = new Bucket;
            
            *freshBucket = {
                yMax,
                yMin,
                initialX,
                sign,
                dX,
                dY,
                0
            };
            
            
            edgeTable.push_back(freshBucket);
        }
        startIndex = i;
    }
    return edgeTable;
}
/*
    Given the edge table of the polygon, fill the polygons
 
    @param edgeTable The polygon's edge table representation
 */
void processEdgeTable (std::list<Bucket*> edgeTable) {
    int scanLine = edgeTable.front()->yMin;
    Bucket b1;
    Bucket b2;
    std::list<Bucket*> activeList;
    
    while (!edgeTable.empty()) {
        // Remove edges from active list if y == ymax
        if (!activeList.empty()) {
            for (auto i = activeList.begin(); i != activeList.end();) {
                Bucket* curr = *i;
                
                if (curr->yMax == scanLine) {
                    i = activeList.erase(i);
                    edgeTable.remove (curr);
                    delete (curr);
                } else {
                    i++;
                }
            }
        }
        
        // Add edges from ET to AL if y == ymin
        for (auto i = edgeTable.begin (); i != edgeTable.end(); i++) {
            Bucket* edge = *i;
            
            if (edge->yMin == scanLine) {
                activeList.push_back(edge);
            }
        }
        
        // Sort by x & slope
        activeList.sort(xCompare);
        
        // Fill polygon pixels
        for (auto i = activeList.begin(); i != activeList.end(); i++) {
            b1 = **i;
            std::advance(i, 1);
            b2 = **i;
            
            for (int x = b1.x; x < b2.x; x++) {
                C.setPixel(x, scanLine);
            }
        }
        
        // Increment scanline
        scanLine++;
        
        // Increment the X variables based on the slope
        for (auto i = activeList.begin(); i != activeList.end(); i++) {
            Bucket* edge = *i;
            
            if (edge->dX != 0) {
                edge->sum += edge->dX;
                
                while (edge->sum >= edge->dY) {
                    edge->x += (edge->sign);
                    edge->sum -= edge->dY;
                }
            }
        }
    }
}
///
// Draw a filled polygon in the Canvas C.
//
// The polygon has n distinct vertices.  The coordinates of the vertices
// making up the polygon are stored in the x and y arrays.  The ith
// vertex will have coordinate (x[i],y[i]).
//
// @param n - number of vertices
// @param x - x coordinates
// @param y - y coordinates
///
void drawPolygon(int n, int x[], int y[] ) {
    // Create Edge Table
    std::list<Bucket*> finalEdgeTable = createEdges(n, x, y);
    
    // Sort edges by minY
    finalEdgeTable.sort(minYCompare);
    
    // Process Edge Table and draw Polygon
    processEdgeTable(finalEdgeTable);
}
